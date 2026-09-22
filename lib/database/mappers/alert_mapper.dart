import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/alert.dart' as domain;

/// Map the alert DB object returned to the domain model
extension AlertMapper on AlertEntity {
  /// Map the alert DB object returned to the domain model
  domain.Alert toDomain() {
    return domain.Alert(
      id: id,
      resource: resource,
      event: event,
      severity: domain.AlertSeverity.fromDb(severity),
      status: domain.AlertStatus.fromDb(status),
    );
  }
}
