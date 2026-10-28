import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';
import 'package:smart_tags/theme/touch_target_theme.dart';
import 'package:smart_tags/widgets/status_badge.dart';

/// A card widget that displays details for a specific platform
class PlatformCard extends ConsumerWidget {
  /// Creates a [PlatformCard].
  const PlatformCard({
    required this.platform,
    this.onBeforeOpen,
    super.key,
  });

  /// The platform data to be displayed in this card.
  final Platform platform;

  /// Optional hook invoked before navigating to platform detail (e.g. catalogue history).
  final Future<void> Function()? onBeforeOpen;

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final touch = context.touchTargetSizes;
    final textBump = touch.platformCardTextSizeBump;

    final counts = ref.watch(
      alertCountsByResourceStreamProvider.select(
        (asyncCounts) => asyncCounts.value?[platform.ref] ?? (open: 0, acknowledged: 0),
      ),
    );
    final openCount = counts.open;
    final acknowledgedCount = counts.acknowledged;

    return GestureDetector(
      onTap: () async {
        await onBeforeOpen?.call();
        if (!context.mounted) return;
        Navigator.of(context)
            .push(
              MaterialPageRoute<void>(
                builder: (context) => PlatformDetailScreen(platformRef: platform.ref),
              ),
            )
            .ignore();
      },
      child: Container(
        padding: touch.platformCardPadding,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outline),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _dash(platform.category).toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurface,
                      fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) + textBump,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(rawStatus: platform.status),
              ],
            ),
            SizedBox(height: touch.enlarged ? 8 : 4),
            Text(
              _dash(platform.model),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) + textBump,
              ),
            ),
            SizedBox(height: touch.enlarged ? 8 : 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _dash(platform.wigosId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + textBump,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.circle, size: 4, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  _dash(platform.observingNetwork ?? platform.network),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + textBump,
                  ),
                ),
              ],
            ),
            if (openCount > 0 || acknowledgedCount > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (openCount > 0)
                    _AlertCountChip(count: openCount, style: AlertStatusPalette.open, enlarged: touch.enlarged),
                  if (openCount > 0 && acknowledgedCount > 0) const SizedBox(width: 8),
                  if (acknowledgedCount > 0)
                    _AlertCountChip(
                      count: acknowledgedCount,
                      style: AlertStatusPalette.acknowledged,
                      enlarged: touch.enlarged,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A pill-shaped chip showing an alert count for a given status, following
/// [AlertStatusPalette] colors.
class _AlertCountChip extends StatelessWidget {
  const _AlertCountChip({required this.count, required this.style, required this.enlarged});

  final int count;
  final AlertStatusStyle style;
  final bool enlarged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: enlarged ? 12 : 10, vertical: enlarged ? 8 : 6),
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${style.label} alerts',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
