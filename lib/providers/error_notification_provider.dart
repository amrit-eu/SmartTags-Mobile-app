import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an error notification to be displayed to the user.
class ErrorNotification {
  /// Creates an [ErrorNotification].
  const ErrorNotification({
    required this.message,
    required this.type,
  });

  /// The error message to display.
  final String message;

  /// The type of error (e.g., 'session_expired', 'network_error', 'generic_error').
  final String type;
}


/// This provider holds the current error notification to be displayed to the user.
/// When an error occurs, it should be set via [ErrorNotificationNotifier].
final errorNotificationProvider =
    NotifierProvider<ErrorNotificationNotifier, ErrorNotification?>(
        ErrorNotificationNotifier.new);

/// Notifier for managing error notifications.
class ErrorNotificationNotifier extends Notifier<ErrorNotification?> {
  @override
  ErrorNotification? build() => null;

  /// Sets an error notification to be displayed.
  void setError(String message, {String type = 'generic_error'}) {
    state = ErrorNotification(
      message: message,
      type: type,
    );
  }

  /// Clears the current error notification.
  void clearError() {
    state = null;
  }
}
