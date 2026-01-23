import 'package:drift/drift.dart';
import 'package:smart_tags/database/db_connection.dart';

part 'db.g.dart';

/// Table definition for platforms metadata.
class Platforms extends Table {
  /// Primary key identifying the record.
  IntColumn get id => integer().autoIncrement()();

  /// External reference (ID) e.g., PLT-12345.
  TextColumn get ref => text().withLength(min: 1, max: 255)();

  /// Model name of the platform.
  TextColumn get model => text()();

  /// Network name (e.g., Argo, DBCP).
  TextColumn get network => text()();

  /// Latest reported latitude.
  RealColumn get lat => real()();

  /// Latest reported longitude.
  RealColumn get lon => real()();

  /// Status string (Active/Inactive).
  TextColumn get status => text()();

  /// Operational status (Deployed/Recovered).
  TextColumn get operationalStatus => text()();

  /// Last update timestamp.
  DateTimeColumn get lastUpdated => dateTime()();

  /// Latitude of the last operation.
  RealColumn get operationLat => real()();

  /// Longitude of the last operation.
  RealColumn get operationLon => real()();

  /// WIGOS identifier (optional).
  TextColumn get wigosId => text().nullable()();

  /// GTS identifier (optional).
  TextColumn get gtsId => text().nullable()();

  /// Batch reference (optional).
  TextColumn get batchRef => text().nullable()();
}

/// The local SQLite database using Drift ORM.
@DriftDatabase(tables: [Platforms])
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] instance for production use.
  AppDatabase() : super(openConnection());

  /// Creates an [AppDatabase] instance with a custom executor (for testing).
  AppDatabase.executor(super.e);

  @override
  int get schemaVersion => 1;

  /// Inserts a list of platforms. Fails if any already exist.
  Future<void> insertPlatforms(List<PlatformsCompanion> companions) async {
    await batch((batch) {
      batch.insertAll(platforms, companions);
    });
  }

  /// Updates a list of platforms based on their primary keys.
  Future<void> updatePlatforms(List<PlatformsCompanion> companions) async {
    await batch((batch) {
      for (final companion in companions) {
        batch.update(platforms, companion);
      }
    });
  }

  /// Helper to handle both (upsert) if needed by the sync service.
  Future<void> syncPlatforms(List<PlatformsCompanion> companions) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(platforms, companions);
    });
  }
}
