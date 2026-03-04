import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_tags/services/auth_service.dart';

import '../utils/jwt_test_utils.dart';
import 'auth_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  final mockFlutterSecureStorage = MockFlutterSecureStorage();

  final mockJwt = buildJwt(
    payload: const {
      'sub': 'joe.bloggs@test.com',
      'name': 'Joe Bloggs',
      'exp': 1767225600, // token expiry 01-Jan-2026 00:00:00
      'contactId': 123456
    },
  );
  final mockAuthResponse = {
    'success': true,
    'access_token_rs256': mockJwt,
    'refresh_token': 'mockRefreshToken',
    'refresh_expires_in': 864000,
    'expires_in': 3600,
    'contact': {
      'id': 123456,
      'email': 'joe.bloggs@test.com',
      'fullName': 'Joe Bloggs',
      'firstName': 'Joe',
      'lastName': 'Bloggs',
    }
  };

  setUp(() {
    reset(mockFlutterSecureStorage);
  });

  group('AuthService', () {
    test('login returns a UserProfile on success', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode(mockAuthResponse), 200);
      });

      final authService = AuthService(client: client, storage: mockFlutterSecureStorage);
      final user = await authService.login(email: 'joe.bloggs@test.com', password: 'password');

      expect(user.fullName, 'Joe Bloggs');
      expect(user.id, 123456);
      expect(user.email, 'joe.bloggs@test.com');
    });

    test('login throws exception on invalid credentials', () async {
      final client = MockClient((request) async {
        return http.Response('Invalid Credentials', 401);
      });

      final authService = AuthService(client: client);

      await expectLater(authService.login(
          email: 'joe.bloggs@test.com',
          password: 'password',
        ),
        throwsA(allOf(isA<AuthException>(), predicate<AuthException>(
              (e) => e.message == 'Invalid credentials',
            ),
          ),
        ),
      );
    });
  });

  test('login throws exception on network error', () async {
    final client = MockClient((request) async {
      throw http.ClientException('Failed to fetch');
    });

    final authService = AuthService(client: client);

    await expectLater(authService.login(
      email: 'joe.bloggs@test.com',
      password: 'password',
    ),
      throwsA(allOf(isA<AuthException>(), predicate<AuthException>(
                (e) => e.message == 'Network error: Failed to fetch',
          ),
        ),
      ),
    );
  });

  test('login throws exception on malformed response', () async {
    final mockResponse = {
      'success': true,
    };

    final client = MockClient((request) async {
      return http.Response(json.encode(mockResponse), 200);
    });

    final authService = AuthService(client: client);
    await expectLater(authService.login(
      email: 'joe.bloggs@test.com',
      password: 'password',
    ),
      throwsA(allOf(isA<AuthException>(), predicate<AuthException>(
                (e) => e.message == 'Invalid server response',
          ),
        ),
      ),
    );
  });

  test('login stores token and refresh token', () async {
    final client = MockClient((request) async {
      return http.Response(json.encode(mockAuthResponse), 200);
    });

    final authService = AuthService(client: client, storage: mockFlutterSecureStorage);
    await authService.login(email: 'joe.bloggs@test.com', password: 'password');

    verify(mockFlutterSecureStorage.write(key: 'token', value: mockJwt)).called(1);
    verify(mockFlutterSecureStorage.write(key: 'refresh_token', value: 'mockRefreshToken')).called(1);
  });

  test('logout deletes stored token and refresh token', () async {
    final client = MockClient((request) async {
      return http.Response(json.encode(mockAuthResponse), 200);
    });

    final authService = AuthService(client: client, storage: mockFlutterSecureStorage);
    await authService.login(email: 'joe.bloggs@test.com', password: 'password');

    await authService.logout();

    verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
    verify(mockFlutterSecureStorage.delete(key: 'refresh_token')).called(1);
  });

  test('access token is retrieved from memory if cached', () async {
    final client = MockClient((request) async {
      return http.Response(json.encode(mockAuthResponse), 200);
    });

    final authService = AuthService(client: client, storage: mockFlutterSecureStorage);
    
    // Use a fixed clock to ensure token is not expired during the test.
    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      await authService.login(email: 'joe.bloggs@test.com', password: 'password');
      await authService.getAccessToken();

      verifyNever(mockFlutterSecureStorage.read(key: 'token'));
    });
  });

  test('access token is retrieved from storage if not cached', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);

    final authService = AuthService(storage: mockFlutterSecureStorage);

    // Use a fixed clock to ensure token is not expired during the test.
    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      final token = await authService.getAccessToken();
      expect(token, mockJwt);
      verify(mockFlutterSecureStorage.read(key: 'token')).called(1);
    });
  });

  test('return null if access token is not cached or stored', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => null);

    final authService = AuthService(storage: mockFlutterSecureStorage);
    final token = await authService.getAccessToken();

    expect(token, null);
    verify(mockFlutterSecureStorage.read(key: 'token')).called(1);
  });

  test('access token from storage is not returned if expired', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');

    final authService = AuthService(storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      final token = await authService.getAccessToken();
      expect(token, null);
      verify(mockFlutterSecureStorage.read(key: 'token')).called(1);
    });
  });

  test('JWT is deleted from storage if expired', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');

    final authService = AuthService(storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      final token = await authService.getAccessToken();
      expect(token, null);
      verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
    });
  });

  test('user information is retrieved from stored JWT', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);

    final authService = AuthService(storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      final user = await authService.getAuthenticatedUser();
      expect(user!.id, 123456);
      expect(user.fullName, 'Joe Bloggs');
      expect(user.email,  'joe.bloggs@test.com');
    });
  });

  test('JWT is deleted and null is returned if expiry time is missing', () async {
    // Missing exp
    final invalidJwt = buildJwt(payload: {
      'name': 'Alice Example',
      'sub': 'alice@example.com',
      'contactId': 123456
    });
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => invalidJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');
    
    final authService = AuthService(storage: mockFlutterSecureStorage);

    final token = await authService.getAccessToken();

    expect(token, null);
    verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
  });

  test('JWT is deleted and no user is returned if claims are invalid', () async {
    // Missing contactId
    final invalidJwt = buildJwt(payload: {
      'name': 'Alice Example',
      'sub': 'alice@example.com',
      'exp': 1767225600, // token expiry 01-Jan-2026 00:00:00
    });
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => invalidJwt);
    final authService = AuthService(storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      final user = await authService.getAuthenticatedUser();
      expect(user, null);
      verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
    });
  });
}
