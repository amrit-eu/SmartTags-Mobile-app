import 'package:flutter_amrit/database/db.dart';

/// A repository that fetches platform data from the OceanOPS API.
class OceanOpsRepository {
  /// Fetches a list of platforms from the API.
  /// Currently returns mock data for demonstration purposes.
  Future<List<PlatformsCompanion>> fetchPlatforms() async {
    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return [
      PlatformsCompanion.insert(
        ref: 'PLT-5906511',
        model: 'ARVOR_C',
        network: 'Argo',
        lat: 45.123,
        lon: -5.456,
        status: 'Active',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        operationLat: 45,
        operationLon: -5.5,
      ),
      PlatformsCompanion.insert(
        ref: 'PLT-5906512',
        model: 'PROVOR_III',
        network: 'Argo',
        lat: 44.890,
        lon: -6.123,
        status: 'Active',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        operationLat: 45,
        operationLon: -6,
      ),
      PlatformsCompanion.insert(
        ref: 'PLT-5906513',
        model: 'SOLO_II',
        network: 'Argo',
        lat: 45.567,
        lon: -4.789,
        status: 'Inactive',
        operationalStatus: 'Recovered',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        operationLat: 46,
        operationLon: -5,
      ),
      PlatformsCompanion.insert(
        ref: 'PLT-4902345',
        model: 'DEEP_ARGO',
        network: 'DBCP',
        lat: 43.5,
        lon: -8.2,
        status: 'Active',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        operationLat: 43,
        operationLon: -8,
      ),
    ];
  }
}
