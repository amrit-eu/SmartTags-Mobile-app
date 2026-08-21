import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/screens/pending_operations_screen.dart';

/// Persistent indicator shown in the main shell when deploy/recover events
/// are queued locally, awaiting (or failing) submission to the Gateway.
class PendingOperationsBanner extends ConsumerWidget {
  /// Creates a [PendingOperationsBanner].
  const PendingOperationsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(pendingPassportEventsProvider).value ?? [];
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final failedCount = events.where((event) => event.status == PendingOperationStatus.failed).length;
    final theme = Theme.of(context);

    return Material(
      color: failedCount > 0
          ? theme.colorScheme.errorContainer.withValues(alpha: 0.85)
          : theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Icon(failedCount > 0 ? Icons.sync_problem : Icons.sync, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${events.length} operation${events.length == 1 ? '' : 's'} queued'
                    '${failedCount > 0 ? ', $failedCount failed' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const PendingOperationsScreen()),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
