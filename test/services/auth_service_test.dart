import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_tags/database/daos/auth_dao.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/services/auth_service.dart';

import '../utils/jwt_test_utils.dart';
import '../utils/test_user.dart';
import 'auth_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, AuthDao])
void main() {
  late MockAuthDao mockAuthDao;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockAuthDao = MockAuthDao();
    mockFlutterSecureStorage = MockFlutterSecureStorage();
  });

  final mockJwt = buildJwt(
    payload: const {
      'sub': 'joe.bloggs@test.com',
      'name': 'Joe Bloggs',
      'exp': 1767225600, // token expiry 01-Jan-2026 00:00:00
      'contactId': 123456,
      'roles': ['alert-editor']
    },
  );
  final mockAuthResponse = buildAuthResponse();

  group('AuthService', () {
    test('login returns a UserProfile on success', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode(mockAuthResponse), 200);
      });

      final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);
      final user = await authService.login(email: 'joe.bloggs@test.com', password: 'password');

      expect(user.fullName, 'Joe Bloggs');
      expect(user.id, 123456);
      expect(user.email, 'joe.bloggs@test.com');
    });

    test('login stores User profile in DB on success', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode(mockAuthResponse), 200);
      });
      final db = AppDatabase.executor(conn.inMemoryConnection());
      final authDao = AuthDao(db);

      final authService = AuthService(authDao: authDao, client: client, storage: mockFlutterSecureStorage);
      await authService.login(email: 'joe.bloggs@test.com', password: 'password');

      final storedUser = await db.select(db.userProfiles).getSingleOrNull();

      expect(storedUser, isNotNull);
      expect(storedUser!.ref, equals(123456));
      expect(storedUser.fullName, equals('Joe Bloggs'));
      expect(storedUser.email, equals('joe.bloggs@test.com'));

      await db.close();
    });

    test('login throws exception on invalid credentials', () async {
      final client = MockClient((request) async {
        return http.Response('Invalid Credentials', 401);
      });

      final authService = AuthService(authDao: mockAuthDao, client: client);

      await expectLater(
        authService.login(
          email: 'joe.bloggs@test.com',
          password: 'password',
        ),
        throwsA(
          allOf(
            isA<AuthException>(),
            predicate<AuthException>(
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

    final authService = AuthService(authDao: mockAuthDao, client: client);

    await expectLater(
      authService.login(
        email: 'joe.bloggs@test.com',
        password: 'password',
      ),
      throwsA(
        allOf(
          isA<AuthException>(),
          predicate<AuthException>(
            (e) => e.message == 'Network error',
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

    final authService = AuthService(authDao: mockAuthDao, client: client);
    await expectLater(
      authService.login(
        email: 'joe.bloggs@test.com',
        password: 'password',
      ),
      throwsA(
        allOf(
          isA<AuthException>(),
          predicate<AuthException>(
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

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);
    await authService.login(email: 'joe.bloggs@test.com', password: 'password');

    verify(mockFlutterSecureStorage.write(key: 'token', value: mockJwt)).called(1);
    verify(mockFlutterSecureStorage.write(key: 'refresh_token', value: 'mockRefreshToken')).called(1);
  });

  test('logout deletes stored token and refresh token', () async {
    final client = MockClient((request) async {
      return http.Response(json.encode(mockAuthResponse), 200);
    });

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);
    await authService.login(email: 'joe.bloggs@test.com', password: 'password');

    await authService.logout();

    verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
    verify(mockFlutterSecureStorage.delete(key: 'refresh_token')).called(1);
    verify(mockFlutterSecureStorage.delete(key: 'userId')).called(1);
  });

  test('logout deletes user information from DB', () async {
    final client = MockClient((request) async {
      return http.Response(json.encode(mockAuthResponse), 200);
    });
    when(mockFlutterSecureStorage.read(key: 'userId')).thenAnswer((_) async => '123456');
    final db = AppDatabase.executor(conn.inMemoryConnection());
    final authDao = AuthDao(db);

    final authService = AuthService(authDao: authDao, client: client, storage: mockFlutterSecureStorage);
    await authService.login(email: 'joe.bloggs@test.com', password: 'password');

    final storedUser = await db.select(db.userProfiles).getSingleOrNull();
    expect(storedUser, isNotNull);

    await authService.logout();
    final storedUserAfterLogout = await db.select(db.userProfiles).getSingleOrNull();
    final storedPrograms = await db.select(db.programs).getSingleOrNull();
    final storedUserRoles = await db.select(db.userRoles).getSingleOrNull();
    final storedUserProgramRoles = await db.select(db.userProgramRoles).getSingleOrNull();

    expect(storedUserAfterLogout, isNull);
    expect(storedPrograms, isNull);
    expect(storedUserRoles, isNull);
    expect(storedUserProgramRoles, isNull);

    await db.close();
  });

  test('access token is retrieved from memory if cached', () async {
    final client = MockClient((request) async {
      return http.Response(json.encode(mockAuthResponse), 200);
    });

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);

    // Use a fixed clock to ensure token is not expired during the test.
    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      await authService.login(email: 'joe.bloggs@test.com', password: 'password');
      await authService.getAccessToken();

      verifyNever(mockFlutterSecureStorage.read(key: 'token'));
    });
  });

  test('access token is retrieved from storage if not cached', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);

    final authService = AuthService(authDao: mockAuthDao, storage: mockFlutterSecureStorage);

    // Use a fixed clock to ensure token is not expired during the test.
    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      final token = await authService.getAccessToken();
      expect(token, mockJwt);
      verify(mockFlutterSecureStorage.read(key: 'token')).called(1);
    });
  });

  test('return null if access token is not cached or stored', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => null);

    final authService = AuthService(authDao: mockAuthDao, storage: mockFlutterSecureStorage);
    final token = await authService.getAccessToken();

    expect(token, null);
    verify(mockFlutterSecureStorage.read(key: 'token')).called(1);
  });

  test('user information is retrieved from stored profile', () async {
    final testUser = createTestUser();
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'userId')).thenAnswer((_) async => testUser.id.toString());
    when(mockAuthDao.loadProfile(123456)).thenAnswer((_) async => testUser);

    final authService = AuthService(authDao: mockAuthDao, storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      final user = await authService.getAuthenticatedUser();
      expect(user!.id, testUser.id);
      expect(user.fullName, testUser.fullName);
      expect(user.email, testUser.email);
    });
  });

  test('no user information is returned if user not found', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'userId')).thenAnswer((_) async => '123456');
    when(mockAuthDao.loadProfile(123456)).thenAnswer((_) async => null);

    final authService = AuthService(authDao: mockAuthDao, storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      final user = await authService.getAuthenticatedUser();
      expect(user, null);
    });
  });

  test('AuthError is thrown and login is unsuccessful if JWT claims are invalid', () async {
    final testUser = createTestUser();
    when(mockFlutterSecureStorage.read(key: 'userId')).thenAnswer((_) async => testUser.id.toString());
    // Missing contactId
    final invalidJwt = buildJwt(
      payload: {
        'name': 'Alice Example',
        'sub': 'alice@example.com',
        'exp': 1767225600, // token expiry 01-Jan-2026 00:00:00
      },
    );

    final client = MockClient((request) async {
      return http.Response(json.encode(buildAuthResponse(accessTokenRs256: invalidJwt)), 200);
    });

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2025, 12, 31)), () async {
      await expectLater(
        authService.login(email: 'joe.bloggs@test.com', password: 'password'),
        throwsA(
          allOf(
            isA<AuthException>(),
            predicate<AuthException>(
                  (e) => e.message == 'Received malformed access token: Invalid JWT user claims',
            ),
          ),
        ),
      );
      verifyNever(mockFlutterSecureStorage.write(key: 'token', value: anyNamed('value')));
    });
  });

  test('Refresh exception is thrown and user is logged out when no refresh token is found.', () async {
    when(mockFlutterSecureStorage.read(key: 'userId')).thenAnswer((_) async => '123456');
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => null);
    final authService = AuthService(authDao: mockAuthDao, storage: mockFlutterSecureStorage);

    // Use a fixed clock to ensure token is expired during the test.
    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      await expectLater(authService.getAccessToken(), throwsA(isA<RefreshException>()));
      verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
      verify(mockFlutterSecureStorage.delete(key: 'refresh_token')).called(1);
    });
  });
  test('RefreshException is thrown and user is logged out when refresh returns 401', () async {
    when(mockFlutterSecureStorage.read(key: 'userId')).thenAnswer((_) async => '123456');
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'invalidRefreshToken');

    final client = MockClient((request) async {
      return http.Response('Invalid refresh token', 401);
    });

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);

    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      await expectLater(authService.getAccessToken(), throwsA(isA<RefreshException>()));
      verify(mockFlutterSecureStorage.delete(key: 'token')).called(1);
      verify(mockFlutterSecureStorage.delete(key: 'refresh_token')).called(1);
    });
  });
  test('AuthException is thrown when refresh request returns server error', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');

    final client = MockClient((request) async {
      return http.Response('Server error', 500);
    });

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);
    // Use a fixed clock to ensure token is expired during the test.
    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      await expectLater(authService.getAccessToken(), throwsA(isA<AuthException>()));
    });
  });

  test('AuthException is thrown when refresh response is malformed JSON', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');

    final client = MockClient((request) async {
      return http.Response('invalid json {', 200);
    });

    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);
    // Use a fixed clock to ensure token is expired during the test.
    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      await expectLater(authService.getAccessToken(), throwsA(isA<AuthException>()));
    });
  });

  test('ClientException is thrown when a network error occurs during token refresh', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');
    final client = MockClient((request) async {
      throw http.ClientException('Failed to refresh token');
    });
    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);
    // Use a fixed clock to ensure token is expired during the test.
    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      await expectLater(authService.getAccessToken(), throwsA(isA<http.ClientException>()));
    });
  });

  test('Access token is refreshed successfully when expired', () async {
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => mockJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');
    final newMockJwt = buildJwt(payload: {'name': 'Alice Example', 'sub': 'alice@example.com', 'contactId': 123456, 'exp': 1767398400, 'roles': ['alert-editor']});
    final client = MockClient((request) async {
      return http.Response(
        json.encode(buildAuthResponse(accessTokenRs256: newMockJwt, refreshToken: 'newMockRefreshToken')),
        200,
      );
    });
    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);

    // Use a fixed clock to ensure token is expired during the test.
    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      final token = await authService.getAccessToken();
      expect(token, newMockJwt);
      verify(mockFlutterSecureStorage.write(key: 'token', value: newMockJwt)).called(1);
      verify(mockFlutterSecureStorage.write(key: 'refresh_token', value: 'newMockRefreshToken')).called(1);
    });
  });

  test('Access token is refreshed successfully when expiry time is missing.', () async {
    // Missing exp
    final invalidJwt = buildJwt(payload: {'name': 'Alice Example', 'sub': 'alice@example.com', 'contactId': 123456});
    when(mockFlutterSecureStorage.read(key: 'token')).thenAnswer((_) async => invalidJwt);
    when(mockFlutterSecureStorage.read(key: 'refresh_token')).thenAnswer((_) async => 'mockRefreshToken');
    final newMockJwt = buildJwt(payload: {'name': 'Alice Example', 'sub': 'alice@example.com', 'contactId': 123456, 'exp': 1, 'roles': ['alert-editor']});
    final client = MockClient((request) async {
      return http.Response(
        json.encode(buildAuthResponse(accessTokenRs256: newMockJwt, refreshToken: 'newMockRefreshToken')),
        200,
      );
    });
    final authService = AuthService(authDao: mockAuthDao, client: client, storage: mockFlutterSecureStorage);

    // Use a fixed clock to ensure token is expired during the test.
    await withClock(Clock.fixed(DateTime(2026, 01, 02)), () async {
      final token = await authService.getAccessToken();
      expect(token, newMockJwt);
      verify(mockFlutterSecureStorage.write(key: 'token', value: newMockJwt)).called(1);
      verify(mockFlutterSecureStorage.write(key: 'refresh_token', value: 'newMockRefreshToken')).called(1);
    });
  });
}
