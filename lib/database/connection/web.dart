import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Opens the connection to the production SQLite database on the web.
QueryExecutor openConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'db.sqlite',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        // ignore: avoid_print // console warning for missing features
        print('There maybe be performance issues due to missing features: ${result.missingFeatures}');
      }

      return result.resolvedExecutor;
    }),
  );
}

/// Opens an in-memory database for testing on the web.
QueryExecutor inMemoryConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'in-memory',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
