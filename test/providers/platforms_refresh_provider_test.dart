import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/services/gateway_repository.dart';

class _FixedConnectivity extends ConnectivityStatus {
  _FixedConnectivity(this.result);

  final ConnectivityResult? result;

  @override
  FutureOr<ConnectivityResult?> build() async => result;
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

class _FakeGatewayRepository extends GatewayRepository {
  _FakeGatewayRepository(this.platforms);

  final List<PlatformsCompanion> platforms;

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async => platforms;
}

class _ThrowingGatewayRepository extends GatewayRepository {
  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    throw Exception('Network error');
  }
}

void main() {
  group('platformsRefreshProvider', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.executor(conn.inMemoryConnection());
    });

    tearDown(() async {
      await db.close();
    });

    test('refreshes platforms when online', () async {
      await db.insertPlatforms([_samplePlatform()]);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(
            () => _FixedConnectivity(ConnectivityResult.wifi),
          ),
          gatewayRepositoryProvider.overrideWithValue(
            _FakeGatewayRepository([_samplePlatform(ref: 'PLT-002')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(platformsRefreshProvider, (_, _) {});
      await container.read(platformsRefreshProvider.future);

      await container.read(platformsRefreshProvider.notifier).refresh();

      expect(container.read(platformsRefreshProvider).hasError, isFalse);
      final rows = await db.select(db.platforms).get();
      expect(rows, hasLength(1));
      expect(rows.single.ref, 'PLT-002');
    });

    test('errors when offline', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(
            () => _FixedConnectivity(ConnectivityResult.none),
          ),
          gatewayRepositoryProvider.overrideWithValue(_ThrowingGatewayRepository()),
        ],
      );
      addTearDown(container.dispose);

      container.listen(platformsRefreshProvider, (_, _) {});
      await container.read(platformsRefreshProvider.future);

      await container.read(platformsRefreshProvider.notifier).refresh();

      expect(container.read(platformsRefreshProvider).hasError, isTrue);
    });

    test('surfaces gateway failures', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(
            () => _FixedConnectivity(ConnectivityResult.wifi),
          ),
          gatewayRepositoryProvider.overrideWithValue(_ThrowingGatewayRepository()),
        ],
      );
      addTearDown(container.dispose);

      container.listen(platformsRefreshProvider, (_, _) {});
      await container.read(platformsRefreshProvider.future);

      await container.read(platformsRefreshProvider.notifier).refresh();

      expect(container.read(platformsRefreshProvider).hasError, isTrue);
    });
  });
}
