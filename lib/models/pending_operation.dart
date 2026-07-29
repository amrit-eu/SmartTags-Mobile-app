import 'package:smart_tags/models/deploy_action.dart';

/// Whether a queued passport event is still awaiting submission, or has
/// failed and needs manual retry.
enum PendingOperationStatus {
  /// Awaiting submission (will be retried automatically on reconnect).
  pending,

  /// A submission attempt failed; stays queued for manual retry.
  failed,
}

/// A deploy/recover passport event queued locally, pending submission to the
/// Gateway (used when the device is offline or a submission attempt fails).
class PendingPassportEvent {
  /// Creates a [PendingPassportEvent].
  const PendingPassportEvent({
    required this.id,
    required this.platformRef,
    required this.action,
    required this.payloadJson,
    required this.createdAt,
    required this.status,
    required this.attempts,
    this.lastError,
  });

  /// Local queue row id (also the FIFO ordering key).
  final int id;

  /// The platform this event is for.
  final String platformRef;

  /// Whether this is a deploy or recover event.
  final DeployAction action;

  /// The exact Gateway JSON request body that will be (re-)sent.
  final String payloadJson;

  /// When this event was queued.
  final DateTime createdAt;

  /// Whether this event is still pending or has failed.
  final PendingOperationStatus status;

  /// Number of submission attempts made so far.
  final int attempts;

  /// The error message from the most recent failed attempt, if any.
  final String? lastError;
}
