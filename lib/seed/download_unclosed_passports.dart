import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:smart_tags/config/gateway_config.dart';
import 'package:smart_tags/config/gateway_headers.dart';
import 'package:smart_tags/services/gateway_passport_mapper.dart';

/// Downloads and parses the Gateway unclosed-missions export for seed builds.
Future<GatewayPassportsResult> downloadUnclosedPassports({
  http.Client? client,
  Uri? uri,
}) async {
  final effectiveUri = uri ?? _unclosedPassportsUri();
  final httpClient = client ?? http.Client();
  final ownsClient = client == null;

  try {
    final response = await httpClient.get(effectiveUri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Gateway unclosed export failed (${response.statusCode}): '
        '${response.body.substring(0, response.body.length.clamp(0, 200))}',
        uri: effectiveUri,
      );
    }

    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final items = (jsonResponse['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final headerTotal = int.tryParse(response.headers[GatewayHeaders.totalCount] ?? '');
    final reportedTotal = jsonResponse['total'] as int? ?? headerTotal;

    return GatewayPassportMapper.fromEnrichedPassportItems(
      items,
      reportedTotal: reportedTotal,
    );
  } finally {
    if (ownsClient) {
      httpClient.close();
    }
  }
}

Uri _unclosedPassportsUri() {
  final override = Platform.environment['SMART_TAGS_GATEWAY_BASE_URL'];
  if (override != null && override.isNotEmpty) {
    final normalized = override.endsWith('/') ? override.substring(0, override.length - 1) : override;
    return Uri.parse('$normalized/api/oceanops/data/enriched-goos-passport-not-closed');
  }
  return GatewayConfig.unclosedPassportsUri;
}
