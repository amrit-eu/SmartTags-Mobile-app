import 'package:latlong2/latlong.dart';

/// CT-RST platform lifecycle status (OceanOPS code table).
enum PlatformStatus {
  /// Platform is registered but not yet confirmed.
  registered,

  /// Platform presence is probable but not confirmed.
  probable,

  /// Platform existence is confirmed.
  confirmed,

  /// Platform is actively operating.
  operational,

  /// Platform is no longer active.
  inactive,

  /// Platform record is closed.
  closed,

  /// Status is missing or not recognised.
  unknown;

  /// Parses a status string from the API or local database.
  static PlatformStatus fromDb(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'REGISTERED':
        return registered;
      case 'PROBABLE':
        return probable;
      case 'CONFIRMED':
        return confirmed;
      case 'OPERATIONAL':
      case 'ACTIVE': // legacy local data
        return operational;
      case 'INACTIVE':
        return inactive;
      case 'CLOSED':
        return closed;
      default:
        return unknown;
    }
  }

  /// Serialises the status for storage in the local database.
  static String platformStatusToDb(PlatformStatus status) => status.apiName;

  /// API / database status code.
  String get apiName => switch (this) {
    registered => 'REGISTERED',
    probable => 'PROBABLE',
    confirmed => 'CONFIRMED',
    operational => 'OPERATIONAL',
    inactive => 'INACTIVE',
    closed => 'CLOSED',
    unknown => 'UNKNOWN',
  };

  /// Human-readable label for UI display.
  String get displayLabel => switch (this) {
    registered => 'Registered',
    probable => 'Probable',
    confirmed => 'Confirmed',
    operational => 'Operational',
    inactive => 'Inactive',
    closed => 'Closed',
    unknown => 'Unknown',
  };
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
  });

  /// The unique identifier of the platform (e.g., PLT-12345).
  final String platformRef;

  /// The model name of the device.
  final String model;

  /// The network the device belongs to (e.g., Argo, DBCP).
  final String network;

  /// The latest reported position of the device.
  final LatLng latestPosition;

  /// The CT-RST lifecycle status of the device.
  final PlatformStatus status;

  /// The operational status (deployed/recovered).
  final OperationalStatus operationalStatus;

  /// The date and time of the last update/operation.
  final DateTime lastUpdated;

  /// The location of the last operation.
  final LatLng operationLocation;

  /// Additional notes about the latest operation (optional).
  final String? operationNotes;
}
