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

  /// The user's unique numeric identifier.
  final int id;

  /// The user's full display name.
  final String fullName;

  /// The user's primary email address.
  final String email;
}
