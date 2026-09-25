import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/models/alert.dart';

/// Whether [alert] is open.
bool isOpenAlert(Alert alert) => alert.status == AlertStatus.open;

/// Returns the open [alerts], or the acknowledged ones when none is open,
/// ordered by severity (most severe first) then last receive time (most
/// recent first).
List<Alert> sortActiveAlerts(Iterable<Alert> alerts) {
  final open = alerts.where(isOpenAlert).toList();
  final shown = open.isNotEmpty ? open : alerts.where((a) => a.status == AlertStatus.acknowledged).toList();
  return shown..sort((a, b) {
    final bySeverity = a.severity.index.compareTo(b.severity.index);
    if (bySeverity != 0) return bySeverity;
    final aTime = a.lastReceiveTime;
    final bTime = b.lastReceiveTime;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  });
}

/// Shows the bottom sheet listing the open [alerts] of a platform.
///
/// [totalAlertCount] is the number shown in the "See all alerts (n)" action.
Future<void> showAlertsBottomSheet(
  BuildContext context, {
  required List<Alert> alerts,
  required int totalAlertCount,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AlertsBottomSheet(alerts: alerts, totalAlertCount: totalAlertCount),
  );
}

/// Bottom sheet content listing active alerts with summary details.
class AlertsBottomSheet extends StatelessWidget {
  /// Creates an [AlertsBottomSheet].
  const AlertsBottomSheet({required this.alerts, required this.totalAlertCount, super.key});

  /// Alerts to display (filtered and sorted by the sheet).
  final List<Alert> alerts;

  /// Total number of alerts for the platform, all statuses included.
  final int totalAlertCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = sortActiveAlerts(alerts);
    final openCount = active.length;
    final onlyAcknowledged = active.isNotEmpty && !isOpenAlert(active.first);
    final headerStyle = onlyAcknowledged ? AlertStatusPalette.acknowledged : AlertStatusPalette.open;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(headerStyle.displayIcon, color: headerStyle.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alerts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '$openCount ${onlyAcknowledged ? 'acknowledged' : 'open'} ${openCount == 1 ? 'alert' : 'alerts'}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final alert in active) _AlertTile(alert: alert),
                    if (totalAlertCount > openCount)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text('See all alerts ($totalAlertCount)'),
                          trailing: const Icon(Icons.chevron_right),
                          // Navigation to the alert history is out of scope for now.
                          onTap: () {},
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

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
