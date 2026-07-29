/// Form payload for a deployment event
/// (`PUT /oceanops/data/goos-passport-events`, `deployment` key).
class DeploymentEventPayload {
  /// Creates a [DeploymentEventPayload].
  const DeploymentEventPayload({
    required this.latitude,
    required this.longitude,
    required this.date,
    this.methodCode,
    this.maxWaterDepth,
    this.elevation,
    this.shipImoNumber,
    this.shipOvhId,
    this.shipName,
  });

  /// Deployment latitude.
  final double latitude;

  /// Deployment longitude.
  final double longitude;

  /// Deployment date/time.
  final DateTime date;

  /// Deployment method code (OceanOPS reference code, e.g. "ship").
  final String? methodCode;

  /// Maximum water depth at the deployment site, in meters.
  final double? maxWaterDepth;

  /// Elevation at the deployment site, in meters.
  final double? elevation;

  /// IMO number of the deploying ship.
  final String? shipImoNumber;

  /// OVH id of the deploying ship.
  final String? shipOvhId;

  /// Name of the deploying ship.
  final String? shipName;
}

/// Form payload for a recovery event (`retrieval` key). `endDate` is
/// intentionally not a field anywhere in the app — it must never be sent.
class RetrievalEventPayload {
  /// Creates a [RetrievalEventPayload].
  const RetrievalEventPayload({
    required this.latitude,
    required this.longitude,
    required this.startDate,
    this.endingCauseCode,
    this.shipImoNumber,
    this.shipOvhId,
    this.shipName,
  });

  /// Recovery latitude.
  final double latitude;

  /// Recovery longitude.
  final double longitude;

  /// Recovery start date/time.
  final DateTime startDate;

  /// Ending cause code (OceanOPS reference code, e.g. "recovered").
  final String? endingCauseCode;

  /// IMO number of the recovering ship.
  final String? shipImoNumber;

  /// OVH id of the recovering ship.
  final String? shipOvhId;

  /// Name of the recovering ship.
  final String? shipName;
}

/// Full request body for `PUT /api/oceanops/data/goos-passport-events`.
/// Exactly one of [deployment]/[retrieval] is non-null.
class PassportEventRequest {
  /// Creates a deployment [PassportEventRequest].
  const PassportEventRequest.deployment({required this.ptfId, required DeploymentEventPayload deployment})
    : deployment = deployment,
      retrieval = null;

  /// Creates a recovery [PassportEventRequest].
  const PassportEventRequest.retrieval({required this.ptfId, required RetrievalEventPayload retrieval})
    : retrieval = retrieval,
      deployment = null;

  /// The platform identifier (`Platform.platformRef`).
  final String ptfId;

  /// The deployment payload, when this request represents a deployment.
  final DeploymentEventPayload? deployment;

  /// The retrieval payload, when this request represents a recovery.
  final RetrievalEventPayload? retrieval;
}
