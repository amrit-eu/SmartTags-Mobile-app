import 'package:drift/drift.dart';
import 'package:smart_tags/database/daos/auth_dao.dart';
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
}

@DataClassName('UserEntity')
/// Table definition for user profile data.
class UserProfiles extends Table {
  /// Primary key identifying the record.
  IntColumn get id => integer()();
  /// External reference (ID) from server.
  IntColumn get ref => integer()();
  /// User's primary email.
  TextColumn get email => text()();
  /// User's secondary email.
  TextColumn get email2 => text().nullable()();
  /// User's full name.
  TextColumn get fullName => text()();
  /// User's first name.
  TextColumn get firstName => text()();
  /// User's last name.
  TextColumn get lastName => text()();
  /// User's title.
  TextColumn get title => text()();
  /// User's ORCID.
  TextColumn get orcid => text()();
  /// User's primary phone number.
  TextColumn get tel => text()();
  /// User's secondary phone number.
  TextColumn get tel2 => text()();
  /// User's postal address
  TextColumn get address => text()();
  /// User's country.
  TextColumn get country => text().nullable()();
  /// Whether user's contact information should be hidden.
  BoolColumn get hideContactInfoFromPublic => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProgramEntity')
/// Table definition for programs associated with a user's permissions.
class Programs extends Table {
  /// Program reference
  IntColumn get id => integer()();
  /// Program display name
  TextColumn get name => text()();
  /// Program slug
  TextColumn get code => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoleEntity')
/// Table definition for roles associated with a user's permissions to a program.
class Roles extends Table {
  /// Role reference
  IntColumn get id => integer()();
  /// Role display name
  TextColumn get name => text()();
  /// Role slug
  TextColumn get code => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table definition to link users to their program roles
class UserProgramRoles extends Table {
  /// User identifier (foreign key)
  IntColumn get userId => integer().references(UserProfiles, #id)();
  /// Program identifier (foreign key)
  IntColumn get programId => integer().references(Programs, #id)();
  /// Role identifier (foreign key)
  IntColumn get roleId => integer().references(Roles, #id)();

  @override
  Set<Column> get primaryKey => {userId, programId, roleId};
}

/// Table to link user to global roles, e.g. "alert_editor"
class UserRoles extends Table {
  /// User identifier (foreign key)
  IntColumn get userId => integer().references(UserProfiles, #id)();
  /// Role code, e.g. "alert_editor"
  TextColumn get roleCode => text()();

  @override
  Set<Column> get primaryKey => {userId, roleCode};
}

/// The local SQLite database using Drift ORM.
@DriftDatabase(
  tables: [Platforms, UserProfiles, Programs, Roles, UserProgramRoles, UserRoles],
  daos: [AuthDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] instance for production use.
  AppDatabase() : super(openConnection());

  /// Creates an [AppDatabase] instance with a custom executor (for testing).
  AppDatabase.executor(super.e);

  @override
  int get schemaVersion => 2;

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
