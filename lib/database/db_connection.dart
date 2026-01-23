import 'package:drift/drift.dart';
import 'package:flutter_amrit/database/connection/unsupported.dart'
    if (dart.library.js_interop) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart'
    as impl;

/// Opens the connection to the production SQLite database.
QueryExecutor openConnection() => impl.openConnection();

/// Opens an in-memory database for testing.
QueryExecutor inMemoryConnection() => impl.inMemoryConnection();
