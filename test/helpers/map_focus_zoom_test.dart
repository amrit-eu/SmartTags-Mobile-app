import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/config/map_config.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/helpers/map_focus_zoom.dart';

Platform _platform(double lat, double lon, {String ref = 'P'}) => Platform(
      id: 1,
      ref: ref,
      model: 'm',
      network: 'n',
      lat: lat,
      lon: lon,
      status: 'OPERATIONAL',
      operationalStatus: 'Deployed',
      lastUpdated: DateTime.utc(2024),
      operationLat: lat,
      operationLon: lon,
      hasLatestObservation: true,
      category: 'Float',
    );

void main() {
  test('resolvePlatformFocusZoom uses min zoom when marker is alone', () {
    const target = LatLng(45, -5);
    final zoom = resolvePlatformFocusZoom(target, [_platform(45, -5)]);
    expect(zoom, MapConfig.platformFocusMinZoom);
  });

  test('resolvePlatformFocusZoom increases zoom when another marker shares cluster radius', () {
    const target = LatLng(45, -5);
    final nearby = _platform(45.001, -5.001, ref: 'Q');
    final zoom = resolvePlatformFocusZoom(target, [_platform(45, -5), nearby]);
    expect(zoom, greaterThan(MapConfig.platformFocusMinZoom));
  });
}
