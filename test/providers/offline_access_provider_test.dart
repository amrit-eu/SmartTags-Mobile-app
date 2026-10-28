import 'dart:async';

import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/offline_access_provider.dart';
import 'package:smart_tags/services/auth_service.dart';

import '../utils/fake_auth_notifiers.dart';
import '../utils/test_user.dart';

/// [AuthService] whose recorded deadline is set by the test.
class _FakeAuthService extends AuthService {
  _FakeAuthService(this.deadline) : super(authDao: AppDatabase.executor(conn.inMemoryConnection()).authDao);

  DateTime? deadline;
  final changes = StreamController<DateTime?>.broadcast();

  @override
  Future<DateTime?> getOfflineAccessDeadline() async => deadline;

  @override
  Stream<DateTime?> get offlineAccessDeadlineChanges => changes.stream;
}

class _FixedConnectivity extends ConnectivityStatus {
  _FixedConnectivity(this.result);

  final ConnectivityResult? result;

  @override
  FutureOr<ConnectivityResult?> build() async => result;
}

/// Signed-in user whose background renewals are counted instead of sent.
class _RenewCountingAuthNotifier extends AuthNotifier {
  _RenewCountingAuthNotifier(this.user);

  final User user;
  int renewCalls = 0;

  @override
  Future<User?> build() async => user;

  @override
  Future<void> renewExpiredSession() async => renewCalls++;
}

void main() {
  ProviderContainer containerWith(
    _FakeAuthService authService, {
    User? user,
    AuthNotifier Function()? auth,
    ConnectivityResult connectivity = ConnectivityResult.none,
  }) {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        authProvider.overrideWith(auth ?? () => FakeAuthNotifier(user)),
        checkConnectionProvider.overrideWith(() => _FixedConnectivity(connectivity)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('OfflineAccess', () {
    test('is valid strictly before the deadline', () {
      final access = OfflineAccess(DateTime(2030));

      expect(access.isExpiredAt(DateTime(2029, 12, 31, 23, 59)), isFalse);
      expect(access.isExpiredAt(DateTime(2030)), isTrue);
    });

    test('a missing deadline counts as expired', () {
      expect(const OfflineAccess(null).isExpiredAt(DateTime(2000)), isTrue);
    });
  });

  group('offlineAccessProvider', () {
    test('is null when no user is signed in', () async {
      final container = containerWith(_FakeAuthService(DateTime(2100)));
      await container.read(authProvider.future);

      expect(await container.read(offlineAccessProvider.future), isNull);
      expect(container.read(offlineAccessExpiredProvider), isFalse);
    });

    test('exposes the recorded deadline for the signed-in user', () async {
      final container = containerWith(_FakeAuthService(DateTime(2100)), user: createTestUser());
      await container.read(authProvider.future);

      expect((await container.read(offlineAccessProvider.future))?.deadline, DateTime(2100));
      expect(container.read(offlineAccessExpiredProvider), isFalse);
    });

    test('is expired for a signed-in user with no recorded deadline', () async {
      final container = containerWith(_FakeAuthService(null), user: createTestUser());
      await container.read(authProvider.future);
      await container.read(offlineAccessProvider.future);

      expect(container.read(offlineAccessExpiredProvider), isTrue);
    });

    test('reloads when the auth service records a new deadline', () async {
      final authService = _FakeAuthService(null);
      final container = containerWith(authService, user: createTestUser());
      final expired = <bool>[];
      container.listen(offlineAccessExpiredProvider, (_, next) => expired.add(next), fireImmediately: true);
      await container.read(authProvider.future);
      await container.read(offlineAccessProvider.future);
      expect(container.read(offlineAccessExpiredProvider), isTrue);

      authService
        ..deadline = DateTime(2100)
        ..changes.add(DateTime(2100));
      await container.read(offlineAccessProvider.future);
      await pumpEventQueue();

      expect(container.read(offlineAccessExpiredProvider), isFalse);
      expect(expired.last, isFalse);
    });

    test('flips to expired when the deadline passes', () async {
      final container = containerWith(
        _FakeAuthService(clock.now().add(const Duration(milliseconds: 50))),
        user: createTestUser(),
      )..listen(offlineAccessExpiredProvider, (_, _) {});
      await container.read(authProvider.future);
      await container.read(offlineAccessProvider.future);
      expect(container.read(offlineAccessExpiredProvider), isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 150));
      await container.read(offlineAccessProvider.future);

      expect(container.read(offlineAccessExpiredProvider), isTrue);
    });
  });

  group('offlineAccessLifecycleProvider', () {
    Future<_RenewCountingAuthNotifier> runLifecycle({
      required DateTime? deadline,
      required ConnectivityResult connectivity,
    }) async {
      final auth = _RenewCountingAuthNotifier(createTestUser());
      final container = containerWith(_FakeAuthService(deadline), auth: () => auth, connectivity: connectivity);
      await container.read(checkConnectionProvider.future);
      // Listened, as at the app root: an unlistened provider is paused.
      container.listen(offlineAccessLifecycleProvider, (_, _) {});
      await container.read(authProvider.future);
      await container.read(offlineAccessProvider.future);
      await pumpEventQueue();
      return auth;
    }

    test('renews an expired session while online', () async {
      final auth = await runLifecycle(deadline: DateTime(2000), connectivity: ConnectivityResult.wifi);

      expect(auth.renewCalls, 1);
    });

    test('renews a session with no recorded deadline while online', () async {
      final auth = await runLifecycle(deadline: null, connectivity: ConnectivityResult.wifi);

      expect(auth.renewCalls, 1);
    });

    test('does not try to renew while offline', () async {
      final auth = await runLifecycle(deadline: DateTime(2000), connectivity: ConnectivityResult.none);

      expect(auth.renewCalls, 0);
    });

    test('does not renew a session that is still valid', () async {
      final auth = await runLifecycle(deadline: DateTime(2100), connectivity: ConnectivityResult.wifi);

      expect(auth.renewCalls, 0);
    });
  });
}
