import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_tags/services/oceanops_repository.dart';

void main() {
  group('OceanOpsRepository', () {
    test('fetchPlatforms returns a list of platforms on success', () async {
      final mockResponse = {
        'data': [
          {
            'ref': 'PLT-123',
            'latestObs': {
              'lat': 10.0,
              'lon': 20.0,
              'obsDate': '2023-01-01T12:00:00',
            },
            'ptfStatus': {'name': 'OPERATIONAL'},
            'ptfModel': {
              'name': 'Model A',
              'network': {'name': 'Net A'},
            },
            'ptfDepl': {
              'lat': 5.0,
              'lon': 6.0,
              'deplDate': '2022-01-01T12:00:00',
            },
          },
        ],
      };

      final client = MockClient((request) async {
        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = OceanOpsRepository(client: client);
      final platforms = await repository.fetchPlatforms();

      expect(platforms.length, 1);
      expect(platforms.first.ref.value, 'PLT-123');
      expect(platforms.first.model.value, 'Model A');
      expect(platforms.first.lat.value, 10.0);
      expect(platforms.first.operationalStatus.value, 'Deployed');
    });

    test('fetchPlatforms maps INACTIVE status to Recovered', () async {
      final mockResponse = {
        'data': [
          {
            'ref': 'PLT-456',
            'ptfStatus': {'name': 'INACTIVE'},
            'latestObs': {'lat': 0.0, 'lon': 0.0},
            'ptfModel': {
              'name': 'Model B',
              'network': {'name': 'Net B'},
            },
          },
        ],
      };

      final client = MockClient((request) async {
        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = OceanOpsRepository(client: client);
      final platforms = await repository.fetchPlatforms();

      expect(platforms.first.operationalStatus.value, 'Recovered');
    });

    test('fetchPlatforms throws an exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository = OceanOpsRepository(client: client);

      expect(repository.fetchPlatforms, throwsException);
    });
  });
}
