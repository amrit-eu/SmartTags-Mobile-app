import 'package:latlong2/latlong.dart';

/// Persisted map camera and popup selection (#132).
class MapViewportSnapshot {
  /// Creates a [MapViewportSnapshot].
  const MapViewportSnapshot({
    this.centerLat,
    this.centerLng,
    this.zoom,
    this.selectedPlatformRef,
  });

  /// Empty snapshot (defaults apply on the map).
  const MapViewportSnapshot.empty()
      : centerLat = null,
        centerLng = null,
        zoom = null,
        selectedPlatformRef = null;

  /// Map centre latitude.
  final double? centerLat;

  /// Map centre longitude.
  final double? centerLng;

  /// Map zoom level.
  final double? zoom;

  /// Platform ref when a popup was open.
  final String? selectedPlatformRef;

  /// Whether a saved camera is available.
  bool get hasCamera => centerLat != null && centerLng != null && zoom != null;

  /// Saved centre as [LatLng], if complete.
  LatLng? get center {
    if (!hasCamera) {
      return null;
    }
    return LatLng(centerLat!, centerLng!);
  }

  /// Returns a copy with optional overrides.
  MapViewportSnapshot copyWith({
    double? centerLat,
    double? centerLng,
    double? zoom,
    String? selectedPlatformRef,
    bool clearSelection = false,
  }) {
    return MapViewportSnapshot(
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      zoom: zoom ?? this.zoom,
      selectedPlatformRef: clearSelection ? null : (selectedPlatformRef ?? this.selectedPlatformRef),
    );
  }
}
