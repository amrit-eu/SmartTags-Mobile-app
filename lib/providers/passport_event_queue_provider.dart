import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/mappers/pending_operation_mapper.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/models/alert.dart';
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

/// Streams all queued operations — deploy/recover events and alert actions/notes
/// (pending + failed), oldest first.
final pendingPassportEventsProvider = StreamProvider<List<PendingPassportEvent>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPendingOperations().map(
    // Rows of an unknown type can't be displayed (nor replayed: the replay
    // marks them failed), so they are left out rather than breaking the stream.
    (rows) =>
        rows.where((row) => PendingOperationKind.tryParse(row.action) != null).map((row) => row.toDomain()).toList(),
  );
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
  Future<void>? _ongoingProcessQueue;

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
        action: PendingOperationKind.fromDeployAction(action).dbValue,
        payloadJson: bodyJson,
      ),
    );
    return authRequired ? PassportEventSubmitOutcome.queuedAuthRequired : PassportEventSubmitOutcome.queued;
  }

  /// Applies [action] to [alert]: sends it immediately when online, otherwise
  /// (or on a network/server/auth failure) queues it for later replay. In both
  /// cases the alert's status is updated locally so the UI reflects it at once.
  ///
  /// Unlike [enqueueOrSend], a 4xx rejection from the Gateway (e.g. 403, 404)
  /// is rethrown as a [GatewayException]: nothing is queued or changed locally,
  /// as replaying it could never succeed.
  Future<PassportEventSubmitOutcome> enqueueOrSendAlertAction({required Alert alert, required AlertAction action}) {
    return _enqueueOrSendAlert(
      alert: alert,
      kind: PendingOperationKind.fromAlertAction(action),
      payload: {'alertId': alert.id, 'action': action.name},
      applyLocally: (db) => db.updateAlertStatus(alert.id, action.resultingStatus),
    );
  }

  /// Adds [text] as a note on [alert]: same send/queue/local-update behaviour
  /// as [enqueueOrSendAlertAction]. The local `lastNote` follows Alerta's
  /// `"<user> : <text>"` format.
  Future<PassportEventSubmitOutcome> enqueueOrSendAlertNote({required Alert alert, required String text}) {
    final author = ref.read(authProvider).value?.fullName;
    return _enqueueOrSendAlert(
      alert: alert,
      kind: PendingOperationKind.alertNote,
      payload: {'alertId': alert.id, 'text': text},
      applyLocally: (db) => db.updateAlertLastNote(alert.id, author == null ? text : '$author : $text'),
    );
  }

  Future<PassportEventSubmitOutcome> _enqueueOrSendAlert({
    required Alert alert,
    required PendingOperationKind kind,
    required Map<String, dynamic> payload,
    required Future<void> Function(AppDatabase db) applyLocally,
  }) async {
    final db = ref.read(databaseProvider);
    final bodyJson = jsonEncode(payload);

    final connectivity = await _currentConnectivity();
    var authRequired = false;
    if (isDeviceOnline(connectivity)) {
      try {
        await ref.read(gatewayRepositoryProvider).submitAlertOperationJson(kind, bodyJson);
        await applyLocally(db);
        return PassportEventSubmitOutcome.sent;
      } on GatewayException catch (e) {
        if (e.isClientError) {
          rethrow;
        }
        authRequired = e is GatewayAuthException;
        debugPrint('Immediate alert operation failed, queuing: $e');
      } on Object catch (e) {
        authRequired = e is AuthException;
        debugPrint('Immediate alert operation failed, queuing: $e');
      }
    }

    await db.enqueuePendingOperation(
      PendingOperationsCompanion.insert(platformRef: alert.resource, action: kind.dbValue, payloadJson: bodyJson),
    );
    await applyLocally(db);
    return authRequired ? PassportEventSubmitOutcome.queuedAuthRequired : PassportEventSubmitOutcome.queued;
  }

  /// Sends one queued row, picking the Gateway call from its kind.
  Future<void> _replay(GatewayRepository repository, PendingOperation row) {
    final kind = PendingOperationKind.fromDb(row.action);
    return kind.isAlert
        ? repository.submitAlertOperationJson(kind, row.payloadJson)
        : repository.submitPassportEventJson(row.payloadJson);
  }

  /// Replays all `pending` rows in FIFO order. Skip-and-continue: a failed
  /// row is marked `failed` with [PendingOperation.lastError] and left in
  /// place; the loop still tries every later row.
  ///
  /// Safe to call repeatedly and concurrently: a second call while a replay
  /// is already running joins that same in-flight run instead of starting a
  /// duplicate one, so every caller's `await` resolves only once the drain
  /// has actually finished (mirrors `PlatformsRefreshNotifier`'s
  /// `_ongoingRefresh` / `InitialSyncNotifier`'s `_ongoingSync`).
  Future<void> processQueue() {
    final ongoing = _ongoingProcessQueue;
    if (ongoing != null) {
      return ongoing;
    }

    final run = _performProcessQueue();
    _ongoingProcessQueue = run;
    return run.whenComplete(() {
      if (identical(_ongoingProcessQueue, run)) {
        _ongoingProcessQueue = null;
      }
    });
  }

  Future<void> _performProcessQueue() async {
    final db = ref.read(databaseProvider);
    final repository = ref.read(gatewayRepositoryProvider);
    final rows = (await db.getPendingOperationsOrdered()).where((row) => row.status == 'pending');

    var failedCount = 0;
    for (final row in rows) {
      try {
        await _replay(repository, row);
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
  }

  /// Retries a single failed row on demand. Rethrows on failure so the
  /// calling UI can show its own feedback for that row.
  Future<void> retryFailed(int id) async {
    final db = ref.read(databaseProvider);
    final row = await db.getPendingOperationById(id);
    if (row == null) return;
    try {
      await _replay(ref.read(gatewayRepositoryProvider), row);
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
