import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/models/platforms_sync_state.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/map_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_feedback_provider.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';
import 'package:smart_tags/widgets/platforms_loading_banner.dart';

/// Non-blocking sync feedback shown above any tab in the main shell.
///
/// Covers first-load download and pull-to-refresh errors in one banner slot.
class InitialSyncShell extends ConsumerStatefulWidget {
  /// Creates an [InitialSyncShell].
  const InitialSyncShell({super.key});

  @override
  ConsumerState<InitialSyncShell> createState() => _InitialSyncShellState();
}

String _syncPhaseMessage(PlatformsSyncState syncState) {
  if (syncState.phase == PlatformsSyncPhase.downloading &&
      syncState.downloadContentLength != null &&
      syncState.downloadContentLength! > 0) {
    final progress = syncState.downloadProgress ?? 0;
    return 'Downloading platforms… ${(progress * 100).round()}%';
  }
  return syncState.bannerMessage ?? 'Downloading platforms…';
}

class _InitialSyncShellState extends ConsumerState<InitialSyncShell> {
  static const Duration _displayPhaseTimeout = Duration(seconds: 8);

  Timer? _displayTimeout;

  @override
  void dispose() {
    _displayTimeout?.cancel();
    super.dispose();
  }

  void _startDisplayTimeoutIfNeeded({required bool showingDisplaying}) {
    if (!showingDisplaying) {
      _displayTimeout?.cancel();
      _displayTimeout = null;
      return;
    }

    _displayTimeout ??= Timer(_displayPhaseTimeout, () {
      if (!mounted) {
        return;
      }
      ref.read(mapMarkersPaintedProvider.notifier).markPainted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncAsync = ref.watch(initialSyncProvider);
    final platformCount = ref.watch(platformsStreamProvider).value?.length ?? 0;
    final markersPainted = ref.watch(mapMarkersPaintedProvider);
    final syncState = ref.watch(platformsSyncPhaseProvider);
    final refresh = ref.watch(platformsRefreshProvider);
    final showUpToDate = ref.watch(platformsRefreshFeedbackProvider);

    ref.listen(platformsStreamProvider, (previous, next) {
      if ((next.value?.length ?? 0) > 0 &&
          ref.read(platformsSyncPhaseProvider).phase == PlatformsSyncPhase.idle) {
        ref.read(initialSyncProvider.notifier).acknowledgeLocalData();
      }
    });

    // Download/save in progress (Retry, pull-to-refresh, or first load).
    if (syncState.phase != PlatformsSyncPhase.idle) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      final showByteProgress = syncState.phase == PlatformsSyncPhase.downloading;
      return PlatformsLoadingBanner(
        message: _syncPhaseMessage(syncState),
        progress: showByteProgress ? syncState.downloadProgress : null,
      );
    }

    if (showUpToDate) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const AppStatusBanner(
        message: 'Everything up to date',
        severity: AppStatusBannerSeverity.success,
        icon: Icons.check_circle,
      );
    }

    // Pull-to-refresh / Retry failures: same top banner as first-load errors.
    if (refresh.hasError) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      final error = refresh.error!;
      final message = error is StateError ? error.message : 'Could not refresh platforms';

      return _SyncFailedBanner(
        key: const ValueKey('refresh-failure'),
        message: message,
        onRetry: () {
          unawaited(
            ref.read(platformsRefreshProvider.notifier).refresh(),
          );
        },
      );
    }

    if (markersPainted &&
        platformCount > 0 &&
        syncState.phase == PlatformsSyncPhase.idle &&
        !syncAsync.isLoading) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const SizedBox.shrink();
    }

    if (syncAsync.hasError && platformCount > 0) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const SizedBox.shrink();
    }

    if (syncAsync.isLoading && syncState.phase == PlatformsSyncPhase.idle) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const PlatformsLoadingBanner(message: 'Preparing download…');
    }

    if (syncAsync.hasError) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return _SyncFailedBanner(
        key: const ValueKey('initial-sync-failure'),
        message: 'Could not load platforms',
        onRetry: () {
          unawaited(ref.read(initialSyncProvider.notifier).retry());
        },
      );
    }

    final status = syncAsync.value;
    if (status == InitialSyncStatus.skippedOffline) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const _OfflineEmptyBanner();
    }

    _startDisplayTimeoutIfNeeded(showingDisplaying: true);
    return const PlatformsLoadingBanner(
      message: 'Displaying platforms…',
    );
  }
}

class _SyncFailedBanner extends StatefulWidget {
  const _SyncFailedBanner({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  State<_SyncFailedBanner> createState() => _SyncFailedBannerState();
}

class _SyncFailedBannerState extends State<_SyncFailedBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return const SizedBox.shrink();
    }

    return AppStatusBanner(
      message: widget.message,
      severity: AppStatusBannerSeverity.error,
      icon: Icons.cloud_off,
      actionLabel: 'Retry',
      onAction: widget.onRetry,
      onDismiss: () {
        setState(() {
          _dismissed = true;
        });
      },
    );
  }
}

class _OfflineEmptyBanner extends StatelessWidget {
  const _OfflineEmptyBanner();

  @override
  Widget build(BuildContext context) {
    return const AppStatusBanner(
      message: 'No local data. Connect to the internet to download platforms.',
      severity: AppStatusBannerSeverity.warning,
      icon: Icons.cloud_off_outlined,
    );
  }
}
