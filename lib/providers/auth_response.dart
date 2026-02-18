import 'package:smart_tags/models/user.dart';

/// A dataclass representing an authentication response from OceanOps.
///
/// Contains the user's unique identifier, full name, and email address.
class AuthResponse {
  /// The user's unique numeric identifier.
  final bool success;

  /// The user's full display name.
  final String accessTokenRs256;

  /// The user's primary email address.
  final String refreshToken;

  final int refreshExpiresIn;

  final int expiresIn;

  final UserProfile contact;

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


  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'success': final bool success,
        'access_token_rs256': final String accessTokenRs256,
        'refresh_token': final String refreshToken,
        'refresh_expires_in': final int refreshExpiresIn,
        'expires_in': final int expiresIn,
        'contact': final UserProfile contact,
      } => AuthResponse(
          success: success,
          accessTokenRs256: accessTokenRs256,
          refreshToken: refreshToken,
          refreshExpiresIn: refreshExpiresIn,
          expiresIn: expiresIn,
          contact: contact,
      ),
      _ => throw const FormatException('Failed to read auth response.'),
    };
  }
}
