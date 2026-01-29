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
import 'package:smart_tags/widgets/top_navigation.dart';

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
  model.Platform? _selectedPlatform;
  LatLng? _selectedPlatformPosition;

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
    if (location != null) {
      _setCurrentLocation(location);
    } else if (context.mounted) {
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

  void _selectPlatformMarker(model.Platform platform, LatLng position) {
    setState(() {
      _selectedPlatform = platform;
      _selectedPlatformPosition = position;
    });
    // Center map on the selected marker.
    Future.delayed(const Duration(milliseconds: 100), () {
      _mapController.move(position, _mapController.camera.zoom);
    });
  }

  /// Clears the selected platform and its position.
  void _clearSelection() {
    setState(() {
      _selectedPlatform = null;
      _selectedPlatformPosition = null;
    });
  }

  /// Builds the popup widget for a selected platform marker.
  Widget _buildPopup(BuildContext context, model.Platform platform) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.model,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${platform.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSelection,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPopupInfoRow(
                'Latitude',
                platform.latestPosition.latitude.toStringAsFixed(3),
              ),
              const SizedBox(height: 8),
              _buildPopupInfoRow(
                'Longitude',
                platform.latestPosition.longitude.toStringAsFixed(3),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => PlatformDetailScreen(platform: platform),
                        ),
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build a row in the popup info.
  Widget _buildPopupInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              _selectPlatformMarker(platformModel, point);
            },
            child: Icon(
              Icons.location_on,
              // Color depends on status and selection.
              color: _selectedPlatformPosition == point ? const Color.fromARGB(255, 2, 0, 101): (dbPlatform.status == 'Active' ? Colors.green : Colors.red),
              // Size increases if this marker is selected.
              size: _selectedPlatformPosition == point ? 40 : 30,
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
      appBar: TopNavigation(title: const Text('SmartTags')),
      body: platformsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (platforms) {
          return Stack(
            children: [
              FlutterMap(
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
              ),
              if (_selectedPlatform != null && _selectedPlatformPosition != null) ...[
                Positioned(
                  top: 20,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {},
                    child: _buildPopup(context, _selectedPlatform!),
                  ),
                ),
              ],
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
