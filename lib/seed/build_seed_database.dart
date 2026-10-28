import 'dart:convert';
import 'dart:io' as io;

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/seed/download_unclosed_passports.dart';

/// Summary written beside the bundled seed asset during release builds.
class SeedDatabaseManifest {
  /// Creates manifest metadata for a generated seed file.
  const SeedDatabaseManifest({
    required this.generatedAt,
    required this.platformCount,
    required this.alertCount,
    required this.schemaVersion,
    required this.gatewayBaseUrl,
  });

  /// UTC timestamp when the seed was produced.
  final DateTime generatedAt;

  /// Number of platform rows in the seed.
  final int platformCount;

  /// Number of alert rows in the seed.
  final int alertCount;

  /// Drift schema version embedded in the seed.
  final int schemaVersion;

  /// Gateway base URL used for the export.
  final String gatewayBaseUrl;

  /// Serializes manifest fields for `seed.manifest.json`.
  Map<String, Object?> toJson() => {
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'platformCount': platformCount,
    'alertCount': alertCount,
    'schemaVersion': schemaVersion,
    'gatewayBaseUrl': gatewayBaseUrl,
  };
}

/// Builds a SQLite seed file compatible with [AppDatabase].
Future<SeedDatabaseManifest> buildSeedDatabase({
  required String outputDirectory,
  bool schemaOnly = false,
}) async {
  final directory = io.Directory(outputDirectory);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final dbPath = p.join(outputDirectory, 'seed.sqlite');
  final manifestPath = p.join(outputDirectory, 'seed.manifest.json');
  final dbFile = io.File(dbPath);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  final generatedAt = DateTime.now().toUtc();
  final gatewayBaseUrl = io.Platform.environment['SMART_TAGS_GATEWAY_BASE_URL'] ?? GatewayConfig.baseUrl;

  final database = AppDatabase.executor(NativeDatabase.createInBackground(dbFile));
  try {
    if (schemaOnly) {
      await database.isEmpty();
    } else {
      final result = await downloadUnclosedPassports();
      await database.syncPlatforms(result.platforms);
      await database.upsertAlerts(result.alerts);
      await database.deleteOrphanedAlerts();
      await database.setLastPlatformsRefresh(generatedAt);

      final manifest = SeedDatabaseManifest(
        generatedAt: generatedAt,
        platformCount: result.platforms.length,
        alertCount: result.alerts.length,
        schemaVersion: database.schemaVersion,
        gatewayBaseUrl: gatewayBaseUrl,
      );
      await io.File(manifestPath).writeAsString(jsonEncode(manifest.toJson()));
      return manifest;
    }

    final manifest = SeedDatabaseManifest(
      generatedAt: generatedAt,
      platformCount: 0,
      alertCount: 0,
      schemaVersion: database.schemaVersion,
      gatewayBaseUrl: gatewayBaseUrl,
    );
    await io.File(manifestPath).writeAsString(jsonEncode(manifest.toJson()));
    return manifest;
  } finally {
    await database.close();
  }
}
