import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/helpers/latest_operation_status.dart';
import 'package:smart_tags/models/platform.dart';

Platform _platform({
  PlatformStatus status = PlatformStatus.operational,
  OperationalStatus operationalStatus = OperationalStatus.deployed,
  String? latestOperationType = 'Deployment',
  DateTime? latestOperationDate,
  int? endingCauseId,
  bool hasLatestObservation = false,
}) {
  return Platform(
    platformRef: 'REF-1',
    model: 'Model',
    network: 'Net',
    latestPosition: const LatLng(0, 0),
    status: status,
    operationalStatus: operationalStatus,
    lastUpdated: DateTime.utc(2025),
    operationLocation: const LatLng(1, 2),
    latestOperationType: latestOperationType,
    latestOperationDate: latestOperationDate,
    endingCauseId: endingCauseId,
    hasLatestObservation: hasLatestObservation,
  );
}

void main() {
  test('deployment is planned when pre-operational and no GTS observation', () {
    final status = resolveOperationCompletionStatus(
      _platform(
        status: PlatformStatus.confirmed,
      ),
    );

    expect(status, OperationCompletionStatus.planned);
  });

  test('deployment is completed when operational', () {
    final status = resolveOperationCompletionStatus(_platform());

    expect(status, OperationCompletionStatus.completed);
  });

  test('deployment is completed when latest observation exists', () {
    final status = resolveOperationCompletionStatus(
      _platform(
        status: PlatformStatus.confirmed,
        hasLatestObservation: true,
      ),
    );

    expect(status, OperationCompletionStatus.completed);
  });

  test('recovery is completed for voluntary ending cause', () {
    final status = resolveOperationCompletionStatus(
      _platform(
        latestOperationType: 'Recovery',
        operationalStatus: OperationalStatus.recovered,
        latestOperationDate: DateTime.utc(2025),
        endingCauseId: voluntaryRecoveryEndingCauseId,
      ),
    );

    expect(status, OperationCompletionStatus.completed);
  });

  test('recovery is unknown without voluntary ending cause', () {
    final status = resolveOperationCompletionStatus(
      _platform(
        latestOperationType: 'Recovery',
        operationalStatus: OperationalStatus.recovered,
        latestOperationDate: DateTime.utc(2025),
        endingCauseId: 10,
      ),
    );

    expect(status, OperationCompletionStatus.unknown);
  });
}
