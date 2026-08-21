import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../helpers/fake_auth_service.dart';

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
}
