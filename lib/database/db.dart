import 'package:drift/drift.dart';
import 'package:smart_tags/database/daos/auth_dao.dart';
import 'package:smart_tags/database/db_connection.dart';

part 'db.g.dart';

/// Table definition for platforms metadata.
@TableIndex(name: 'idx_platforms_ref', columns: {#ref}, unique: true)
class Platforms extends Table {
  /// Primary key identifying the record.
  IntColumn get id => integer().autoIncrement()();

  /// External reference (ID) e.g., PLT-12345.
  TextColumn get ref => text().withLength(min: 1, max: 255)();

  /// Model name of the platform.
  TextColumn get model => text()();

  /// Category name of the platform
  TextColumn get category => text()();

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

  /// Platform's name.
  TextColumn get name => text().nullable()();

  /// Oceanops Pltaform internal Id (operator's/ program's id for the platform).
  TextColumn get internalId => text().nullable()();

  /// OceanTags QR code reference for the physical platform.
  TextColumn get qrCode => text().nullable()();

  /// WIGOS identifier (optional).
  TextColumn get wigosId => text().nullable()();

  /// GTS identifier (optional).
  TextColumn get gtsId => text().nullable()();

  /// Batch reference (optional).
  TextColumn get batchRef => text().nullable()();

  /// Additional notes about the latest operation (optional).
  TextColumn get operationNotes => text().nullable()();

  /// Platform serial number.
  TextColumn get serial => text().nullable()();

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
  BoolColumn get hasLatestObservation => boolean().withDefault(const Constant(false))();

  /// The Gateway/OceanOPS platform identifier (`ptfId` in the enriched
  /// passport API), distinct from [ref]. Required to submit deploy/recover
  /// passport events to the Gateway.
  TextColumn get ptfId => text().nullable()();

  /// Supervising program identifier from the passport's
  /// `affiliation.supervisingProgram` (optional). Needed for permission
  /// checks (e.g. `canEdit(Resource.deployment, programId: ...)`).
  IntColumn get programId => integer().nullable()();

  /// Supervising program display name (optional).
  TextColumn get programName => text().nullable()();

  /// Supervising program slug (optional).
  TextColumn get programCode => text().nullable()();
}

@DataClassName('AlertEntity')
/// Table definition for alerts linked to platform
class Alerts extends Table {
  /// the alert id (unique identifier on Notification Center / Alerta side)
  TextColumn get id => text()();

  /// the alert resource identifier (= platform ref attribute)
  TextColumn get resource => text().references(Platforms, #ref)();

  /// Alert's event name
  TextColumn get event => text()();

  /// Alerts's severity
  TextColumn get severity => text()();

  /// Alerts's status
  TextColumn get status => text()();

  /// Alert's value (e.g. "12%"), as sent by Alerta
  TextColumn get value => text().nullable()();

  /// When the alert was first created
  DateTimeColumn get createTime => dateTime().nullable()();

  /// When the alert was last received
  DateTimeColumn get lastReceiveTime => dateTime().nullable()();

  /// Alerts's event description
  TextColumn get description => text()();

  /// Alerts's "more info" url
  TextColumn get url => text().nullable()();

  /// Alerts's service origin
  TextColumn get service => text()();

  /// Alerts's service origin
  TextColumn get origin => text().nullable()();

  /// Alerts's previous severity
  TextColumn get previousSeverity => text()();

  /// Alerts's duplicate count
  IntColumn get duplicateCount => integer()();

  /// Alerts's category
  TextColumn get alertCategory => text()();

  /// Alerts's category
  TextColumn get country => text()();

  /// Alerts last note
  TextColumn get lastNote => text().nullable()();

  /// Alert's free-form attributes (e.g. `Country`, `wigos_id`, `url`), whose
  /// keys vary per alert source. Stored as raw JSON rather than dedicated
  /// columns since the shape isn't fixed.
  TextColumn get attributes => text().nullable().map(
    NullAwareTypeConverter.wrap(
      TypeConverter.json2<Map<String, dynamic>>(fromJson: (json) => json! as Map<String, dynamic>),
    ),
  )();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AlertNoteEntity')
/// Table definition for alerts linked to platform
class AlertsNote extends Table {
  /// the alert id (unique identifier on Notification Center / Alerta side)
  TextColumn get id => text()();

  /// Note's content text
  TextColumn get note => text()();
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

/// FIFO queue of deploy/recover passport events awaiting submission to the
/// Gateway (used when the device is offline or a submission attempt fails).
class PendingOperations extends Table {
  /// Primary key identifying the record; the natural FIFO ordering key.
  IntColumn get id => integer().autoIncrement()();

  /// The platform this event is for (`Platform.platformRef`).
  TextColumn get platformRef => text()();

  /// The type of operation: 'deploy' or 'recover'.
  TextColumn get action => text()();

  /// The exact Gateway JSON request body, stored verbatim so replay never
  /// needs to rebuild it from form state.
  TextColumn get payloadJson => text()();

  /// When this event was queued.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 'pending' (awaiting/replay-eligible) or 'failed' (needs manual retry).
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// The error message from the most recent failed attempt, if any.
  TextColumn get lastError => text().nullable()();

  /// Number of submission attempts made so far.
  IntColumn get attempts => integer().withDefault(const Constant(0))();
}

/// Recent catalogue opens keyed by platform [platformRef] (#143).
///
/// Stored when the user opens platform detail from a catalogue result card
/// (not on each keystroke). [platformModel] is a snapshot for the autosuggest
/// label when the local platform row is unavailable.
class CatalogueSearchHistories extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Platform reference used for catalogue search (matches [Platforms.ref]).
  TextColumn get platformRef => text().withLength(min: 1, max: 255)();

  /// Model name at the time the user opened the platform from search.
  TextColumn get platformModel => text().nullable()();

  /// WIGOS / passport id snapshot ([Platforms.wigosId]) for autosuggest labels.
  TextColumn get wigosId => text().nullable()();

  /// When the user last opened this platform from catalogue search.
  DateTimeColumn get searchedAt => dateTime()();
}

/// Single-row table storing small pieces of app-level sync metadata
/// (currently just the last successful platforms refresh timestamp, used as
/// the `updatedSince` filter for the next delta search).
class SyncMetadata extends Table {
  /// Fixed row id — this table only ever holds a single row (`1`).
  IntColumn get id => integer()();

  /// Timestamp of the last successful platforms refresh (pull-to-refresh).
  DateTimeColumn get lastPlatformsRefresh => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The local SQLite database using Drift ORM.
@DriftDatabase(
  tables: [
    Platforms,
    Alerts,
    UserProfiles,
    Programs,
    Roles,
    UserProgramRoles,
    UserRoles,
    PendingOperations,
    SyncMetadata,
    CatalogueSearchHistories,
  ],
  daos: [AuthDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] instance for production use.
  AppDatabase() : super(openConnection());

  /// Creates an [AppDatabase] instance with a custom executor (for testing).
  AppDatabase.executor(super.e);

  @override
  int get schemaVersion => 1;

  // TODO(ylubac): Once the app's first version has been published, schema
  // changes will need a real onUpgrade migration strategy (bumping
  // schemaVersion and migrating step by step). Until then, devs just
  // uninstall/reinstall the app, so onCreate is enough.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    // onUpgrade: (Migrator m, int from, int to) async {
    //   if (from < 2) {
    //     // here migrations inscructions
    //     // await m.addColumn(platforms, platforms.platformCategory);
    //   }
    // },
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

  /// Inserts or replaces the given platforms (matched by `ref`), without
  /// touching local platforms absent from [companions]. Used by the
  /// delta refresh (`updatedSince`). Requires the unique index on
  /// `platforms.ref`.
  Future<void> upsertPlatforms(List<PlatformsCompanion> companions) async {
    await batch((batch) {
      batch.insertAll(platforms, companions, mode: InsertMode.insertOrReplace);
    });
  }

  /// Helper to sync alerts to database.
  /// Currently empties and re-inserts, but could be optimized to do upserts in the future.
  Future<void> syncAlerts(List<AlertsCompanion> companions) async {
    await transaction(() async {
      await delete(alerts).go();
      await batch((batch) {
        batch.insertAll(alerts, companions);
      });
    });
  }

  /// Inserts or replaces the given alerts (matched by `id`), without
  /// touching local alerts absent from [companions]. Used by the
  /// delta refresh (`updatedSince`).
  Future<void> upsertAlerts(List<AlertsCompanion> companions) async {
    await batch((batch) {
      batch.insertAll(alerts, companions, mode: InsertMode.insertOrReplace);
    });
  }

  /// Deletes alerts whose `resource` doesn't match any local platform `ref`
  /// (e.g. alerts for platforms outside the fetched scope, or removed
  /// server-side). Cheap: indexed anti-join on `platforms.ref`. Should be
  /// called after syncing/upserting both platforms and alerts.
  Future<void> deleteOrphanedAlerts() async {
    await customStatement(
      'DELETE FROM alerts WHERE resource NOT IN (SELECT ref FROM platforms)',
    );
  }

  /// Returns the timestamp of the last successful platforms refresh, or
  /// `null` if a refresh has never completed successfully.
  Future<DateTime?> getLastPlatformsRefresh() async {
    final row = await (select(
      syncMetadata,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.lastPlatformsRefresh;
  }

  /// Persists [when] as the last successful platforms refresh timestamp.
  Future<void> setLastPlatformsRefresh(DateTime when) async {
    await into(syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion.insert(
        id: const Value(1),
        lastPlatformsRefresh: Value(when),
      ),
    );
  }

  /// Maximum catalogue search history rows kept locally (#143).
  static const int catalogueSearchHistoryLimit = 15;

  /// Records that the user opened [platformRef] from catalogue search (#143).
  Future<void> recordCatalogueSearchEntry({
    required String platformRef,
    String? platformModel,
    String? wigosId,
  }) async {
    final now = DateTime.now().toUtc();
    await transaction(() async {
      await (delete(catalogueSearchHistories)..where((t) => t.platformRef.equals(platformRef))).go();
      await into(catalogueSearchHistories).insert(
        CatalogueSearchHistoriesCompanion.insert(
          platformRef: platformRef,
          platformModel: Value(platformModel),
          wigosId: Value(wigosId),
          searchedAt: now,
        ),
      );

      final rows = await (select(catalogueSearchHistories)..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])).get();
      if (rows.length > catalogueSearchHistoryLimit) {
        final excess = rows.sublist(catalogueSearchHistoryLimit);
        for (final row in excess) {
          await (delete(catalogueSearchHistories)..where((t) => t.id.equals(row.id))).go();
        }
      }
    });
  }

  /// Removes all catalogue search history rows (#143).
  Future<void> clearCatalogueSearchHistory() {
    return delete(catalogueSearchHistories).go();
  }

  /// Recent catalogue search entries, newest first (#143).
  Stream<List<CatalogueSearchHistory>> watchCatalogueSearchHistory() {
    return (select(catalogueSearchHistories)
          ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
          ..limit(catalogueSearchHistoryLimit))
        .watch();
  }

  /// Watches all platforms, optionally filtered by a search query.
  Stream<List<Platform>> watchPlatforms({String? query}) {
    final queryBuilder = select(platforms);

    if (query != null && query.isNotEmpty) {
      queryBuilder.where((tbl) {
        final likeQuery = '${query.toLowerCase()}%';
        return tbl.ref.lower().like(likeQuery) |
            tbl.model.lower().like(likeQuery) |
            tbl.wigosId.lower().like(likeQuery);
      });
    }

    return queryBuilder.watch();
  }

  /// Helper function to select a specific platform by its reference. Returns a list
  Future<List<Platform>> getPlatformByRef(String ref) {
    return (select(platforms)..where((p) => p.ref.equals(ref))).get();
  }

  /// Returns every passport/deployment stored for the physical platform
  /// identified by [qrCode].
  Future<List<Platform>> getPlatformsByQrCode(String qrCode) {
    return (select(platforms)..where((p) => p.qrCode.equals(qrCode))).get();
  }

  /// Returns alerts associated with every passport/deployment belonging to
  /// the physical platform identified by [qrCode].
  Future<List<AlertEntity>> getAlertsByQrCode(String qrCode) {
    final query = select(alerts).join([
      innerJoin(platforms, platforms.ref.equalsExp(alerts.resource)),
    ])..where(platforms.qrCode.equals(qrCode));

    return query.map((row) => row.readTable(alerts)).get();
  }

  /// Watches a single platform by its reference, emitting updates on changes.
  Stream<Platform?> watchPlatformByRef(String ref) {
    return (select(platforms)..where((p) => p.ref.equals(ref))).watchSingleOrNull();
  }

  /// Watches all alerts raised against the given platform resource (ref),
  /// emitting updates on changes.
  Stream<List<AlertEntity>> watchAlertsByResource(String resource) {
    return (select(alerts)..where((a) => a.resource.equals(resource))).watch();
  }

  /// Watches a single alert by its id, emitting updates on changes.
  Stream<AlertEntity?> watchAlertById(String id) {
    return (select(alerts)..where((a) => a.id.equals(id))).watchSingleOrNull();
  }

  /// Sets the local `status` of the alert [id] (e.g. after an action was
  /// applied or queued while offline).
  /// Mirrors Alerta's severity handling: closing an alert resets its severity
  /// to `normal` (remembering the old one in `previousSeverity`), and
  /// re-opening a closed alert restores that previous severity.
  Future<void> updateAlertStatus(String id, String status) {
    return transaction(() async {
      final current = await (select(alerts)..where((a) => a.id.equals(id))).getSingleOrNull();
      if (current == null) {
        return;
      }

      var severity = current.severity;
      var previousSeverity = current.previousSeverity;
      if (status == 'closed' && current.status != 'closed' && severity != 'normal') {
        previousSeverity = severity;
        severity = 'normal';
      } else if (status == 'open' && current.status == 'closed') {
        severity = previousSeverity;
        previousSeverity = 'normal';
      }

      await (update(alerts)..where((a) => a.id.equals(id))).write(
        AlertsCompanion(status: Value(status), severity: Value(severity), previousSeverity: Value(previousSeverity)),
      );
    });
  }

  /// Sets the local `lastNote` of the alert [id].
  Future<void> updateAlertLastNote(String id, String? lastNote) {
    return (update(alerts)..where((a) => a.id.equals(id))).write(AlertsCompanion(lastNote: Value(lastNote)));
  }

  /// Watches every alert across all resources in a single subscription.
  ///
  /// Used to derive per-resource data (e.g. counts) for many platforms at
  /// once without opening one DB stream per resource.
  Stream<List<AlertEntity>> watchAllAlerts() {
    return select(alerts).watch();
  }

  /// Appends a new deploy/recover event to the FIFO queue.
  Future<int> enqueuePendingOperation(PendingOperationsCompanion companion) =>
      into(pendingOperations).insert(companion);

  /// Watches all queued events (pending + failed), oldest first.
  Stream<List<PendingOperation>> watchPendingOperations() =>
      (select(pendingOperations)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  /// One-shot FIFO fetch of all queued events, used by the replay loop.
  Future<List<PendingOperation>> getPendingOperationsOrdered() =>
      (select(pendingOperations)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  /// Fetches a single queued event by id.
  Future<PendingOperation?> getPendingOperationById(int id) =>
      (select(pendingOperations)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Removes a queued event once it has been sent successfully.
  Future<void> deletePendingOperation(int id) => (delete(pendingOperations)..where((t) => t.id.equals(id))).go();

  /// Marks a queued event as failed, recording the error and attempt count.
  Future<void> markPendingOperationFailed(int id, {required String error, required int attempts}) =>
      (update(pendingOperations)..where((t) => t.id.equals(id))).write(
        PendingOperationsCompanion(
          status: const Value('failed'),
          lastError: Value(error),
          attempts: Value(attempts),
        ),
      );
}
