import 'package:drift/drift.dart';
import 'package:smart_tags/database/db.dart';

/// Maps enriched GOOS passport items from the Gateway API to Drift companions.
abstract final class GatewayPassportMapper {
  /// Converts a single enriched passport [item] JSON object.
  static PlatformsCompanion fromPassportItem(Map<String, dynamic> item) {
    final passport = item['passport'] as Map<String, dynamic>? ?? {};
    final identification = passport['identification'] as Map<String, dynamic>? ?? {};
    final status = passport['status'] as Map<String, dynamic>? ?? {};
    final affiliation = passport['affiliation'] as Map<String, dynamic>? ?? {};
    final operations = passport['operations'] as Map<String, dynamic>? ?? {};
    final hardware = passport['hardware'] as Map<String, dynamic>? ?? {};

    final platformHardware = hardware['platform'] as Map<String, dynamic>? ?? {};
    final asset = platformHardware['asset'] as Map<String, dynamic>? ?? {};
    final assetModel = asset['model'] as Map<String, dynamic>? ?? {};
    final assetType = assetModel['type'] as Map<String, dynamic>? ?? {};

    final reportingStatus = status['reportingStatus'] as Map<String, dynamic>? ?? {};
    final latestObservation = status['latestObservation'] as Map<String, dynamic>? ?? {};
    final endingCause = status['endingCause'] as Map<String, dynamic>? ?? {};
    final supervisingProgram = affiliation['supervisingProgram'] as Map<String, dynamic>?;

    final observingNetworks = _observingNetworkNames(affiliation);
    final latestOperation = _resolveLatestOperation(operations);

    final latestLat = _asDouble(latestObservation['latitude']) ?? 0.0;
    final latestLon = _asDouble(latestObservation['longitude']) ?? 0.0;
    final operationLat = latestOperation?.lat ?? latestLat;
    final operationLon = latestOperation?.lon ?? latestLon;

    final latestObsTimestamp = latestObservation['timestamp'] as String?;
    final hasLatestObservation = latestObsTimestamp != null && latestObsTimestamp.isNotEmpty;

    return PlatformsCompanion.insert(
      ref: (item['reference'] as String?) ?? (identification['reference'] as String?) ?? 'Unknown',
      ptfId: Value(_asPtfId(item['ptfId'])),
      model: (assetModel['name'] as String?) ?? 'Unknown',
      network: observingNetworks.isNotEmpty ? observingNetworks.first : 'Unknown',
      lat: latestLat,
      lon: latestLon,
      status: (reportingStatus['name'] as String?) ?? 'Unknown',
      operationalStatus: latestOperation?.type == 'Recovery' ? 'Recovered' : 'Deployed',
      lastUpdated: _parseDateTime(latestObsTimestamp) ?? DateTime.now(),
      operationLat: operationLat,
      operationLon: operationLon,
      wigosId: Value(identification['passportId'] as String?),
      platformCategory: Value(assetType['name'] as String?),
      reportingStatus: Value(reportingStatus['name'] as String?),
      observingNetwork: Value(observingNetworks.join(', ')),
      latestOperationType: Value(latestOperation?.type),
      latestOperationDate: Value(latestOperation?.date),
      endingCauseId: Value(_asInt(endingCause['id'])),
      hasLatestObservation: Value(hasLatestObservation),
      programId: Value(supervisingProgram?['id'] as int?),
      programName: Value(supervisingProgram?['name'] as String?),
      programCode: Value(supervisingProgram?['code'] as String?),
    );
  }

  /// Picks whichever of `operations.deployment` / `operations.retrieval`
  /// actually happened last, comparing their dates rather than assuming
  /// retrieval always wins — a platform can be redeployed after recovery.
  static _OperationEntry? _resolveLatestOperation(Map<String, dynamic> operations) {
    final deployment = operations['deployment'] as Map<String, dynamic>?;
    final retrieval = operations['retrieval'] as Map<String, dynamic>?;

    final candidates = <_OperationEntry>[
      if (_parseDateTime(deployment?['timestamp'] as String?) case final date?)
        _OperationEntry(
          type: 'Deployment',
          date: date,
          lat: _asDouble(deployment?['latitude']),
          lon: _asDouble(deployment?['longitude']),
        ),
      if (_parseDateTime(retrieval?['startTimestamp'] as String?) case final date?)
        _OperationEntry(
          type: 'Recovery',
          date: date,
          lat: _asDouble(retrieval?['latitude']),
          lon: _asDouble(retrieval?['longitude']),
        ),
    ];
    if (candidates.isEmpty) {
      return null;
    }
    return candidates.reduce((a, b) => b.date.isAfter(a.date) ? b : a);
  }

  static List<String> _observingNetworkNames(Map<String, dynamic> affiliation) {
    final networks = affiliation['goosObservingNetworks'] as List<dynamic>? ?? [];
    return networks
        .whereType<Map<String, dynamic>>()
        .map((network) => network['name'] as String?)
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  /// The Gateway/OceanOPS platform id (`ptfId`) may come through as a number
  /// or a string depending on the endpoint; normalise to a string.
  static String? _asPtfId(Object? value) {
    if (value is num) {
      return value.toString();
    }
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

/// A single dated entry from `operations` (`deployment` or `retrieval`),
/// normalised so [GatewayPassportMapper._resolveLatestOperation] can compare
/// them by date regardless of which field name each one uses.
class _OperationEntry {
  const _OperationEntry({required this.type, required this.date, this.lat, this.lon});

  /// `'Deployment'` or `'Recovery'`.
  final String type;
  final DateTime date;
  final double? lat;
  final double? lon;
}
