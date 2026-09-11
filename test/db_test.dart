import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;

void main() {
  group('Database Verification Tests', () {
    test('Test .sqlite file exists after init', () async {
      // This test specifically checks native file creation
      if (const bool.fromEnvironment('dart.library.io')) {
        final tempDir = Directory.systemTemp.createTempSync();
        final dbFile = File(p.join(tempDir.path, 'test_db.sqlite'));

        final db = AppDatabase.executor(NativeDatabase(dbFile));

        // Trigger a query to initialize the database
        await db.select(db.platforms).get();
        await db.close();

        expect(dbFile.existsSync(), isTrue, reason: 'Database file should be created');

        // Cleanup
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });

    test('isEmpty returns true for a new database', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());
      expect(await db.isEmpty(), isTrue);
      await db.close();
    });

    test('Test content can be added to the DB', () async {
      // Use platform-aware in-memory database
      final db = AppDatabase.executor(conn.inMemoryConnection());

      final now = DateTime.now();
      await db
          .into(db.platforms)
          .insert(
            PlatformsCompanion.insert(
              ref: 'PLT-TEST-001',
              model: 'Test Sensor',
              network: 'TestNet',
              lat: 10,
              lon: 20,
              status: 'OPERATIONAL',
              operationalStatus: 'Deployed',
              lastUpdated: now,
              operationLat: 10,
              operationLon: 20,
            ),
          );

      final platforms = await db.select(db.platforms).get();

      expect(platforms.length, 1);
      expect(platforms.first.ref, 'PLT-TEST-001');
      expect(platforms.first.model, 'Test Sensor');

      await db.close();
    });

    test('Test insertPlatforms and updatePlatforms', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());
      final now = DateTime.now();

      final platforms = [
        PlatformsCompanion.insert(
          ref: 'PLT-001',
          model: 'Model A',
          network: 'Net A',
          lat: 1,
          lon: 1,
          status: 'OPERATIONAL',
          operationalStatus: 'Deployed',
          lastUpdated: now,
          operationLat: 1,
          operationLon: 1,
        ),
      ];

      // Test batch insert
      await db.insertPlatforms(platforms);
      var results = await db.select(db.platforms).get();
      expect(results.length, 1);
      expect(results.first.model, 'Model A');

      // Test batch update
      final updatedPlatforms = [
        PlatformsCompanion(
          id: Value(results.first.id),
          ref: const Value('PLT-001'),
          model: const Value('Model A Updated'),
        ),
      ];
      await db.updatePlatforms(updatedPlatforms);

      results = await db.select(db.platforms).get();
      expect(results.first.model, 'Model A Updated');
      expect(results.first.ref, 'PLT-001'); // Should remain unchanged

      await db.close();
    });

    test('Test upsertPlatforms inserts new rows and updates existing ones by ref', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());
      final now = DateTime.now();

      PlatformsCompanion platform({required String ref, required String model, required double lat}) {
        return PlatformsCompanion.insert(
          ref: ref,
          model: model,
          network: 'Net',
          lat: lat,
          lon: lat,
          status: 'OPERATIONAL',
          operationalStatus: 'Deployed',
          lastUpdated: now,
          operationLat: lat,
          operationLon: lat,
        );
      }

      await db.insertPlatforms([platform(ref: 'PLT-001', model: 'Model A', lat: 1)]);

      // Delta refresh: PLT-001 changed, PLT-002 is new. Any local platform
      // absent from this list (there is none here) must stay untouched.
      await db.upsertPlatforms([
        platform(ref: 'PLT-001', model: 'Model A Updated', lat: 1),
        platform(ref: 'PLT-002', model: 'Model B', lat: 2),
      ]);

      final results = await db.select(db.platforms).get();
      expect(results, hasLength(2));
      expect(results.firstWhere((r) => r.ref == 'PLT-001').model, 'Model A Updated');
      expect(results.firstWhere((r) => r.ref == 'PLT-002').model, 'Model B');

      await db.close();
    });

    test('Test upsertPlatforms leaves platforms absent from the batch untouched', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());
      final now = DateTime.now();

      await db.insertPlatforms([
        PlatformsCompanion.insert(
          ref: 'PLT-001',
          model: 'Model A',
          network: 'Net',
          lat: 1,
          lon: 1,
          status: 'OPERATIONAL',
          operationalStatus: 'Deployed',
          lastUpdated: now,
          operationLat: 1,
          operationLon: 1,
        ),
      ]);

      await db.upsertPlatforms([
        PlatformsCompanion.insert(
          ref: 'PLT-002',
          model: 'Model B',
          network: 'Net',
          lat: 2,
          lon: 2,
          status: 'OPERATIONAL',
          operationalStatus: 'Deployed',
          lastUpdated: now,
          operationLat: 2,
          operationLon: 2,
        ),
      ]);

      final results = await db.select(db.platforms).get();
      expect(results.map((r) => r.ref), containsAll(['PLT-001', 'PLT-002']));
      expect(results, hasLength(2));

      await db.close();
    });

    test('Test getLastPlatformsRefresh/setLastPlatformsRefresh persist the timestamp', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());

      expect(await db.getLastPlatformsRefresh(), null);

      final when = DateTime.utc(2026, 7);
      await db.setLastPlatformsRefresh(when);
      expect((await db.getLastPlatformsRefresh())!.isAtSameMomentAs(when), isTrue);

      final later = DateTime.utc(2026, 7, 2);
      await db.setLastPlatformsRefresh(later);
      expect((await db.getLastPlatformsRefresh())!.isAtSameMomentAs(later), isTrue);

      await db.close();
    });
  });

  group('PendingOperations queue', () {
    test('enqueue, watch (FIFO order), and delete', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());

      final firstId = await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{"a":1}'),
      );
      final secondId = await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-002', action: 'recover', payloadJson: '{"b":2}'),
      );

      final ordered = await db.getPendingOperationsOrdered();
      expect(ordered.map((row) => row.id).toList(), [firstId, secondId]);
      expect(ordered.first.status, 'pending');
      expect(ordered.first.attempts, 0);

      await db.deletePendingOperation(firstId);
      final afterDelete = await db.getPendingOperationsOrdered();
      expect(afterDelete.map((row) => row.id).toList(), [secondId]);

      await db.close();
    });

    test('markPendingOperationFailed records the error and attempt count', () async {
      final db = AppDatabase.executor(conn.inMemoryConnection());

      final id = await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{}'),
      );

      await db.markPendingOperationFailed(id, error: 'Server rejected', attempts: 1);

      final row = await db.getPendingOperationById(id);
      expect(row!.status, 'failed');
      expect(row.lastError, 'Server rejected');
      expect(row.attempts, 1);

      await db.close();
    });
  });
}
