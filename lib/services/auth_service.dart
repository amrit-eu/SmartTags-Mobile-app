import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/helpers/jwt_decode.dart';
import 'package:smart_tags/models/auth_response.dart';
import 'package:smart_tags/models/user.dart';

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  /// Creates an [AuthException] with the given [message].
  const AuthException(this.message);
  /// The error message describing the authentication failure.
  final String message;

  @override
  String toString() => message;
}

/// A service responsible for handling authentication-related API calls.
///
/// This service communicates with the backend API to log in a user
/// and returns the authenticated [UserProfile].
/// It throws [AuthException] on invalid credentials, network errors,
/// or malformed responses.
class AuthService {
  /// Creates an [AuthService] with the provided HTTP client.
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const storage = FlutterSecureStorage();

  Future<UserProfile?> retrieveLoggedInUser() async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      final claims = decodeJwtClaims(token);
      if (claims != null) {
        final tokenExpiry = DateTime.fromMillisecondsSinceEpoch((claims['exp'] as int) * 1000);
        if (DateTime.now().isBefore(tokenExpiry)) {
          return UserProfile(
              id: claims['contactId'] as int,
              fullName: claims['name'] as String,
              email: claims['sub'] as String
          );
        }
      }
    }
    return null;
  }

  /// Authenticates a user with the given [email] and [password].
  /// Returns a [UserProfile] if authentication is successful.
  ///
  /// Throws [AuthException] if:
  /// - The credentials are invalid (status code != 200)
  /// - There is a network error
  /// - The server returns an invalid response
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final loggedInUser = await retrieveLoggedInUser();
    if (loggedInUser != null) {
      return loggedInUser;
    }

    // TODO(eawetchy): Change to https://amrit-gateway.isival.ifremer.fr/api/oceanops/auth/login once code on Isival is up to date)
    final uri = Uri.parse('https://amrit-gateway.isival.ifremer.fr/api/oceanops/data/auth/login');

    try {
      final response = await _client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': email,
          'password': password,
        }),
      );

      final successCodes = <int>[200, 201];
      if (successCodes.contains(response.statusCode)) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(json);

        await storage.write(key: 'token', value: authResponse.accessTokenRs256);
        await storage.write(key: 'refresh_token', value: authResponse.refreshToken);

        return authResponse.contact;
      } else if (response.statusCode == 401) {
        throw const AuthException('Invalid credentials');
      } else {
        throw const AuthException('Unable to authenticate');
      }
    } on http.ClientException catch (e) {
      throw AuthException('Network error: ${e.message}');
    } on FormatException {
      throw const AuthException('Invalid server response');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'refresh_token');
  }
}
