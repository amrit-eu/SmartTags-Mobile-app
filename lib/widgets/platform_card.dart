import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/platform.dart' as model_entity;
import 'package:smart_tags/screens/platform_detail_screen.dart';
import 'package:smart_tags/widgets/status_badge.dart';

/// A card widget that displays details for a specific platform.
class PlatformCard extends StatelessWidget {
  /// Creates a [PlatformCard].
  const PlatformCard({
    required this.platform,
    super.key,
  });

  /// The platform data to be displayed in this card.
  final Platform platform;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusStyle = PlatformStatusPalette.resolve(platform.status);
    final platformStatus = model_entity.PlatformStatus.fromDb(platform.status);

    return GestureDetector(
      onTap: () {
        final platformModel = model_entity.Platform(
          platformRef: platform.ref,
          model: platform.model,
          network: platform.network,
          latestPosition: LatLng(platform.lat, platform.lon),
          status: platformStatus,
          operationalStatus: platform.operationalStatus == 'Deployed'
              ? model_entity.OperationalStatus.deployed
              : model_entity.OperationalStatus.recovered,
          lastUpdated: platform.lastUpdated,
          operationLocation: LatLng(
            platform.operationLat,
            platform.operationLon,
          ),
        );
        unawaited(
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => PlatformDetailScreen(platformRef: platformModel.platformRef),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: statusStyle.backgroundColor, width: 2),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform.model,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        platform.ref,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(rawStatus: platform.status),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                platform.network,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
