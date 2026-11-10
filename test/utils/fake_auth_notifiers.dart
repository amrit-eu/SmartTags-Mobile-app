import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/offline_access_provider.dart';
import 'package:smart_tags/services/auth_service.dart';

import 'test_user.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._user);

  final User? _user;

  @override
  Future<User?> build() async => _user;
}

/// Offline access ending at a fixed deadline for the signed-in user (`null`
/// when no user is signed in), without reading secure storage.
class FakeOfflineAccessNotifier extends OfflineAccessNotifier {
  FakeOfflineAccessNotifier(this._deadline);

  /// Access that stays valid for the whole test.
  FakeOfflineAccessNotifier.valid() : _deadline = DateTime(2100);

  final DateTime? _deadline;

  @override
  Future<OfflineAccess?> build() async {
    final userId = ref.watch(authProvider.select((async) => async.value?.id));
    return userId == null ? null : OfflineAccess(_deadline);
  }
}

/// Override for tests that sign a user in through [FakeAuthNotifier] and
/// expect their cached permissions to apply.
final Override validOfflineAccessOverride = offlineAccessProvider.overrideWith(FakeOfflineAccessNotifier.valid);

class FakeAuthSuccessNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;

  @override
  Future<void> login(String email, String password) async {
    state = AsyncData(createTestUser());
  }
}

class FakeAuthFailureNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;

  @override
  Future<void> login(String email, String password) async {
    state = AsyncError(
      const AuthException('Invalid Credentials'),
      StackTrace.current,
    );
  }
}
