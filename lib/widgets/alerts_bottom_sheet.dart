import 'package:flutter/material.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/screens/alerts_screen.dart';
import 'package:smart_tags/widgets/alert_tile.dart';

/// Whether [alert] is open.
bool isOpenAlert(Alert alert) => alert.status == AlertStatus.open;

/// Returns the open [alerts], or the acknowledged ones when none is open,
/// sorted with [sortAlertsByStatus].
List<Alert> sortActiveAlerts(Iterable<Alert> alerts) {
  final open = alerts.where(isOpenAlert);
  return sortAlertsByStatus(open.isNotEmpty ? open : alerts.where((a) => a.status == AlertStatus.acknowledged));
}

/// Shows the bottom sheet listing the open [alerts] of a platform.
///
/// [totalAlertCount] is the number shown in the "See all alerts (n)" action.
Future<void> showAlertsBottomSheet(
  BuildContext context, {
  required List<Alert> alerts,
  required int totalAlertCount,
  required String platformRef,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AlertsBottomSheet(alerts: alerts, totalAlertCount: totalAlertCount, platformRef: platformRef),
  );
}

/// Bottom sheet content listing active alerts with summary details.
class AlertsBottomSheet extends StatelessWidget {
  /// Creates an [AlertsBottomSheet].
  const AlertsBottomSheet({
    required this.alerts,
    required this.totalAlertCount,
    required this.platformRef,
    super.key,
  });

  /// Alerts to display (filtered and sorted by the sheet).
  final List<Alert> alerts;

  /// Total number of alerts for the platform, all statuses included.
  final int totalAlertCount;

  /// Reference of the platform the alerts belong to.
  final String platformRef;

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
                    // display alert card for each alert in list :
                    for (final alert in active) AlertTile(alert: alert),
                    // display "see all alerts" if there is more alert to see
                    if (totalAlertCount > openCount)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text('See all alerts ($totalAlertCount)'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final navigator = Navigator.of(context)..pop();
                            await navigator.push(
                              MaterialPageRoute<void>(builder: (_) => AlertsScreen(platformRef: platformRef)),
                            );
                          },
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
