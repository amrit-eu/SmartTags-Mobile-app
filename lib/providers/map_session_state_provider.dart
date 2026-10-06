import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/models/map_viewport_snapshot.dart';
import 'package:smart_tags/providers/db_providers.dart';

/// Loads and persists map camera + popup selection (#132).
final mapSessionStateProvider =
    AsyncNotifierProvider<MapSessionStateNotifier, MapViewportSnapshot>(
  MapSessionStateNotifier.new,
);

/// Drift-backed map session persistence.
class MapSessionStateNotifier extends AsyncNotifier<MapViewportSnapshot> {
  Timer? _cameraDebounce;

  @override
  Future<MapViewportSnapshot> build() async {
    ref.onDispose(() => _cameraDebounce?.cancel());
    final db = ref.watch(databaseProvider);
    return await db.getMapViewportSnapshot() ?? const MapViewportSnapshot.empty();
  }

  /// Debounced camera persist after pan/zoom.
  void schedulePersistCamera(LatLng center, double zoom) {
    _cameraDebounce?.cancel();
    _cameraDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(persistCamera(center, zoom));
    });
  }

  /// Writes camera centre and zoom to local storage.
  Future<void> persistCamera(LatLng center, double zoom) async {
    final current = state.value ?? const MapViewportSnapshot.empty();
    final next = current.copyWith(
      centerLat: center.latitude,
      centerLng: center.longitude,
      zoom: zoom,
    );
    state = AsyncData(next);
    await ref.read(databaseProvider).setMapViewportSnapshot(next);
  }

  /// Writes or clears the selected platform ref (popup open ⇔ non-null).
  Future<void> persistSelection(String? platformRef) async {
    final current = state.value ?? const MapViewportSnapshot.empty();
    final next = current.copyWith(
      selectedPlatformRef: platformRef,
      clearSelection: platformRef == null,
    );
    state = AsyncData(next);
    await ref.read(databaseProvider).setMapViewportSnapshot(next);
  }
}
