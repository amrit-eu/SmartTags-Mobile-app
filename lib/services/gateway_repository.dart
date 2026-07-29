import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_passport_mapper.dart';
import 'package:smart_tags/services/passport_event_mapper.dart';

/// Exception thrown when a Gateway API call fails (non-200, network, or auth error).
class GatewayException implements Exception {
  /// Creates a [GatewayException] with the given [message].
  const GatewayException(this.message);

  /// The error message describing the Gateway failure.
  final String message;

  @override
  String toString() => message;
}

/// Fetches platform passport data from, and submits passport events to, the
/// Amrit Gateway API.
class GatewayRepository {
  /// Creates a [GatewayRepository] instance.
  GatewayRepository({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  final http.Client _client;
  final AuthService _authService;

  /// Loads unclosed missions from the Gateway enriched passport endpoint.
  Future<List<PlatformsCompanion>> fetchUnclosedMissions() async {
    final uri = GatewayConfig.unclosedPassportsUri;
    try {
      if (kDebugMode) {
        debugPrint('Gateway GET $uri');
      }
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

      if (kDebugMode) {
        debugPrint('Gateway returned ${items.length} unclosed missions');
      }
      return items;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Gateway fetchUnclosedMissions error: $e\n$st');
      }
      rethrow;
    }
  }

  String _truncate(String value, {int max = 200}) {
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max)}…';
  }

  /// Sends a pre-built Gateway JSON [body] to `PUT /oceanops/data/goos-passport-events`.
  /// Storing/replaying the raw JSON [body] (rather than re-deriving it from a
  /// [PassportEventRequest]) lets the offline queue resend an identical
  /// request without depending on form state.
  ///
  /// Throws [GatewayException] on missing auth, non-200 response, or network error.
  /// [RefreshException] (forced logout) from [AuthService.getAccessToken] propagates.
  Future<void> submitPassportEventJson(String body) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw const GatewayException('Not authenticated. Please log in again.');
    }
    try {
      final response = await _client.put(
        GatewayConfig.goosPassportEventsUri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: body,
      );
      if (response.statusCode != 200) {
        throw GatewayException('Failed to submit passport event (Status ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw GatewayException('Network error: ${e.message}');
    }
  }

  /// Builds the Gateway JSON body from [request] then sends it.
  Future<void> submitPassportEvent(PassportEventRequest request) {
    return submitPassportEventJson(jsonEncode(PassportEventMapper.toJson(request)));
  }
}
