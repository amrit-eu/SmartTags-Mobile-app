import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';
import 'package:smart_tags/widgets/status_badge.dart';

/// A card widget that displays details for a specific platform
class PlatformCard extends ConsumerWidget {
  /// Creates a [PlatformCard].
  const PlatformCard({
    required this.platform,
    super.key,
  });

  /// The platform data to be displayed in this card.
  final Platform platform;

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

    final counts = ref.watch(
      alertCountsByResourceStreamProvider.select(
        (asyncCounts) => asyncCounts.value?[platform.ref] ?? (open: 0, acknowledged: 0),
      ),
    );
    final openCount = counts.open;
    final acknowledgedCount = counts.acknowledged;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute<void>(
                builder: (context) => PlatformDetailScreen(platformRef: platform.ref),
              ),
            )
            .ignore();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(rawStatus: platform.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _dash(platform.model),
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    _dash(platform.wigosId),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.circle, size: 4, color: colorScheme.onSurfaceVariant),
                ),
                Flexible(
                  child: Text(
                    _dash(platform.observingNetwork ?? platform.network),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            if (openCount > 0 || acknowledgedCount > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (openCount > 0) _AlertCountChip(count: openCount, style: AlertStatusPalette.open),
                  if (openCount > 0 && acknowledgedCount > 0) const SizedBox(width: 8),
                  if (acknowledgedCount > 0)
                    _AlertCountChip(count: acknowledgedCount, style: AlertStatusPalette.acknowledged),
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
  const _AlertCountChip({required this.count, required this.style});

  final int count;
  final AlertStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
