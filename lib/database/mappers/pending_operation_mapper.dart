import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/pending_operation.dart' as domain;

/// Map the pending-operation DB row to the domain model.
extension PendingOperationMapper on PendingOperation {
  /// Map the pending-operation DB row to the domain model.
  domain.PendingPassportEvent toDomain() {
    return domain.PendingPassportEvent(
      id: id,
      platformRef: platformRef,
      action: action == 'deploy' ? DeployAction.deploy : DeployAction.recover,
      payloadJson: payloadJson,
      createdAt: createdAt,
      status: status == 'failed' ? domain.PendingOperationStatus.failed : domain.PendingOperationStatus.pending,
      attempts: attempts,
      lastError: lastError,
    );
  }
}
