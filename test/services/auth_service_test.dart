import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_tags/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('login returns a UserProfile on success', () async {
      final mockResponse = {
        'success': true,
        'access_token_rs256': 'mockToken',
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

      final client = MockClient((request) async {
        return http.Response(json.encode(mockResponse), 200);
      });

      final authService = AuthService(client: client);
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
}
