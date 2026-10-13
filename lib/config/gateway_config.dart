/// Gateway API configuration for SmartTags.
abstract final class GatewayConfig {
  /// Public Gateway base URL on Isival (Apache proxy → NestJS).
  static const String baseUrl = 'https://amrit.isival.ifremer.fr/amrit-gateway';

  /// Builds a Gateway API URI from a path relative to `/api/`.
  static Uri apiUri(String path) => Uri.parse('$baseUrl/api/$path');

  /// Enriched passport export for unclosed missions (#111).
  static Uri get unclosedPassportsUri => apiUri('oceanops/data/enriched-goos-passport-not-closed');

  /// Enriched passport export search
  static Uri get passportsSearchUri => apiUri('oceanops/data/enriched-goos-passport/search');

  /// Login endpoint for mobile authentication.
  static Uri get loginUri => apiUri('oceanops/data/auth/login');

  /// Logout endpoint for mobile authentication.
  static Uri get logoutUri => apiUri('oceanops/data/auth/logout');

  /// refresh endpoint for mobile authentication.
  static Uri get refreshUri => apiUri('oceanops/data/auth/refresh');

  /// Deploy/recover passport event submission endpoint.
  static Uri get goosPassportEventsUri => apiUri('oceanops/data/goos-passport-events');

  /// endpoint to get a specfic alert or action on it (:id/action) :
  static Uri get actOnAlertsUri => apiUri('alerta/alert');

  /// `PUT` endpoint to apply an action (ack, unack, close, open…) to alert [id].
  static Uri alertActionUri(String id) => Uri.parse('$actOnAlertsUri/${Uri.encodeComponent(id)}/action');

  /// `PUT` endpoint to add a note to alert [id].
  static Uri alertNoteUri(String id) => Uri.parse('$actOnAlertsUri/${Uri.encodeComponent(id)}/note');
}
