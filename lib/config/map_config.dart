import 'package:latlong2/latlong.dart';

/// ArcGIS ocean basemap tile URLs and default viewport for flutter_map.
abstract final class MapConfig {
  static const String _arcgisOceanBase = 'https://server.arcgisonline.com/ArcGIS/rest/services/Ocean';

  /// ArcGIS ocean base layer tile URL template.
  static const String oceanBaseTileUrl = '$_arcgisOceanBase/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}';

  /// ArcGIS ocean reference layer (labels, boundaries).
  static const String oceanReferenceTileUrl = '$_arcgisOceanBase/World_Ocean_Reference/MapServer/tile/{z}/{y}/{x}';

  /// User agent sent with tile requests (required by flutter_map).
  static const String userAgentPackageName = 'com.example.flutter_amrit';

  /// Initial map center (Atlantic Ocean, near Europe).
  static const LatLng defaultCenter = LatLng(45, -5);

  /// Initial map zoom level.
  static const double defaultZoom = 4;

  /// Preferred zoom when opening a platform from details (surroundings context).
  static const double platformFocusMinZoom = 8;

  /// Last zoom level at which the map still builds marker clusters.
  static const double platformClusterMaxZoom = 15;

  /// Highest zoom searched for a level where no other platform shares the cluster radius.
  static const double platformFocusMaxZoom = platformClusterMaxZoom;

  /// Zoom above [platformClusterMaxZoom] so focused markers render individually (selection ring).
  static const double platformFocusDeclusterZoom = platformClusterMaxZoom + 1;

  /// Matches the main map cluster `maxClusterRadius` for focus zoom heuristics.
  static const double platformClusterRadiusPx = 120;
}
