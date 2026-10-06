import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/models/passport_filter_dto.dart';
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

/// A [GatewayException] specifically caused by missing or rejected
/// authentication (no access token, or the server returned 401). Callers can
/// use this to distinguish "the user needs to log in" from a transient
/// network/server failure, since reconnecting alone won't resolve it.
class GatewayAuthException extends GatewayException {
  /// Creates a [GatewayAuthException] with the given [message].
  const GatewayAuthException(super.message);
}

/// Called after each paginated Gateway page during unclosed-missions download.
typedef GatewayDownloadProgressCallback = void Function(int downloaded, int total);

/// Fetches platform passport data from, and submits passport events to, the
/// Amrit Gateway API.
class GatewayRepository {
  /// Creates a [GatewayRepository] instance.
  GatewayRepository({required AuthService authService, http.Client? client})
    : _client = client ?? http.Client(),
      _authService = authService;

  final http.Client _client;
  final AuthService _authService;

  static const int _unclosedPageSize = 50;

  /// Loads unclosed missions via paginated enriched passport search.
  ///
  /// [onDownloadProgress] receives item counts (`downloaded` / `total`) after
  /// each page so the UI can show `Downloading platforms N/M` during the
  /// network phase.
  Future<GatewayPassportsResult> fetchUnclosedMissions({
    GatewayDownloadProgressCallback? onDownloadProgress,
  }) async {
    try {
      final allItems = <Map<String, dynamic>>[];
      var offset = 0;
      int? reportedTotal;

      while (true) {
        final dto = PassportFilterDto.unclosedPaginated(
          limit: _unclosedPageSize,
          offset: offset,
        );
        final jsonResponse = await _postPassportSearch(dto);
        final pageItems =
            (jsonResponse['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
        reportedTotal ??= jsonResponse['total'] as int?;
        allItems.addAll(pageItems);

        final total = reportedTotal ?? allItems.length;
        onDownloadProgress?.call(allItems.length, total);

        if (pageItems.isEmpty || pageItems.length < _unclosedPageSize || allItems.length >= total) {
          break;
        }
        offset += pageItems.length;
      }

      final result = GatewayPassportMapper.fromEnrichedPassportItems(
        allItems,
        reportedTotal: reportedTotal,
      );

      if (kDebugMode) {
        debugPrint(
          'Gateway returned ${result.platforms.length} unclosed missions '
          '(${result.alerts.length} alerts)',
        );
      }
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Gateway fetchUnclosedMissions error: $e\n$st');
      }
      rethrow;
    }
  }

  /// Searches passports on the Gateway enriched passport search endpoint.
  ///
  /// When [searchDto] is null, delegates to [fetchUnclosedMissions] instead
  /// of issuing a search request.
  Future<GatewayPassportsResult> searchPassports(PassportFilterDto? searchDto) async {
    if (searchDto == null) {
      return fetchUnclosedMissions();
    }

    try {
      final jsonResponse = await _postPassportSearch(searchDto);
      final items = (jsonResponse['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
      final reportedTotal = jsonResponse['total'] as int?;
      final result = GatewayPassportMapper.fromEnrichedPassportItems(
        items,
        reportedTotal: reportedTotal,
      );

      if (kDebugMode) {
        debugPrint('Gateway returned ${result.platforms.length} passports (${result.alerts.length} alerts)');
      }
      return result;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Gateway searchPassports error: $e\n$st');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _postPassportSearch(PassportFilterDto searchDto) async {
    final uri = GatewayConfig.passportsSearchUri;
    final body = jsonEncode(searchDto.toJson());
    if (kDebugMode) {
      debugPrint('Gateway POST $uri body=$body');
    }
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception(
        'Failed to search passports '
        '(Status ${response.statusCode}, body=${_truncate(response.body)})',
      );
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// The Gateway returns `201 Created` for some POST endpoints (e.g. the
  /// passport search) rather than `200 OK`, so any 2xx status is accepted.
  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

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
      throw const GatewayAuthException('Not authenticated. Please log in again.');
    }
    try {
      final response = await _client.put(
        GatewayConfig.goosPassportEventsUri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: body,
      );
      if (response.statusCode == 401) {
        throw const GatewayAuthException('Session expired. Please log in again.');
      }
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
