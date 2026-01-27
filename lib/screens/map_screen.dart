import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/models/platform.dart' as model;
import 'package:smart_tags/providers.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';

/// A screen displaying an interactive ocean map with markers.
class MapScreen extends ConsumerStatefulWidget {
  /// Creates a [MapScreen] widget.
  ///
  /// `locationFetcher` can be provided in tests to return a mocked
  ///  current location as a [LatLng].
  /// `onLocationCentered` is called after the map is centered.
  const MapScreen({
    super.key,
    this.locationFetcher,
    this.onLocationCentered,
  });

  /// Optional test / injection hook to provide a LocationFetcher
  @visibleForTesting
  final LocationFetcher? locationFetcher;

  /// Optional callback called after the map is centered on the user's location
  @visibleForTesting
  final ValueChanged<LatLng>? onLocationCentered;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  late final MapController _mapController;
  late AnimationController _pulseController;

  // Initial map center (Atlantic Ocean, near Europe as in reference image)
  static const LatLng _defaultCenter = LatLng(45, -5);
  static const double _defaultZoom = 4;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Animation controller for pulsing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.6,
      upperBound: 1.3,
    );
    unawaited(_pulseController.repeat(reverse: true));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<LatLng?> _getCurrentLocation() async {
    final locationFetcher = widget.locationFetcher ?? LocationFetcher();
    final location = await locationFetcher.getUserLocation();
    return location;
  }

  void _setCurrentLocation(LatLng location) {
    /// Helper method to set the current location state
    setState(() {
      _currentLocation = location;
    });
  }

  Future<void> _centerOnLocation(BuildContext context) async {
    final location = await _getCurrentLocation();
    if (location != null) {_setCurrentLocation(location);}
    else if (context.mounted) {
      _showToast(context, 'Unable to fetch current location', 'Close');
    }
    // Move to current location.
    // This will use the last previous known location if fetching fails.
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 10);
      // Call the onLocationCentered callback with location.
      widget.onLocationCentered?.call(_currentLocation!);
    }
  }

  Widget _buildCurrentLocationMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: _pulseController.value * 30,
          height: _pulseController.value * 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers(List<Platform> databasePlatforms) {
    final markers = <Marker>[];

    // Add current location marker if available
    if (_currentLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: _currentLocation!,
          child: _buildCurrentLocationMarker(),
        ),
      );
    }

    // Use platforms from the database
    for (final dbPlatform in databasePlatforms) {
      final point = LatLng(dbPlatform.lat, dbPlatform.lon);

      markers.add(
        Marker(
          point: point,
          child: GestureDetector(
            onTap: () {
              final platformModel = model.Platform(
                id: dbPlatform.ref,
                model: dbPlatform.model,
                network: dbPlatform.network,
                latestPosition: point,
                status: dbPlatform.status == 'Active' ? model.PlatformStatus.active : model.PlatformStatus.inactive,
                operationalStatus: dbPlatform.operationalStatus == 'Deployed'
                    ? model.OperationalStatus.deployed
                    : model.OperationalStatus.recovered,
                lastUpdated: dbPlatform.lastUpdated,
                operationLocation: LatLng(
                  dbPlatform.operationLat,
                  dbPlatform.operationLon,
                ),
              );
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => PlatformDetailScreen(platform: platformModel),
                  ),
                ),
              );
            },
            child: Icon(
              Icons.location_on,
              color: dbPlatform.status == 'Active' ? Colors.green : Colors.red,
              size: 30,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final platformsAsync = ref.watch(platformsStreamProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {
            // Profile action placeholder
          },
        ),
        title: const Text('SmartTags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Menu action placeholder
            },
          ),
        ],
      ),
      body: platformsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (platforms) {
          return FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
            ),
            children: [
              // Ocean Base Tiles
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/'
                    'Ocean/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.flutter_amrit',
              ),
              // Ocean Reference Tiles (labels)
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/'
                    'Ocean/World_Ocean_Reference/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.flutter_amrit',
              ),
              // Markers
              MarkerLayer(markers: _buildMarkers(platforms)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          await _centerOnLocation(context);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _showToast(BuildContext context, String message, String label) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: label, onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
