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
  AuthService({
    http.Client? client,
    FlutterSecureStorage? storage,
  }) :
    _client = client ?? http.Client(),
    _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;

  String? _cachedToken;

  Future<void> _saveToken(String token, String refreshToken) async {
    _cachedToken = token;
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  bool _isExpired(String token) {
    final claims = decodeJwtClaims(token);
    if (claims != null) {
      final tokenExpiry = DateTime.fromMillisecondsSinceEpoch((claims['exp'] as int) * 1000);
      return !DateTime.now().isBefore(tokenExpiry);
    }
    return true;
  }

  Future<String?> _refreshToken() async {
    // stub to implement in issue #23
    // update storage + _cachedToken
    return null;
  }

  UserProfile? _decodeUserFromToken(String token) {
    final claims = decodeJwtClaims(token);
    if (claims != null) {
      return UserProfile(
          id: claims['contactId'] as int,
          fullName: claims['name'] as String,
          email: claims['sub'] as String
      );
    }
    return null;
  }

  /// Returns JWT from memory cache or secure storage if expiry time has not passed
  /// If stored token is expired, attempts to refresh
  Future<String?> getAccessToken() async {
    // check token cached in memory first
    if (_cachedToken != null) {
      if (!_isExpired(_cachedToken!)) return _cachedToken;
      return _refreshToken();
    }
    // else return token from storage
    final token = await _storage.read(key: 'token');
    if (token == null) return null;
    if (!_isExpired(token)) return _cachedToken = token;
    return _refreshToken();
  }

  /// Decode user information from stored JWT
  Future<UserProfile?> getAuthenticatedUser() async {
    final token = await getAccessToken();
    if (token != null) {
      return _decodeUserFromToken(token);
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

        await _saveToken(authResponse.accessTokenRs256, authResponse.refreshToken);

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

  /// Delete tokens from cache and secure storage.
  /// Should send a logout request to Gateway API, but no logout URL is currently documented.
  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refresh_token');
  }
}
