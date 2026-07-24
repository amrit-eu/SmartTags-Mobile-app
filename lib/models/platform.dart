import 'package:latlong2/latlong.dart';
import 'package:smart_tags/extensions/string_extension.dart';

/// Represents the status of a platform.
enum PlatformStatus {
  /// Platform is currently transmitting data.
  active,

  /// Platform is not transmitting data.
  inactive,

  /// Invalid value
  unknown;

  /// Convert to PlatformStatus from string stored in DB
  static PlatformStatus platformStatusFromDb(String value) {
    return PlatformStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PlatformStatus.unknown,
    );
  }

  /// Convert PlatformStatus to string for storing in DB
  static String platformStatusToDb(PlatformStatus status) {
    return status.name.capitalize();
  }
}

/// Represents the operational status of a platform.
enum OperationalStatus {
  /// Platform has been deployed.
  deployed,

  /// Platform has been recovered.
  recovered,

  /// Invalid value
  unknown;

  /// Convert to OperationalStatus from string stored in DB
  static OperationalStatus operationalStatusFromDb(String value) {
    return OperationalStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => OperationalStatus.unknown,
    );
  }
}

/// A model representing an ocean platform and its metadata.
class Platform {
  /// Creates a [Platform] instance.
  const Platform({
    required this.platformRef,
    required this.model,
    required this.network,
    required this.latestPosition,
    required this.status,
    required this.operationalStatus,
    required this.lastUpdated,
    required this.operationLocation,
    this.operationNotes,
    this.platformCategory,
    this.reportingStatus,
    this.observingNetwork,
    this.latestOperationType,
    this.latestOperationDate,
    this.wigosId,
  });

  /// The unique identifier of the platform (e.g., PLT-12345).
  final String platformRef;

  /// The model name of the device.
  final String model;

  /// The network the device belongs to (e.g., Argo, DBCP).
  final String network;

  /// The latest reported position of the device.
  final LatLng latestPosition;

  /// The current status of the device (active/inactive).
  final PlatformStatus status;

  /// The operational status (deployed/recovered).
  final OperationalStatus operationalStatus;

  /// The date and time of the last update/operation.
  final DateTime lastUpdated;

  /// The location of the last operation.
  final LatLng operationLocation;

  /// Additional notes about the latest operation (optional).
  final String? operationNotes;

  /// Platform category from passport metadata (e.g. Float).
  final String? platformCategory;

  /// Passport reporting status label.
  final String? reportingStatus;

  /// Observing network names from passport affiliation.
  final String? observingNetwork;

  /// Latest operation type (Deployment/Recovery).
  final String? latestOperationType;

  /// Latest operation date from passport.
  final DateTime? latestOperationDate;

  /// WIGOS identifier when available.
  final String? wigosId;
}
