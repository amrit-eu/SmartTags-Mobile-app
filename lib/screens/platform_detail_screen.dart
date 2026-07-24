import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/config/map_config.dart';
import 'package:smart_tags/database/mappers/platform_mapper.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/deploy_platform_screen.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen displaying detailed information about a specific platform.
class PlatformDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [PlatformDetailScreen] widget.
  const PlatformDetailScreen({required this.platformRef, super.key});

  /// The platform reference used to watch live updates from the database.
  final String platformRef;

  @override
  ConsumerState<PlatformDetailScreen> createState() => _PlatformDetailScreenState();
}

class _PlatformDetailScreenState extends ConsumerState<PlatformDetailScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformAsync = ref.watch(platformByRefStreamProvider(widget.platformRef));
    
    // Listen for position updates and auto-center map
    ref.listen(platformByRefStreamProvider(widget.platformRef), (previous, next) {
      next.whenData((dbPlatform) {
        if (dbPlatform != null && mounted) {
          final newPosition = LatLng(dbPlatform.lat, dbPlatform.lon);
          _mapController.move(newPosition, _mapController.camera.zoom);
        }
      });
    });
    
    final platform = platformAsync.value?.toDomain();
    if (platform == null) {
      return Scaffold(
        appBar: TopNavigation(title: const Text('Platform Details'), leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: TopNavigation(
        title: const Text('Platform Details'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SectionContainer(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: platform.latestPosition,
                        initialZoom: 10,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none
                        )
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: MapConfig.oceanBaseTileUrl,
                          userAgentPackageName: MapConfig.userAgentPackageName,
                        ),
                        TileLayer(
                          urlTemplate: MapConfig.oceanReferenceTileUrl,
                          userAgentPackageName: MapConfig.userAgentPackageName,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: platform.latestPosition,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Latest position',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Platform Metadata Section
            SectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    platform.model,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    platform.platformRef,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(height: 24),
                  ContainerRow(
                    label: 'Latest position',
                    value:
                        '${platform.latestPosition.latitude.toStringAsFixed(3)}, '
                        '${platform.latestPosition.longitude.toStringAsFixed(3)}',
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Network',
                    value: platform.network,
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Status',
                    value: platform.status == PlatformStatus.active ? 'Active' : 'Inactive',
                    valueColor: platform.status == PlatformStatus.active ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Latest Operation Section
            SectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Operation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  ContainerRow(
                    label: 'Operational Status',
                    value: platform.operationalStatus == OperationalStatus.deployed ? 'Deployed' : 'Recovered',
                    valueColor: platform.operationalStatus == OperationalStatus.deployed ? Colors.blue : Colors.orange,
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Last updated',
                    value:
                        '${DateFormat(
                          'MMM dd, yyyy, hh:mm a',
                        ).format(platform.lastUpdated)} UTC',
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Position',
                    value:
                        '${platform.operationLocation.latitude.toStringAsFixed(3)}, '
                        '${platform.operationLocation.longitude.toStringAsFixed(3)}',
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Notes',
                    value: '${
                      platform.operationNotes != null && platform.operationNotes!.isNotEmpty
                      ? platform.operationNotes
                      : 'No additional notes.'
                    }',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 72),
          ],
        ),
      ),
      floatingActionButton: 
        FloatingActionButton.extended(
          heroTag: platform.operationalStatus == OperationalStatus.deployed ? 'recover' : 'deploy',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<DeployPlatformScreen>(
                builder: (context) => DeployPlatformScreen(
                  action: platform.operationalStatus == OperationalStatus.deployed
                  ? DeployAction.recover
                  : DeployAction.deploy,
                  platform: platform,
                ),
              ),
            );
          },
          icon: platform.operationalStatus == OperationalStatus.deployed
          ? const Icon(Icons.repeat)
          : const Icon(Icons.arrow_circle_up_rounded),
          label: platform.operationalStatus == OperationalStatus.deployed
          ? const Text('Recover')
          : const Text('Deploy'),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
