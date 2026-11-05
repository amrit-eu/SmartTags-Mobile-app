import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smart_tags/seed/seed_database_paths.dart';

/// Copies the bundled seed SQLite file into the app documents directory
/// before Drift opens, when no local database file exists yet (#184).
Future<void> installBundledSeedDatabaseIfNeeded() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return;
  }

  final documentsDirectory = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(documentsDirectory.path, 'db.sqlite'));
  if (dbFile.existsSync()) {
    return;
  }

  final ByteData seedBytes;
  try {
    seedBytes = await rootBundle.load(SeedDatabasePaths.assetPath);
  } on Object {
    return;
  }

  await dbFile.parent.create(recursive: true);
  await dbFile.writeAsBytes(
    seedBytes.buffer.asUint8List(seedBytes.offsetInBytes, seedBytes.lengthInBytes),
    flush: true,
  );
}
