import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  final mockService = MockAuthService();
  late ProviderContainer container;

  const testUser = UserProfile(
    fullName: 'Joe Bloggs',
    id: 123456,
    email: 'test@test.com',
  );

  setUp(() {
    reset(mockService);
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });


  test('initial state is null if no user is authenticated', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => null);
    final result = await container.read(authProvider.future);
    expect(result, isNull);
  });

  test('shows authenticated user as logged in', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => testUser);
    final result = await container.read(authProvider.future);
    expect(result, testUser);
  });

  test('login emits loading then data', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => null);
    when(mockService.login(email: 'test@test.com', password: 'password')).thenAnswer((_) async => testUser);

    final notifier = container.read(authProvider.notifier);

    final future = notifier.login('test@test.com', 'password');
    expect(container.read(authProvider), isA<AsyncLoading<UserProfile?>>());
    await future;

    expect(container.read(authProvider).value, testUser);
  });

  test('login success sets user', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => null);
    when(mockService.login(email: 'test@test.com', password: 'password')).thenAnswer((_) async => testUser);

    final notifier = container.read(authProvider.notifier);

    await notifier.login('test@test.com', 'password');

    expect(container.read(authProvider).value, testUser);
  });

  test('login failure sets AsyncError', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => null);
    when(mockService.login(email: 'test@test.com', password: 'password'))
        .thenThrow(const AuthException('Invalid Credentials'));

    final notifier = container.read(authProvider.notifier);

    await notifier.login('test@test.com', 'password');

    final state = container.read(authProvider);
    expect(state, isA<AsyncError<UserProfile?>>());
  });

  test('logout sets user to null', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => null);
    when(mockService.logout()).thenAnswer((_) async => null);
    when(mockService.login(email: 'test@test.com', password: 'password')).thenAnswer((_) async => testUser);

    final notifier = container.read(authProvider.notifier);
    await notifier.login('test@test.com', 'password');
    expect(container.read(authProvider).value, testUser);

    await notifier.logout();
    expect(container.read(authProvider).value, isNull);
  });

  test('logout calls AuthService logout', () async {
    final notifier = container.read(authProvider.notifier);
    when(mockService.logout()).thenAnswer((_) async => null);

    await notifier.logout();

    verify(mockService.logout()).called(1);
  });

  test('logout failure emits error, then returns to logged in user value', () async {
    when(mockService.getAuthenticatedUser()).thenAnswer((_) async => testUser);
    when(mockService.logout()).thenThrow(PlatformException(message: "Couldn't delete token", code: '1'));
    final notifier = container.read(authProvider.notifier)
    ..state = const AsyncData<UserProfile?>(testUser);

    final states = <AsyncValue<UserProfile?>>[];
    final sub = container.listen(
      authProvider,
          (prev, next) => states.add(next),
    );

    await notifier.logout();

    // Cleanup subscription
    sub.close();

    expect(states.length, 3);
    expect(states[0], isA<AsyncLoading<UserProfile?>>());
    expect(states[1], isA<AsyncError<UserProfile?>>());
    expect(states[2], const AsyncData<UserProfile?>(testUser));

  });
}
