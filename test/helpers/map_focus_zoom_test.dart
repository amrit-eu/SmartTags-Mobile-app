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

  test('resolvePlatformFocusZoom uses decluster zoom when overlap remains at maxZoom', () {
    const target = LatLng(45, -5);
    final crowded = [
      _platform(45, -5),
      _platform(45.0001, -5.0001, ref: 'A'),
      _platform(45.0001, -4.9999, ref: 'B'),
      _platform(44.9999, -5.0001, ref: 'C'),
    ];
    final zoom = resolvePlatformFocusZoom(
      target,
      crowded,
      maxZoom: 10,
      declusterZoom: 11,
    );
    expect(zoom, 11);
  });

  test('resolvePlatformFocusZoom declusters when neighbors stay within cluster radius at max zoom', () {
    const target = LatLng(45, -5);
    final zoom = resolvePlatformFocusZoom(target, [
      _platform(45, -5),
      _platform(45.00005, -5.00005, ref: 'near'),
    ]);
    expect(zoom, MapConfig.platformFocusDeclusterZoom);
  });
}
