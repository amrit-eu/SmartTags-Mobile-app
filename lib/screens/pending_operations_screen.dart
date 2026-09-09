import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// Lists queued/failed deploy-recover passport events, with manual retry for
/// failed ones.
class PendingOperationsScreen extends ConsumerWidget {
  /// Creates a [PendingOperationsScreen].
  const PendingOperationsScreen({super.key});

  Future<void> _retry(BuildContext context, WidgetRef ref, PendingPassportEvent event) async {
    try {
      await ref.read(passportEventQueueProvider.notifier).retryFailed(event.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Synced.')));
      }
    } on Object catch (e) {
      debugPrint('Retry failed for pending operation ${event.id}: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retry failed: still queued.')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(pendingPassportEventsProvider).value ?? [];

    return Scaffold(
      appBar: TopNavigation(title: const Text('Queued Operations'), leading: const BackButton()),
      body: events.isEmpty
          ? const Center(child: Text('No queued operations.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final event = events[index];
                final isFailed = event.status == PendingOperationStatus.failed;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${event.action == DeployAction.deploy ? 'Deploy' : 'Recover'} — ${event.platformRef}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Chip(label: Text(isFailed ? 'Failed' : 'Pending')),
                          ],
                        ),
                        Text(DateFormat('MMM dd, yyyy, hh:mm a').format(event.createdAt)),
                        if (isFailed && event.lastError != null)
                          Text(
                            event.lastError!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                        if (isFailed)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _retry(context, ref, event),
                              child: const Text('Retry'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
