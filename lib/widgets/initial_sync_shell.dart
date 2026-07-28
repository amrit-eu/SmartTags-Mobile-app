import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/map_providers.dart';

/// Non-blocking first-load sync feedback shown above any tab in the main shell.
class InitialSyncShell extends ConsumerStatefulWidget {
  /// Creates an [InitialSyncShell].
  const InitialSyncShell({super.key});

  @override
  ConsumerState<InitialSyncShell> createState() => _InitialSyncShellState();
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

    ref.listen(platformsStreamProvider, (previous, next) {
      if ((next.value?.length ?? 0) > 0) {
        ref.read(initialSyncProvider.notifier).acknowledgeLocalData();
      }
    });

    if (markersPainted && platformCount > 0) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const SizedBox.shrink();
    }

    if (syncAsync.hasError && platformCount > 0) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const SizedBox.shrink();
    }

    if (syncAsync.isLoading) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const _SyncProgressBanner(
        message: 'Loading platforms…',
      );
    }

    if (syncAsync.hasError) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return _SyncFailedBanner(
        onRetry: () {
          ref.read(initialSyncProvider.notifier).retry();
        },
      );
    }

    final status = syncAsync.value;
    if (status == InitialSyncStatus.skippedOffline) {
      _startDisplayTimeoutIfNeeded(showingDisplaying: false);
      return const _OfflineEmptyBanner();
    }

    _startDisplayTimeoutIfNeeded(showingDisplaying: true);
    return const _SyncProgressBanner(
      message: 'Displaying platforms…',
    );
  }
}

class _SyncProgressBanner extends StatelessWidget {
  const _SyncProgressBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            minHeight: 3,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _SyncFailedBanner extends StatelessWidget {
  const _SyncFailedBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 18,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Could not load platforms',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _OfflineEmptyBanner extends StatelessWidget {
  const _OfflineEmptyBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No local data. Connect to the internet to download platforms.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
