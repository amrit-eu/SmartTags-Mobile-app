import 'package:smart_tags/models/api_object.dart';

/// Dataclass representing a user role for authorisation.
class Role extends ApiObject {
  /// Creates a [Role]
  const Role({
    required super.id,
    required super.name,
    required super.code,
  });

  /// Deserialises JSON response from API into a [Role] object
  factory Role.fromJson(Map<String, dynamic> json) {
    final r = ApiObject.parseJson(json);
    return Role(id: r.id, name: r.name, code: r.code);
  }

  Map<String, dynamic> toJson() => toJsonFields();
}
