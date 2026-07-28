import 'package:flutter/material.dart';

/// Shared progress strip used for first-load sync and pull-to-refresh.
class PlatformsLoadingBanner extends StatelessWidget {
  /// Creates a [PlatformsLoadingBanner].
  const PlatformsLoadingBanner({
    super.key,
    this.message = 'Downloading platforms…',
    this.progress,
  });

  /// Status text shown under the progress bar.
  final String message;

  /// Optional determinate progress `0..1`. When null, the bar is indeterminate.
  final double? progress;

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
            value: progress,
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
