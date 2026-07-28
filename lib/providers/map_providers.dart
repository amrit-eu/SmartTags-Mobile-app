import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the map has painted platform markers at least once.
final mapMarkersPaintedProvider =
    NotifierProvider<MapMarkersPaintedNotifier, bool>(
  MapMarkersPaintedNotifier.new,
);

/// Tracks first map marker paint for initial-load UX.
class MapMarkersPaintedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Marks platform markers as painted on the map.
  void markPainted() {
    if (!state) {
      state = true;
    }
  }

  /// Resets marker paint tracking. For tests only.
  @visibleForTesting
  void reset() {
    state = false;
  }
}
