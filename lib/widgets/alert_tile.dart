import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/models/alert.dart';

/// Card summarising an [Alert]: status, severity, event and last receive time.
class AlertTile extends StatelessWidget {
  /// Creates an [AlertTile].
  const AlertTile({required this.alert, super.key});

  /// Alert to display.
  final Alert alert;

  static final _dateFormat = DateFormat('MMM dd, yyyy, hh:mm a');

  static String _duration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes.clamp(0, 59)}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusStyle = AlertStatusPalette.forStatus(alert.status);
    final severityStyle = AlertSeverityPalette.forSeverity(alert.severity);
    final subtle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final lastReceive = alert.lastReceiveTime;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: statusStyle.color, width: 4)),
            ),
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusStyle.displayIcon, color: statusStyle.color, size: 32),
                        const SizedBox(height: 4),
                        _Chip(
                          label: alert.status == AlertStatus.acknowledged ? 'Ack' : statusStyle.label,
                          background: statusStyle.color.withValues(alpha: 0.2),
                          foreground: statusStyle.color,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Leave a line for the severity chip pinned to the top right.
                          const SizedBox(height: 20),
                          Text(alert.event, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          if (lastReceive != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Last received ${_dateFormat.format(lastReceive.toUtc())} UTC (${_duration(DateTime.now().difference(lastReceive))} ago)',
                                    style: subtle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _Chip(
              label: severityStyle.label,
              background: severityStyle.chipColor,
              foreground: severityStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
