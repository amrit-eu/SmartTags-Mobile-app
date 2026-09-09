import 'package:flutter/material.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/models/platform.dart';

/// Planned vs completed state for the latest operation row (#100).
enum OperationCompletionStatus {
  /// Deployment not yet confirmed by GTS observation.
  planned,

  /// Deployment confirmed or recovery completed per passport rules.
  completed,

  /// Recovery without voluntary ending cause, or indeterminate state.
  unknown,
}

/// Voluntary recovery of the platform (OceanOPS ending cause id).
const voluntaryRecoveryEndingCauseId = 25;

/// Resolves operation completion status for display on platform details (#100).
OperationCompletionStatus resolveOperationCompletionStatus(Platform platform) {
  final operationType = _normalizedOperationType(platform);

  if (operationType == 'recovery') {
    return _isRecoveryCompleted(platform)
        ? OperationCompletionStatus.completed
        : OperationCompletionStatus.unknown;
  }

  if (_isDeploymentCompleted(platform)) {
    return OperationCompletionStatus.completed;
  }
  if (_isDeploymentPlanned(platform)) {
    return OperationCompletionStatus.planned;
  }
  return OperationCompletionStatus.unknown;
}

/// Badge colours for planned/completed chips (#100).
PlatformStatusStyle operationCompletionStyle(OperationCompletionStatus status) {
  return switch (status) {
    OperationCompletionStatus.planned => const PlatformStatusStyle(
      label: 'Planned',
      backgroundColor: Color(0xFFC55E0A),
      textColor: Colors.white,
    ),
    OperationCompletionStatus.completed => const PlatformStatusStyle(
      label: 'Completed',
      backgroundColor: Color(0xFF2E7D32),
      textColor: Colors.white,
    ),
    OperationCompletionStatus.unknown => PlatformStatusPalette.unknown,
  };
}

String _normalizedOperationType(Platform platform) {
  final type = platform.latestOperationType?.trim().toLowerCase();
  if (type == 'deployment' || type == 'recovery') {
    return type!;
  }
  return platform.operationalStatus == OperationalStatus.recovered
      ? 'recovery'
      : 'deployment';
}

bool _isDeploymentPlanned(Platform platform) {
  return _isPreOperational(platform.status) || !platform.hasLatestObservation;
}

bool _isDeploymentCompleted(Platform platform) {
  return _isPostOperational(platform.status) || platform.hasLatestObservation;
}

bool _isRecoveryCompleted(Platform platform) {
  return platform.latestOperationDate != null &&
      platform.endingCauseId == voluntaryRecoveryEndingCauseId;
}

bool _isPreOperational(PlatformStatus status) {
  return switch (status) {
    PlatformStatus.registered ||
    PlatformStatus.probable ||
    PlatformStatus.confirmed =>
      true,
    _ => false,
  };
}

bool _isPostOperational(PlatformStatus status) {
  return switch (status) {
    PlatformStatus.operational || PlatformStatus.inactive => true,
    _ => false,
  };
}
