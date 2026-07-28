/// Base class for simple id/name/code API objects.
abstract class ApiObject {
  /// Creates an [ApiObject]
  const ApiObject({
    required this.id,
    required this.name,
    required this.code,
  });

  /// The objects's unique numeric identifier.
  final int id;
  /// The objects's display name.
  final String name;
  /// The object's unique lowercase, hyphenated identifier (e.g. "argo-australia")
  final String code;

  /// Shared JSON validation/parsing helper.
  static ({int id, String name, String code}) parseJson(
      Map<String, dynamic> json,
      ) {
    return switch (json) {
      {
      'id': final int id,
      'name': final String name,
      'code': final String code,
      } =>
      (id: id, name: name, code: code),
      _ => throw const FormatException('Failed to parse ApiObject.'),
    };
  }

  /// Shared JSON encoding helper.
  Map<String, dynamic> toJsonFields() => {
    'id': id,
    'name': name,
    'code': code,
  };
}
