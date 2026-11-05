import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/seed/build_seed_database.dart';

void main() {
  test('buildSeedDatabase schema-only creates an empty Drift-compatible database', () async {
    final tempDir = await Directory.systemTemp.createTemp('smart-tags-seed-test-');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final manifest = await buildSeedDatabase(
      outputDirectory: tempDir.path,
      schemaOnly: true,
    );

    expect(manifest.platformCount, 0);
    expect(manifest.schemaVersion, 2);

    final dbFile = File('${tempDir.path}/seed.sqlite');
    expect(dbFile.existsSync(), isTrue);

    final database = AppDatabase.executor(NativeDatabase(dbFile));
    addTearDown(database.close);
    expect(await database.isEmpty(), isTrue);
  });
}
