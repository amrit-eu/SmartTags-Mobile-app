import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';
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
  return GatewayRepository(authService: ref.watch(authServiceProvider));
});

/// Loads unclosed missions from the Gateway into the local database on startup
/// when the database is empty and the device is online.
final initialSyncProvider =
    AsyncNotifierProvider<InitialSyncNotifier, InitialSyncStatus>(
  InitialSyncNotifier.new,
);

/// Coordinates the one-time initial Gateway → Drift sync.
class InitialSyncNotifier extends AsyncNotifier<InitialSyncStatus> {
  Future<InitialSyncStatus>? _ongoingSync;

  @override
  Future<InitialSyncStatus> build() async {
    return _runSyncIfNeeded();
  }

  /// Retries the initial sync when the database is still empty.
  Future<void> retry() async {
    final db = ref.read(databaseProvider);
    if (!await db.isEmpty()) {
      state = const AsyncValue.data(InitialSyncStatus.notNeeded);
      return;
    }

    if (!isDeviceOnline(await _currentConnectivity())) {
      state = const AsyncValue.data(InitialSyncStatus.skippedOffline);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final result = await _runSyncIfNeeded();
      state = AsyncValue.data(result);
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clears a stale loading/error state once platform rows exist locally.
  void acknowledgeLocalData() {
    if (state.hasError || state.isLoading) {
      state = const AsyncValue.data(InitialSyncStatus.notNeeded);
    }
  }

  Future<InitialSyncStatus> _runSyncIfNeeded() {
    final existing = _ongoingSync;
    if (existing != null) {
      return existing;
    }

    final sync = _performSync();
    _ongoingSync = sync;
    return sync.whenComplete(() {
      if (identical(_ongoingSync, sync)) {
        _ongoingSync = null;
      }
    });
  }

  Future<InitialSyncStatus> _performSync() async {
    final db = ref.read(databaseProvider);
    if (!await db.isEmpty()) {
      return InitialSyncStatus.notNeeded;
    }

    final connectivity = await _currentConnectivity();
    if (!isDeviceOnline(connectivity)) {
      return InitialSyncStatus.skippedOffline;
    }

    final repository = ref.read(gatewayRepositoryProvider);
    final phase = ref.read(platformsSyncPhaseProvider.notifier)
      ..setDownloading();
    try {
      final platforms = await repository.fetchUnclosedMissions();
      if (platforms.isNotEmpty) {
        phase.setSaving();
        await db.syncPlatforms(platforms);
      }
      return InitialSyncStatus.completed;
    } finally {
      phase.setIdle();
    }
  }

  Future<ConnectivityResult?> _currentConnectivity() async {
    final async = ref.read(checkConnectionProvider);
    final value = async.value;
    if (value != null) {
      return value;
    }
    if (async.hasError) {
      return null;
    }
    try {
      return await ref
          .read(checkConnectionProvider.future)
          .timeout(const Duration(seconds: 5));
    } on Object {
      return null;
    }
  }
}

/// Retries initial sync when connectivity is restored and the database is still empty.
final initialSyncLifecycleProvider = Provider<void>((ref) {
  ref.listen(
    checkConnectionProvider.select((async) => async.value),
    (previous, next) async {
      if (!isDeviceOnline(previous) && isDeviceOnline(next)) {
        final db = ref.read(databaseProvider);
        if (await db.isEmpty()) {
          await ref.read(initialSyncProvider.notifier).retry();
        }
      }
    },
  );
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
