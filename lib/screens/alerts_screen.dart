import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/widgets/alert_tile.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// Status filter applied on the [AlertsScreen] list.
enum AlertsFilter {
  /// Every alert.
  all('All'),

  /// Open alerts only.
  open('Open'),

  /// Acknowledged alerts only.
  acknowledged('Acknowledged'),

  /// Closed alerts only.
  closed('Closed');

  const AlertsFilter(this.label);

  /// Label shown on the selector.
  final String label;

  /// Whether [alert] passes this filter.
  bool matches(Alert alert) => switch (this) {
    all => true,
    open => alert.status == AlertStatus.open,
    acknowledged => alert.status == AlertStatus.acknowledged,
    closed => alert.status == AlertStatus.closed,
  };
}

/// Orders [alerts] by status (open, acknowledged, closed, other), then severity
/// (most severe first), then last receive time (most recent first).
List<Alert> sortAlertsByStatus(Iterable<Alert> alerts) {
  int statusRank(AlertStatus status) => switch (status) {
    AlertStatus.open => 0,
    AlertStatus.acknowledged => 1,
    AlertStatus.closed => 2,
    AlertStatus.unknown => 3,
  };

  return alerts.toList()..sort((a, b) {
    final byStatus = statusRank(a.status).compareTo(statusRank(b.status));
    if (byStatus != 0) return byStatus;
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

/// Full screen listing every alert (open, acknowledged and closed) of a platform.
class AlertsScreen extends ConsumerStatefulWidget {
  /// Creates an [AlertsScreen].
  const AlertsScreen({required this.platformRef, super.key});

  /// Reference of the platform whose alerts are listed.
  final String platformRef;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertsFilter _filter = AlertsFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertsAsync = ref.watch(alertsByResourceStreamProvider(widget.platformRef));
    final alerts = sortAlertsByStatus(alertsAsync.value ?? const <Alert>[]);
    final visible = alerts.where(_filter.matches).toList();

    return Scaffold(
      appBar: TopNavigation(title: const Text('Alerts'), leading: const BackButton()),
      body: alertsAsync.isLoading && !alertsAsync.hasValue
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    widget.platformRef,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final filter in AlertsFilter.values) ...[
                        ChoiceChip(
                          label: Text('${filter.label} (${alerts.where(filter.matches).length})'),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '${visible.length} ${visible.length == 1 ? 'alert' : 'alerts'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [for (final alert in visible) AlertTile(alert: alert)],
                        ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'No alerts',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
