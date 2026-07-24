/// Gateway API configuration for SmartTags.
abstract final class GatewayConfig {
  /// Public Gateway base URL on Isival (Apache proxy → NestJS).
  static const String baseUrl = 'https://amrit.isival.ifremer.fr/amrit-gateway';

  /// Builds a Gateway API URI from a path relative to `/api/`.
  static Uri apiUri(String path) => Uri.parse('$baseUrl/api/$path');

  /// Enriched passport export for unclosed missions (#111).
  static Uri get unclosedPassportsUri =>
      apiUri('oceanops/data/enriched-goos-passport-not-closed');

  /// Login endpoint for mobile authentication.
  static Uri get loginUri => apiUri('oceanops/data/auth/login');
}
