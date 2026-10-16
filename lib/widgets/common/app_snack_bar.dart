import 'package:flutter/material.dart';

/// Standard duration for transient feedback across the app.
const appSnackBarDuration = Duration(seconds: 4);

/// Visual severity of transient feedback.
enum AppSnackBarSeverity {
  /// Neutral feedback, cancellations or queued work.
  info,

  /// Confirmation that an operation completed successfully.
  success,

  /// A condition requiring attention, such as missing permissions.
  warning,

  /// An operation failed.
  error,
}

/// Builds consistently configured transient feedback.
///
/// Use a top status banner instead when a condition is persistent or requires
/// ongoing corrective action.
SnackBar buildAppSnackBar({
  required BuildContext context,
  required String message,
  AppSnackBarSeverity severity = AppSnackBarSeverity.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  assert(
    (actionLabel == null) == (onAction == null),
    'actionLabel and onAction must either both be provided or both be null.',
  );

  final theme = Theme.of(context);
  final colorScheme = switch (severity) {
    AppSnackBarSeverity.success => ColorScheme.fromSeed(seedColor: Colors.green, brightness: theme.brightness),
    AppSnackBarSeverity.warning => ColorScheme.fromSeed(seedColor: Colors.amber, brightness: theme.brightness),
    _ => theme.colorScheme,
  };
  final (background, foreground, icon) = switch (severity) {
    AppSnackBarSeverity.info => (colorScheme.inverseSurface, colorScheme.onInverseSurface, Icons.info_outline),
    AppSnackBarSeverity.success => (
      colorScheme.primaryContainer,
      colorScheme.onPrimaryContainer,
      Icons.check_circle_outline,
    ),
    AppSnackBarSeverity.warning => (
      colorScheme.primaryContainer,
      colorScheme.onPrimaryContainer,
      Icons.warning_amber_outlined,
    ),
    AppSnackBarSeverity.error => (colorScheme.errorContainer, colorScheme.onErrorContainer, Icons.error_outline),
  };

  return SnackBar(
    backgroundColor: background,
    content: Row(
      children: [
        Icon(icon, color: foreground, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: TextStyle(color: foreground)),
        ),
      ],
    ),
    // This intentionally pins the app policy instead of relying on Flutter's
    // current default duration.
    // ignore: avoid_redundant_argument_values
    duration: appSnackBarDuration,
    persist: false,
    action: actionLabel == null
        ? null
        : SnackBarAction(
            label: actionLabel,
            onPressed: onAction!,
            textColor: foreground,
          ),
  );
}
