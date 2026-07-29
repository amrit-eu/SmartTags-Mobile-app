import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/services/passport_event_mapper.dart';

void main() {
  group('PassportEventMapper', () {
    test('maps a minimal deployment request, omitting unset optional fields', () {
      final request = PassportEventRequest.deployment(
        ptfId: '1155387',
        deployment: DeploymentEventPayload(
          latitude: -12.667,
          longitude: -78.67,
          date: DateTime.utc(2026, 7, 9),
        ),
      );

      final json = PassportEventMapper.toJson(request);

      expect(json, {
        'ptfId': '1155387',
        'deployment': {
          'date': '2026-07-09T00:00:00Z',
          'latitude': -12.667,
          'longitude': -78.67,
        },
      });
    });

    test('maps a full deployment request including all optional fields', () {
      final request = PassportEventRequest.deployment(
        ptfId: '1140678',
        deployment: DeploymentEventPayload(
          latitude: 53.57989,
          longitude: 2.993217,
          date: DateTime.utc(2018, 11, 30),
          methodCode: 'ship',
          maxWaterDepth: 4500,
          elevation: -12,
          shipImoNumber: 'IMO9876543',
          shipOvhId: '4521',
          shipName: 'R/V Pourquoi Pas?',
        ),
      );

      final json = PassportEventMapper.toJson(request);

      expect(json, {
        'ptfId': '1140678',
        'deployment': {
          'date': '2018-11-30T00:00:00Z',
          'latitude': 53.57989,
          'longitude': 2.993217,
          'method': {'code': 'ship'},
          'maxWaterDepth': 4500,
          'elevation': -12,
          'ship': {'imoNumber': 'IMO9876543', 'ovhId': '4521', 'name': 'R/V Pourquoi Pas?'},
        },
      });
    });

    test('maps a retrieval request and never includes endDate', () {
      final request = PassportEventRequest.retrieval(
        ptfId: '1140678',
        retrieval: RetrievalEventPayload(
          latitude: 66.57989,
          longitude: 6.993217,
          startDate: DateTime.utc(2022, 11, 30),
          endingCauseCode: 'recovered',
          shipImoNumber: 'IMO1234567',
          shipOvhId: '9981',
          shipName: 'R/V Thalassa',
        ),
      );

      final json = PassportEventMapper.toJson(request);

      expect(json, {
        'ptfId': '1140678',
        'retrieval': {
          'startDate': '2022-11-30T00:00:00Z',
          'latitude': 66.57989,
          'longitude': 6.993217,
          'endingCause': {'code': 'recovered'},
          'ship': {'imoNumber': 'IMO1234567', 'ovhId': '9981', 'name': 'R/V Thalassa'},
        },
      });
      expect((json['retrieval']! as Map<String, dynamic>).containsKey('endDate'), isFalse);
    });

    test('omits the ship object entirely when all ship fields are blank', () {
      final request = PassportEventRequest.retrieval(
        ptfId: '1140678',
        retrieval: RetrievalEventPayload(
          latitude: 66.57989,
          longitude: 6.993217,
          startDate: DateTime.utc(2022, 11, 30),
          shipImoNumber: '',
          shipOvhId: '   ',
          shipName: null,
        ),
      );

      final json = PassportEventMapper.toJson(request);
      final retrieval = json['retrieval']! as Map<String, dynamic>;

      expect(retrieval.containsKey('ship'), isFalse);
      expect(retrieval.containsKey('endingCause'), isFalse);
    });

    test('truncates sub-second precision to whole seconds with a trailing Z', () {
      final request = PassportEventRequest.deployment(
        ptfId: '1',
        deployment: DeploymentEventPayload(
          latitude: 0,
          longitude: 0,
          date: DateTime.utc(2026, 7, 9, 12, 34, 56, 789),
        ),
      );

      final json = PassportEventMapper.toJson(request);
      final deployment = json['deployment']! as Map<String, dynamic>;

      expect(deployment['date'], '2026-07-09T12:34:56Z');
    });
  });
}
