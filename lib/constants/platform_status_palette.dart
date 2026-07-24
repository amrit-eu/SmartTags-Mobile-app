import 'package:flutter/material.dart';
import 'package:smart_tags/models/platform.dart';

/// Visual style for a platform status badge or map marker.
class PlatformStatusStyle {
  const PlatformStatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Human-readable status label.
  final String label;

  /// Background colour for badges, chips, and map markers.
  final Color backgroundColor;

  /// Text colour for badges and chips.
  final Color textColor;
}

abstract final class PlatformStatusPalette {
  /// Registered
  static const registered = PlatformStatusStyle(
    label: 'Registered',
    backgroundColor: Color(0xFF64B5F6),
    textColor: Colors.black,
  );

  /// Probable
  static const probable = PlatformStatusStyle(
    label: 'Probable',
    backgroundColor: Color(0xFFFBC02D),
    textColor: Colors.black,
  );

  /// Confirmed
  static const confirmed = PlatformStatusStyle(
    label: 'Confirmed',
    backgroundColor: Color(0xFF1976D2),
    textColor: Colors.white,
  );

  /// Operational
  static const operational = PlatformStatusStyle(
    label: 'Operational',
    backgroundColor: Color(0xFF2E7D32),
    textColor: Colors.white,
  );

  /// Inactive
  static const inactive = PlatformStatusStyle(
    label: 'Inactive',
    backgroundColor: Color(0xFFC62828),
    textColor: Colors.white,
  );

  /// Closed — terminal state.
  static const closed = PlatformStatusStyle(
    label: 'Closed',
    backgroundColor: Color(0xFF212121),
    textColor: Colors.white,
  );

  /// Unknown — neutral fallback for unrecognised statuses.
  static const unknown = PlatformStatusStyle(
    label: 'Unknown',
    backgroundColor: Color(0xFF757575),
    textColor: Colors.white,
  );

  /// Resolves a raw status string from the API or local database.
  static PlatformStatusStyle resolve(String? rawStatus) {
    return forStatus(PlatformStatus.fromDb(rawStatus));
  }

  /// Returns the palette entry for a [PlatformStatus] value.
  static PlatformStatusStyle forStatus(PlatformStatus status) {
    return switch (status) {
      PlatformStatus.registered => registered,
      PlatformStatus.probable => probable,
      PlatformStatus.confirmed => confirmed,
      PlatformStatus.operational => operational,
      PlatformStatus.inactive => inactive,
      PlatformStatus.closed => closed,
      PlatformStatus.unknown => unknown,
    };
  }
}

abstract final class OperationalStatusPalette {
  /// Deployed
  static const deployed = PlatformStatusStyle(
    label: 'Deployed',
    backgroundColor: Color(0xFF1976D2),
    textColor: Colors.white,
  );

  /// Recovered
  static const recovered = PlatformStatusStyle(
    label: 'Recovered',
    backgroundColor: Color(0xFFEF6C00),
    textColor: Colors.white,
  );

  /// Unknown fallback
  static const unknown = PlatformStatusStyle(
    label: 'Unknown',
    backgroundColor: Color(0xFF757575),
    textColor: Colors.white,
  );

  /// Returns the palette entry for an [OperationalStatus] value.
  static PlatformStatusStyle forStatus(OperationalStatus status) {
    return switch (status) {
      OperationalStatus.deployed => deployed,
      OperationalStatus.recovered => recovered,
      OperationalStatus.unknown => unknown,
    };
  }
}
