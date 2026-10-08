import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/models/deploy_action.dart';

/// Whether a queued operation is still awaiting submission, or has failed and
/// needs manual retry.
enum PendingOperationStatus {
  /// Awaiting submission (will be retried automatically on reconnect).
  pending,

  /// A submission attempt failed; stays queued for manual retry.
  failed,
}

/// The kind of operation held in the offline queue. [dbValue] is what is
/// stored in the `action` column of the `PendingOperations` table.
enum PendingOperationKind {
  /// Deploy passport event.
  deploy('deploy'),

  /// Recover passport event.
  recover('recover'),

  /// Re-open an alert.
  alertOpen('alert_open'),

  /// Acknowledge an alert.
  alertAck('alert_ack'),

  /// Unacknowledge an alert.
  alertUnack('alert_unack'),

  /// Close an alert.
  alertClose('alert_close'),

  /// Add a note to an alert.
  alertNote('alert_note');

  const PendingOperationKind(this.dbValue);

  /// Value stored in the `action` column.
  final String dbValue;

  /// Parses the `action` column value, or returns `null` if it is unknown
  /// (e.g. a row written by a different app version).
  static PendingOperationKind? tryParse(String value) {
    for (final kind in values) {
      if (kind.dbValue == value) {
        return kind;
      }
    }
    return null;
  }

  /// Parses the `action` column value.
  ///
  /// Throws a [FormatException] if it is unknown: guessing a kind could replay
  /// the wrong request against the Gateway.
  static PendingOperationKind fromDb(String value) {
    return tryParse(value) ?? (throw FormatException('Unknown queued operation type "$value"'));
  }

  /// The kind matching a deploy/recover [action].
  static PendingOperationKind fromDeployAction(DeployAction action) {
    return action == DeployAction.deploy ? deploy : recover;
  }

  /// The kind matching an alert [action].
  static PendingOperationKind fromAlertAction(AlertAction action) {
    return switch (action) {
      AlertAction.open => alertOpen,
      AlertAction.ack => alertAck,
      AlertAction.unack => alertUnack,
      AlertAction.close => alertClose,
    };
  }

  /// Whether this operation targets an alert rather than a platform passport.
  bool get isAlert => this != deploy && this != recover;

  /// The [AlertAction] to apply for alert-action kinds, `null` otherwise
  /// (including [alertNote]).
  AlertAction? get alertAction => switch (this) {
    alertOpen => AlertAction.open,
    alertAck => AlertAction.ack,
    alertUnack => AlertAction.unack,
    alertClose => AlertAction.close,
    _ => null,
  };
}

/// An operation queued locally, pending submission to the Gateway (used when
/// the device is offline or a submission attempt fails): a deploy/recover
/// passport event, or an action/note on an alert.
class PendingPassportEvent {
  /// Creates a [PendingPassportEvent].
  const PendingPassportEvent({
    required this.id,
    required this.platformRef,
    required this.kind,
    required this.payloadJson,
    required this.createdAt,
    required this.status,
    required this.attempts,
    this.lastError,
  });

  /// Local queue row id (also the FIFO ordering key).
  final int id;

  /// The platform this operation is for (for alerts: the alert's resource).
  final String platformRef;

  /// What kind of operation this is.
  final PendingOperationKind kind;

  /// The exact Gateway JSON request body that will be (re-)sent.
  final String payloadJson;

  /// When this operation was queued.
  final DateTime createdAt;

  /// Whether this operation is still pending or has failed.
  final PendingOperationStatus status;

  /// Number of submission attempts made so far.
  final int attempts;

  /// The error message from the most recent failed attempt, if any.
  final String? lastError;
}
