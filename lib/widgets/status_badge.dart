import 'package:flutter/material.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/models/platform.dart';

/// A compact badge displaying a platform or operational status.
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge] from a raw status string.
  const StatusBadge({
    required this.rawStatus,
    this.showLeadingDot = false,
    super.key,
  })  : status = null,
        operationalStatus = null,
        style = null;

  /// Creates a [StatusBadge] from a [PlatformStatus] enum value.
  const StatusBadge.fromStatus({
    required this.status,
    this.showLeadingDot = false,
    super.key,
  })  : rawStatus = null,
        operationalStatus = null,
        style = null;

  /// Creates a [StatusBadge] from an [OperationalStatus] enum value.
  const StatusBadge.fromOperationalStatus({
    required this.operationalStatus,
    this.showLeadingDot = false,
    super.key,
  })  : rawStatus = null,
        status = null,
        style = null;

  /// Creates a [StatusBadge] with an explicit [PlatformStatusStyle].
  const StatusBadge.fromStyle({
    required PlatformStatusStyle this.style,
    this.showLeadingDot = false,
    super.key,
  })  : rawStatus = null,
        status = null,
        operationalStatus = null;

  /// Raw status value from the API or local database.
  final String? rawStatus;

  /// Parsed platform status when constructed via [StatusBadge.fromStatus].
  final PlatformStatus? status;

  /// Parsed operational status when constructed via [StatusBadge.fromOperationalStatus].
  final OperationalStatus? operationalStatus;

  /// Explicit style when constructed via [StatusBadge.fromStyle].
  final PlatformStatusStyle? style;

  /// When true, shows a dot before the label (passport summary mock).
  final bool showLeadingDot;

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeStyle.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLeadingDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: badgeStyle.textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            badgeStyle.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: badgeStyle.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
