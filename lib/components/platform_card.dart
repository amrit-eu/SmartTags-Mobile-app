import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/platform.dart' as model_entity;
import 'package:smart_tags/screens/platform_detail_screen.dart';

class PlatformCard extends StatelessWidget {
  const PlatformCard({
    required this.platform,
    super.key,
  });

  final Platform platform;

  @override
  Widget build(BuildContext context) {
    final isActive = platform.status == 'Active';
    final backgroundColor = isActive ? const Color.fromARGB(255, 1, 56, 3) : const Color.fromARGB(255, 134, 3, 16);
    final borderColor = isActive ? const Color.fromARGB(255, 1, 146, 8) : const Color.fromARGB(255, 139, 3, 3);

    return GestureDetector(
      onTap: () {
        final platformModel = model_entity.Platform(
          id: platform.ref,
          model: platform.model,
          network: platform.network,
          latestPosition: LatLng(platform.lat, platform.lon),
          status: platform.status == 'Active'
              ? model_entity.PlatformStatus.active
              : model_entity.PlatformStatus.inactive,
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
              builder: (context) => PlatformDetailScreen(platform: platformModel),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
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
                        ),
                      ),
                      Text(
                        platform.ref,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color.fromARGB(134, 243, 217, 217),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Operation location',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${platform.operationLat.toStringAsFixed(2)}, ${platform.operationLon.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                platform.network,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
