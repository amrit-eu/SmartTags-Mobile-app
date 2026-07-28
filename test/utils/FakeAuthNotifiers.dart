import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/services/auth_service.dart';

import '../utils/test_user.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(this._user);

  final User? _user;

  @override
  Future<User?> build() async => _user;
}

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