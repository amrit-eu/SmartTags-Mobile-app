import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/map_viewport_snapshot.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.executor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('setMapViewportSnapshot round-trips camera and selection (#132)', () async {
    const state = MapViewportSnapshot(
      centerLat: 12.5,
      centerLng: -4.25,
      zoom: 7.5,
      selectedPlatformRef: 'PLT-001',
    );

    await db.setMapViewportSnapshot(state);
    final loaded = await db.getMapViewportSnapshot();

    expect(loaded, isNotNull);
    expect(loaded!.centerLat, 12.5);
    expect(loaded.centerLng, -4.25);
    expect(loaded.zoom, 7.5);
    expect(loaded.selectedPlatformRef, 'PLT-001');
  });

  test('setMapViewportSnapshot clears selection (#132)', () async {
    await db.setMapViewportSnapshot(
      const MapViewportSnapshot(
        centerLat: 1,
        centerLng: 2,
        zoom: 3,
        selectedPlatformRef: 'PLT-001',
      ),
    );

    await db.setMapViewportSnapshot(
      const MapViewportSnapshot(
        centerLat: 1,
        centerLng: 2,
        zoom: 3,
      ),
    );

    final loaded = await db.getMapViewportSnapshot();
    expect(loaded?.selectedPlatformRef, isNull);
  });
}
