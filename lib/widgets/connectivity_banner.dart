import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';

/// Persistent offline indicator shown in the main shell when local data exists.
class ConnectivityBanner extends ConsumerWidget {
  /// Creates a [ConnectivityBanner].
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(checkConnectionProvider).value;
    if (isDeviceOnline(connectivity)) {
      return const SizedBox.shrink();
    }

    final platformCount = ref.watch(platformsStreamProvider).value?.length ?? 0;
    if (platformCount == 0) {
      // First-load empty state is handled by [InitialSyncShell].
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 16,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline — showing local data',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
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
