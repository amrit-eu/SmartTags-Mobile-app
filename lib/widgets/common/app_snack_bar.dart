import 'package:flutter/material.dart';

/// Standard duration for transient feedback across the app.
const appSnackBarDuration = Duration(seconds: 4);

/// Builds consistently configured transient feedback.
///
/// Use a top status banner instead when a condition is persistent or requires
/// ongoing corrective action.
SnackBar buildAppSnackBar({
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  assert(
    (actionLabel == null) == (onAction == null),
    'actionLabel and onAction must either both be provided or both be null.',
  );

  return SnackBar(
    content: Text(message),
    // This intentionally pins the app policy instead of relying on Flutter's
    // current default duration.
    // ignore: avoid_redundant_argument_values
    duration: appSnackBarDuration,
    action: actionLabel == null
        ? null
        : SnackBarAction(
            label: actionLabel,
            onPressed: onAction!,
          ),
  );
}
