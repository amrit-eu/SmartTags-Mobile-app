import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/providers/qr_passport_lookup_provider.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';

Map<String, dynamic> passport(String ref, String code, String date) => {
  'reference': ref,
  'passport': {
    'identification': {'qrCode': code, 'passportId': ref},
    'status': {
      'reportingStatus': {'name': 'OPERATIONAL'},
    },
    'operations': {
      'deployment': {'timestamp': date},
    },
  },
};

PlatformsCompanion local(String ref, String code) => PlatformsCompanion.insert(
  ref: ref,
  model: 'Float',
  network: 'Argo',
  lat: 0,
  lon: 0,
  status: 'OPERATIONAL',
  operationalStatus: 'Deployed',
  lastUpdated: DateTime.utc(2024),
  operationLat: 0,
  operationLon: 0,
  category: 'Float',
  qrCode: Value(code),
);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.executor(conn.inMemoryConnection()));
  tearDown(() async => db.close());

  GatewayRepository gateway(http.Client client) => GatewayRepository(
    client: client,
    authService: AuthService(authDao: db.authDao),
  );

  test('online posts correct filter and returns matching distinct passports', () async {
    var calls = 0;
    final olderPassport = passport('OLD', 'AbC', '2020-01-01T00:00:00Z')
      ..['alerts'] = [
        {'id': 'alert-1', 'resource': 'OLD', 'event': 'TEST', 'severity': 'minor', 'status': 'open'},
      ];
    final client = MockClient((request) async {
      calls++;
      expect(request.method, 'POST');
      expect(request.url, GatewayConfig.passportsSearchUri);
      expect(jsonDecode(request.body), {
        'paginationEnabled': false,
        'filters': {'qrCode': 'AbC'},
      });
      return http.Response(
        jsonEncode({
          'items': [
            olderPassport,
            passport('OLD', 'AbC', '2020-01-01T00:00:00Z'),
            passport('NEW', 'AbC', '2025-01-01T00:00:00Z'),
            passport('OTHER', 'abc', '2026-01-01T00:00:00Z'),
          ],
        }),
        200,
      );
    });
    await db.setLastPlatformsRefresh(DateTime.utc(2023));
    final result = await QrPassportLookupRepository(
      database: db,
      gateway: gateway(client),
      connectivity: () async => ConnectivityResult.wifi,
    ).lookupByQrCode('AbC');

    expect(calls, 1);
    expect(result.platforms.map((p) => p.ref), ['NEW', 'OLD']);
    expect((await db.getPlatformByRef('NEW')).single.qrCode, 'AbC');
    expect((await db.getAlertsByQrCode('AbC')).single.id, 'alert-1');
    expect(await db.getPlatformByRef('OTHER'), isEmpty);
    expect((await db.getLastPlatformsRefresh())?.toUtc(), DateTime.utc(2023));
  });

  test('offline uses exact local matches without an API call', () async {
    await db.insertPlatforms([local('A', 'AbC'), local('B', 'AbC'), local('C', 'abc')]);
    final result = await QrPassportLookupRepository(
      database: db,
      gateway: gateway(MockClient((_) async => throw StateError('Unexpected request'))),
      connectivity: () async => ConnectivityResult.none,
    ).lookupByQrCode('AbC');
    expect(result.platforms.map((p) => p.ref), ['A', 'B']);
  });

  test('offline unknown QR code returns an empty result', () async {
    final result = await QrPassportLookupRepository(
      database: db,
      gateway: gateway(MockClient((_) async => throw StateError('Unexpected request'))),
      connectivity: () async => ConnectivityResult.none,
    ).lookupByQrCode('UNKNOWN');
    expect(result.qrCode, 'UNKNOWN');
    expect(result.platforms, isEmpty);
  });

  test('connection loss during request falls back to local rows', () async {
    await db.insertPlatforms([local('CACHED', 'AbC')]);
    var online = true;
    final result = await QrPassportLookupRepository(
      database: db,
      gateway: gateway(
        MockClient((_) async {
          online = false;
          throw Exception('Disconnected');
        }),
      ),
      connectivity: () async => online ? ConnectivityResult.wifi : ConnectivityResult.none,
    ).lookupByQrCode('AbC');
    expect(result.platforms.single.ref, 'CACHED');
  });

  test('API failure is reported for retry', () async {
    final repository = QrPassportLookupRepository(
      database: db,
      gateway: gateway(MockClient((_) async => http.Response('Server error', 500))),
      connectivity: () async => ConnectivityResult.wifi,
    );
    await expectLater(repository.lookupByQrCode('AbC'), throwsException);
  });

  test('invalid API response is an error rather than an empty result', () async {
    final repository = QrPassportLookupRepository(
      database: db,
      gateway: gateway(MockClient((_) async => http.Response('{}', 200))),
      connectivity: () async => ConnectivityResult.wifi,
    );
    await expectLater(repository.lookupByQrCode('AbC'), throwsA(isA<FormatException>()));
  });
}
