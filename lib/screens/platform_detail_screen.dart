import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/components/common/container.dart';
import 'package:smart_tags/components/top_navigation.dart';
import 'package:smart_tags/models/platform.dart';

/// A screen displaying detailed information about a specific platform.
class PlatformDetailScreen extends StatelessWidget {
  /// Creates a [PlatformDetailScreen] widget.
  const PlatformDetailScreen({required this.platform, super.key});

  /// The platform data to display.
  final Platform platform;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigation(
        title: const Text('Platform Details'),
        leading: const BackButton(),
        actions: const [],
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
                      options: MapOptions(
                        initialCenter: platform.latestPosition,
                        initialZoom: 6,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/Ocean/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}',
                        ),
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/Ocean/World_Ocean_Reference/MapServer/tile/{z}/{y}/{x}',
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
                    platform.id,
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
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
