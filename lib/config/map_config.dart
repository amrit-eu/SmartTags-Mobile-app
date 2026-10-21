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

  /// Highest zoom when de-clustering; kept low so focus stays wider (popup identifies the platform).
  static const double platformFocusMaxZoom = 10.5;

  /// Matches [MapScreen] cluster `maxClusterRadius` for focus zoom heuristics.
  static const double platformClusterRadiusPx = 120;
}
