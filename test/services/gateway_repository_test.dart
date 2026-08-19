import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/daos/auth_dao.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
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
};

void main() {
  group('GatewayPassportMapper', () {
    test('maps passport fields required for #97 and #99', () {
      final companion = GatewayPassportMapper.fromPassportItem(_samplePassportItem);

      expect(companion.ref.value, '2900314');
      expect(companion.ptfId.value, '22');
      expect(companion.model.value, 'PROVOR_MT');
      expect(companion.platformCategory.value, 'Float');
      expect(companion.reportingStatus.value, 'OPERATIONAL');
      expect(companion.observingNetwork.value, 'Argo');
      expect(companion.wigosId.value, '2900314');
      expect(companion.status.value, 'OPERATIONAL');
      expect(companion.latestOperationType.value, 'Deployment');
      expect(companion.operationalStatus.value, 'Deployed');
      expect(companion.lat.value, 33.815);
      expect(companion.lon.value, 149.765);
    });

    test('maps ended missions to Recovery', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      (item['passport'] as Map<String, dynamic>)['operations'] = {
        'deployment': {
          'latitude': 1,
          'longitude': 2,
          'timestamp': '2001-10-12T00:00:00Z',
        },
        'endTimestamp': '2002-06-08T23:54:33Z',
      };

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.latestOperationType.value, 'Recovery');
      expect(companion.operationalStatus.value, 'Recovered');
    });

    test('accepts a string ptfId and normalizes it', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      item['ptfId'] = '1155387';

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.ptfId.value, '1155387');
    });

    test('leaves ptfId null when missing from the source item', () {
      final item = jsonDecode(jsonEncode(_samplePassportItem)) as Map<String, dynamic>;
      item.remove('ptfId');

      final companion = GatewayPassportMapper.fromPassportItem(item);

      expect(companion.ptfId.value, isNull);
    });
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
      final platforms = await repository.fetchUnclosedMissions();

      expect(platforms.length, 1);
      expect(platforms.first.ref.value, '2900314');
    });

    test('fetchUnclosedMissions throws on error response', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository = GatewayRepository(client: client, authService: _FakeAuthService(null));

      expect(repository.fetchUnclosedMissions, throwsException);
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
}
