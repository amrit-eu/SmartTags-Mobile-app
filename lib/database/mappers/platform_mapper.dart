import 'package:latlong2/latlong.dart' hide Path;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/platform.dart' as domain;
import 'package:smart_tags/models/program.dart';

/// Map the platform DB object returned to the domain model
extension PlatformMapper on Platform {
  /// Map the platform DB object returned to the domain model
  domain.Platform toDomain() {
    final programIdValue = programId;
    final programNameValue = programName;
    final programCodeValue = programCode;
    return domain.Platform(
      platformRef: ref,
      model: model,
      network: network,
      latestPosition: LatLng(lat, lon),
      status: domain.PlatformStatus.fromDb(status),
      operationalStatus: domain.OperationalStatus.operationalStatusFromDb(operationalStatus),
      lastUpdated: lastUpdated,
      operationLocation: LatLng(operationLat, operationLon),
      operationNotes: operationNotes,
      platformCategory: platformCategory,
      reportingStatus: reportingStatus,
      observingNetwork: observingNetwork,
      latestOperationType: latestOperationType,
      latestOperationDate: latestOperationDate,
      wigosId: wigosId,
      ptfId: ptfId,
      program: programIdValue != null && programNameValue != null && programCodeValue != null
          ? Program(id: programIdValue, name: programNameValue, code: programCodeValue)
          : null,
    );
  }
}
