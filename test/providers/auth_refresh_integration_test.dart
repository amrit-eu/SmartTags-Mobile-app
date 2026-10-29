import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/providers/offline_access_provider.dart';
import 'package:smart_tags/providers/permission_provider.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../services/auth_service_test.mocks.dart';
import '../utils/jwt_test_utils.dart';
import '../utils/test_user.dart';

void main() {
  final now = DateTime.utc(2026, 10, 23);
  final originalUser = createTestUser();
  late AppDatabase database;
  late AuthService service;
  late http.Client client;
  late ProviderContainer container;
  late Map<String, String> stored;
  late User refreshedUser;
  late String refreshedToken;
  late int refreshStatus;
  Completer<void>? logoutGate;
  late Completer<void> logoutStarted;

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      authServiceProvider.overrideWithValue(service),
      gatewayRepositoryProvider.overrideWithValue(GatewayRepository(authService: service, client: client)),
    ],
  );

  setUp(() async {
    database = AppDatabase.executor(conn.inMemoryConnection());
    await database.authDao.saveProfile(originalUser);
    await database.enqueuePendingOperation(
      PendingOperationsCompanion.insert(
        platformRef: 'PLATFORM-1',
        action: 'deploy',
        payloadJson: '{"ptfId":"1"}',
        userRef: originalUser.id,
      ),
    );
    stored = {
      'userId': originalUser.id.toString(),
      'refresh_token': 'original-refresh-token',
      // Offline access still valid, so cached permissions apply.
      'refresh_expires_at': DateTime.utc(2100).millisecondsSinceEpoch.toString(),
      'token': buildJwt(
        payload: {
          'contactId': originalUser.id,
          'name': originalUser.fullName,
          'sub': originalUser.email,
          'roles': originalUser.roles,
          'exp': now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch ~/ 1000,
        },
      ),
    };
    final storage = MockFlutterSecureStorage();
    when(storage.read(key: anyNamed('key'))).thenAnswer((call) async => stored[call.namedArguments[#key]]);
    when(storage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((call) async {
      stored[call.namedArguments[#key] as String] = call.namedArguments[#value] as String;
    });
    when(storage.delete(key: anyNamed('key'))).thenAnswer((call) async {
      stored.remove(call.namedArguments[#key]);
    });

    refreshedUser = createTestUser(fullName: 'Updated contact', roles: [], programRoles: []);
    refreshedToken = buildJwt(
      payload: {
        'contactId': refreshedUser.id,
        'name': refreshedUser.fullName,
        'sub': refreshedUser.email,
        'roles': refreshedUser.roles,
        'exp': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      },
    );
    refreshStatus = 200;
    logoutGate = null;
    logoutStarted = Completer<void>();
    client = MockClient((request) async {
      if (request.url.path.endsWith('/refresh')) {
        return http.Response(
          jsonEncode(
            buildAuthResponse(
              accessTokenRs256: refreshedToken,
              refreshToken: 'updated-refresh-token',
              contact: refreshedUser,
            ),
          ),
          refreshStatus,
        );
      }
      if (request.url.path.endsWith('/logout')) {
        logoutStarted.complete();
        await logoutGate?.future;
        return http.Response('{}', 200);
      }
      expect(request.headers['Authorization'], 'Bearer $refreshedToken');
      return http.Response('{}', 200);
    });
    service = AuthService(
      authDao: database.authDao,
      storage: storage,
      client: client,
      connectivityForRefresh: () async => ConnectivityResult.wifi,
    );
    container = createContainer();
    await container.read(authProvider.future);
  });

  tearDown(() async {
    container.dispose();
    service.dispose();
    await database.close();
  });

  test('a token refresh updates persisted roles and live permissions', () async {
    expect(container.read(permissionProvider).canEdit(Resource.deployment, programId: 4), isTrue);
    expect(container.read(permissionProvider).canAckAlert(programId: 4), isTrue);

    await withClock(Clock.fixed(now), () async {
      await container.read(gatewayRepositoryProvider).submitPassportEventJson('{}');
    });
    await container.pump();

    final current = container.read(authProvider).value!;
    expect(current.fullName, refreshedUser.fullName);
    expect(current.roles, isEmpty);
    expect(current.programRoles, isEmpty);
    expect(container.read(permissionProvider).canEdit(Resource.deployment, programId: 4), isFalse);
    expect(container.read(permissionProvider).canAckAlert(programId: 4), isFalse);
    expect(stored['token'], refreshedToken);
    expect(stored['refresh_token'], 'updated-refresh-token');
    expect((await database.authDao.loadProfile(originalUser.id))!.programRoles, isEmpty);
    expect(await database.getPendingOperationsOrdered(), hasLength(1));

    container.dispose();
    container = createContainer();
    final restored = await container.read(authProvider.future);
    expect(restored!.fullName, refreshedUser.fullName);
    expect(restored.roles, isEmpty);
    expect(restored.programRoles, isEmpty);
    expect(container.read(permissionProvider).canEdit(Resource.deployment, programId: 4), isFalse);
  });

  test('refresh 401 invalidates UI permissions before logout cleanup completes', () async {
    refreshStatus = 401;
    final gate = Completer<void>();
    logoutGate = gate;
    await withClock(Clock.fixed(now), () async {
      final rejected = expectLater(
        container.read(gatewayRepositoryProvider).submitPassportEventJson('{}'),
        throwsA(isA<GatewayAuthException>()),
      );
      await logoutStarted.future;
      try {
        await container.pump();
        expect(container.read(authProvider).value, isNull);
        expect(container.read(permissionProvider).canEdit(Resource.deployment, programId: 4), isFalse);
        expect(container.read(errorNotificationProvider)?.type, 'session_expired');
        expect(container.read(errorNotificationProvider)?.message, 'Session has expired: please log in again.');
      } finally {
        gate.complete();
      }
      await rejected;
    });

    expect(stored, isEmpty);
    expect(await database.authDao.loadProfile(originalUser.id), isNull);
    final pending = await database.getPendingOperationsOrdered();
    expect(pending, hasLength(1));
    expect(pending.single.userRef, originalUser.id);
    expect(pending.single.status, 'pending');
  });

  test('a rejected background renewal after offline expiry logs out and preserves queued work', () async {
    refreshStatus = 401;
    stored.remove('refresh_expires_at');
    await container.read(offlineAccessProvider.future);
    expect(container.read(offlineAccessExpiredProvider), isTrue);

    await container.read(authProvider.notifier).renewExpiredSession();
    await container.pump();

    expect(container.read(authProvider).value, isNull);
    expect(container.read(errorNotificationProvider)?.type, 'session_expired');
    expect(container.read(errorNotificationProvider)?.message, 'Session has expired: please log in again.');
    expect(stored, isEmpty);
    final pending = await database.getPendingOperationsOrdered();
    expect(pending.single.userRef, originalUser.id);
    expect(pending.single.status, 'pending');
  });

  test('a successful background renewal restores offline access', () async {
    stored.remove('refresh_expires_at');
    await container.read(offlineAccessProvider.future);
    expect(container.read(offlineAccessExpiredProvider), isTrue);

    await container.read(authProvider.notifier).renewExpiredSession();
    await container.pump();
    await container.read(offlineAccessProvider.future);

    expect(container.read(authProvider).value, isNotNull);
    expect(container.read(offlineAccessExpiredProvider), isFalse);
    expect(stored['refresh_expires_at'], isNotNull);
  });

  test('missing refresh credentials clear observable session state and preserve queued work', () async {
    stored.remove('refresh_token');
    await withClock(Clock.fixed(now), () async {
      await expectLater(
        container.read(gatewayRepositoryProvider).addAlertNote('alert-1', 'A note'),
        throwsA(isA<GatewayAuthException>()),
      );
    });
    await container.pump();

    expect(container.read(authProvider).value, isNull);
    expect(container.read(permissionProvider).canAckAlert(programId: 4), isFalse);
    expect(container.read(errorNotificationProvider)?.type, 'session_expired');
    expect(stored, isEmpty);
    expect((await database.getPendingOperationsOrdered()).single.userRef, originalUser.id);
  });

  test('refresh 503 preserves the user, permissions and queued work', () async {
    refreshStatus = 503;
    final previousCredentials = Map<String, String>.of(stored);
    await withClock(Clock.fixed(now), () async {
      await expectLater(
        container.read(gatewayRepositoryProvider).submitPassportEventJson('{}'),
        throwsA(isA<GatewayException>().having((error) => error is GatewayAuthException, 'auth rejection', isFalse)),
      );
    });
    await container.pump();

    expect(container.read(authProvider).value!.id, originalUser.id);
    expect(container.read(permissionProvider).canEdit(Resource.deployment, programId: 4), isTrue);
    expect(stored, previousCredentials);
    expect(await database.authDao.loadProfile(originalUser.id), isNotNull);
    expect(container.read(errorNotificationProvider), isNull);
    final pending = await database.getPendingOperationsOrdered();
    expect(pending.single.status, 'pending');
    expect(pending.single.userRef, originalUser.id);
  });
}
