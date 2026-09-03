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

  /// CT-RST platform status (e.g. OPERATIONAL, INACTIVE).
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

  /// Additional notes about the latest operation (optional).
  TextColumn get operationNotes => text().nullable()();

  /// Platform category from passport (e.g. Float, Drifting buoy).
  TextColumn get platformCategory => text().nullable()();

  /// Passport reporting status for display chips (#97).
  TextColumn get reportingStatus => text().nullable()();

  /// Observing network names from passport affiliation (#97).
  TextColumn get observingNetwork => text().nullable()();

  /// Latest operation type: Deployment or Recovery (#99).
  TextColumn get latestOperationType => text().nullable()();

  /// Latest operation date from passport (#99).
  DateTimeColumn get latestOperationDate => dateTime().nullable()();

  /// Passport ending cause id for recovery status (#100).
  IntColumn get endingCauseId => integer().nullable()();

  /// Whether passport includes a GTS latest observation (#100).
  BoolColumn get hasLatestObservation =>
      boolean().withDefault(const Constant(false))();
}

/// The local SQLite database using Drift ORM.
@DriftDatabase(tables: [Platforms])
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] instance for production use.
  AppDatabase() : super(openConnection());

  /// Creates an [AppDatabase] instance with a custom executor (for testing).
  AppDatabase.executor(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(platforms, platforms.platformCategory);
        await m.addColumn(platforms, platforms.reportingStatus);
        await m.addColumn(platforms, platforms.observingNetwork);
        await m.addColumn(platforms, platforms.latestOperationType);
        await m.addColumn(platforms, platforms.latestOperationDate);
      }
      if (from < 3) {
        await m.addColumn(platforms, platforms.endingCauseId);
        await m.addColumn(platforms, platforms.hasLatestObservation);
      }
    },
  );

  /// Returns true when no platform rows exist locally.
  Future<bool> isEmpty() async {
    final rows = await (select(platforms)..limit(1)).get();
    return rows.isEmpty;
  }

  /// Inserts a list of platforms. Fails if any already exist.
  Future<void> insertPlatforms(List<PlatformsCompanion> companions) async {
    await batch((batch) {
      batch.insertAll(platforms, companions);
    });
  }

  /// Updates a list of platforms based on their ref.
  Future<void> updatePlatforms(List<PlatformsCompanion> companions) async {
    await batch((batch) {
      for (final companion in companions) {
        batch.update(platforms, companion, where: (tbl) => tbl.ref.equals(companion.ref.value));
      }
    });
  }

  /// Helper to sync platforms to database.
  /// Currently empties and re-inserts, but could be optimized to do upserts in the future.
  Future<void> syncPlatforms(List<PlatformsCompanion> companions) async {
    await transaction(() async {
      await delete(platforms).go();
      await batch((batch) {
        batch.insertAll(platforms, companions);
      });
    });
  }

  /// Watches all platforms, optionally filtered by a search query.
  Stream<List<Platform>> watchPlatforms({String? query}) {
    final queryBuilder = select(platforms);

    if (query != null && query.isNotEmpty) {
      queryBuilder.where((tbl) {
        final likeQuery = '%${query.toLowerCase()}%';
        return tbl.ref.lower().like(likeQuery) | tbl.model.lower().like(likeQuery);
      });
    }

    return queryBuilder.watch();
  }

  /// Helper function to select a specific platform by its reference. Returns a list
  Future<List<Platform>> getPlatformByRef(String ref) {
    return (select(platforms)..where((p) => p.ref.equals(ref))).get();
  }

  /// Watches a single platform by its reference, emitting updates on changes.
  Stream<Platform?> watchPlatformByRef(String ref) {
    return (select(platforms)..where((p) => p.ref.equals(ref)))
        .watchSingleOrNull();
  }
}
