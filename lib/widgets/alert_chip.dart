import 'package:flutter/material.dart';

/// A small rounded pill used to display an alert's status or severity.
class AlertChip extends StatelessWidget {
  /// Creates an [AlertChip].
  const AlertChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    super.key,
  });

  /// Text displayed inside the chip.
  final String label;

  /// Background colour of the chip.
  final Color background;

  /// Colour of the label (and [icon], if any).
  final Color foreground;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
