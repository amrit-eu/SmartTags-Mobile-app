import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../helpers/fake_auth_service.dart';

class _FixedConnectivity extends ConnectivityStatus {
  _FixedConnectivity(this.result);

  final ConnectivityResult? result;

  @override
  FutureOr<ConnectivityResult?> build() async => result;
}

PlatformsCompanion _samplePlatform() {
  return PlatformsCompanion.insert(
    ref: 'PLT-001',
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

void main() {
  group('initialSyncProvider', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.executor(conn.inMemoryConnection());
    });

    tearDown(() async {
      await db.close();
    });

    test('returns notNeeded when database already has data', () async {
      await db.insertPlatforms([_samplePlatform()]);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
        ],
      );
      addTearDown(container.dispose);

      final status = await container.read(initialSyncProvider.future);
      expect(status, InitialSyncStatus.notNeeded);
    });

    test('skips sync when database is empty and device is offline', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.none)),
          gatewayRepositoryProvider.overrideWithValue(_ThrowingGatewayRepository()),
        ],
      );
      addTearDown(container.dispose);

      final status = await container.read(initialSyncProvider.future);
      expect(status, InitialSyncStatus.skippedOffline);
    });

    test('syncs platforms when database is empty and device is online', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(_FakeGatewayRepository([_samplePlatform()])),
        ],
      );
      addTearDown(container.dispose);

      final status = await container.read(initialSyncProvider.future);
      expect(status, InitialSyncStatus.completed);
      expect(await db.isEmpty(), isFalse);
    });

    test('surfaces errors when sync fails while online', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(_ThrowingGatewayRepository()),
        ],
      );
      addTearDown(container.dispose);

      container.listen(initialSyncProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      expect(container.read(initialSyncProvider).hasError, isTrue);
    });

    test('retry succeeds after an initial failure', () async {
      final repository = _ToggleGatewayRepository([_samplePlatform()]);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(() => _FixedConnectivity(ConnectivityResult.wifi)),
          gatewayRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(initialSyncProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(container.read(initialSyncProvider).hasError, isTrue);

      repository.shouldSucceed = true;
      await container.read(initialSyncProvider.notifier).retry();

      expect(container.read(initialSyncProvider).value, InitialSyncStatus.completed);
      expect(await db.isEmpty(), isFalse);
    });
  });
}

class _FakeGatewayRepository extends GatewayRepository {
  _FakeGatewayRepository(this.platforms) : super(authService: NoOpAuthService());

  final List<PlatformsCompanion> platforms;

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async => platforms;
}

class _ThrowingGatewayRepository extends GatewayRepository {
  _ThrowingGatewayRepository() : super(authService: NoOpAuthService());

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    throw Exception('Network error');
  }
}

class _ToggleGatewayRepository extends GatewayRepository {
  _ToggleGatewayRepository(this.platforms) : super(authService: NoOpAuthService());

  final List<PlatformsCompanion> platforms;
  bool shouldSucceed = false;

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    if (!shouldSucceed) {
      throw Exception('Network error');
    }
    return platforms;
  }
}
