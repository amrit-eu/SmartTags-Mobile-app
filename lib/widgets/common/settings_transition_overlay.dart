import 'package:flutter/material.dart';

/// Blocks interaction while display settings rebuild the app.
class SettingsTransitionOverlay extends StatelessWidget {
  /// Creates an overlay with [message] and an indeterminate progress indicator.
  const SettingsTransitionOverlay({required this.message, super.key});

  /// Short status shown under the spinner.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AbsorbPointer(
      child: ColoredBox(
        color: theme.colorScheme.scrim.withValues(alpha: 0.45),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 16),
                  Text(message, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
