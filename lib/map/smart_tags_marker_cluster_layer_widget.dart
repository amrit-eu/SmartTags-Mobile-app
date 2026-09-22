import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:smart_tags/map/smart_tags_marker_cluster_layer.dart';

/// Map layer wrapper that uses [SmartTagsMarkerClusterLayer] (app fork of upstream).
class SmartTagsMarkerClusterLayerWidget extends StatelessWidget {
  /// Creates a cluster layer with SmartTags tap / spiderfy behavior.
  const SmartTagsMarkerClusterLayerWidget({required this.options, super.key});

  /// Clustering options (from flutter_map_marker_cluster).
  final MarkerClusterLayerOptions options;

  @override
  Widget build(BuildContext context) {
    final mapController = MapController.of(context);
    final mapCamera = MapCamera.of(context);

    return SmartTagsMarkerClusterLayer(
      mapController: mapController,
      mapCamera: mapCamera,
      options: options,
    );
  }
}
