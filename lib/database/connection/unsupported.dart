import 'package:drift/drift.dart';

/// Opens the connection to the production SQLite database.
QueryExecutor openConnection() {
  throw UnsupportedError('Opening a database is not supported on this platform.');
}

/// Opens an in-memory database for testing.
QueryExecutor inMemoryConnection() {
  throw UnsupportedError('Testing is not supported on this platform.');
}
