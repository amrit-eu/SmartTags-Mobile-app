import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/daos/auth_dao.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/passport_filter_dto.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_passport_mapper.dart';
import 'package:smart_tags/services/gateway_repository.dart';

/// A throwaway [AuthDao] backed by an in-memory DB, only to satisfy
/// [AuthService]'s required constructor argument. Never queried, since
/// [_FakeAuthService] overrides [AuthService.getAccessToken].
AuthDao _fakeAuthDao() => AppDatabase.executor(conn.inMemoryConnection()).authDao;

class _FakeAuthService extends AuthService {
  _FakeAuthService(this._token) : super(authDao: _fakeAuthDao());

  final String? _token;

  @override
  Future<String?> getAccessToken() async => _token;
}

const Map<String, dynamic> _samplePassportItem = {
  'ptfId': 22,
  'passportId': '0-22000-0-2900314',
  'reference': '2900314',
  'passport': {
    'identification': {
      'reference': '2900314',
      'passportId': '0-22000-0-2900314',
      'qrCode': 'RFHCZ3S',
    },
    'status': {
      'reportingStatus': {
        'name': 'OPERATIONAL',
      },
      'latestObservation': {
        'latitude': 33.815,
        'longitude': 149.765,
        'timestamp': '2002-06-08T23:54:33Z',
      },
    },
    'hardware': {
      'platform': {
        'asset': {
          'wmo': '2900314',
          'model': {
            'name': 'PROVOR_MT',
            'type': {
              'name': 'Float',
            },
          },
        },
      },
    },
    'operations': {
      'deployment': {
        'latitude': 33.999,
        'longitude': 143.993,
        'timestamp': '2001-10-12T00:00:00Z',
      },
    },
    'affiliation': {
      'goosObservingNetworks': [
        {
          'name': 'Argo',
          'wigosCode': 'argo',
        },
      ],
    },
  },
  'alerts': [
    {
      'id': 'dcb42bf8-3f75-4241-a549-d79513fc8591',
      'resource': '2900314',
      'event': 'Float_Approaching_EEZ_Turkey_ARV',
      'severity': 'minor',
      'status': 'open',
      'text': 'Float approaching Turkey EEZ',
      'service': 'passports',
      'duplicateCount': 0,
      'attributes': {'Country': 'Italy', 'alertCategory': 'Geofence', 'country': 'Italy'},
      'history': <Map<String, dynamic>>[],
    },
  ],
};

void main() {
  group('GatewayPassportMapper', () {
    test('maps passport fields required for #97 and #99', () {
      final companion = GatewayPassportMapper.fromPassportItem(_samplePassportItem);

      expect(companion.ref.value, '2900314');
      expect(companion.ptfId.value, '22');
      expect(companion.model.value, 'PROVOR_MT');
      expect(companion.reportingStatus.value, 'OPERATIONAL');
      expect(companion.observingNetwork.value, 'Argo');
      expect(companion.wigosId.value, '0-22000-0-2900314');
      expect(companion.qrCode.value, 'RFHCZ3S');
      expect(companion.status.value, 'OPERATIONAL');
      expect(companion.latestOperationType.value, 'Deployment');
      expect(companion.operationalStatus.value, 'Deployed');
      expect(companion.lat.value, 33.815);
      expect(companion.lon.value, 149.765);
      expect(companion.hasLatestObservation.value, isTrue);
    });

    test('maps ending cause and observation flag for recovery (#100)', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      final passport = item['passport'] as Map<String, dynamic>;
      passport['status'] = {
        'reportingStatus': {'name': 'INACTIVE'},
        'latestObservation': {
          'latitude': 1,
          'longitude': 2,
          'timestamp': '2002-06-08T23:54:33Z',
        },
        'endingCause': {'id': 25, 'code': 'voluntary-recovery-of-the-platform'},
      };
      passport['operations'] = {
        'deployment': {
          'latitude': 1,
          'longitude': 2,
          'timestamp': '2001-10-12T00:00:00Z',
        },
        'retrieval': {
          'latitude': 1,
          'longitude': 2,
          'startTimestamp': '2002-06-08T23:54:33Z',
        },
      };

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.latestOperationType.value, 'Recovery');
      expect(companion.endingCauseId.value, 25);
      expect(companion.hasLatestObservation.value, isTrue);
    });

    test('maps ended missions to Recovery', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      (item['passport'] as Map<String, dynamic>)['operations'] = {
        'deployment': {
          'latitude': 1,
          'longitude': 2,
          'timestamp': '2001-10-12T00:00:00Z',
        },
        'retrieval': {
          'latitude': 1,
          'longitude': 2,
          'startTimestamp': '2002-06-08T23:54:33Z',
        },
      };

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.latestOperationType.value, 'Recovery');
      expect(companion.operationalStatus.value, 'Recovered');
    });

    test('maps a redeployment after recovery back to Deployment', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      (item['passport'] as Map<String, dynamic>)['operations'] = {
        'retrieval': {
          'latitude': 1,
          'longitude': 2,
          'startTimestamp': '2001-10-12T00:00:00Z',
        },
        'deployment': {
          'latitude': 3,
          'longitude': 4,
          'timestamp': '2002-06-08T23:54:33Z',
        },
      };

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.latestOperationType.value, 'Deployment');
      expect(companion.operationalStatus.value, 'Deployed');
      expect(companion.operationLat.value, 3);
      expect(companion.operationLon.value, 4);
    });

    test('accepts a string ptfId and normalizes it', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      item['ptfId'] = '1155387';

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.ptfId.value, '1155387');
    });

    test('leaves ptfId null when missing from the source item', () {
      final item = (jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>)..remove('ptfId');

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.ptfId.value, isNull);
    });

    test('leaves qrCode null when passport identification value is null', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      final passport = item['passport'] as Map<String, dynamic>;
      (passport['identification'] as Map<String, dynamic>)['qrCode'] = null;

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.qrCode.value, isNull);
    });

    test('alertsFromPassportItem keeps only the Alert model attributes', () {
      final alerts = GatewayPassportMapper.alertsFromPassportItem(_samplePassportItem);

      expect(alerts, hasLength(1));
      expect(alerts.first.id.value, 'dcb42bf8-3f75-4241-a549-d79513fc8591');
      expect(alerts.first.resource.value, '2900314');
      expect(alerts.first.event.value, 'Float_Approaching_EEZ_Turkey_ARV');
      expect(alerts.first.severity.value, 'minor');
      expect(alerts.first.status.value, 'open');
    });

    test('alertsFromPassportItem drops alerts missing a required field', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      (item['alerts'] as List<dynamic>).cast<Map<String, dynamic>>().first.remove('severity');

      final alerts = GatewayPassportMapper.alertsFromPassportItem(item);

      expect(alerts, isEmpty);
    });

    test(
      'fromEnrichedPassportItems skips items with no passport data, but still collects their alerts',
      () {
        // An alert-only item: no `passport` key at all, just a reference and
        // its alerts (seen in the wild for orphaned/out-of-scope alerts).
        const alertOnlyItem = {
          'reference': '4902437',
          'alerts': [
            {
              'id': 'efa16767-712f-4dfb-99d0-3ca431ceed8c',
              'resource': '4902437',
              'event': 'TECH_FLAG_MpeBrokenAlarm_LOGICAL',
              'severity': 'major',
              'status': 'open',
              'text': 'MPE broken alarm',
              'service': 'passports',
              'duplicateCount': 0,
              'attributes': {'alertCategory': 'Technical', 'country': 'France'},
            },
          ],
        };

        final result = GatewayPassportMapper.fromEnrichedPassportItems([
          _samplePassportItem,
          alertOnlyItem,
        ]);

        // Only the item with actual passport data becomes a platform.
        expect(result.platforms, hasLength(1));
        expect(result.platforms.single.ref.value, '2900314');

        // Alerts from both items are still collected (the alert-only item's
        // alert is pruned later by `deleteOrphanedAlerts` if it ends up
        // pointing at no local platform).
        expect(result.alerts, hasLength(2));
        expect(result.alerts.map((a) => a.resource.value), containsAll(['2900314', '4902437']));
      },
    );
  });

  group('GatewayRepository', () {
    test('fetchUnclosedMissions returns mapped platforms on success', () async {
      final mockResponse = {
        'items': [_samplePassportItem],
        'total': 1,
      };

      final client = MockClient((request) async {
        expect(request.url, GatewayConfig.unclosedPassportsUri);
        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));
      final result = await repository.fetchUnclosedMissions();

      expect(result.platforms.length, 1);
      expect(result.platforms.first.ref.value, '2900314');
      expect(result.alerts.length, 1);
      expect(result.alerts.first.id.value, 'dcb42bf8-3f75-4241-a549-d79513fc8591');
    });

    test('fetchUnclosedMissions throws on error response', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));

      expect(repository.fetchUnclosedMissions, throwsException);
    });

    test('searchPassports posts the filters and returns mapped platforms on 200', () async {
      final mockResponse = {
        'items': [_samplePassportItem],
        'total': 1,
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, GatewayConfig.passportsSearchUri);
        expect(request.headers['Content-Type'], 'application/json');
        expect(
          json.decode(request.body),
          {
            'filters': {'updatedSince': '2026-07-01T00:00:00.000Z'},
          },
        );
        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));
      final result = await repository.searchPassports(
        const PassportFilterDto(
          filters: {'updatedSince': '2026-07-01T00:00:00.000Z'},
        ),
      );

      expect(result.platforms.length, 1);
      expect(result.platforms.first.ref.value, '2900314');
    });

    test('searchPassports accepts a 201 response (Gateway returns Created on this endpoint)', () async {
      final mockResponse = {
        'items': [_samplePassportItem],
        'total': 1,
      };

      final client = MockClient((request) async {
        return http.Response(json.encode(mockResponse), 201);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));
      final result = await repository.searchPassports(const PassportFilterDto(filters: {}));

      expect(result.platforms.length, 1);
      expect(result.platforms.first.ref.value, '2900314');
    });

    test('searchPassports throws on error response', () async {
      final client = MockClient((request) async {
        return http.Response('Bad request', 400);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));

      expect(
        () => repository.searchPassports(const PassportFilterDto(filters: {})),
        throwsException,
      );
    });

    test('searchPassports delegates to fetchUnclosedMissions when searchDto is null', () async {
      final mockResponse = {
        'items': [_samplePassportItem],
        'total': 1,
      };

      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url, GatewayConfig.unclosedPassportsUri);
        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));
      final result = await repository.searchPassports(null);

      expect(result.platforms.length, 1);
    });
  });

  group('submitPassportEventJson', () {
    const body = '{"ptfId":"1155387","deployment":{"date":"2026-07-09T00:00:00Z"}}';

    test('sends a PUT with the Bearer token and JSON body', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url, GatewayConfig.goosPassportEventsUri);
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.body, body);
        return http.Response('{"status":"ok"}', 200);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

      await repository.submitPassportEventJson(body);
    });

    test('throws GatewayException when there is no access token', () async {
      final client = MockClient((request) async {
        fail('Should not send a request without a token');
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));

      expect(
        () => repository.submitPassportEventJson(body),
        throwsA(isA<GatewayException>()),
      );
    });

    test('throws GatewayException on a non-200 response', () async {
      final client = MockClient((request) async {
        return http.Response('Bad request', 400);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

      expect(
        () => repository.submitPassportEventJson(body),
        throwsA(isA<GatewayException>()),
      );
    });
  });

  group('pairPlatformToQRCode', () {
    const platformId = '1004967';
    const qrCode = 'AbC/123';

    for (final passportsUpToDate in [false, true]) {
      test('sends an authenticated POST and accepts 201 with passportsUpToDate=$passportsUpToDate', () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url, GatewayConfig.pairPlatformToQrCodeUri);
          expect(request.headers['Authorization'], 'Bearer test-token');
          expect(request.headers['Content-Type'], 'application/json');
          expect(jsonDecode(request.body), {'ptfId': 1004967, 'qrCode': qrCode});
          return http.Response(
            jsonEncode({
              'ptfId': 1004967,
              'qrCode': qrCode,
              'localIdentifier': '5500023',
              'passportsUpToDate': passportsUpToDate,
            }),
            201,
          );
        });
        final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

        await repository.pairPlatformToQRCode(platformId, qrCode);
      });
    }

    test('does not send a request without an access token', () async {
      final client = MockClient((request) async {
        fail('Should not send a request without a token');
      });
      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));

      await expectLater(
        repository.pairPlatformToQRCode(platformId, qrCode),
        throwsA(isA<GatewayAuthException>()),
      );
    });

    test('throws GatewayAuthException when the server rejects authentication', () async {
      final client = MockClient((request) async => http.Response('Unauthorized', 401));
      final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

      await expectLater(
        repository.pairPlatformToQRCode(platformId, qrCode),
        throwsA(isA<GatewayAuthException>()),
      );
    });

    for (final statusCode in [400, 403, 409, 500]) {
      test('reports a failed pairing response with status $statusCode', () async {
        final client = MockClient((request) async => http.Response('Pairing failed', statusCode));
        final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

        await expectLater(
          repository.pairPlatformToQRCode(platformId, qrCode),
          throwsA(
            isA<GatewayException>().having(
              (error) => error.message,
              'message',
              'Failed to pair platform to QR code (Status $statusCode)',
            ),
          ),
        );
      });
    }

    test('wraps transport failures in GatewayException', () async {
      final client = MockClient((request) async => throw http.ClientException('Connection lost'));
      final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

      await expectLater(
        repository.pairPlatformToQRCode(platformId, qrCode),
        throwsA(
          isA<GatewayException>().having((error) => error.message, 'message', 'Network error: Connection lost'),
        ),
      );
    });

    test('rejects invalid platform identifiers before sending a request', () async {
      final client = MockClient((request) async {
        fail('Should not send a request with an invalid platform ID');
      });
      final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

      for (final invalidId in ['', '   ', 'DEP-1', '0', '-1', '1.5', '0x10']) {
        await expectLater(
          repository.pairPlatformToQRCode(invalidId, qrCode),
          throwsA(isA<GatewayException>()),
        );
      }
    });

    test('rejects empty QR codes before sending a request', () async {
      final client = MockClient((request) async {
        fail('Should not send a request with an empty QR code');
      });
      final repository = GatewayRepository(client: client, authService: _FakeAuthService('test-token'));

      for (final emptyCode in ['', '   ']) {
        await expectLater(
          repository.pairPlatformToQRCode(platformId, emptyCode),
          throwsA(isA<GatewayException>()),
        );
      }
    });
  });
}
