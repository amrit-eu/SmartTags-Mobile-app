import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Brief “everything up to date” banner after a delta refresh with no changes.
final platformsRefreshFeedbackProvider = NotifierProvider<PlatformsRefreshFeedbackNotifier, bool>(
  PlatformsRefreshFeedbackNotifier.new,
);

/// Shows and auto-hides the up-to-date confirmation strip.
class PlatformsRefreshFeedbackNotifier extends Notifier<bool> {
  Timer? _hideTimer;

  @override
  bool build() {
    ref.onDispose(() => _hideTimer?.cancel());
    return false;
  }

  /// Displays the success banner for [duration], then hides it.
  void showEverythingUpToDate({Duration duration = const Duration(seconds: 3)}) {
    _hideTimer?.cancel();
    state = true;
    _hideTimer = Timer(duration, () {
      if (ref.mounted) {
        state = false;
      }
    });
  }

  /// Hides the banner immediately (e.g. when a new refresh starts).
  void clear() {
    _hideTimer?.cancel();
    state = false;
  }
}
