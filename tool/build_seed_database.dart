import 'dart:io';

import 'package:smart_tags/seed/build_seed_database.dart';
import 'package:smart_tags/seed/seed_database_paths.dart';

Future<void> main(List<String> arguments) async {
  final schemaOnly = arguments.contains('--schema-only');
  final outputDirectory = _readOutputDirectory(arguments) ?? SeedDatabasePaths.outputDirectory;

  stderr.writeln(
    schemaOnly
        ? 'Building schema-only seed at $outputDirectory …'
        : 'Downloading unclosed missions and building seed at $outputDirectory …',
  );

  final manifest = await buildSeedDatabase(
    outputDirectory: outputDirectory,
    schemaOnly: schemaOnly,
  );

  final dbFile = File('$outputDirectory/seed.sqlite');
  stderr.writeln(
    'Seed ready: ${dbFile.path} '
    '(${await dbFile.length()} bytes, '
    '${manifest.platformCount} platforms, '
    '${manifest.alertCount} alerts, '
    'schema v${manifest.schemaVersion}).',
  );
}

String? _readOutputDirectory(List<String> arguments) {
  for (var index = 0; index < arguments.length - 1; index++) {
    if (arguments[index] == '--output') {
      return arguments[index + 1];
    }
  }
  return null;
}
