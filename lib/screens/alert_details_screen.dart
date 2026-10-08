import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/database/mappers/platform_mapper.dart';
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/permission_provider.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/widgets/alert_chip.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen displaying the full details of a single [Alert].
class AlertDetailsScreen extends ConsumerWidget {
  /// Creates an [AlertDetailsScreen] for [alert].
  const AlertDetailsScreen({required this.alert, super.key});

  /// Alert to display.
  final Alert alert;

  /// Attribute keys already surfaced as dedicated fields/sections elsewhere
  /// on the screen, so they aren't repeated in "Other information".
  static const _attributesShownElsewhere = {'country', 'alert_category', 'url', 'guidance'};

  static final _dateFormat = DateFormat('MMM dd, yyyy, hh:mm a');

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  static String _date(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return '${_dateFormat.format(value.toUtc())} UTC';
  }

  /// Looks up [key] in [attributes] case-insensitively and formats it,
  /// returning null when absent or empty.
  static String? _attributeText(Map<String, dynamic>? attributes, String key) {
    if (attributes == null) {
      return null;
    }
    for (final entry in attributes.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        final formatted = _formatAttributeValue(entry.value);
        return formatted == '-' ? null : formatted;
      }
    }
    return null;
  }

  static String _urlHost(String url) {
    final host = Uri.tryParse(url)?.host;
    return (host != null && host.isNotEmpty) ? host : url;
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Permissions: the alert resource is the platform ref.
    final platform = ref.watch(platformByRefStreamProvider(alert.resource)).value?.toDomain();
    final userPermissions = ref.watch(permissionProvider);
    final programId = platform?.program?.id;
    final hasPlatform = platform != null;
    final canAcknowledge =
        hasPlatform && userPermissions.canAckAlert(programId: programId) && alert.status == AlertStatus.open;
    final canUnacknowledge =
        hasPlatform && userPermissions.canUnackAlert(programId: programId) && alert.status == AlertStatus.acknowledged;
    final canClose =
        hasPlatform &&
        userPermissions.canCloseAlert(programId: programId) &&
        (alert.status == AlertStatus.open || alert.status == AlertStatus.acknowledged);
    final canOpen =
        hasPlatform && userPermissions.canOpenAlert(programId: programId) && alert.status == AlertStatus.closed;
    final canAddNote = hasPlatform && userPermissions.canAddANoteToAlert(programId: programId);

    final actionCount = [canAcknowledge, canUnacknowledge, canClose, canOpen, canAddNote].where((c) => c).length;

    final ackColor = AlertStatusPalette.acknowledged.color;
    final closeColor = AlertStatusPalette.closed.color;
    final openColor = AlertStatusPalette.open.color;

    final statusStyle = AlertStatusPalette.forStatus(alert.status);
    final severityStyle = AlertSeverityPalette.forSeverity(alert.severity);
    final attributes = alert.attributes;
    final guidance = _attributeText(attributes, 'guidance');
    final url = alert.url;
    final hasUrl = url != null && url.trim().isNotEmpty;
    final lastNote = alert.lastNote;
    final hasLastNote = lastNote != null && lastNote.trim().isNotEmpty;
    final otherInfoEntries = <MapEntry<String, String>>[
      MapEntry("Alert's id", _dash(alert.id)),
      MapEntry('Service', _dash(alert.service)),
      if (alert.origin != null && alert.origin!.trim().isNotEmpty) MapEntry('Origin', _dash(alert.origin)),
      MapEntry('Category', _dash(alert.alertCategory)),
      if (alert.previousSeverity != AlertSeverity.unknown)
        MapEntry('Previous severity', AlertSeverityPalette.forSeverity(alert.previousSeverity).label),
      if (alert.duplicateCount > 0) MapEntry('Duplicate count', '${alert.duplicateCount}'),
      MapEntry('Last received time', _date(alert.lastReceiveTime)),
      MapEntry('Alert creation time', _date(alert.createTime)),
      if (attributes != null)
        for (final entry in attributes.entries)
          if (entry.value != null && !_attributesShownElsewhere.contains(entry.key.toLowerCase()))
            MapEntry(_formatAttributeLabel(entry.key), _formatAttributeValue(entry.value)),
    ];

    return Scaffold(
      appBar: TopNavigation(title: const Text('Alert Details'), leading: const BackButton()),
      floatingActionButton: actionCount == 0
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 12,
              children: [
                if (canAddNote)
                  FloatingActionButton.extended(
                    heroTag: 'alert-add-note',
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    onPressed: () => _addNote(context, ref),
                    icon: const Icon(Icons.message_outlined),
                    label: const Text('Add a note'),
                  ),
                if (canClose)
                  FloatingActionButton.extended(
                    heroTag: 'alert-close',
                    backgroundColor: closeColor,
                    foregroundColor: Colors.white,
                    onPressed: () => _act(context, ref, AlertAction.close),
                    icon: Icon(AlertStatusPalette.closed.actionIcon),
                    label: const Text('Close'),
                  ),
                if (canOpen)
                  FloatingActionButton.extended(
                    heroTag: 'alert-open',
                    backgroundColor: openColor,
                    foregroundColor: Colors.black,
                    onPressed: () => _act(context, ref, AlertAction.open),
                    icon: Icon(AlertStatusPalette.open.actionIcon),
                    label: const Text('Open'),
                  ),
                if (canUnacknowledge)
                  FloatingActionButton.extended(
                    heroTag: 'alert-unack',
                    backgroundColor: ackColor,
                    foregroundColor: Colors.black,
                    onPressed: () => _act(context, ref, AlertAction.unack),
                    icon: const Icon(Icons.undo),
                    label: const Text('Unacknowledge'),
                  ),
                if (canAcknowledge)
                  FloatingActionButton.extended(
                    heroTag: 'alert-ack',
                    backgroundColor: ackColor,
                    foregroundColor: Colors.black,
                    onPressed: () => _act(context, ref, AlertAction.ack),
                    icon: Icon(AlertStatusPalette.acknowledged.actionIcon),
                    label: const Text('Acknowledge'),
                  ),
              ],
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, actionCount == 0 ? 16 : 16 + actionCount * 68.0 + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AlertChip(
                        label: alert.status == AlertStatus.acknowledged ? 'Ack' : statusStyle.label,
                        background: statusStyle.color.withValues(alpha: 0.2),
                        foreground: statusStyle.color,
                        icon: statusStyle.displayIcon,
                      ),
                      const Spacer(),
                      AlertChip(
                        label: severityStyle.label,
                        background: severityStyle.chipColor,
                        foreground: severityStyle.textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.event,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (alert.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    HtmlWidget(
                      alert.description,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      onTapUrl: (url) {
                        unawaited(_launchUrl(url));
                        return true;
                      },
                    ),
                  ],
                  if (hasUrl) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl(url),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text('See more on ${_urlHost(url)}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (guidance != null) ...[
              SectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guidance',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    Text(guidance, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key attributes',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  ContainerRow(label: 'Resource', value: _dash(alert.resource)),
                  const Divider(height: 16),
                  ContainerRow(label: 'Event', value: _dash(alert.event)),
                  const Divider(height: 16),
                  ContainerRow(label: 'Severity', value: severityStyle.label),
                  const Divider(height: 16),
                  ContainerRow(label: 'Status', value: statusStyle.label),
                  const Divider(height: 16),
                  ContainerRow(label: 'Country', value: _dash(alert.country)),
                  const Divider(height: 16),
                  ContainerRow(label: 'Value', value: _dash(alert.value)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (hasLastNote) ...[
              SectionContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'Last note',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(lastNote, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Other information',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  for (var i = 0; i < otherInfoEntries.length; i++) ...[
                    ContainerRow(label: otherInfoEntries[i].key, value: otherInfoEntries[i].value),
                    if (i != otherInfoEntries.length - 1) const Divider(height: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Applies [action] to [alert] through the Gateway, then leaves the screen
  /// and schedules a delayed platforms refresh to pick up the change.
  Future<void> _act(BuildContext context, WidgetRef ref, AlertAction action) {
    return _submit(
      context,
      ref,
      send: (repository) => repository.actOnAlert(alert.id, action),
      successMessage: switch (action) {
        AlertAction.ack => 'Alert acknowledged',
        AlertAction.unack => 'Alert unacknowledged',
        AlertAction.close => 'Alert closed',
        AlertAction.open => 'Alert reopened',
      },
    );
  }

  /// Asks the user for a note, then adds it to [alert] through the Gateway.
  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final text = await showDialog<String>(context: context, builder: (_) => const _AddNoteDialog());
    if (text == null || text.trim().isEmpty || !context.mounted) {
      return;
    }
    await _submit(
      context,
      ref,
      send: (repository) => repository.addAlertNote(alert.id, text.trim()),
      successMessage: 'Note added',
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function(GatewayRepository repository) send,
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final refresh = ref.read(platformsRefreshProvider.notifier);
    try {
      await send(ref.read(gatewayRepositoryProvider));
    } on GatewayException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    navigator.pop();
    // Fire-and-forget: give the back-end time to process before re-fetching.
    refresh.refreshAfterDelay().ignore();
  }

  /// Turns a raw attribute key (e.g. `wigos_id`) into a human-readable label.
  static String _formatAttributeLabel(String key) {
    final words = key.replaceAll('_', ' ').replaceAll('-', ' ').trim().split(RegExp(r'\s+'));
    return words.map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  /// Renders an attribute's value regardless of its type (string, number,
  /// list, or nested map), since `attributes` is a free-form JSON blob whose
  /// shape varies per alert source.
  static String _formatAttributeValue(dynamic value) {
    if (value == null) {
      return '-';
    }
    if (value is List) {
      if (value.isEmpty) {
        return '-';
      }
      return value.map(_formatAttributeValue).join(', ');
    }
    if (value is Map) {
      if (value.isEmpty) {
        return '-';
      }
      return value.entries.map((entry) => '${entry.key}: ${_formatAttributeValue(entry.value)}').join(', ');
    }
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }
}

/// Dialog asking the user for the text of a note.
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a note'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Note', border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(_controller.text), child: const Text('Add')),
      ],
    );
  }
}
