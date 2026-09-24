import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/models/alert.dart';

/// Whether [alert] is still requiring attention (open or acknowledged).
bool isActiveAlert(Alert alert) => alert.status == AlertStatus.open || alert.status == AlertStatus.acknowledged;

/// Returns the open/acknowledged [alerts], ordered by severity (most severe
/// first) then last receive time (most recent first).
List<Alert> sortActiveAlerts(Iterable<Alert> alerts) {
  return alerts.where(isActiveAlert).toList()..sort((a, b) {
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

/// Shows the bottom sheet listing the open/acknowledged [alerts] of a platform.
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
    final openCount = active.where((a) => a.status == AlertStatus.open).length;

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
                  Icon(AlertStatusPalette.open.displayIcon, color: AlertStatusPalette.open.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alerts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '$openCount open ${openCount == 1 ? 'alert' : 'alerts'}',
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
                    Card(
                      margin: const EdgeInsets.only(top: 4),
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
    final created = alert.createTime;
    final value = alert.value?.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: statusStyle.color, width: 4)),
        ),
        child: ListTile(
          // Navigation to the alert details is out of scope for now.
          onTap: () {},
          leading: Icon(statusStyle.displayIcon, color: statusStyle.color, size: 32),
          title: Row(
            children: [
              Expanded(
                child: Text(alert.event, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
              _Chip(
                label: severityStyle.label,
                background: severityStyle.chipColor,
                foreground: severityStyle.textColor,
              ),
              const SizedBox(width: 6),
              _Chip(
                label: statusStyle.label,
                background: statusStyle.color.withValues(alpha: 0.2),
                foreground: statusStyle.color,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value != null && value.isNotEmpty) Text('Value: $value', style: subtle),
              if (lastReceive != null)
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('Last received ${_dateFormat.format(lastReceive.toUtc())} UTC', style: subtle),
                    ),
                  ],
                ),
              if (created != null)
                Text(
                  'Duration: ${_duration(DateTime.now().difference(created))}',
                  style: subtle,
                ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
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
