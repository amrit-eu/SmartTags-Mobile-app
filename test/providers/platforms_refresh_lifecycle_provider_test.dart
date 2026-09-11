import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../helpers/fake_auth_service.dart';

/// Connectivity fake whose value can be changed after construction, to
/// simulate an offline -> online transition mid-test.
class _ControllableConnectivity extends ConnectivityStatus {
  _ControllableConnectivity(this._initial);

  final ConnectivityResult? _initial;

  @override
  FutureOr<ConnectivityResult?> build() async => _initial;

  void set(ConnectivityResult? value) => state = AsyncValue.data(value);
}

PlatformsCompanion _samplePlatform({String ref = 'PLT-001'}) {
  return PlatformsCompanion.insert(
    ref: ref,
    model: 'Test',
    network: 'Net',
    lat: 0,
    lon: 0,
    status: 'OPERATIONAL',
    operationalStatus: 'Deployed',
    lastUpdated: DateTime.utc(2025),
    operationLat: 0,
    operationLon: 0,
  );
}

/// Combined fake covering both call sites that share `gatewayRepositoryProvider`:
/// [PlatformsRefreshNotifier] (`fetchUnclosedMissions`) and
/// [PassportEventQueueNotifier] (`submitPassportEventJson`).
class _CombinedGatewayRepository extends GatewayRepository {
  _CombinedGatewayRepository({this.unclosedMissions = const []}) : super(authService: NoOpAuthService());

  final List<PlatformsCompanion> unclosedMissions;
  int fetchUnclosedMissionsCallCount = 0;
  int submitCallCount = 0;

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    fetchUnclosedMissionsCallCount++;
    return unclosedMissions;
  }

  @override
  Future<void> submitPassportEventJson(String body) async {
    submitCallCount++;
  }
}

void main() {
  group('platformsRefreshLifecycleProvider', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.executor(conn.inMemoryConnection()));
    tearDown(() async => db.close());

    test('reconnecting with no pending queue refreshes immediately, without the delay', () async {
      final repository = _CombinedGatewayRepository(unclosedMissions: [_samplePlatform()]);
      final connectivity = _ControllableConnectivity(ConnectivityResult.none);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => connectivity),
          gatewayRepositoryProvider.overrideWithValue(repository),
          // Left at the real 3s default deliberately: if the "no queue"
          // path incorrectly went through refreshAfterDelay, this test
          // would fail (the refresh wouldn't have happened by the time we
          // assert, since pumpEventQueue() doesn't wait 3 real seconds).
        ],
      );
      addTearDown(container.dispose);

      container
        ..listen(platformsRefreshLifecycleProvider, (_, _) {})
        ..listen(platformsRefreshProvider, (_, _) {});
      await container.read(checkConnectionProvider.future);

      connectivity.set(ConnectivityResult.wifi);
      await pumpEventQueue();

      expect(repository.fetchUnclosedMissionsCallCount, 1);
    });

    test('reconnecting with a pending queue drains it, waits the delay, then refreshes', () async {
      await db.enqueuePendingOperation(
        PendingOperationsCompanion.insert(platformRef: 'PLT-001', action: 'deploy', payloadJson: '{"a":1}'),
      );
      final repository = _CombinedGatewayRepository(unclosedMissions: [_samplePlatform()]);
      final connectivity = _ControllableConnectivity(ConnectivityResult.none);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => connectivity),
          gatewayRepositoryProvider.overrideWithValue(repository),
          platformsRefreshDelayProvider.overrideWithValue(const Duration(milliseconds: 20)),
        ],
      );
      addTearDown(container.dispose);

      container
        ..listen(platformsRefreshLifecycleProvider, (_, _) {})
        ..listen(passportEventQueueProvider, (_, _) {})
        ..listen(platformsRefreshProvider, (_, _) {});
      await container.read(checkConnectionProvider.future);

      connectivity.set(ConnectivityResult.wifi);
      await pumpEventQueue(); // lets the drain (and its DB writes) settle

      // Drain finished — the queued row is gone — but the 20ms delay
      // hasn't elapsed yet, so refresh must not have fired.
      expect(await db.getPendingOperationsOrdered(), isEmpty);
      expect(repository.fetchUnclosedMissionsCallCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(repository.fetchUnclosedMissionsCallCount, 1);
      expect(repository.submitCallCount, 1);
    });
  });
}
