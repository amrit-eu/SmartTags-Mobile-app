/// ArcGIS ocean basemap tile URLs for flutter_map.
abstract final class MapConfig {
  static const String _arcgisOceanBase =
      'https://server.arcgisonline.com/ArcGIS/rest/services/Ocean';

  /// ArcGIS ocean base layer tile URL template.
  static const String oceanBaseTileUrl =
      '$_arcgisOceanBase/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}';

  /// ArcGIS ocean reference layer (labels, boundaries).
  static const String oceanReferenceTileUrl =
      '$_arcgisOceanBase/World_Ocean_Reference/MapServer/tile/{z}/{y}/{x}';

  /// User agent sent with tile requests (required by flutter_map).
  static const String userAgentPackageName = 'com.example.flutter_amrit';
}
