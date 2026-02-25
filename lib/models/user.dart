/// A dataclass representing a user's profile.
///
/// Contains the user's unique identifier, full name, and email address.
class UserProfile {
  /// Creates a [UserProfile].
  ///
  /// All fields are required and must be non-null.
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
  });

  /// Deserialises JSON response from API into a [UserProfile] object
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'id': final int id,
      'fullName': final String fullName,
      'email': final String email,
      } => UserProfile(
        id: id,
        fullName: fullName,
        email: email,
      ),
      _ => throw const FormatException('Failed to create user.'),
    };
  }


  /// The user's unique numeric identifier.
  final int id;

  /// The user's full display name.
  final String fullName;

  /// The user's primary email address.
  final String email;
}
