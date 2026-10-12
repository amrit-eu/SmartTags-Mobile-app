import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/screens/pending_operations_screen.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

/// Persistent indicator shown in the main shell when deploy/recover events
/// are queued locally, awaiting (or failing) submission to the Gateway.
class PendingOperationsBanner extends ConsumerStatefulWidget {
  /// Creates a [PendingOperationsBanner].
  const PendingOperationsBanner({super.key});

  @override
  ConsumerState<PendingOperationsBanner> createState() => _PendingOperationsBannerState();
}

class _PendingOperationsBannerState extends ConsumerState<PendingOperationsBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingPassportEventsProvider, (previous, next) {
      final previousEvents = previous?.value;
      final nextEvents = next.value;

      if (_dismissed &&
          previousEvents != null &&
          nextEvents != null &&
          _queueSignature(previousEvents) != _queueSignature(nextEvents)) {
        setState(() {
          _dismissed = false;
        });
      }
    });

    final events = ref.watch(pendingPassportEventsProvider).value ?? const <PendingPassportEvent>[];

    if (events.isEmpty || _dismissed) {
      return const SizedBox.shrink();
    }

    final failedCount = events
        .where(
          (event) => event.status == PendingOperationStatus.failed,
        )
        .length;

    return AppStatusBanner(
      message:
          '${events.length} operation${events.length == 1 ? '' : 's'} queued'
          '${failedCount > 0 ? ', $failedCount failed' : ''}',
      severity: failedCount > 0 ? AppStatusBannerSeverity.error : AppStatusBannerSeverity.info,
      icon: failedCount > 0 ? Icons.sync_problem : Icons.sync,
      actionLabel: 'View',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PendingOperationsScreen(),
          ),
        );
      },
      onDismiss: () {
        setState(() {
          _dismissed = true;
        });
      },
    );
  }

  String _queueSignature(List<PendingPassportEvent> events) {
    final sortedEvents = [...events]..sort((first, second) => first.id.compareTo(second.id));

    return sortedEvents
        .map(
          (event) =>
              '${event.id}:'
              '${event.status.name}:'
              '${event.attempts}:'
              '${event.lastError ?? ''}',
        )
        .join('|');
  }
}
