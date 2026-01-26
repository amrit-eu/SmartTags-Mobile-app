import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/services/oceanops_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final oceanOpsRepositoryProvider = Provider<OceanOpsRepository>((ref) {
  return OceanOpsRepository();
});

final initialSyncProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  final repository = ref.watch(oceanOpsRepositoryProvider);

  try {
    final platforms = await repository.fetchPlatforms();
    await db.syncPlatforms(platforms);
  } catch (e, st) {
    debugPrint('Failed to sync data: $e');
    // optionally: rethrow to surface error state
    // throw e;
  }
});

final platformsStreamProvider = StreamProvider<List<Platform>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.platforms).watch();
});

final platformByRefProvider = FutureProvider.family<List<Platform>, String>((
    ref, platformRef
    ) async {
  final db = ref.watch(databaseProvider);
  return await db.getPlatformByRef(platformRef);
});

