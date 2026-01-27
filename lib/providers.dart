import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/services/oceanops_repository.dart';

/// Provides a singleton instance of [AppDatabase] for the lifetime of the
/// provider scope.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provides an instance of [OceanOpsRepository], which is responsible for
/// fetching platform data from the remote API.
///
/// This provider does not manage any internal state and acts as a simple
/// dependency-injection wrapper for the repository.
final oceanOpsRepositoryProvider = Provider<OceanOpsRepository>((ref) {
  return OceanOpsRepository();
});

/// Performs the initial synchronization of platform data from the remote API
/// into the local database.
final initialSyncProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  final repository = ref.watch(oceanOpsRepositoryProvider);

  try {
    final platforms = await repository.fetchPlatforms();
    await db.syncPlatforms(platforms);
  } catch (e, st) {
    debugPrint('Failed to sync data: $e');
    Error.throwWithStackTrace(e, st);
  }
});

/// Streams the full list of [Platform] entities from the local database.
///
/// This provider:
/// - Emits updates whenever the underlying platforms table changes
/// - Reflects only local database state (no network calls)
final platformsStreamProvider = StreamProvider<List<Platform>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.platforms).watch();
});

/// Fetches one or more [Platform] records matching the given platform
/// reference.
///
/// This is a parameterized (family) provider, allowing callers to request
/// platform data for a specific reference identifier.
///
/// The data is fetched from the local database only.
final FutureProviderFamily<List<Platform>, String> platformByRefProvider = FutureProvider.family<List<Platform>, String>((
    ref, platformRef
    ) async {
  final db = ref.watch(databaseProvider);
  return db.getPlatformByRef(platformRef);
});
