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
  _FakeGatewayRepository({this.unclosedMissions = const [], this.searchResults = const []})
    : super(authService: NoOpAuthService());

  /// Returned by [fetchUnclosedMissions] — used as the fallback fetch when
  /// there's no stored `cachedSince` baseline yet.
  final List<PlatformsCompanion> unclosedMissions;

  /// Returned by [searchPassports] once a baseline is stored.
  final List<PlatformsCompanion> searchResults;

  int fetchUnclosedMissionsCallCount = 0;

  /// The DTO passed to [searchPassports] on each call, in order.
  final List<PassportFilterDto?> capturedSearchDtos = [];

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    fetchUnclosedMissionsCallCount++;
    return unclosedMissions;
  }

  @override
  Future<List<PlatformsCompanion>> searchPassports(PassportFilterDto? searchDto) async {
    capturedSearchDtos.add(searchDto);
    return searchResults;
  }
}

class _ThrowingGatewayRepository extends GatewayRepository {
  _ThrowingGatewayRepository() : super(authService: NoOpAuthService());

  @override
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    throw Exception('Network error');
  }

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

    test('first refresh (no stored baseline) fetches unclosed missions instead of an unfiltered search', () async {
      await db.insertPlatforms([_samplePlatform()]); // PLT-001, pre-existing local row.

      final fakeRepository = _FakeGatewayRepository(
        unclosedMissions: [_samplePlatform(ref: 'PLT-002')],
      );
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
      // No baseline yet -> falls back to fetchUnclosedMissions (bounded,
      // not an unfiltered search) and replaces local platforms with it,
      // same as the initial sync.
      expect(fakeRepository.fetchUnclosedMissionsCallCount, 1);
      expect(fakeRepository.capturedSearchDtos, isEmpty);
      final rows = await db.select(db.platforms).get();
      expect(rows.map((r) => r.ref), ['PLT-002']);

      // The baseline is now stamped for the next refresh.
      expect(await db.getLastPlatformsRefresh(), isNotNull);
    });

    test('subsequent refresh sends cachedSince/paginationEnabled and upserts without touching untouched rows', () async {
      final fakeRepository = _FakeGatewayRepository(
        unclosedMissions: [_samplePlatform()],
        searchResults: [_samplePlatform(ref: 'PLT-002')],
      );
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

      // First refresh: no baseline yet -> fetchUnclosedMissions, seeds PLT-001.
      await container.read(platformsRefreshProvider.notifier).refresh();
      final firstRefresh = await db.getLastPlatformsRefresh();

      // Second refresh: baseline present -> delta search + upsert.
      await container.read(platformsRefreshProvider.notifier).refresh();

      expect(fakeRepository.fetchUnclosedMissionsCallCount, 1);
      expect(fakeRepository.capturedSearchDtos, hasLength(1));
      final searchDto = fakeRepository.capturedSearchDtos.single!;
      expect(searchDto.cachedSince, firstRefresh!.toUtc().toIso8601String());
      expect(searchDto.paginationEnabled, isFalse);
      expect(searchDto.filters, isNull);

      // The delta result (PLT-002) is upserted; PLT-001 (absent from the
      // delta response) is left untouched, not deleted.
      final rows = await db.select(db.platforms).get();
      expect(rows.map((r) => r.ref), containsAll(['PLT-001', 'PLT-002']));
      expect(rows, hasLength(2));
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
