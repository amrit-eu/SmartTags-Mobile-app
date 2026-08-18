import 'dart:convert';
import 'package:clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/daos/auth_dao.dart';
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

/// Exception thrown when the refresh token is invalid or credentials have expired.
/// This is a critical error that requires logout.
class RefreshException extends AuthException {
  /// Creates a [RefreshException] with the given [message].
  const RefreshException(super.message);
}

/// A service responsible for handling authentication-related API calls.
///
/// This service communicates with the backend API to log in a user
/// and returns the authenticated [User].
/// It throws [AuthException] on invalid credentials, network errors,
/// or malformed responses.
class AuthService {
  /// Creates an [AuthService] with the provided HTTP client.
  AuthService({
    required AuthDao authDao,
    http.Client? client,
    FlutterSecureStorage? storage,
  }) : _authDao = authDao,
       _client = client ?? http.Client(),
       _storage = storage ?? const FlutterSecureStorage();

  final AuthDao _authDao;
  final http.Client _client;
  final FlutterSecureStorage _storage;

  String? _cachedToken;
  String? _cachedUserId;

  Future<void> _saveToken(String token, String refreshToken) async {
    try {
      _decodeToken(token);
    } catch (e) {
      // Malformed token from the server
      throw AuthException('Received malformed access token: $e');
    }

    _cachedToken = token;
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _saveUserInfo(User user) async {
    await _authDao.saveProfile(user);
  }

  Future<void> _deleteAccessToken() async {
    _cachedToken = null;
    await _storage.delete(key: 'token');
  }

  bool _isExpired(String token) {
    try {
      final claims = decodeJwtClaims(token);
      if (claims['exp'] is! int) {
        debugPrint('JWT is missing exp claim or it is not a valid integer');
        return true;
      }
      // API returns expiry as seconds since epoch, convert to match available Dart function
      final tokenExpiry = DateTime.fromMillisecondsSinceEpoch((claims['exp'] as int) * 1000);
      // Consider the token expired if it's within 30 seconds of expiry to avoid edge cases where token expires during a request.
      final expiryBuffer = tokenExpiry.subtract(const Duration(seconds: 30));
      return !clock.now().isBefore(expiryBuffer);
    } on JwtDecodingException catch (exc) {
      debugPrint('Failed to decode JWT claims: ${exc.message}');
      return true;
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// If successful, saves the new access token and returns it.
  Future<String?> _refreshToken() async {
    // Get the refresh token from secure storage. If it's not available, we can't refresh.
    // Log the user out in this case since they need to log in again to get a new refresh token.
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      debugPrint('No refresh token found in storage');
      throw const RefreshException('No refresh token available');
    }

    final uri = GatewayConfig.refreshUri;
    debugPrint('Attempting token refresh');
    try {
      final response = await _client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );
      final successCodes = <int>[200, 201];
      if (successCodes.contains(response.statusCode)) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(json);
        await _saveToken(authResponse.accessTokenRs256, authResponse.refreshToken);
        debugPrint('Token refresh successful');
        // Return the new access token so the caller can retry the original request.
        return authResponse.accessTokenRs256;
      } else if (response.statusCode == 401) {
        throw const RefreshException('Invalid refresh token');
      } else {
        throw const AuthException('Unable to refresh token');
      }
    } on FormatException {
      throw const AuthException('Invalid server response');
    }
  }

  TokenClaims _decodeToken(String token) {
    final claims = decodeJwtClaims(token);
    final roles = claims['roles'];

    if (claims['contactId'] is! int ||
        claims['name'] is! String ||
        claims['sub'] is! String ||
        claims['exp'] is! int ||
        roles is! List ||
        roles.any((e) => e is! String)) {
      throw const AuthException('Invalid JWT user claims');
    }

    return TokenClaims(
      contactId: claims['contactId'] as int,
      name: claims['name'] as String,
      sub: claims['sub'] as String,
      roles: roles.cast<String>(),
      exp: claims['exp'] as int,
    );
  }

  /// Retrieve ID of the current user from memory cache or storage.
  Future<String?> getUserId() async {
    // Check in-memory cache first for performance, then fallback to secure storage.
    final userId = _cachedUserId ?? await _storage.read(key: 'userId');
    return userId;
  }

  /// Returns JWT from memory cache or secure storage if expiry time has not passed
  /// If stored token is expired, attempts to refresh
  Future<String?> getAccessToken() async {
    // Check in-memory cache first for performance, then fallback to secure storage.
    var token = _cachedToken ?? await _storage.read(key: 'token');

    // Return null if no token is found.
    if (token == null) return null;

    // Refresh if expired.
    if (_isExpired(token)) {
      try {
        token = await _refreshToken();
      } on RefreshException {
        // refresh error (401 or no refresh token found) - force logout
        await logout();
        // Rethrow to notify caller of the logout event so it can update UI accordingly.
        rethrow;
      } on (AuthException, http.ClientException) catch (exc) {
        // Network error or server error during refresh - keep user logged in with old token and let them retry.
        debugPrint('Token refresh failed: $exc');
        rethrow;
      }
    }
    _cachedToken = token;
    return token;
  }

  /// Decode user information from stored JWT
  Future<User?> getAuthenticatedUser() async {
    final userId = await getUserId();
    if (userId == null) return null;
    final user = _authDao.loadProfile(int.parse(userId));
    return user;
  }

  /// Authenticates a user with the given [email] and [password].
  /// Returns a [User] if authentication is successful.
  ///
  /// Throws [AuthException] if:
  /// - The credentials are invalid (status code != 200)
  /// - There is a network error
  /// - The server returns an invalid response
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final uri = GatewayConfig.loginUri;

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
        final userInfo = authResponse.contact;
        _cachedUserId = userInfo.id.toString();
        await _storage.write(key: 'userId', value: userInfo.id.toString());
        await _saveUserInfo(userInfo);

        return userInfo;
      } else if (response.statusCode == 401) {
        throw const AuthException('Invalid credentials');
      } else {
        throw const AuthException('Unable to authenticate');
      }
    } on http.ClientException catch (e) {
      debugPrint('Network error during login: ${e.message}');
      throw const AuthException('Network error');
    } on FormatException {
      throw const AuthException('Invalid server response');
    }
  }

  /// Delete tokens from cache and secure storage.
  Future<Null> logout() async {
    final logoutUri = GatewayConfig.logoutUri;
    // post to back-end logout and ignore results
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken != null) {
      try {
        await _client.post(
          logoutUri,
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'refresh_token': refreshToken,
          }),
        );
      } catch (e) {
        debugPrint('Logout backend call failed (ignored): $e');
      }
    }

    // delete local tokens
    await _deleteAccessToken();
    await _storage.delete(key: 'refresh_token');
    final userId = await getUserId();
    final parsedUserId = userId != null ? int.tryParse(userId) : null;
    if (parsedUserId != null) {
      await _authDao.clearProfile(parsedUserId);
    }
    await _storage.delete(key: 'userId');

    // reinit _cachedUserId;
    _cachedUserId = null;

    return null;
  }
}
