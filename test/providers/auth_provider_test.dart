import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/services/auth_service.dart';

const testUser = UserProfile(
  fullName: 'Joe Bloggs',
  id: 123456,
  email: 'test@test.com',
);

class MockSuccessAuthService extends AuthService {
  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    return testUser;
  }
}

class MockFailedAuthService extends AuthService {
  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    throw const AuthException('Invalid Credentials');
  }
}

ProviderContainer MockSetup() {
  final mockService = MockSuccessAuthService();
  return ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(mockService),
    ],
  );
}

void main() {
  test('initial state is null (logged out)', () async {
    final container = ProviderContainer();

    final result = await container.read(authProvider.future);

    expect(result, isNull);
  });

  test('login success sets user', () async {
    final container = MockSetup();
    final notifier = container.read(authProvider.notifier);

    await notifier.login('test@test.com', 'password');

    expect(container.read(authProvider).value, testUser);
  });

  test('login failure sets AsyncError', () async {
    final mockService = MockFailedAuthService();
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockService),
      ],
    );
    final notifier = container.read(authProvider.notifier);

    await notifier.login('test@test.com', 'password');

    final state = container.read(authProvider);
    expect(state, isA<AsyncError<UserProfile?>>());
  });

  test('logout sets user to null', () async {
    final container = MockSetup();
    final notifier = container.read(authProvider.notifier);
    await notifier.login('test@test.com', 'password');
    expect(container.read(authProvider).value, testUser);

    notifier.logout();
    expect(container.read(authProvider).value, isNull);
  });

  test('login emits loading then data', () async {
    final container = MockSetup();

    final notifier = container.read(authProvider.notifier);
    final future = notifier.login('test@test.com', 'password');

    expect(container.read(authProvider), isA<AsyncLoading<UserProfile?>>());

    await future;

    expect(container.read(authProvider).value, testUser);
  });
}
