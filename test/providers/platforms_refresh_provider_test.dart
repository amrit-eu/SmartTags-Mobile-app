import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/passport_filter_dto.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/services/gateway_repository.dart';

import '../helpers/fake_auth_service.dart';

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
  _FakeGatewayRepository(this.platforms) : super(authService: NoOpAuthService());

  final List<PlatformsCompanion> platforms;

  /// The `filters` map passed to [searchPassports] on each call, in order.
  final List<Map<String, dynamic>?> capturedFilters = [];

  @override
  Future<List<PlatformsCompanion>> searchPassports(PassportFilterDto? searchDto) async {
    capturedFilters.add(searchDto?.filters);
    return platforms;
  }
}

class _ThrowingGatewayRepository extends GatewayRepository {
  _ThrowingGatewayRepository() : super(authService: NoOpAuthService());

  @override
  Future<List<PlatformsCompanion>> searchPassports(PassportFilterDto? searchDto) async {
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

    test('refreshes platforms when online, upserting without touching untouched rows', () async {
      await db.insertPlatforms([_samplePlatform()]); // PLT-001, pre-existing local row.

      final fakeRepository = _FakeGatewayRepository([_samplePlatform(ref: 'PLT-002')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(
            () => _FixedConnectivity(ConnectivityResult.wifi),
          ),
          gatewayRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(platformsRefreshProvider, (_, _) {});
      await container.read(platformsRefreshProvider.future);

      await container.read(platformsRefreshProvider.notifier).refresh();

      expect(container.read(platformsRefreshProvider).hasError, isFalse);
      final rows = await db.select(db.platforms).get();
      // Delta result (PLT-002) is upserted; the pre-existing PLT-001 (absent
      // from the delta response) is left untouched, not deleted.
      expect(rows.map((r) => r.ref), containsAll(['PLT-001', 'PLT-002']));
      expect(rows, hasLength(2));

      // No refresh had run yet, so the first search is unfiltered.
      expect(fakeRepository.capturedFilters.single, isEmpty);
      expect(await db.getLastPlatformsRefresh(), isNotNull);
    });

    test('sends updatedSince from the previous refresh on the next refresh', () async {
      final fakeRepository = _FakeGatewayRepository([_samplePlatform(ref: 'PLT-002')]);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          checkConnectionProvider.overrideWith(
            () => _FixedConnectivity(ConnectivityResult.wifi),
          ),
          gatewayRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(platformsRefreshProvider, (_, _) {});
      await container.read(platformsRefreshProvider.future);

      await container.read(platformsRefreshProvider.notifier).refresh();
      final firstRefresh = await db.getLastPlatformsRefresh();
      await container.read(platformsRefreshProvider.notifier).refresh();

      expect(fakeRepository.capturedFilters, hasLength(2));
      expect(fakeRepository.capturedFilters[0], isEmpty);
      expect(fakeRepository.capturedFilters[1], {'updatedSince': firstRefresh!.toUtc().toIso8601String()});
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
