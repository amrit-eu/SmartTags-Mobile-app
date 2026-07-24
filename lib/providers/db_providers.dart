import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/services/gateway_repository.dart';

/// Provides a singleton instance of [AppDatabase] for the lifetime of the
/// provider scope.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provides an instance of [GatewayRepository] for Gateway passport sync.
final gatewayRepositoryProvider = Provider<GatewayRepository>((ref) {
  return GatewayRepository();
});

/// Loads unclosed missions from the Gateway into the local database on startup
/// when the database is empty.
final initialSyncProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);

  if (!await db.isEmpty()) {
    return;
  }

  final repository = ref.watch(gatewayRepositoryProvider);

  try {
    final platforms = await repository.fetchUnclosedMissions();
    if (platforms.isEmpty) {
      return;
    }
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

///
final StreamProviderFamily<List<Platform>, String> platformsWatchProvider =
    StreamProvider.family<List<Platform>, String>((ref, String query) {
      final db = ref.watch(databaseProvider);
      return db.watchPlatforms(query: query);
    });

/// Watches a single [Platform] by its reference, emitting updates on changes.
final StreamProviderFamily<Platform?, String> platformByRefStreamProvider =
    StreamProvider.family<Platform?, String>((ref, platformRef) {
      final db = ref.watch(databaseProvider);
      return db.watchPlatformByRef(platformRef);
    });

/// Fetches one or more [Platform] records matching the given platform
/// reference.
///
/// This is a parameterized (family) provider, allowing callers to request
/// platform data for a specific reference identifier.
///
/// The data is fetched from the local database only.
final FutureProviderFamily<List<Platform>, String> platformByRefProvider =
    FutureProvider.family<List<Platform>, String>(
      retry: (retryCount, error) => null,
      (ref, platformRef) async {
        final db = ref.watch(databaseProvider);
        return db.getPlatformByRef(platformRef);
    });
