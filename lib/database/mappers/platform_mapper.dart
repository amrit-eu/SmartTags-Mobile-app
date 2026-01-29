import 'package:latlong2/latlong.dart' hide Path;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/platform.dart' as domain;

/// Map the platform DB object returned to the domain model
extension PlatformMapper on Platform {
  /// Map the platform DB object returned to the domain model
  domain.Platform toDomain() {
    return domain.Platform(
      id: ref,
      model: model,
      network: network,
      latestPosition: LatLng(lat, lon),
      status: domain.PlatformStatus.platformStatusFromDb(status),
      operationalStatus: domain.OperationalStatus.operationalStatusFromDb(operationalStatus),
      lastUpdated: lastUpdated,
      operationLocation: LatLng(operationLat, operationLon),
    );
  }
}
