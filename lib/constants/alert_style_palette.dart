import 'package:flutter/material.dart';
import 'package:smart_tags/models/alert.dart';

/// Visual style for an alert status badge or indicator.
class AlertStatusStyle {
  /// Creates an [AlertStatusStyle] with the given label, priority, colors
  /// and icons.
  const AlertStatusStyle({
    required this.label,
    required this.priority,
    required this.color,
    required this.displayIcon,
    required this.actionIcon,
  });

  /// Human-readable status label.
  final String label;

  /// Priority order — lower is more urgent (open < acknowledged < closed).
  final int priority;

  /// Colour for badges and indicators.
  final Color color;

  /// Icon used to display the current status.
  final IconData displayIcon;

  /// Icon used for the state-enabled action (e.g. acknowledge/close button).
  final IconData actionIcon;
}

/// Badge and indicator colors/icons for each [AlertStatus].
abstract final class AlertStatusPalette {
  /// Open — at least one open alert.
  static const open = AlertStatusStyle(
    label: 'Open',
    priority: 1,
    color: Color(0xFFEF9823),
    displayIcon: Icons.warning,
    actionIcon: Icons.warning,
  );

  /// Acknowledged — no open alerts, at least one acknowledged.
  static const acknowledged = AlertStatusStyle(
    label: 'Acknowledged',
    priority: 2,
    color: Color(0xFF5DB3E7),
    displayIcon: Icons.check_circle_outline,
    actionIcon: Icons.check_circle_outline,
  );

  /// Closed — no open or acknowledged alerts.
  static const closed = AlertStatusStyle(
    label: 'Closed',
    priority: 3,
    color: Color(0xFF52A351),
    displayIcon: Icons.check_circle,
    actionIcon: Icons.cancel_outlined,
  );

  /// Unknown — neutral fallback for unrecognised statuses.
  static const unknown = AlertStatusStyle(
    label: 'Unknown',
    priority: 4,
    color: Color(0xFF757575),
    displayIcon: Icons.help_outline,
    actionIcon: Icons.help_outline,
  );

  /// Resolves a raw status string from the API or local database.
  static AlertStatusStyle resolve(String? rawStatus) {
    return forStatus(AlertStatus.fromDb(rawStatus));
  }

  /// Returns the palette entry for an [AlertStatus] value.
  static AlertStatusStyle forStatus(AlertStatus status) {
    return switch (status) {
      AlertStatus.open => open,
      AlertStatus.acknowledged => acknowledged,
      AlertStatus.closed => closed,
      AlertStatus.unknown => unknown,
    };
  }

  /// Derives the aggregate status style from open/acknowledged alert counts:
  /// open when there is at least one open alert, acknowledged when there are
  /// none open but at least one acknowledged, closed otherwise.
  static AlertStatusStyle forCounts({required int openCount, required int acknowledgedCount}) {
    if (openCount > 0) return open;
    if (acknowledgedCount > 0) return acknowledged;
    return closed;
  }
}

/// Visual style for an alert severity badge or chip.
class AlertSeverityStyle {
  /// Creates an [AlertSeverityStyle] with the given label and colors.
  const AlertSeverityStyle({
    required this.label,
    required this.chipColor,
    required this.textColor,
  });

  /// Human-readable severity label.
  final String label;

  /// Background colour for the severity chip.
  final Color chipColor;

  /// Text colour for the severity chip.
  final Color textColor;
}

/// Chip colors for each [AlertSeverity].
abstract final class AlertSeverityPalette {
  /// Critical
  static const critical = AlertSeverityStyle(
    label: 'Critical',
    chipColor: Color(0xFFD32F2F),
    textColor: Colors.white,
  );

  /// Major
  static const major = AlertSeverityStyle(
    label: 'Major',
    chipColor: Color(0xFFED6C02),
    textColor: Colors.white,
  );

  /// Minor
  static const minor = AlertSeverityStyle(
    label: 'Minor',
    chipColor: Color(0xFFE2E2E2),
    textColor: Color(0xFF212121),
  );

  /// Warning
  static const warning = AlertSeverityStyle(
    label: 'Warning',
    chipColor: Color(0xFF0288D1),
    textColor: Colors.white,
  );

  /// Informational
  static const informational = AlertSeverityStyle(
    label: 'Informational',
    chipColor: Color(0xFF2E7D32),
    textColor: Colors.white,
  );

  /// Debug
  static const debug = AlertSeverityStyle(
    label: 'Debug',
    chipColor: Color(0xFFBDBDBD),
    textColor: Color(0xFF212121),
  );

  /// Trace
  static const trace = AlertSeverityStyle(
    label: 'Trace',
    chipColor: Color(0xFFE2E2E2),
    textColor: Color(0xFF212121),
  );

  /// Indeterminate
  static const indeterminate = AlertSeverityStyle(
    label: 'Indeterminate',
    chipColor: Color(0xFF757575),
    textColor: Colors.white,
  );

  /// Cleared
  static const cleared = AlertSeverityStyle(
    label: 'Cleared',
    chipColor: Color(0xFF388E3C),
    textColor: Colors.white,
  );

  /// Normal
  static const normal = AlertSeverityStyle(
    label: 'Normal',
    chipColor: Color(0xFFE2E2E2),
    textColor: Color(0xFF212121),
  );

  /// Ok
  static const ok = AlertSeverityStyle(
    label: 'Ok',
    chipColor: Color(0xFF2E7D32),
    textColor: Colors.white,
  );

  /// Unknown
  static const unknown = AlertSeverityStyle(
    label: 'Unknown',
    chipColor: Color(0xFF9E9E9E),
    textColor: Colors.white,
  );

  /// Resolves a raw severity string from the API or local database.
  static AlertSeverityStyle resolve(String? rawSeverity) {
    return forSeverity(AlertSeverity.fromDb(rawSeverity));
  }

  /// Returns the palette entry for an [AlertSeverity] value.
  static AlertSeverityStyle forSeverity(AlertSeverity severity) {
    return switch (severity) {
      AlertSeverity.critical => critical,
      AlertSeverity.major => major,
      AlertSeverity.minor => minor,
      AlertSeverity.warning => warning,
      AlertSeverity.informational => informational,
      AlertSeverity.debug => debug,
      AlertSeverity.trace => trace,
      AlertSeverity.indeterminate => indeterminate,
      AlertSeverity.cleared => cleared,
      AlertSeverity.normal => normal,
      AlertSeverity.ok => ok,
      AlertSeverity.unknown => unknown,
    };
  }
}
