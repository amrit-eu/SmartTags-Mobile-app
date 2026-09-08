import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/config/map_config.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/database/mappers/platform_mapper.dart';
import 'package:smart_tags/helpers/coordinate_format.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/permission_provider.dart';
import 'package:smart_tags/screens/deploy_platform_screen.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/status_badge.dart';
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
    final userPermissions = ref.watch(permissionProvider);
    // TODO(eawetchy): Example - Replace with actual programID once included in platform metadata and required permissions
    final canEditExamplePlatform = userPermissions.canEdit(Resource.deployment, programId: 16410);
    
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
                              child: Icon(
                                Icons.location_on,
                                color: PlatformStatusPalette.forStatus(platform.status).backgroundColor,
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
                          'Latest observation',
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

            _PlatformSummaryCard(platform: platform),
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
                    label: 'Last updated',
                    value:
                        '${DateFormat(
                          'MMM dd, yyyy, hh:mm a',
                        ).format(platform.lastUpdated)} UTC',
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Position',
                    value: formatLatLng(platform.operationLocation),
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
          onPressed: canEditExamplePlatform
              ? () async {
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
                }
              : null,
          backgroundColor: canEditExamplePlatform ? null : const Color.fromARGB(40, 40, 40, 40),
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

/// Passport-aligned summary on the platform details page (#97).
class _PlatformSummaryCard extends StatelessWidget {
  const _PlatformSummaryCard({required this.platform});

  final Platform platform;

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    final trimmed = value.trim();
    if (trimmed.toLowerCase() == 'unknown') {
      return '-';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dash(platform.platformCategory),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dash(platform.model),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge.fromOperationalStatus(
                operationalStatus: platform.operationalStatus,
                showLeadingDot: true,
              ),
            ],
          ),
          const Divider(height: 24),
          ContainerRow(
            label: 'WIGOS ID',
            value: _dash(platform.wigosId),
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Latest observation',
            value: formatLatLng(platform.latestPosition),
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Last updated',
            value:
                '${DateFormat('MMM dd, yyyy, hh:mm a').format(platform.lastUpdated)} UTC',
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Observing network',
            value: _dash(platform.observingNetwork ?? platform.network),
          ),
        ],
      ),
    );
  }
}
