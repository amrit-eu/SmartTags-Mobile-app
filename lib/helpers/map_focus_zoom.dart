import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:smart_tags/config/map_config.dart';
import 'package:smart_tags/database/db.dart';

const Distance _distance = Distance();

/// Approximate metres per pixel at [zoom] for Web Mercator tiles (256 px).
double metersPerPixelAtZoom(double zoom, double latitude) {
  const earthCircumferenceM = 40075016.686;
  final latRad = latitude * math.pi / 180;
  return earthCircumferenceM * math.cos(latRad) / (256 * math.pow(2, zoom));
}

/// Lowest zoom in `[minZoom, maxZoom]` where no other [platforms] fall inside the
/// map cluster radius (see main map `maxClusterRadius: 120`).
///
/// If still overlapping at [maxZoom], returns [declusterZoom] (above the cluster
/// layer max) so the selected marker and ring are not hidden in a cluster badge.
double resolvePlatformFocusZoom(
  LatLng target,
  Iterable<Platform> platforms, {
  double minZoom = MapConfig.platformFocusMinZoom,
  double maxZoom = MapConfig.platformFocusMaxZoom,
  double declusterZoom = MapConfig.platformFocusDeclusterZoom,
  double clusterRadiusPx = MapConfig.platformClusterRadiusPx,
}) {
  for (var z = minZoom; z <= maxZoom; z += 0.5) {
    final clusterRadiusM = metersPerPixelAtZoom(z, target.latitude) * clusterRadiusPx;
    final overlapsCluster = platforms.any((platform) {
      final other = LatLng(platform.lat, platform.lon);
      if (_sameLatLng(other, target)) {
        return false;
      }
      return _distance.as(LengthUnit.Meter, target, other) < clusterRadiusM;
    });
    if (!overlapsCluster) {
      return z;
    }
  }
  return declusterZoom;
}

bool _sameLatLng(LatLng a, LatLng b) {
  return (a.latitude - b.latitude).abs() < 0.00001 && (a.longitude - b.longitude).abs() < 0.00001;
}
