import 'package:flutter/material.dart';

/// Visual Severity applied to to an [AppStatusBanner].
enum AppStatusBannerSeverity {
  /// Neutral information or app status.
  info,

  /// Confirmation that an operation completed successfully.
  success,

  /// A condition requiring user attention.
  warning,

  /// An error has occurred.
  error,
}

/// Consistent presentation for informational and warning banners.
///
/// Visibility and dismissal state are controlled by the parent. Providing
/// [onDismiss] adds a standard close button to the banner.
class AppStatusBanner extends StatelessWidget {
  /// Creates an application status banner.
  const AppStatusBanner({
    required this.message,
    super.key,
    this.severity = AppStatusBannerSeverity.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.showProgress = false,
    this.progress,
  }) : assert(
         (actionLabel == null && onAction == null) || (actionLabel != null && onAction != null),
         'actionLabel and onAction must both be provided or both be omitted.',
       ),
       assert(
         showProgress || progress == null,
         'showProgress must be true if progress is provided.',
       ),
       assert(
         progress == null || (progress >= 0 && progress <= 1),
         'progress must be between 0 and 1.',
       );

  /// Message displayed in the banner.
  final String message;

  /// Visual severity of the banner.
  final AppStatusBannerSeverity severity;

  /// Optional icon to display in the banner.
  final IconData? icon;

  /// Optional action label.
  final String? actionLabel;

  /// Callback invoked by the optional action button.
  final VoidCallback? onAction;

  /// Callback invoked by the standard close button. If null, the close button is not displayed.
  final VoidCallback? onDismiss;

  /// Whether to display a progress indicator above the message.
  final bool showProgress;

  /// Optional determinate progress value between 0 and 1.
  ///
  /// When [showProgress] is true, and this is null, the progress indicator is indeterminate.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(theme.colorScheme);

    return Material(
      color: colors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showProgress)
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 10,
                    color: colors.foreground,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.foreground,
                    ),
                    child: Text(actionLabel!),
                  ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    color: colors.foreground,
                    tooltip: 'Dismiss banner',
                    icon: const Icon(Icons.close),
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

  ({Color background, Color foreground}) _colorsFor(
    ColorScheme colorScheme,
  ) {
    return switch (severity) {
      AppStatusBannerSeverity.info => (
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
      ),
      AppStatusBannerSeverity.success => (
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
      ),
      AppStatusBannerSeverity.warning => (
        background: colorScheme.tertiaryContainer,
        foreground: colorScheme.onTertiaryContainer,
      ),
      AppStatusBannerSeverity.error => (
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
      ),
    };
  }
}
