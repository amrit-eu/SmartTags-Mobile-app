import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/config/map_config.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/mappers/platform_mapper.dart';
import 'package:smart_tags/helpers/coordinate_format.dart';
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/map/smart_tags_marker_cluster_layer_widget.dart';
import 'package:smart_tags/models/platform.dart' as model;
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/map_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';
import 'package:smart_tags/widgets/map_pull_to_refresh.dart';
import 'package:smart_tags/widgets/map_skeleton_loader.dart';
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
    this.showMapSkeleton = true,
    this.reportMarkersPainted = true,
    this.recenterOnMarkerSelect = true,
  });

  /// Optional test / injection hook to provide a LocationFetcher
  @visibleForTesting
  final LocationFetcher? locationFetcher;

  /// Optional callback called after the map is centered on the user's location
  @visibleForTesting
  final ValueChanged<LatLng>? onLocationCentered;

  /// Whether to show a skeleton overlay while basemap tiles load on first open.
  @visibleForTesting
  final bool showMapSkeleton;

  /// Whether to notify [mapMarkersPaintedProvider] after markers are built.
  @visibleForTesting
  final bool reportMarkersPainted;

  /// Whether selecting a marker pans the map to keep it clear of the popup.
  @visibleForTesting
  final bool recenterOnMarkerSelect;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  LatLng? _currentLocation;
  late final MapController _mapController;
  late AnimationController _pulseController;
  late AnimationController _popupAnimationController;
  AnimationController? _mapPanAnimationController;
  late final ValueNotifier<model.Platform?> _selectedPlatformNotifier;

  /// Cached platform markers — rebuilt only when the platforms list changes.
  List<Platform>? _markersCacheSource;
  List<Marker> _platformMarkers = const [];
  final Map<String, _PlatformMapMarkerState> _platformMarkerStates = {};
  var _ignoreNextBackgroundTap = false;
  ProviderSubscription<AsyncValue<Platform?>>? _selectedPlatformSubscription;

  // Initial map center (Atlantic Ocean, near Europe as in reference image)
  static const LatLng _defaultCenter = LatLng(45, -5);
  static const double _defaultZoom = 4;

  static const int _minBaseTilesBeforeHideSkeleton = 4;
  static const Duration _mapSkeletonTimeout = Duration(seconds: 8);
  static const Duration _mapPanDuration = Duration(milliseconds: 450);
  static const Offset _popupMapCenterOffset = Offset(-40, 150);
  /// Spiderfy pin distance from cluster badge (px); default 40 overlaps 44px markers + ring.
  static const int _clusterSpiderfyCircleRadius = 58;
  static const double _clusterMaxZoom = 15;

  var _loadedBaseTileCount = 0;
  var _mapSkeletonVisible = false;
  var _mapSkeletonMounted = false;
  var _mapSkeletonDismissScheduled = false;
  final _countedBaseTiles = <String>{};
  var _markersPaintedScheduled = false;
  Timer? _mapSkeletonTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapSkeletonVisible = widget.showMapSkeleton;
    _mapSkeletonMounted = widget.showMapSkeleton;

    if (_mapSkeletonVisible) {
      _mapSkeletonTimeoutTimer = Timer(_mapSkeletonTimeout, () {
        if (mounted) {
          _scheduleDismissMapSkeleton();
        }
      });
    }

    // Animation controller for pulsing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.6,
      upperBound: 1.3,
    );
    unawaited(_pulseController.repeat(reverse: true));

    // Animation controller for popup effect.
    _popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _selectedPlatformNotifier = ValueNotifier<model.Platform?>(null);
  }

  @override
  void dispose() {
    _mapSkeletonTimeoutTimer?.cancel();
    _mapPanAnimationController?.dispose();
    _pulseController.dispose();
    _popupAnimationController.dispose();
    _selectedPlatformSubscription?.close();
    _selectedPlatformNotifier.dispose();
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

  LatLng _mapCenterForPoint(LatLng point, double zoom, {Offset offset = Offset.zero}) {
    if (offset == Offset.zero) {
      return point;
    }
    final camera = _mapController.camera;
    final projected = camera.projectAtZoom(point, zoom);
    return camera.unprojectAtZoom(
      camera.rotatePoint(projected, projected - offset),
      zoom,
    );
  }

  void _stopMapPanAnimation() {
    _mapPanAnimationController?.stop();
    _mapPanAnimationController?.dispose();
    _mapPanAnimationController = null;
  }

  /// Smoothly pans so [point] sits below the top-left popup, not under it.
  bool _shouldRecenterForPopup(LatLng point) {
    final camera = _mapController.camera;
    final screen = camera.latLngToScreenOffset(point);
    final size = camera.nonRotatedSize;
    const popupRight = 256.0;
    const popupBottom = 300.0;
    const edgeMargin = 56.0;

    return screen.dx < popupRight ||
        screen.dy < popupBottom ||
        screen.dx > size.width - edgeMargin ||
        screen.dy > size.height - edgeMargin;
  }

  void _animateMapToPoint(
    LatLng point, {
    Offset offset = _popupMapCenterOffset,
    Duration duration = _mapPanDuration,
  }) {
    if (!widget.recenterOnMarkerSelect || !_shouldRecenterForPopup(point)) {
      return;
    }

    final zoom = _mapController.camera.zoom;
    final targetCenter = _mapCenterForPoint(point, zoom, offset: offset);
    final startCenter = _mapController.camera.center;

    if (startCenter.latitude == targetCenter.latitude &&
        startCenter.longitude == targetCenter.longitude) {
      return;
    }

    _stopMapPanAnimation();
    final controller = AnimationController(vsync: this, duration: duration);
    _mapPanAnimationController = controller;

    final latTween = Tween<double>(
      begin: startCenter.latitude,
      end: targetCenter.latitude,
    );
    final lngTween = Tween<double>(
      begin: startCenter.longitude,
      end: targetCenter.longitude,
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    unawaited(
      (controller
            ..addListener(() {
              _mapController.move(
                LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
                zoom,
              );
            })
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
                if (identical(_mapPanAnimationController, controller)) {
                  _mapPanAnimationController = null;
                }
                controller.dispose();
              }
            }))
          .forward(),
    );
  }

  void _selectPlatformMarker(
    Platform dbPlatform,
    LatLng position, {
    bool recenter = true,
  }) {
    _ignoreNextBackgroundTap = true;
    final previousRef = _selectedPlatformNotifier.value?.platformRef;
    _selectedPlatformNotifier.value = dbPlatform.toDomain();
    _updateMarkerHighlight(previousRef: previousRef, newRef: dbPlatform.ref);
    _watchSelectedPlatform(dbPlatform.ref);
    // Popup and map pan run together — no loading overlay (data is already local).
    unawaited(_popupAnimationController.forward(from: 0));
    if (recenter) {
      _animateMapToPoint(position);
    }
  }

  void _onClusterTap(MarkerClusterNode cluster) {
    _ignoreNextBackgroundTap = true;
    _dismissSelectedPlatform();
    _stopMapPanAnimation();
    // Camera pan/zoom + spiderfy are handled by [MarkerClusterLayer] animations.
  }

  void _watchSelectedPlatform(String platformRef) {
    _selectedPlatformSubscription?.close();
    _selectedPlatformSubscription = ref.listenManual(
      platformByRefStreamProvider(platformRef),
      (previous, next) {
        next.whenData((platform) {
          if (platform != null && mounted) {
            final current = _selectedPlatformNotifier.value;
            final newPosition = LatLng(platform.lat, platform.lon);
            _selectedPlatformNotifier.value = platform.toDomain();
            // Skip re-pan when the stream echoes the same coordinates we already show.
            if (current != null &&
                (current.latestPosition.latitude - newPosition.latitude).abs() < 0.00001 &&
                (current.latestPosition.longitude - newPosition.longitude).abs() < 0.00001) {
              return;
            }
            _animateMapToPoint(newPosition);
          }
        });
      },
    );
  }

  void _onMapBackgroundTap(TapPosition tapPosition, LatLng point) {
    if (_ignoreNextBackgroundTap) {
      _ignoreNextBackgroundTap = false;
      return;
    }
    if (_selectedPlatformNotifier.value != null) {
      _clearSelection();
    }
  }

  /// Closes popup, ring, and stream subscription without affecting cluster spiderfy state.
  void _dismissSelectedPlatform() {
    final previousRef = _selectedPlatformNotifier.value?.platformRef;
    if (previousRef == null) {
      return;
    }
    _stopMapPanAnimation();
    _selectedPlatformSubscription?.close();
    _selectedPlatformSubscription = null;
    _selectedPlatformNotifier.value = null;
    _updateMarkerHighlight(previousRef: previousRef);
    if (_popupAnimationController.isAnimating) {
      _popupAnimationController.stop();
    }
  }

  /// Clears the selected platform.
  void _clearSelection() {
    _dismissSelectedPlatform();
  }

  void _onBaseTileLoaded(TileImage tile) {
    if (!_mapSkeletonVisible || tile.loadError || !tile.readyToDisplay) {
      return;
    }

    final tileKey = '${tile.coordinates.z}_${tile.coordinates.x}_${tile.coordinates.y}';
    if (!_countedBaseTiles.add(tileKey)) {
      return;
    }

    _loadedBaseTileCount++;
    if (_loadedBaseTileCount >= _minBaseTilesBeforeHideSkeleton) {
      _scheduleDismissMapSkeleton();
    }
  }

  void _scheduleDismissMapSkeleton() {
    if (!_mapSkeletonVisible || _mapSkeletonDismissScheduled) {
      return;
    }
    _mapSkeletonDismissScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _dismissMapSkeleton();
    });
  }

  void _dismissMapSkeleton() {
    if (!_mapSkeletonVisible) {
      return;
    }
    setState(() {
      _mapSkeletonVisible = false;
    });
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _mapSkeletonMounted = false;
        });
      }
    });
  }

  Widget _baseTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    _onBaseTileLoaded(tile);
    return tileWidget;
  }

  void _scheduleMarkersPaintedNotification() {
    if (_markersPaintedScheduled) {
      return;
    }
    _markersPaintedScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(mapMarkersPaintedProvider.notifier).markPainted();
      });
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
                          'WMO ID: ${platform.platformRef}',
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
                formatLatitude(platform.latestPosition.latitude),
              ),
              const SizedBox(height: 8),
              _buildPopupInfoRow(
                'Longitude',
                formatLongitude(platform.latestPosition.longitude),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => PlatformDetailScreen(platformRef: platform.platformRef),
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
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Marker _platformMarkerFor(Platform dbPlatform) {
    final point = LatLng(dbPlatform.lat, dbPlatform.lon);
    final selectedRef = _selectedPlatformNotifier.value?.platformRef;
    return Marker(
      key: ValueKey('platform-marker-${dbPlatform.ref}'),
      point: point,
      width: _PlatformMapMarker.markerSize,
      height: _PlatformMapMarker.markerSize,
      alignment: Alignment.center,
      child: _PlatformMapMarker(
        dbPlatform: dbPlatform,
        initiallySelected: dbPlatform.ref == selectedRef,
        onTap: () => _selectPlatformMarker(dbPlatform, point),
        states: _platformMarkerStates,
      ),
    );
  }

  void _updateMarkerHighlight({String? previousRef, String? newRef}) {
    if (previousRef != null) {
      _platformMarkerStates[previousRef]?.setSelected(selected: false);
    }
    if (newRef != null) {
      _platformMarkerStates[newRef]?.setSelected(selected: true);
    }
  }

  List<Marker> _platformMarkersFor(List<Platform> databasePlatforms) {
    if (!identical(_markersCacheSource, databasePlatforms)) {
      _markersCacheSource = databasePlatforms;
      _platformMarkers = databasePlatforms
          .map(_platformMarkerFor)
          .toList(growable: false);
    }
    return _platformMarkers;
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

    markers.addAll(_platformMarkersFor(databasePlatforms));

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final platformsAsync = ref.watch(platformsStreamProvider);

    final platforms = platformsAsync.value ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          await _centerOnLocation(context);
        },
        child: const Icon(Icons.my_location),
      ),
      body: MapPullToRefresh(
        enabled: !_mapSkeletonVisible,
        // Header only — do not start a pull from the map tiles.
        edgeStartMaxY: kToolbarHeight,
        onRefresh: _refreshPlatforms,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: TopNavigation(title: const Text('SmartTags')),
            ),
            Expanded(
              child: platformsAsync.when(
                loading: () => _buildMapBody(platforms),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: _buildMapBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBody(List<Platform> platforms) {
    if (widget.reportMarkersPainted && platforms.isNotEmpty) {
      _scheduleMarkersPaintedNotification();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
              interactionOptions: const InteractionOptions(
                keyboardOptions: KeyboardOptions(
                  enableRFZooming: true,
                ),
              ),
              onTap: _onMapBackgroundTap,
            ),
            children: [
            TileLayer(
              urlTemplate: MapConfig.oceanBaseTileUrl,
              userAgentPackageName: MapConfig.userAgentPackageName,
              tileBuilder: _baseTileBuilder,
            ),
            TileLayer(
              urlTemplate: MapConfig.oceanReferenceTileUrl,
              userAgentPackageName: MapConfig.userAgentPackageName,
            ),
            SmartTagsMarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 120,
                size: const Size(40, 40),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                maxZoom: _clusterMaxZoom,
                showPolygon: false,
                spiderfyCircleRadius: _clusterSpiderfyCircleRadius,
                markerChildBehavior: true,
                centerMarkerOnClick: false,
                onClusterTap: _onClusterTap,
                markers: _buildMarkers(platforms),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            ],
          ),
        ),
        ValueListenableBuilder<model.Platform?>(
          valueListenable: _selectedPlatformNotifier,
          builder: (context, selectedPlatform, _) {
            if (selectedPlatform == null) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 20,
              left: 16,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(
                  CurvedAnimation(parent: _popupAnimationController, curve: Curves.easeOutCubic),
                ),
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {},
                  child: _buildPopup(context, selectedPlatform),
                ),
              ),
            );
          },
        ),
        if (_mapSkeletonMounted)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_mapSkeletonVisible,
              child: AnimatedOpacity(
                opacity: _mapSkeletonVisible ? 1 : 0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: const MapSkeletonLoader(),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _refreshPlatforms() async {
    // Errors are shown by [InitialSyncShell] (top banner + Retry).
    await ref.read(platformsRefreshProvider.notifier).refresh();
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

class _PlatformMapMarker extends StatefulWidget {
  const _PlatformMapMarker({
    required this.dbPlatform,
    required this.onTap,
    required this.states,
    required this.initiallySelected,
  });

  static const markerSize = 44.0;

  final Platform dbPlatform;
  final VoidCallback onTap;
  final Map<String, _PlatformMapMarkerState> states;
  final bool initiallySelected;

  @override
  State<_PlatformMapMarker> createState() => _PlatformMapMarkerState();
}

class _PlatformMapMarkerState extends State<_PlatformMapMarker> {
  static const _selectionRingColor = Color.fromARGB(255, 2, 0, 101);
  static const Duration _ringFadeDuration = Duration(milliseconds: 150);
  static const _pinSize = 30.0;
  static const double _ringSize = _PlatformMapMarker.markerSize;

  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected;
    widget.states[widget.dbPlatform.ref] = this;
  }

  @override
  void dispose() {
    if (widget.states[widget.dbPlatform.ref] == this) {
      widget.states.remove(widget.dbPlatform.ref);
    }
    super.dispose();
  }

  void setSelected({required bool selected}) {
    if (_selected != selected && mounted) {
      setState(() => _selected = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.location_on,
            color: PlatformStatusPalette.resolve(widget.dbPlatform.status).backgroundColor,
            size: _pinSize,
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _selected ? 1 : 0,
              duration: _ringFadeDuration,
              curve: Curves.easeOut,
              child: Container(
                width: _ringSize,
                height: _ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectionRingColor,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
