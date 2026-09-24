/// Lifecycle status of an alert (Notification Center / Alerta).
enum AlertStatus {
  /// Alert is open and requires attention.
  open,

  /// Alert has been acknowledged.
  acknowledged,

  /// Alert has been closed.
  closed,

  /// Status is missing or not recognised.
  unknown;

  /// Parses a status string from the API or local database.
  static AlertStatus fromDb(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'OPEN':
        return open;
      case 'ACK':
      case 'ACKNOWLEDGED':
        return acknowledged;
      case 'CLOSED':
        return closed;
      default:
        return unknown;
    }
  }
}

/// Severity of an alert (Notification Center / Alerta).
enum AlertSeverity {
  /// Critical severity.
  critical,

  /// Major severity.
  major,

  /// Minor severity.
  minor,

  /// Warning severity.
  warning,

  /// Informational severity.
  informational,

  /// Debug severity.
  debug,

  /// Trace severity.
  trace,

  /// Indeterminate severity.
  indeterminate,

  /// Cleared severity.
  cleared,

  /// Normal severity.
  normal,

  /// Ok severity.
  ok,

  /// Severity is missing or not recognised.
  unknown;

  /// Parses a severity string from the API or local database.
  static AlertSeverity fromDb(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'CRITICAL':
        return critical;
      case 'MAJOR':
        return major;
      case 'MINOR':
        return minor;
      case 'WARNING':
        return warning;
      case 'INFORMATIONAL':
        return informational;
      case 'DEBUG':
        return debug;
      case 'TRACE':
        return trace;
      case 'INDETERMINATE':
        return indeterminate;
      case 'CLEARED':
        return cleared;
      case 'NORMAL':
        return normal;
      case 'OK':
        return ok;
      default:
        return unknown;
    }
  }
}

/// A model representing an alert raised against a platform resource.
class Alert {
  /// Creates an [Alert] instance.
  const Alert({
    required this.id,
    required this.resource,
    required this.event,
    required this.severity,
    required this.status,
    this.value,
    this.createTime,
    this.lastReceiveTime,
  });

  /// The unique identifier of the alert (Notification Center / Alerta side).
  final String id;

  /// The alert resource identifier (= platform ref attribute).
  final String resource;

  /// The alert's event name.
  final String event;

  /// The alert's severity.
  final AlertSeverity severity;

  /// The alert's status.
  final AlertStatus status;

  /// The alert's value (e.g. "12%"), if any.
  final String? value;

  /// When the alert was first created, if known.
  final DateTime? createTime;

  /// When the alert was last received, if known.
  final DateTime? lastReceiveTime;
}
