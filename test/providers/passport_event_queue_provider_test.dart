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
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
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
/// `null` succeeds, otherwise the given exception is thrown. [onSend], if
/// given, runs (and is awaited) while each call is in flight, with the call's
/// 0-based index — used to change the session mid-replay.
class _ScriptedGatewayRepository extends GatewayRepository {
  _ScriptedGatewayRepository(this.outcomes, {this.onSend}) : super(authService: NoOpAuthService());

  final List<Exception?> outcomes;
  final FutureOr<void> Function(int call)? onSend;
  final List<String> sentBodies = [];
  var _calls = 0;

  @override
  Future<void> submitPassportEventJson(String body) async {
    sentBodies.add(body);
    final call = _calls++;
    final outcome = call < outcomes.length ? outcomes[call] : outcomes.last;
    await onSend?.call(call);
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

/// Auth notifier whose user can be switched mid-test (logout / login as
/// someone else).
class _SwitchableAuthNotifier extends AuthNotifier {
  _SwitchableAuthNotifier(this._initial);

  final User? _initial;

  @override
  Future<User?> build() async => _initial;

  void setUser(User? user) => state = AsyncData(user);

  /// Mirrors [AuthNotifier.logout]'s first step, before credentials are cleared.
  void beginLogout() => state = const AsyncLoading();
}

final int _userId = createTestUser().id;

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
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

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
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.deploy, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.queued);
      final rows = await db.getPendingOperationsOrdered();
      expect(rows, hasLength(1));
      expect(rows.single.status, 'pending');
    });

    test('enqueueOrSend does not queue (notQueuedAuthRequired) when no user is logged in', () async {
      final repository = _ScriptedGatewayRepository([const GatewayAuthException('Not authenticated.')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(null)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.deploy, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.notQueuedAuthRequired);
      expect(await db.getPendingOperationsOrdered(), isEmpty);
    });

    test('enqueueOrSend queues directly when offline, without calling the repository', () async {
      final repository = _ScriptedGatewayRepository([null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.none)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSend(platformRef: 'PLT-001', action: DeployAction.recover, request: _sampleRequest());

      expect(outcome, PassportEventSubmitOutcome.queued);
      expect(repository.sentBodies, isEmpty);
      final rows = await db.getPendingOperationsOrdered();
      expect(rows.single.userRef, _userId);
    });

    test('processQueue is skip-and-continue: a failed row is marked failed, later rows still send', () async {
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-001',
          action: 'deploy',
          payloadJson: '{"a":1}',
          userRef: _userId,
        ),
      );
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-002',
          action: 'recover',
          payloadJson: '{"b":2}',
          userRef: _userId,
        ),
      );
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-003',
          action: 'deploy',
          payloadJson: '{"c":3}',
          userRef: _userId,
        ),
      );

      // Item 2 (index 1) fails, items 1 and 3 succeed.
      final repository = _ScriptedGatewayRepository([null, const GatewayException('Simulated failure'), null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

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
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-001',
          action: 'deploy',
          payloadJson: '{"a":1}',
          userRef: _userId,
        ),
      );

      final gate = Completer<void>();
      final repository = _GatedGatewayRepository(gate.future);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

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
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-001',
          action: 'deploy',
          payloadJson: '{"a":1}',
          userRef: _userId,
        ),
      );
      await db.markPendingOperationFailed(id, error: 'boom', attempts: 1);

      final repository = _ScriptedGatewayRepository([null]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await container.read(passportEventQueueProvider.notifier).retryFailed(id);

      expect(await db.getPendingOperationsOrdered(), isEmpty);
    });

    test('retryFailed rethrows and keeps the row failed when the retry also fails', () async {
      final id = await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-001',
          action: 'deploy',
          payloadJson: '{"a":1}',
          userRef: _userId,
        ),
      );
      await db.markPendingOperationFailed(id, error: 'boom', attempts: 1);

      final repository = _ScriptedGatewayRepository([const GatewayException('Simulated failure')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await expectLater(
        container.read(passportEventQueueProvider.notifier).retryFailed(id),
        throwsA(isA<GatewayException>()),
      );

      final row = await db.getPendingOperationById(id);
      expect(row!.status, 'failed');
      expect(row.attempts, 2);
    });

    group('rows are tied to the user who queued them', () {
      const otherUserId = 999;

      ProviderContainer containerFor(_ScriptedGatewayRepository repository, AuthNotifier Function() auth) {
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
            gatewayRepositoryProvider.overrideWithValue(repository),
            authProvider.overrideWith(auth),
          ],
        );
        addTearDown(container.dispose);
        return container;
      }

      Future<int> enqueueFor(int userRef, String platformRef) {
        return db.enqueuePendingOperation(
          PendingOperationsCompanion.insert(
            platformRef: platformRef,
            action: 'deploy',
            payloadJson: '{"p":"$platformRef"}',
            userRef: userRef,
          ),
        );
      }

      test('processQueue only replays the current user rows; other users rows stay pending', () async {
        await enqueueFor(otherUserId, 'PLT-OTHER');
        await enqueueFor(_userId, 'PLT-MINE');
        final repository = _ScriptedGatewayRepository([null]);
        final container = containerFor(repository, () => FakeAuthNotifier(createTestUser()));
        await container.read(authProvider.future);

        await container.read(passportEventQueueProvider.notifier).processQueue();

        expect(repository.sentBodies, ['{"p":"PLT-MINE"}']);
        final remaining = (await db.getPendingOperationsOrdered()).single;
        expect(remaining.platformRef, 'PLT-OTHER');
        expect(remaining.status, 'pending');
        expect(remaining.attempts, 0);
      });

      test('processQueue does nothing when no user is logged in', () async {
        await enqueueFor(_userId, 'PLT-001');
        final repository = _ScriptedGatewayRepository([null]);
        final container = containerFor(repository, () => FakeAuthNotifier(null));
        await container.read(authProvider.future);

        await container.read(passportEventQueueProvider.notifier).processQueue();

        expect(repository.sentBodies, isEmpty);
        expect((await db.getPendingOperationsOrdered()).single.status, 'pending');
      });

      test('retryFailed ignores a row queued by another user', () async {
        final id = await enqueueFor(otherUserId, 'PLT-001');
        await db.markPendingOperationFailed(id, error: 'boom', attempts: 1);
        final repository = _ScriptedGatewayRepository([null]);
        final container = containerFor(repository, () => FakeAuthNotifier(createTestUser()));
        await container.read(authProvider.future);

        await container.read(passportEventQueueProvider.notifier).retryFailed(id);

        expect(repository.sentBodies, isEmpty);
        final row = await db.getPendingOperationById(id);
        expect(row!.status, 'failed');
        expect(row.attempts, 1);
      });

      test('pendingPassportEventsProvider lists only the current user rows and follows user changes', () async {
        await enqueueFor(_userId, 'PLT-MINE');
        await enqueueFor(otherUserId, 'PLT-OTHER');
        final auth = _SwitchableAuthNotifier(createTestUser());
        final container = containerFor(_ScriptedGatewayRepository([null]), () => auth)
          ..listen(pendingPassportEventsProvider, (_, _) {});

        await container.read(authProvider.future);
        var events = await container.read(pendingPassportEventsProvider.future);
        expect(events.map((e) => e.platformRef), ['PLT-MINE']);

        auth.setUser(createTestUser(id: otherUserId));
        events = await container.read(pendingPassportEventsProvider.future);
        expect(events.map((e) => e.platformRef), ['PLT-OTHER']);

        auth.setUser(null);
        events = await container.read(pendingPassportEventsProvider.future);
        expect(events, isEmpty);
      });

      group('replay pauses when the session ends', () {
        Future<void> enqueueThree() async {
          await enqueueFor(_userId, 'PLT-1');
          await enqueueFor(_userId, 'PLT-2');
          await enqueueFor(_userId, 'PLT-3');
        }

        Future<void> expectUntouchedPending(List<String> platformRefs) async {
          final rows = await db.getPendingOperationsOrdered();
          expect(rows.map((r) => r.platformRef), platformRefs);
          for (final row in rows) {
            expect(row.status, 'pending');
            expect(row.attempts, 0);
            expect(row.userRef, _userId);
          }
        }

        test('logout during a send: that row completes, later rows stay pending', () async {
          await enqueueThree();
          final auth = _SwitchableAuthNotifier(createTestUser());
          final repository = _ScriptedGatewayRepository([null], onSend: (_) => auth.setUser(null));
          final container = containerFor(repository, () => auth);
          await container.read(authProvider.future);

          await container.read(passportEventQueueProvider.notifier).processQueue();

          expect(repository.sentBodies, ['{"p":"PLT-1"}']);
          await expectUntouchedPending(['PLT-2', 'PLT-3']);
        });

        test('logout starting during a send stops the replay before credentials are cleared', () async {
          await enqueueThree();
          final auth = _SwitchableAuthNotifier(createTestUser());
          final repository = _ScriptedGatewayRepository([null], onSend: (_) => auth.beginLogout());
          final container = containerFor(repository, () => auth);
          await container.read(authProvider.future);

          await container.read(passportEventQueueProvider.notifier).processQueue();

          expect(repository.sentBodies, ['{"p":"PLT-1"}']);
          await expectUntouchedPending(['PLT-2', 'PLT-3']);
        });

        test('account change during a send: no later row is sent with the new account', () async {
          await enqueueThree();
          final auth = _SwitchableAuthNotifier(createTestUser());
          final repository = _ScriptedGatewayRepository([
            null,
          ], onSend: (_) => auth.setUser(createTestUser(id: otherUserId)));
          final container = containerFor(repository, () => auth);
          await container.read(authProvider.future);

          await container.read(passportEventQueueProvider.notifier).processQueue();

          expect(repository.sentBodies, ['{"p":"PLT-1"}']);
          await expectUntouchedPending(['PLT-2', 'PLT-3']);
        });

        test('the in-flight row keeps its real result; no error is shown after logout', () async {
          await enqueueThree();
          final auth = _SwitchableAuthNotifier(createTestUser());
          final repository = _ScriptedGatewayRepository([
            const GatewayException('boom', statusCode: 500),
          ], onSend: (_) => auth.setUser(null));
          final container = containerFor(repository, () => auth);
          await container.read(authProvider.future);

          await container.read(passportEventQueueProvider.notifier).processQueue();

          final rows = await db.getPendingOperationsOrdered();
          expect(rows.map((r) => (r.platformRef, r.status)), [
            ('PLT-1', 'failed'),
            ('PLT-2', 'pending'),
            ('PLT-3', 'pending'),
          ]);
          expect(rows.first.attempts, 1);
          expect(container.read(errorNotificationProvider), isNull);
        });

        test('an auth failure stops the replay: the row and later rows stay pending', () async {
          await enqueueThree();
          final repository = _ScriptedGatewayRepository([null, const GatewayAuthException('Session expired'), null]);
          final container = containerFor(repository, () => FakeAuthNotifier(createTestUser()));
          await container.read(authProvider.future);

          await container.read(passportEventQueueProvider.notifier).processQueue();

          expect(repository.sentBodies, ['{"p":"PLT-1"}', '{"p":"PLT-2"}']);
          await expectUntouchedPending(['PLT-2', 'PLT-3']);
          expect(container.read(errorNotificationProvider)?.type, 'session_expired');
        });

        test("a new account's pass does not join the previous account's run", () async {
          await enqueueFor(_userId, 'PLT-A1');
          await enqueueFor(_userId, 'PLT-A2');
          await enqueueFor(otherUserId, 'PLT-B1');
          final started = Completer<void>();
          final gate = Completer<void>();
          final auth = _SwitchableAuthNotifier(createTestUser());
          final repository = _ScriptedGatewayRepository(
            [null],
            onSend: (call) async {
              if (call == 0) {
                started.complete();
                await gate.future;
              }
            },
          );
          final container = containerFor(repository, () => auth);
          await container.read(authProvider.future);
          final queue = container.read(passportEventQueueProvider.notifier);

          final first = queue.processQueue();
          await started.future;
          auth.setUser(createTestUser(id: otherUserId));
          final second = queue.processQueue();
          gate.complete();
          await first;
          await second;

          expect(repository.sentBodies, ['{"p":"PLT-A1"}', '{"p":"PLT-B1"}']);
          final remaining = (await db.getPendingOperationsOrdered()).single;
          expect(remaining.platformRef, 'PLT-A2');
          expect(remaining.status, 'pending');
          expect(remaining.attempts, 0);
        });

        test('a paused replay resumes when its author logs in again', () async {
          await enqueueThree();
          final allSent = Completer<void>();
          final auth = _SwitchableAuthNotifier(null);
          final repository = _ScriptedGatewayRepository(
            [null],
            onSend: (call) {
              if (call == 0) auth.setUser(null);
              if (call == 2) allSent.complete();
            },
          );
          final container = containerFor(repository, () => auth)
            ..listen(passportEventQueueLifecycleProvider, (_, _) {});
          await container.read(authProvider.future);
          await container.read(checkConnectionProvider.future);
          final queue = container.read(passportEventQueueProvider.notifier);

          // Logging in starts a pass, paused by the logout during its first send.
          auth.setUser(createTestUser());
          await queue.processQueue();
          expect(repository.sentBodies, ['{"p":"PLT-1"}']);
          await expectUntouchedPending(['PLT-2', 'PLT-3']);

          // Logging back in resumes it, without anyone calling processQueue.
          auth.setUser(createTestUser());
          await allSent.future.timeout(const Duration(seconds: 5));
          await queue.processQueue();

          expect(repository.sentBodies, ['{"p":"PLT-1"}', '{"p":"PLT-2"}', '{"p":"PLT-3"}']);
          expect(await db.getPendingOperationsOrdered(), isEmpty);
        });
      });
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

    ProviderContainer containerWith(
      _AlertGatewayRepository repository,
      ConnectivityResult connectivity, {
      bool loggedIn = true,
    }) {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(connectivity)),
          gatewayRepositoryProvider.overrideWithValue(repository),
          authProvider.overrideWith(() => FakeAuthNotifier(loggedIn ? createTestUser() : null)),
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

    test('online with an expired session, user still known: queues it under that user', () async {
      final repository = _AlertGatewayRepository([const GatewayAuthException('Session expired')]);
      final container = containerWith(repository, ConnectivityResult.wifi);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack);

      expect(outcome, PassportEventSubmitOutcome.queued);
      expect((await db.getPendingOperationsOrdered()).single.userRef, _userId);
    });

    test('not logged in: nothing queued, alert left untouched', () async {
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.none, loggedIn: false);

      final outcome = await container
          .read(passportEventQueueProvider.notifier)
          .enqueueOrSendAlertAction(alert: alert, action: AlertAction.ack);

      expect(outcome, PassportEventSubmitOutcome.notQueuedAuthRequired);
      expect(await db.getPendingOperationsOrdered(), isEmpty);
      expect((await storedAlert()).status, 'open');
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
        PendingOperationsCompanion.insert(
          platformRef: 'PLT-001',
          action: 'something_new',
          payloadJson: '{}',
          userRef: _userId,
        ),
      );
      final repository = _AlertGatewayRepository([null]);
      final container = containerWith(repository, ConnectivityResult.wifi);
      await container.read(authProvider.future);

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
