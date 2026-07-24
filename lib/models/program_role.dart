import 'package:smart_tags/models/program.dart';
import 'package:smart_tags/models/role.dart';

/// Dataclass representing a user's role in a specific program.
class ProgramRole {
  /// Creates a [ProgramRole].
  const ProgramRole({
    required this.program,
    required this.role,
  });

  /// Deserialises JSON response from API into a [ProgramRole] object
  factory ProgramRole.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'program': final Map<String, dynamic> program,
      'role': final Map<String, dynamic> role,
      } =>
          ProgramRole(
            program: Program.fromJson(program),
            role: Role.fromJson(role),
          ),
      _ => throw const FormatException('Failed to create ProgramRole.'),
    };
  }

  /// The program this role assignment applies to.
  final Program program;
  /// The role assigned to the user for [program].
  final Role role;
}