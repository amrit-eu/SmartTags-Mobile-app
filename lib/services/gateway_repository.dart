import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/config/gateway_headers.dart';
import 'package:smart_tags/helpers/platforms_download_progress.dart';
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/models/passport_filter_dto.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_passport_mapper.dart';
import 'package:smart_tags/services/passport_event_mapper.dart';

/// Exception thrown when a Gateway API call fails (non-200, network, or auth error).
class GatewayException implements Exception {
  /// Creates a [GatewayException] with the given [message] and, when the
  /// failure came from an HTTP response, its [statusCode].
  const GatewayException(this.message, {this.statusCode});

  /// The error message describing the Gateway failure.
  final String message;

  /// The HTTP status code of the response, if the failure came from one.
  final int? statusCode;

  /// Whether the server rejected the request itself (4xx): replaying it
  /// unchanged can never succeed.
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

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

/// Reports bytes received while downloading a bulk Gateway export.
typedef GatewayDownloadProgressCallback = void Function(int bytesReceived, int? contentLength);

/// Fetches platform passport data from, and submits passport events to, the
/// Amrit Gateway API.
class GatewayRepository {
  /// Creates a [GatewayRepository] instance.
  GatewayRepository({required AuthService authService, http.Client? client})
    : _client = client ?? http.Client(),
      _authService = authService;

  final http.Client _client;
  final AuthService _authService;

  /// Loads unclosed missions from the cached Gateway export endpoint.
  Future<GatewayPassportsResult> fetchUnclosedMissions({
    GatewayDownloadProgressCallback? onDownloadProgress,
  }) async {
    final uri = GatewayConfig.unclosedPassportsUri;
    try {
      if (kDebugMode) {
        debugPrint('Gateway GET $uri');
      }
      final request = http.Request('GET', uri);
      final streamedResponse = await _client.send(request);

      if (!_isSuccess(streamedResponse.statusCode)) {
        final errorBody = await streamedResponse.stream.bytesToString();
        throw Exception(
          'Failed to load unclosed missions '
          '(Status ${streamedResponse.statusCode}, body=${_truncate(errorBody)})',
        );
      }

      final contentLength = _responseContentLength(streamedResponse);
      if (kDebugMode) {
        debugPrint(
          'Gateway unclosed export Content-Length=$contentLength '
          '(stream=${streamedResponse.contentLength}, '
          'header=${streamedResponse.headers['content-length']})',
        );
      }
      if (contentLength != null && contentLength > 0) {
        onDownloadProgress?.call(0, contentLength);
        await yieldForDownloadProgressUi();
      }
      final bodyBytes = await _collectStreamedBody(
        streamedResponse.stream,
        contentLength: contentLength,
        onProgress: onDownloadProgress,
      );

      final jsonResponse = json.decode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
      return _passportsResultFromJson(
        jsonResponse,
        label: 'unclosed missions',
        headerTotal: _parseTotalCountHeader(streamedResponse.headers),
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Gateway fetchUnclosedMissions error: $e\n$st');
      }
      rethrow;
    }
  }

  Future<Uint8List> _collectStreamedBody(
    Stream<List<int>> stream, {
    int? contentLength,
    GatewayDownloadProgressCallback? onProgress,
  }) async {
    if (contentLength != null && contentLength > 0) {
      onProgress?.call(0, contentLength);
    }
    final builder = BytesBuilder(copy: false);
    var received = 0;
    await for (final chunk in stream) {
      builder.add(chunk);
      received += chunk.length;
      onProgress?.call(received, contentLength);
    }
    if (contentLength == null && received > 0) {
      onProgress?.call(received, received);
    }
    return builder.takeBytes();
  }

  int? _responseContentLength(http.StreamedResponse response) {
    final fromResponse = response.contentLength;
    if (fromResponse != null && fromResponse > 0) {
      return fromResponse;
    }
    return _parseContentLength(response.headers['content-length']);
  }

  int? _parseContentLength(String? headerValue) {
    if (headerValue == null || headerValue.isEmpty) {
      return null;
    }
    return int.tryParse(headerValue);
  }

  int? _parseTotalCountHeader(Map<String, String> headers) {
    final value = headers[GatewayHeaders.totalCount];
    if (value == null || value.isEmpty) {
      return null;
    }
    return int.tryParse(value);
  }

  GatewayPassportsResult _passportsResultFromJson(
    Map<String, dynamic> jsonResponse, {
    required String label,
    int? headerTotal,
  }) {
    final items = (jsonResponse['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
    final reportedTotal = jsonResponse['total'] as int? ?? headerTotal;
    final result = GatewayPassportMapper.fromEnrichedPassportItems(
      items,
      reportedTotal: reportedTotal,
    );

    if (kDebugMode) {
      debugPrint(
        'Gateway returned ${result.platforms.length} $label '
        '(${result.alerts.length} alerts)',
      );
    }
    return result;
  }

  /// Searches passports on the Gateway enriched passport search endpoint.
  ///
  /// When [searchDto] is null, delegates to [fetchUnclosedMissions] instead
  /// of issuing a search request.
  Future<GatewayPassportsResult> searchPassports(
    PassportFilterDto? searchDto, {
    GatewayDownloadProgressCallback? onDownloadProgress,
  }) async {
    if (searchDto == null) {
      return fetchUnclosedMissions(onDownloadProgress: onDownloadProgress);
    }

    try {
      final searchResponse = await _postPassportSearch(
        searchDto,
        onDownloadProgress: onDownloadProgress,
      );
      return _passportsResultFromJson(
        searchResponse.body,
        label: 'passports',
        headerTotal: searchResponse.headerTotal,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Gateway searchPassports error: $e\n$st');
      }
      rethrow;
    }
  }

  Future<({Map<String, dynamic> body, int? headerTotal})> _postPassportSearch(
    PassportFilterDto searchDto, {
    GatewayDownloadProgressCallback? onDownloadProgress,
  }) async {
    final uri = GatewayConfig.passportsSearchUri;
    final bodyBytes = utf8.encode(jsonEncode(searchDto.toJson()));
    if (kDebugMode) {
      debugPrint('Gateway POST $uri body=${utf8.decode(bodyBytes)}');
    }

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..bodyBytes = bodyBytes;

    final streamedResponse = await _client.send(request);

    if (!_isSuccess(streamedResponse.statusCode)) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw Exception(
        'Failed to search passports '
        '(Status ${streamedResponse.statusCode}, body=${_truncate(errorBody)})',
      );
    }

    final headerTotal = _parseTotalCountHeader(streamedResponse.headers);
    final contentLength = _responseContentLength(streamedResponse);
    if (contentLength != null && contentLength > 0) {
      onDownloadProgress?.call(0, contentLength);
      await yieldForDownloadProgressUi();
    }
    final responseBytes = await _collectStreamedBody(
      streamedResponse.stream,
      contentLength: contentLength,
      onProgress: onDownloadProgress,
    );

    final jsonResponse = json.decode(utf8.decode(responseBytes)) as Map<String, dynamic>;
    final rawItems = jsonResponse['items'];
    if (rawItems is! List<dynamic> || rawItems.any((item) => item is! Map<String, dynamic>)) {
      throw const FormatException('Invalid passport search response');
    }
    return (body: jsonResponse, headerTotal: headerTotal);
  }

  /// The Gateway returns `201 Created` for some POST endpoints (e.g. the
  /// passport search) rather than `200 OK`, so any 2xx status is accepted.
  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  /// Returns a valid access token, translating [AuthService.getAccessToken]
  /// failures into [GatewayException]s so callers only have one type to handle.
  Future<String> _accessToken() async {
    final String? token;
    try {
      token = await _authService.getAccessToken();
    } on RefreshException {
      // AuthService has already logged out: a fresh login is required.
      throw const GatewayAuthException('session expired. Please log in again.');
    } on AuthException {
      throw const GatewayException('Unable to refresh session');
    } on http.ClientException {
      throw const GatewayException('Network error');
    }
    if (token == null) {
      throw const GatewayAuthException('Not authenticated. Please log in again.');
    }
    return token;
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
  Future<void> submitPassportEventJson(String body) async {
    final token = await _accessToken();
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

  /// Applies [action] to the alert [alertId] via `PUT /alerta/alert/:id/action`.
  ///
  /// Throws [GatewayException] on missing auth, non-2xx response, or network error.
  Future<void> actOnAlert(String alertId, AlertAction action) {
    return _putAlert(
      GatewayConfig.alertActionUri(alertId),
      {'action': action.name, 'timeout': null},
      'apply "${action.name}" to the alert',
    );
  }

  /// Adds a note with [text] to the alert [alertId] via `PUT /alerta/alert/:id/note`.
  ///
  /// Throws [GatewayException] on missing auth, non-2xx response, or network error.
  Future<void> addAlertNote(String alertId, String text) {
    return _putAlert(GatewayConfig.alertNoteUri(alertId), {'text': text}, 'add the note');
  }

  Future<void> _putAlert(Uri uri, Map<String, dynamic> body, String description) async {
    final token = await _accessToken();
    try {
      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 401) {
        throw const GatewayAuthException('Unauthorized or session expired. Please log in again.');
      }
      if (!_isSuccess(response.statusCode)) {
        throw GatewayException(
          'Failed to $description (Status ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw GatewayException('Network error: ${e.message}');
    }
  }

  /// Replays a queued alert operation: [payloadJson] is the body stored when it
  /// was queued (`{"alertId", "action"}` or `{"alertId", "text"}`).
  Future<void> submitAlertOperationJson(PendingOperationKind kind, String payloadJson) {
    final payload = json.decode(payloadJson) as Map<String, dynamic>;
    final alertId = payload['alertId'] as String;
    if (kind == PendingOperationKind.alertNote) {
      return addAlertNote(alertId, payload['text'] as String);
    }
    final action = kind.alertAction;
    if (action == null) {
      throw ArgumentError.value(kind, 'kind', 'Not an alert operation');
    }
    return actOnAlert(alertId, action);
  }

  /// Builds the Gateway JSON body from [request] then sends it.
  Future<void> submitPassportEvent(PassportEventRequest request) {
    return submitPassportEventJson(jsonEncode(PassportEventMapper.toJson(request)));
  }

  /// Pairs a [platformId] with a [qrCode].
  ///
  /// [platformId] must be the numeric Gateway/OceanOPS `ptfId`.
  /// A successful response confirms pairing even when passport regeneration is still pending.
  ///
  /// Throws [GatewayException] on invalid input, an unsuccessful response,
  /// or a network error. Throws [GatewayAuthException] on missing or rejected auth.
  Future<void> pairPlatformToQRCode(String platformId, String qrCode) async {
    final ptfId = int.tryParse(platformId.trim(), radix: 10);
    if (ptfId == null || ptfId <= 0) {
      throw const GatewayException('Invalid platform ID. A positive numeric ptfId is required.');
    }
    if (qrCode.trim().isEmpty) {
      throw const GatewayException('QR code must not be empty.');
    }

    final token = await _authService.getAccessToken();
    if (token == null) {
      throw const GatewayAuthException('Not authenticated. Please log in again.');
    }
    try {
      final response = await _client.post(
        GatewayConfig.pairPlatformToQrCodeUri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'ptfId': ptfId, 'qrCode': qrCode}),
      );
      if (response.statusCode == 401) {
        throw const GatewayAuthException('Failed to pair platform to QR code: Unauthorized.');
      }
      if (response.statusCode == 409) {
        throw const GatewayException('QR code already paired to another platform.');
      }
      if (!_isSuccess(response.statusCode)) {
        throw GatewayException('Failed to pair platform to QR code (Status ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw GatewayException('Network error: ${e.message}');
    }
  }
}
