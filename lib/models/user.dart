import 'package:smart_tags/models/country.dart';
import 'package:smart_tags/models/program_role.dart';

/// A dataclass representing a user's profile.
class User {
  /// Creates a [User].
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.orcid,
    required this.tel,
    required this.tel2,
    required this.address,
    required this.hideContactInfoFromPublic,
    required this.roles,
    required this.programRoles,
    this.email2,
    this.country,
  });

  /// Deserialises JSON response from API into a [User] object
  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final int id,
        'email': final String email,
        'email2': final String? email2,
        'fullName': final String fullName,
        'firstName': final String firstName,
        'lastName': final String lastName,
        'title': final String title,
        'orcid': final String orcid,
        'tel': final String tel,
        'tel2': final String tel2,
        'address': final String address,
        'hideContactInfoFromPublic': final bool hideContactInfoFromPublic,
        'country': final Map<String, dynamic>? countryJson,
        'roles': final List<dynamic> roles,
        'programRoles': final List<dynamic> programRoles,
      } =>
        User(
          id: id,
          fullName: fullName,
          email: email,
          email2: email2,
          firstName: firstName,
          lastName: lastName,
          title: title,
          orcid: orcid,
          tel: tel,
          tel2: tel2,
          address: address,
          hideContactInfoFromPublic: hideContactInfoFromPublic,
          country: countryJson != null ? Country.fromJson(countryJson) : null,
          roles: roles.cast<String>(),
          programRoles: programRoles.cast<Map<String, dynamic>>().map(ProgramRole.fromJson).toList(),
        ),
      _ => throw const FormatException('Failed to create user profile.'),
    };
  }

  /// The user's unique numeric identifier.
  final int id;

  /// The user's full display name.
  final String fullName;

  /// The user's primary email address.
  final String email;

  /// The user's secondary email address, if provided.
  final String? email2;

  /// The user's first name.
  final String firstName;

  /// The user's last name.
  final String lastName;

  /// The user's professional or academic title.
  final String title;

  /// The user's ORCID identifier.
  final String orcid;

  /// The user's primary telephone number.
  final String tel;

  /// The user's secondary telephone number.
  final String tel2;

  /// The user's postal address.
  final String address;

  /// Whether the user's contact info is hidden from public view.
  final bool hideContactInfoFromPublic;

  /// The user's country, if provided.
  final Country? country;

  /// The user's global role identifiers.
  final List<String> roles;

  /// The programs and associated roles assigned to the user.
  final List<ProgramRole> programRoles;
}

/// A dataclass representing a user JWT's claims.
class TokenClaims {
  /// Creates a [TokenClaims] object.
  const TokenClaims({
    required this.contactId,
    required this.name,
    required this.sub,
    required this.roles,
    required this.exp,
  });

  /// Deserialises JSON response from API into a [TokenClaims] object
  factory TokenClaims.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'contactId': final int contactId,
        'name': final String name,
        'sub': final String sub,
        'roles': final List<String> roles,
        'exp': final int exp,
      } =>
        TokenClaims(
          contactId: contactId,
          name: name,
          sub: sub,
          roles: roles,
          exp: exp,
        ),
      _ => throw const FormatException('Failed to create JWT claims.'),
    };
  }

  /// The user's unique numeric identifier.
  final int contactId;

  /// The user's full display name.
  final String name;

  /// The user's primary email address.
  final String sub;

  /// List of the user's general app roles
  final List<String> roles;

  /// Token expiry timestamp
  final int exp;
}
