import 'package:flutter/material.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/models/platform.dart';

/// A compact badge displaying a platform or operational status.
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge] from a raw status string.
  const StatusBadge({
    required this.rawStatus,
    super.key,
  })  : status = null,
        operationalStatus = null,
        style = null;

  /// Creates a [StatusBadge] from a [PlatformStatus] enum value.
  const StatusBadge.fromStatus({
    required this.status,
    super.key,
  })  : rawStatus = null,
        operationalStatus = null,
        style = null;

  /// Creates a [StatusBadge] from an [OperationalStatus] enum value.
  const StatusBadge.fromOperationalStatus({
    required this.operationalStatus,
    super.key,
  })  : rawStatus = null,
        status = null,
        style = null;

  /// Creates a [StatusBadge] with an explicit [PlatformStatusStyle].
  const StatusBadge.fromStyle({
    required PlatformStatusStyle style,
    super.key,
  })  : rawStatus = null,
        status = null,
        operationalStatus = null,
        style = style;

  /// Raw status value from the API or local database.
  final String? rawStatus;

  /// Parsed platform status when constructed via [StatusBadge.fromStatus].
  final PlatformStatus? status;

  /// Parsed operational status when constructed via [StatusBadge.fromOperationalStatus].
  final OperationalStatus? operationalStatus;

  /// Explicit style when constructed via [StatusBadge.fromStyle].
  final PlatformStatusStyle? style;

  PlatformStatusStyle _resolveStyle() {
    final explicitStyle = style;
    if (explicitStyle != null) {
      return explicitStyle;
    }

    final resolvedStatus = status;
    if (resolvedStatus != null) {
      return PlatformStatusPalette.forStatus(resolvedStatus);
    }

    final resolvedOperationalStatus = operationalStatus;
    if (resolvedOperationalStatus != null) {
      return OperationalStatusPalette.forStatus(resolvedOperationalStatus);
    }

    return PlatformStatusPalette.resolve(rawStatus);
  }

  @override
  Widget build(BuildContext context) {
    final badgeStyle = _resolveStyle();

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
