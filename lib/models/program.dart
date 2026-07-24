import 'package:smart_tags/models/api_object.dart';

/// Dataclass representing a program of operations.
class Program extends ApiObject {
  /// Creates a [Program]
  const Program({
    required super.id,
    required super.name,
    required super.code,
  });

  /// Deserialises JSON response from API into a [Program] object
  factory Program.fromJson(Map<String, dynamic> json) {
    final r = ApiObject.parseJson(json);
    return Program(id: r.id, name: r.name, code: r.code);
  }
}
