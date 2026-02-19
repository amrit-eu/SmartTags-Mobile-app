import 'dart:convert';
import 'package:http/http.dart' as http;
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
  AuthService(this._client);

  final http.Client _client;

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
    final uri = Uri.parse('https://oceanops-api-main.isival.ifremer.fr/api/data/auth/login');

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

      if (response.statusCode != 200) {
        throw const AuthException('Invalid credentials');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(json);
      return authResponse.contact;

    } on http.ClientException catch (e) {
      throw AuthException('Network error: ${e.message}');
    } on FormatException {
      throw const AuthException('Invalid server response');
    }
  }
}
