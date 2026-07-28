import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/services/gateway_passport_mapper.dart';

/// Fetches platform passport data from the Amrit Gateway API.
class GatewayRepository {
  /// Creates a [GatewayRepository] instance.
  GatewayRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Loads unclosed missions from the Gateway enriched passport endpoint.
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    final uri = GatewayConfig.unclosedPassportsUri;
    try {
      debugPrint('Gateway GET $uri');
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load unclosed missions '
          '(Status ${response.statusCode}, body=${_truncate(response.body)})',
        );
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final items = (jsonResponse['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GatewayPassportMapper.fromPassportItem)
          .toList();

      debugPrint('Gateway returned ${items.length} unclosed missions');
      return items;
    } catch (e, st) {
      debugPrint('Gateway fetchUnclosedMissions error: $e\n$st');
      rethrow;
    }
  }

  String _truncate(String value, {int max = 200}) {
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max)}…';
  }
}
