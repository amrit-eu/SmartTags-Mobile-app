import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_tags/database/db.dart';

/// A repository that fetches platform data from the OceanOPS API.
class OceanOpsRepository {
  /// Creates an [OceanOpsRepository] instance.
  OceanOpsRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// The base URL for the OceanOPS API.
  static const String _baseUrl = 'https://www.ocean-ops.org/api/1/data/platform/';

  /// Fetches a list of platforms from the API.
  Future<List<PlatformsCompanion>> fetchPlatforms() async {
    try {
      final formattedDate = DateTime.now().toUtc().subtract(const Duration(days: 5)).toString().split('.')[0];

      final apiUrl = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'exp': jsonEncode([
            "ptfStatus.name in ('INACTIVE','CLOSED','OPERATIONAL') and latestObs.obsDate>'$formattedDate'",
          ]),
          'include': jsonEncode([
            'ref',
            'latestObs.lat',
            'latestObs.lon',
            'latestObs.obsDate',
            'ptfStatus.name',
            'ptfDepl.deplDate',
            'ptfModel.name',
            'ptfModel.network.name',
            'ptfDepl.lat',
            'ptfDepl.lon',
          ]),
        },
      );

      final response = await _client.get(apiUrl);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final platformsData = (jsonResponse['data'] as List).cast<Map<String, dynamic>>();

        return platformsData.map((platformJson) {
          final latestObs = platformJson['latestObs'] as Map<String, dynamic>?;
          final lat = (latestObs?['lat'] as num?)?.toDouble() ?? 0.0;
          final lon = (latestObs?['lon'] as num?)?.toDouble() ?? 0.0;

          final ptfStatus = platformJson['ptfStatus'] as Map<String, dynamic>?;
          final status = (ptfStatus?['name'] as String?) ?? 'Unknown';

          // Map API status to operational ones
          // Based on current DB schema: operationalStatus is Deployed/Recovered
          final isRecovered = status.toUpperCase() == 'INACTIVE' || status.toUpperCase() == 'CLOSED';

          final ptfModel = platformJson['ptfModel'] as Map<String, dynamic>?;
          final network = ptfModel?['network'] as Map<String, dynamic>?;

          final ptfDepl = platformJson['ptfDepl'] as Map<String, dynamic>?;

          return PlatformsCompanion.insert(
            ref: (platformJson['ref'] as String?) ?? 'Unknown',
            model: (ptfModel?['name'] as String?) ?? 'Unknown',
            network: (network?['name'] as String?) ?? 'Unknown',
            lat: lat,
            lon: lon,
            status: status,
            operationalStatus: isRecovered ? 'Recovered' : 'Deployed',
            lastUpdated: latestObs?['obsDate'] != null
                ? DateTime.tryParse(latestObs!['obsDate'] as String) ?? DateTime.now()
                : DateTime.now(),
            operationLat: (ptfDepl?['lat'] as num?)?.toDouble() ?? lat,
            operationLon: (ptfDepl?['lon'] as num?)?.toDouble() ?? lon,
          );
        }).toList();
      } else {
        throw Exception('Failed to load platforms (Status ${response.statusCode})');
      }
    } catch (e) {
      // Re-throw or handle error as appropriate for your app's error policy
      rethrow;
    }
  }
}
