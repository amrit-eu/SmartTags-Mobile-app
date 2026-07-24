import 'package:smart_tags/models/user.dart';

/// A dataclass representing an authentication response from OceanOps.
///
/// Contains the user's unique identifier, full name, and email address.
class AuthResponse {
  /// Creates an [AuthResponse].
  ///
  /// All fields are required and must be non-null.
  const AuthResponse({
    required this.success,
    required this.accessTokenRs256,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.expiresIn,
    required this.contact,
  });

  /// Deserialises JSON response from API into an [AuthResponse] object
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'success': final bool success,
      'access_token_rs256': final String accessTokenRs256,
      'refresh_token': final String refreshToken,
      'refresh_expires_in': final int refreshExpiresIn,
      'expires_in': final int expiresIn,
      'contact': final Map<String, dynamic> contact,
      } => AuthResponse(
        success: success,
        accessTokenRs256: accessTokenRs256,
        refreshToken: refreshToken,
        refreshExpiresIn: refreshExpiresIn,
        expiresIn: expiresIn,
        contact: User.fromJson(contact),
      ),
      _ => throw const FormatException('Failed to read auth response.'),
    };
  }

  /// Success status of authentication
  final bool success;

  /// JWT session token returned from API
  final String accessTokenRs256;

  /// Refresh token to renew session JWT
  final String refreshToken;

  /// Seconds until expiry of refresh token (default: 864000 = 7 days)
  final int refreshExpiresIn;

  /// Seconds until expiry of session token (default: 3600 = 1 hour)
  final int expiresIn;

  /// [User] object containing information about the contact user
  final User contact;
}
