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
              status: 'Active',
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
          status: 'Active',
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
          model: const Value('Model A Updated'),
        ),
      ];
      await db.updatePlatforms(updatedPlatforms);

      results = await db.select(db.platforms).get();
      expect(results.first.model, 'Model A Updated');
      expect(results.first.ref, 'PLT-001'); // Should remain unchanged

      await db.close();
    });
  });
}
