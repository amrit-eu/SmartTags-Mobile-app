import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_amrit/database/db.dart';
import 'package:flutter_amrit/models/platform.dart' as model;
import 'package:flutter_amrit/screens/platform_detail_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// A screen displaying an interactive ocean map with markers.
class MapScreen extends StatefulWidget {
  /// Creates a [MapScreen] widget.
  const MapScreen({required this.database, super.key});

  /// The local database instance.
  final AppDatabase database;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  bool _isLocationLoaded = false;
  late final MapController _mapController;
  late AnimationController _pulseController;

  // Initial map center (Atlantic Ocean, near Europe as in reference image)
  static const LatLng _defaultCenter = LatLng(45, -5);
  static const double _defaultZoom = 4;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    unawaited(_getCurrentLocation());

    // Animation controller for pulsing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.6,
      upperBound: 1.3,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    // Request permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied.');
      return;
    }

    // Fetch location
    try {
      final position = await Geolocator.getCurrentPosition();
      debugPrint(
        'Location Found: ${position.latitude}, ${position.longitude}',
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoaded = true;
      });
    } on Exception catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _centerOnLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 10);
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
    if (_isLocationLoaded && _currentLocation != null) {
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
      body: StreamBuilder<List<Platform>>(
        stream: widget.database.select(widget.database.platforms).watch(),
        builder: (context, snapshot) {
          final platforms = snapshot.data ?? [];
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
        onPressed: _centerOnLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
