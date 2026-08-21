import 'package:smart_tags/models/passport_event.dart';

/// Builds the outgoing JSON body for `PUT /oceanops/data/goos-passport-events`
/// from a [PassportEventRequest]. Optional fields are omitted entirely (not
/// sent as `null`) when left blank in the form's "Other fields" section.
abstract final class PassportEventMapper {
  /// Converts [request] to the Gateway JSON request body.
  static Map<String, dynamic> toJson(PassportEventRequest request) {
    final deployment = request.deployment;
    final retrieval = request.retrieval;
    return {
      'ptfId': request.ptfId,
      if (deployment != null) 'deployment': _deploymentJson(deployment),
      if (retrieval != null) 'retrieval': _retrievalJson(retrieval),
    };
  }

  static Map<String, dynamic> _deploymentJson(DeploymentEventPayload d) => {
    'date': _formatDateTime(d.date),
    'latitude': d.latitude,
    'longitude': d.longitude,
    if (_notEmpty(d.methodCode)) 'method': {'code': d.methodCode},
    if (d.maxWaterDepth != null) 'maxWaterDepth': d.maxWaterDepth,
    if (d.elevation != null) 'elevation': d.elevation,
    if (_hasShip(d.shipImoNumber, d.shipOvhId, d.shipName)) 'ship': _shipJson(d.shipImoNumber, d.shipOvhId, d.shipName),
  };

  // endDate is deliberately never included: no such form field exists.
  static Map<String, dynamic> _retrievalJson(RetrievalEventPayload r) => {
    'startDate': _formatDateTime(r.startDate),
    'latitude': r.latitude,
    'longitude': r.longitude,
    if (_notEmpty(r.endingCauseCode)) 'endingCause': {'code': r.endingCauseCode},
    if (_hasShip(r.shipImoNumber, r.shipOvhId, r.shipName)) 'ship': _shipJson(r.shipImoNumber, r.shipOvhId, r.shipName),
  };

  static Map<String, dynamic> _shipJson(String? imo, String? ovh, String? name) => {
    if (_notEmpty(imo)) 'imoNumber': imo,
    if (_notEmpty(ovh)) 'ovhId': ovh,
    if (_notEmpty(name)) 'name': name,
  };

  static bool _hasShip(String? imo, String? ovh, String? name) => _notEmpty(imo) || _notEmpty(ovh) || _notEmpty(name);

  static bool _notEmpty(String? value) => value != null && value.trim().isNotEmpty;

  /// Formats to `"yyyy-MM-ddTHH:mm:ssZ"` — `DateTime.toIso8601String()` on a
  /// UTC time includes milliseconds, so truncate down to whole seconds.
  static String _formatDateTime(DateTime dateTime) {
    final iso = dateTime.toUtc().toIso8601String();
    return '${iso.substring(0, 19)}Z';
  }
}
