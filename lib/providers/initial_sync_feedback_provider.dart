import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Brief success banner after the first Gateway download into an empty DB.
final initialSyncFeedbackProvider = NotifierProvider<InitialSyncFeedbackNotifier, bool>(
  InitialSyncFeedbackNotifier.new,
);

/// Shows and auto-hides the first-load success strip.
class InitialSyncFeedbackNotifier extends Notifier<bool> {
  Timer? _hideTimer;

  @override
  bool build() {
    ref.onDispose(() => _hideTimer?.cancel());
    return false;
  }

  /// Displays the success banner for [duration], then hides it.
  void showFirstLoadComplete({Duration duration = const Duration(seconds: 3)}) {
    _hideTimer?.cancel();
    state = true;
    _hideTimer = Timer(duration, () {
      if (ref.mounted) {
        state = false;
      }
    });
  }

  /// Hides the banner immediately (e.g. when a new first-load sync starts).
  void clear() {
    _hideTimer?.cancel();
    state = false;
  }
}
