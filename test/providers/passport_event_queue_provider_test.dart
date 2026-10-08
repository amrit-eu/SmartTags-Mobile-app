import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../helpers/fake_auth_service.dart';
import '../utils/fake_auth_notifiers.dart';
import '../utils/test_user.dart';

class _FixedConnectivity extends ConnectivityStatus {
  _FixedConnectivity(this.result);

  final ConnectivityResult? result;

  @override
  FutureOr<ConnectivityResult?> build() async => result;
}

PassportEventRequest _sampleRequest() {
  return PassportEventRequest.deployment(
    ptfId: 'PLT-001',
    deployment: DeploymentEventPayload(latitude: 1, longitude: 2, date: DateTime.utc(2026)),
  );
}

/// Fake repository whose outcome per call is scripted by [outcomes]:
/// `null` succeeds, otherwise the given exception is thrown.
class _ScriptedGatewayRepository extends GatewayRepository {
  _ScriptedGatewayRepository(this.outcomes) : super(authService: NoOpAuthService());

  final List<Exception?> outcomes;
  final List<String> sentBodies = [];
  var _calls = 0;

  @override
  Future<void> submitPassportEventJson(String body) async {
    sentBodies.add(body);
    final outcome = _calls < outcomes.length ? outcomes[_calls] : outcomes.last;
    _calls++;
    if (outcome != null) {
      throw outcome;
    }
  }
}

/// Fake repository recording alert operations; per-call outcome is scripted
/// like [_ScriptedGatewayRepository] (`null` succeeds).
class _AlertGatewayRepository extends GatewayRepository {
  _AlertGatewayRepository(this.outcomes) : super(authService: NoOpAuthService());

  final List<Exception?> outcomes;
  final List<({PendingOperationKind kind, String body})> sent = [];
  var _calls = 0;

  @override
  Future<void> submitAlertOperationJson(PendingOperationKind kind, String payloadJson) async {
    sent.add((kind: kind, body: payloadJson));
    final outcome = _calls < outcomes.length ? outcomes[_calls] : outcomes.last;
    _calls++;
    if (outcome != null) {
      throw outcome;
    }
  }
}

/// Fake repository whose single submission blocks on [gate] before
/// resolving — used to prove a second concurrent `processQueue()` call
/// joins the first in-flight run rather than starting its own pass.
class _GatedGatewayRepository extends GatewayRepository {
  _GatedGatewayRepository(this.gate) : super(authService: NoOpAuthService());

  final Future<void> gate;
  int callCount = 0;

  @override
  Future<void> submitPassportEventJson(String body) async {
    callCount++;
    await gate;
  }
}

void main() {
  group('PassportEventQueueNotifier', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.executor(conn.inMemoryConnection());
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueueOrSend sends immediately when online and succeeds', () async {
      final repository = _ScriptedGatewayRepository([null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.deploy, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.sent);
      expect(await db.getPendingOperationsOrdered(), isEmpty);
      expect(repository.sentBodies, hasLength(1));
    });

    test('enqueueOrSend queues when online but the request throws a non-auth error', () async {
      final repository = _ScriptedGatewayRepository([const GatewayException('Simulated failure')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.deploy, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.queued);
      final rows = await db.getPendingOperationsOrdered();
      expect(rows, hasLength(1));
      expect(rows.single.status, 'pending');
    });

    test('enqueueOrSend queues with queuedAuthRequired when not authenticated', () async {
      final repository = _ScriptedGatewayRepository([const GatewayAuthException('Not authenticated.')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.deploy, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.queuedAuthRequired);
      expect(await db.getPendingOperationsOrdered(), hasLength(1));
    });

    test('enqueueOrSend queues directly when offline, without calling the repository', () async {
      final repository = _ScriptedGatewayRepository([null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.none)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.recover, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.queued);
      expect(repository.sentBodies, isEmpty);
      expect(await db.getPendingOperationsOrdered(), hasLength(1));
    });

    test('processQueue is skip-and-continue: a failed row is marked failed, later rows still send', () async {
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{"a":1}'),
      );
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-002', action: 'recover', payloadJson: '{"b":2}'),
      );
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-003', action: 'deploy', payloadJson: '{"c":3}'),
      );

      // Item 2 (index 1) fails, items 1 and 3 succeed.
      final repository = _ScriptedGatewayRepository([null, const GatewayException('Simulated failure'), null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(passportEventQueueProvider.notifier).processQueue();

      final remaining = await db.getPendingOperationsOrdered();
      expect(remaining, hasLength(1));
      expect(remaining.single.platformRef, 'PLT-002');
      expect(remaining.single.status, 'failed');
      expect(remaining.single.lastError, isNotNull);
      expect(repository.sentBodies, hasLength(3));
    });

    test('processQueue: a second concurrent call joins the first instead of starting a new pass', () async {
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{"a":1}'),
      );

      final gate = Completer<void>();
      final repository = _GatedGatewayRepository(gate.future);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(passportEventQueueProvider.notifier);
      final first = notifier.processQueue();
      final second = notifier.processQueue();

      // Neither call has resolved yet, so the row must still be pending.
      await Future<void>.delayed(Duration.zero);
      expect(await db.getPendingOperationsOrdered(), hasLength(1));

      gate.complete();
      await first;
      await second;

      expect(await db.getPendingOperationsOrdered(), isEmpty);
      // Exactly one submission attempt — the second call joined the first
      // run rather than starting its own pass.
      expect(repository.callCount, 1);
    });

    test('retryFailed resends a single row and removes it on success', () async {
      final id = await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{"a":1}'),
      );
      await db.markPendingOperationFailed(id, error: 'boom', attempts: 1);

      final repository = _ScriptedGatewayRepository([null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(passportEventQueueProvider.notifier).retryFailed(id);

      expect(await db.getPendingOperationsOrdered(), isEmpty);
    });

    test('retryFailed rethrows and keeps the row failed when the retry also fails', () async {
      final id = await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{"a":1}'),
      );
      await db.markPendingOperationFailed(id, error: 'boom', attempts: 1);

      final repository = _ScriptedGatewayRepository([const GatewayException('Simulated failure')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(passportEventQueueProvider.notifier).retryFailed(id),
        throwsA(isA<GatewayException>()),
      );

      final row = await db.getPendingOperationById(id);
      expect(row!.status, 'failed');
      expect(row.attempts, 2);
    });
  });

  group('PassportEventQueueNotifier — alert operations', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.executor(conn.inMemoryConnection());
      await db.insertPlatforms([
        PlatformsCompanion.insert(
          ref: 'PLT-001',
          model: 'Test Sensor',
          category: 'Profiling Float',
          network: 'Argo',
          lat: 1,
          lon: 2,
          status: 'OPERATIONAL',
          operationalStatus: 'Deployed',
          lastUpdated: DateTime.utc(2026),
          operationLat: 1,
          operationLon: 2,
        ),
      ]);
      await db.upsertAlerts([
        AlertsCompanion.insert(
          id: 'alert-1',
          resource: 'PLT-001',
          event: 'LowBattery',
          severity: 'warning',
          status: 'open',
          description: 'Battery low',
          service: 'service',
          previousSeverity: 'normal',
          duplicateCount: 0,
          alertCategory: 'category',
          country: 'country',
        ),
      ]);
    });

    tearDown(() async {
      await db.close();
    });

    const alert = Alert(
      id: 'alert-1',
      resource: 'PLT-001',
      event: 'LowBattery',
      severity: AlertSeverity.warning,
      status: AlertStatus.open,
      description: 'Battery low',
      service: 'service',
      previousSeverity: AlertSeverity.normal,
      duplicateCount: 0,
      alertCategory: 'category',
      country: 'country',
    );

    ProviderContainer containerWith(_AlertGatewayRepository repository, ConnectivityResult connectivity) {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(connectivity)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    Future<AlertEntity> storedAlert() async => (await db.watchAlertById('alert-1').first)!;

    test('offline: queues the action and updates the status locally, without calling the Gateway', () async {
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.none);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack);

      expect(outcome, PassportEventSubmitOutcome.queued);
      expect(repository.sent, isEmpty);
      final rows = await db.getPendingOperationsOrdered();
      expect(rows.single.action, 'alert_ack');
      expect(rows.single.platformRef, 'PLT-001');
      expect(jsonDecode(rows.single.payloadJson), {'alertId': 'alert-1', 'action': 'ack'});
      expect((await storedAlert()).status, 'ack');
      expect((await storedAlert()).severity, 'warning');
    });

    test('online: sends the action, queues nothing and updates the status locally', () async {
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.wifi);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertAction(alert: alert, action: AlertAction.close);

      expect(outcome, PassportEventSubmitOutcome.sent);
      expect(repository.sent.single.kind, PendingOperationKind.alertClose);
      expect(await db.getPendingOperationsOrdered(), isEmpty);
      expect((await storedAlert()).status, 'closed');
      expect((await storedAlert()).severity, 'normal');
    });

    test('online with a server error (5xx): queues and updates locally', () async {
      final repository = _AlertGatewayRepository([const GatewayException('boom', statusCode: 500)]);
      final container = containerWith(repository, ConnectivityResult.wifi);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack);

      expect(outcome, PassportEventSubmitOutcome.queued);
      expect(await db.getPendingOperationsOrdered(), hasLength(1));
      expect((await storedAlert()).status, 'ack');
      expect((await storedAlert()).severity, 'warning');
    });

    test('online with an expired session: queues with queuedAuthRequired', () async {
      final repository = _AlertGatewayRepository([const GatewayAuthException('Session expired')]);
      final container = containerWith(repository, ConnectivityResult.wifi);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack);

      expect(outcome, PassportEventSubmitOutcome.queuedAuthRequired);
      expect(await db.getPendingOperationsOrdered(), hasLength(1));
    });

    test('online with a 4xx rejection: rethrows, queues nothing, leaves the alert untouched', () async {
      final repository = _AlertGatewayRepository([const GatewayException('Forbidden', statusCode: 403)]);
      final container = containerWith(repository, ConnectivityResult.wifi);

      await expectLater(
        container
            .read(passportEventQueueProvider.notifier)
            .enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack),
        throwsA(isA<GatewayException>()),
      );

      expect(await db.getPendingOperationsOrdered(), isEmpty);
      expect((await storedAlert()).status, 'open');
    });

    test('offline note: queues it and sets lastNote to "<user> : <text>"', () async {
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.none);
      await container.read(authProvider.future);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertNote(alert: alert, text: 'Checked on site');

      expect(outcome, PassportEventSubmitOutcome.queued);
      final rows = await db.getPendingOperationsOrdered();
      expect(rows.single.action, 'alert_note');
      expect(jsonDecode(rows.single.payloadJson), {'alertId': 'alert-1', 'text': 'Checked on site'});
      expect((await storedAlert()).lastNote, 'Joe Bloggs : Checked on site');
    });

    test('processQueue replays queued alert operations in FIFO order', () async {
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.none);
      final queue = container.read(passportEventQueueProvider.notifier);
      await queue.enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack);
      await queue.enqueueOrSendAlertNote(alert: alert, text: 'note');

      await queue.processQueue();

      expect(repository.sent.map((s) => s.kind), [PendingOperationKind.alertAck, PendingOperationKind.alertNote]);
      expect(await db.getPendingOperationsOrdered(), isEmpty);
    });

    test('processQueue marks a row of unknown type failed instead of replaying it', () async {
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'something_new', payloadJson: '{}'),
      );
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.wifi);

      await container.read(passportEventQueueProvider.notifier).processQueue();

      expect(repository.sent, isEmpty);
      final row = (await db.getPendingOperationsOrdered()).single;
      expect(row.status, 'failed');
      expect(row.lastError, contains('something_new'));
    });

    test('closing resets severity to normal, re-opening restores the previous severity', () async {
      await db.updateAlertStatus('alert-1', 'closed');
      var stored = await storedAlert();
      expect(stored.status, 'closed');
      expect(stored.severity, 'normal');
      expect(stored.previousSeverity, 'warning');

      await db.updateAlertStatus('alert-1', 'open');
      stored = await storedAlert();
      expect(stored.status, 'open');
      expect(stored.severity, 'warning');
      expect(stored.previousSeverity, 'normal');
    });

    test('ack / unack leave severities untouched', () async {
      await db.updateAlertStatus('alert-1', 'ack');
      await db.updateAlertStatus('alert-1', 'open');
      final stored = await storedAlert();
      expect(stored.severity, 'warning');
      expect(stored.previousSeverity, 'normal');
    });
  });
}
