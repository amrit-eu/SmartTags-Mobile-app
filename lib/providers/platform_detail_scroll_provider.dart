import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saved scroll offsets when leaving platform details for the map (#168).
final platformDetailScrollProvider =
    NotifierProvider<PlatformDetailScrollNotifier, Map<String, double>>(
  PlatformDetailScrollNotifier.new,
);

/// In-memory scroll positions keyed by platform ref.
class PlatformDetailScrollNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => {};

  /// Stores [offset] for [platformRef] before navigating away.
  void save(String platformRef, double offset) {
    state = {...state, platformRef: offset};
  }

  /// Returns a saved offset and removes it (one restore per save).
  double? take(String platformRef) {
    final offset = state[platformRef];
    if (offset == null) {
      return null;
    }
    final next = Map<String, double>.from(state)..remove(platformRef);
    state = next;
    return offset;
  }
}
