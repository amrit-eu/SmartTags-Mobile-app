import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Platform details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // More actions placeholder
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            _SectionContainer(
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
            _SectionContainer(
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
                  _MetadataRow(
                    label: 'Latest position',
                    value:
                        '${platform.latestPosition.latitude.toStringAsFixed(3)}, '
                        '${platform.latestPosition.longitude.toStringAsFixed(3)}',
                  ),
                  const Divider(height: 16),
                  _MetadataRow(
                    label: 'Network',
                    value: platform.network,
                  ),
                  const Divider(height: 16),
                  _MetadataRow(
                    label: 'Status',
                    value: platform.status == PlatformStatus.active ? 'Active' : 'Inactive',
                    valueColor: platform.status == PlatformStatus.active ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Latest Operation Section
            _SectionContainer(
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
                  _MetadataRow(
                    label: 'Operational Status',
                    value: platform.operationalStatus == OperationalStatus.deployed ? 'Deployed' : 'Recovered',
                    valueColor: platform.operationalStatus == OperationalStatus.deployed ? Colors.blue : Colors.orange,
                  ),
                  const Divider(height: 16),
                  _MetadataRow(
                    label: 'Last updated',
                    value:
                        '${DateFormat(
                          'MMM dd, yyyy, hh:mm a',
                        ).format(platform.lastUpdated)} UTC',
                  ),
                  const Divider(height: 16),
                  _MetadataRow(
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

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: height == null ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
