import 'package:flutter/material.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/models/platform.dart';

/// A compact badge displaying a platform status with CT-RST colours.
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge] from a raw status string.
  const StatusBadge({
    required this.rawStatus,
    super.key,
  }) : status = null;

  /// Creates a [StatusBadge] from a [PlatformStatus] enum value.
  const StatusBadge.fromStatus({
    required this.status,
    super.key,
  }) : rawStatus = null;

  /// Raw status value from the API or local database.
  final String? rawStatus;

  /// Parsed platform status when constructed via [StatusBadge.fromStatus].
  final PlatformStatus? status;

  @override
  Widget build(BuildContext context) {
    final PlatformStatusStyle badgeStyle;
    final resolvedStatus = status;
    if (resolvedStatus != null) {
      badgeStyle = PlatformStatusPalette.forStatus(resolvedStatus);
    } else {
      badgeStyle = PlatformStatusPalette.resolve(rawStatus);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeStyle.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeStyle.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: badgeStyle.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
