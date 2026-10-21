import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/config/map_config.dart';

/// One-shot request to focus the main map tab on a platform (#168).
class MapFocusRequest {
  /// Creates a [MapFocusRequest] for [platformRef].
  const MapFocusRequest({
    required this.platformRef,
    this.zoom = MapConfig.platformSurroundingsZoom,
  });

  /// Platform ref to centre on and select.
  final String platformRef;

  /// Map zoom used when opening from platform details (surroundings context).
  final double zoom;
}

/// Pending focus for the main map tab; cleared after apply.
final mapFocusRequestProvider =
    NotifierProvider<MapFocusRequestNotifier, MapFocusRequest?>(
  MapFocusRequestNotifier.new,
);

/// Sets or clears the pending main-map focus target.
class MapFocusRequestNotifier extends Notifier<MapFocusRequest?> {
  @override
  MapFocusRequest? build() => null;

  /// Opens the main map centred on [platformRef].
  void showPlatform(String platformRef) {
    state = MapFocusRequest(platformRef: platformRef);
  }

  /// Clears a handled request.
  void clear() {
    state = null;
  }
}
