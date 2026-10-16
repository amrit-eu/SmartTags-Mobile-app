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

/// Actions that can be applied to an alert through the Gateway.
enum AlertAction {
  /// Re-open the alert.
  open,

  /// Acknowledge the alert.
  ack,

  /// Remove the acknowledgement from the alert.
  unack,

  /// Close the alert.
  close;

  /// The status stored locally for an alert once this action has been applied
  /// (read back by [AlertStatus.fromDb]). Alerta returns an unacknowledged
  /// alert to `open`.
  String get resultingStatus => switch (this) {
    open => 'open',
    ack => 'ack',
    unack => 'open',
    close => 'closed',
  };
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
    required this.description,
    required this.service,
    required this.previousSeverity,
    required this.duplicateCount,
    required this.alertCategory,
    required this.country,
    this.value,
    this.createTime,
    this.lastReceiveTime,
    this.url,
    this.origin,
    this.attributes,
    this.lastNote,
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

  /// The alert's event description.
  final String description;

  /// The alert's "more info" url, if any.
  final String? url;

  /// The alert's service origin.
  final String service;

  /// The alert's origin, if any.
  final String? origin;

  /// The alert's previous severity.
  final AlertSeverity previousSeverity;

  /// The alert's duplicate count.
  final int duplicateCount;

  /// The alert's category.
  final String alertCategory;

  /// The alert's country.
  final String country;

  /// The alert's last note, if any.
  final String? lastNote;

  /// The alert's free-form attributes, whose keys vary per alert source.
  final Map<String, dynamic>? attributes;
}
