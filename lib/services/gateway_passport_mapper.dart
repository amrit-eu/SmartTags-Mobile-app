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
    final deployment = operations['deployment'] as Map<String, dynamic>?;
    final supervisingProgram = affiliation['supervisingProgram'] as Map<String, dynamic>?;

    final observingNetworks = _observingNetworkNames(affiliation);
    final endTimestamp = operations['endTimestamp'] as String?;
    final hasEnded = endTimestamp != null && endTimestamp.isNotEmpty;

    final latestLat = _asDouble(latestObservation['latitude']) ?? 0.0;
    final latestLon = _asDouble(latestObservation['longitude']) ?? 0.0;
    final operationLat = _asDouble(deployment?['latitude']) ?? latestLat;
    final operationLon = _asDouble(deployment?['longitude']) ?? latestLon;

    final latestObsTimestamp = latestObservation['timestamp'] as String?;
    final deploymentTimestamp = deployment?['timestamp'] as String?;

    return PlatformsCompanion.insert(
      ref: (item['reference'] as String?) ?? (identification['reference'] as String?) ?? 'Unknown',
      ptfId: Value(_asPtfId(item['ptfId'])),
      model: (assetModel['name'] as String?) ?? 'Unknown',
      network: observingNetworks.isNotEmpty ? observingNetworks.first : 'Unknown',
      lat: latestLat,
      lon: latestLon,
      status: (reportingStatus['name'] as String?) ?? 'Unknown',
      operationalStatus: hasEnded ? 'Recovered' : 'Deployed',
      lastUpdated: _parseDateTime(latestObsTimestamp) ?? DateTime.now(),
      operationLat: operationLat,
      operationLon: operationLon,
      wigosId: Value(_wigosId(asset, affiliation)),
      platformCategory: Value(assetType['name'] as String?),
      reportingStatus: Value(reportingStatus['name'] as String?),
      observingNetwork: Value(observingNetworks.join(', ')),
      latestOperationType: Value(
        hasEnded ? 'Recovery' : (deployment != null ? 'Deployment' : null),
      ),
      latestOperationDate: Value(
        _parseDateTime(hasEnded ? endTimestamp : deploymentTimestamp),
      ),
      programId: Value(supervisingProgram?['id'] as int?),
      programName: Value(supervisingProgram?['name'] as String?),
      programCode: Value(supervisingProgram?['code'] as String?),
    );
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

  static String? _wigosId(Map<String, dynamic> asset, Map<String, dynamic> affiliation) {
    final wmo = asset['wmo'] as String?;
    if (wmo != null && wmo.isNotEmpty) {
      return wmo;
    }

    final networks = affiliation['goosObservingNetworks'] as List<dynamic>? ?? [];
    for (final network in networks) {
      if (network is Map<String, dynamic>) {
        final wigosCode = network['wigosCode'] as String?;
        if (wigosCode != null && wigosCode.isNotEmpty) {
          return wigosCode;
        }
      }
    }
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
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
