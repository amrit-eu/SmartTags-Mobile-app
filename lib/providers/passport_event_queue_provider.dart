import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/mappers/pending_operation_mapper.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/services/passport_event_mapper.dart';

/// Streams all queued deploy/recover events (pending + failed), oldest first.
final pendingPassportEventsProvider = StreamProvider<List<PendingPassportEvent>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPendingOperations().map((rows) => rows.map((row) => row.toDomain()).toList());
});

/// The result of attempting to submit a passport event via
/// [PassportEventQueueNotifier.enqueueOrSend].
enum PassportEventSubmitOutcome {
  /// Sent to the Gateway immediately.
  sent,

  /// Queued locally because the user isn't authenticated (or their session
  /// expired) — reconnecting alone won't resolve this; the user needs to log in.
  queuedAuthRequired,

  /// Queued locally because the device is offline or the request failed for
  /// another reason (network/server error); will be retried automatically.
  queued,
}

/// Coordinates submitting deploy/recover passport events to the Gateway,
/// queueing them locally when offline or when a submission attempt fails.
final passportEventQueueProvider = NotifierProvider<PassportEventQueueNotifier, void>(
  PassportEventQueueNotifier.new,
);

/// Notifier managing the offline queue of deploy/recover passport events.
class PassportEventQueueNotifier extends Notifier<void> {
  bool _replaying = false;

  @override
  void build() {}

  /// Attempts to send [request] immediately when online; otherwise (or on
  /// failure) queues it locally for later replay. Never throws: every
  /// failure path degrades to "queued".
  Future<PassportEventSubmitOutcome> enqueueOrSend({
    required String platformRef,
    required DeployAction action,
    required PassportEventRequest request,
  }) async {
    final db = ref.read(databaseProvider);
    final bodyJson = jsonEncode(PassportEventMapper.toJson(request));

    final connectivity = await _currentConnectivity();
    var authRequired = false;
    if (isDeviceOnline(connectivity)) {
      try {
        await ref.read(gatewayRepositoryProvider).submitPassportEventJson(bodyJson);
        return PassportEventSubmitOutcome.sent;
      } on Object catch (e) {
        authRequired = e is AuthException || e is GatewayAuthException;
        debugPrint('Immediate passport event submission failed, queuing: $e');
      }
    }

    await db.enqueuePendingOperation(
      PendingOperationsCompanion.insert(
        platformRef: platformRef,
        action: action == DeployAction.deploy ? 'deploy' : 'recover',
        payloadJson: bodyJson,
      ),
    );
    return authRequired ? PassportEventSubmitOutcome.queuedAuthRequired : PassportEventSubmitOutcome.queued;
  }

  /// Replays all `pending` rows in FIFO order. Skip-and-continue: a failed
  /// row is marked `failed` with [PendingOperation.lastError] and left in
  /// place; the loop still tries every later row. Safe to call repeatedly.
  Future<void> processQueue() async {
    if (_replaying) return;
    _replaying = true;
    try {
      final db = ref.read(databaseProvider);
      final repository = ref.read(gatewayRepositoryProvider);
      final rows = (await db.getPendingOperationsOrdered()).where((row) => row.status == 'pending');

      var failedCount = 0;
      for (final row in rows) {
        try {
          await repository.submitPassportEventJson(row.payloadJson);
          await db.deletePendingOperation(row.id);
        } on Object catch (e) {
          await db.markPendingOperationFailed(row.id, error: e.toString(), attempts: row.attempts + 1);
          failedCount++;
        }
      }
      if (failedCount > 0) {
        ref
            .read(errorNotificationProvider.notifier)
            .setError(
              '$failedCount queued operation${failedCount == 1 ? '' : 's'} failed to sync and '
              '${failedCount == 1 ? 'needs' : 'need'} manual retry.',
              type: 'queue_sync_failed',
            );
      }
    } finally {
      _replaying = false;
    }
  }

  /// Retries a single failed row on demand. Rethrows on failure so the
  /// calling UI can show its own feedback for that row.
  Future<void> retryFailed(int id) async {
    final db = ref.read(databaseProvider);
    final row = await db.getPendingOperationById(id);
    if (row == null) return;
    try {
      await ref.read(gatewayRepositoryProvider).submitPassportEventJson(row.payloadJson);
      await db.deletePendingOperation(id);
    } on Object catch (e) {
      await db.markPendingOperationFailed(id, error: e.toString(), attempts: row.attempts + 1);
      rethrow;
    }
  }

  Future<ConnectivityResult?> _currentConnectivity() async {
    final async = ref.read(checkConnectionProvider);
    final value = async.value;
    if (value != null) return value;
    if (async.hasError) return null;
    try {
      return await ref.read(checkConnectionProvider.future).timeout(const Duration(seconds: 5));
    } on Object {
      return null;
    }
  }
}

/// Triggers an automatic replay pass on app start (if already online), and
/// whenever connectivity transitions from offline to online, or the user
/// logs in (auth-required failures can't be fixed by reconnecting alone —
/// they need a fresh login). Mirrors [initialSyncLifecycleProvider]; must be
/// `ref.watch`'d at the app root.
final passportEventQueueLifecycleProvider = Provider<void>((ref) {
  unawaited(
    Future.microtask(() async {
      final async = ref.read(checkConnectionProvider);
      if (isDeviceOnline(async.value)) {
        await ref.read(passportEventQueueProvider.notifier).processQueue();
      }
    }),
  );

  ref
    ..listen(checkConnectionProvider.select((async) => async.value), (previous, next) {
      if (!isDeviceOnline(previous) && isDeviceOnline(next)) {
        unawaited(ref.read(passportEventQueueProvider.notifier).processQueue());
      }
    })
    ..listen(authProvider.select((async) => async.value), (previous, next) {
      if (previous == null && next != null) {
        unawaited(ref.read(passportEventQueueProvider.notifier).processQueue());
      }
    });
});
