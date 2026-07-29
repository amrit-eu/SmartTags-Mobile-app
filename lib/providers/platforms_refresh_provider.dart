import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';

/// Manual / pull-to-refresh Gateway → local platforms sync.
///
/// Separate from [initialSyncProvider], which only runs when the DB is empty.
final platformsRefreshProvider =
    AsyncNotifierProvider<PlatformsRefreshNotifier, void>(
  PlatformsRefreshNotifier.new,
);

/// Reloads unclosed missions from the Gateway into Drift.
class PlatformsRefreshNotifier extends AsyncNotifier<void> {
  Future<void>? _ongoingRefresh;

  @override
  Future<void> build() async {}

  /// Fetches passport data and replaces local platforms when online.
  Future<void> refresh() async {
    final ongoing = _ongoingRefresh;
    if (ongoing != null) {
      return ongoing;
    }

    final refresh = _performRefresh();
    _ongoingRefresh = refresh;
    try {
      await refresh;
    } finally {
      if (identical(_ongoingRefresh, refresh)) {
        _ongoingRefresh = null;
      }
    }
  }

  Future<void> _performRefresh() async {
    final connectivity = await _currentConnectivity();
    if (!isDeviceOnline(connectivity)) {
      final error = StateError('Offline — connect to refresh platforms');
      _logRefreshFailure(error, StackTrace.current, connectivity: connectivity);
      state = AsyncValue.error(error, StackTrace.current);
      return;
    }

    final phase = ref.read(platformsSyncPhaseProvider.notifier);
    state = const AsyncValue.loading();
    phase.setDownloading();
    if (kDebugMode) {
      debugPrint(
        'Platforms refresh: fetching ${GatewayConfig.unclosedPassportsUri} '
        '(connectivity=${connectivity?.name})',
      );
    }

    try {
      final repository = ref.read(gatewayRepositoryProvider);
      final platforms = await repository.fetchUnclosedMissions();
      if (platforms.isNotEmpty) {
        phase.setSaving();
        final db = ref.read(databaseProvider);
        await db.syncPlatforms(platforms);
        if (kDebugMode) {
          debugPrint('Platforms refresh: synced ${platforms.length} platforms');
        }
      } else if (kDebugMode) {
        debugPrint(
          'Platforms refresh: gateway returned 0 platforms (local DB unchanged)',
        );
      }
      state = const AsyncValue.data(null);
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      _logRefreshFailure(error, stackTrace, connectivity: connectivity);
    } finally {
      phase.setIdle();
    }
  }

  void _logRefreshFailure(
    Object error,
    StackTrace stackTrace, {
    ConnectivityResult? connectivity,
  }) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(
      'Platforms refresh failed: $error '
      '(connectivity=${connectivity?.name ?? 'unknown'})\n$stackTrace',
    );
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
