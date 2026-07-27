import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/initial_sync_status.dart';
import 'package:smart_tags/providers/db_providers.dart';

/// Test [InitialSyncNotifier] that returns a fixed status from [build].
class StaticInitialSyncNotifier extends InitialSyncNotifier {
  /// Creates a notifier that resolves [build] to [status].
  StaticInitialSyncNotifier(this.status) : error = null;

  /// Creates a notifier whose [build] never completes.
  StaticInitialSyncNotifier.loading() : status = null, error = null;

  /// Creates a notifier whose [build] throws [error].
  StaticInitialSyncNotifier.error(this.error) : status = null;

  final InitialSyncStatus? status;
  final Object? error;

  @override
  Future<InitialSyncStatus> build() async {
    if (error != null) {
      throw error!;
    }
    if (status == null) {
      await Completer<void>().future;
    }
    return status!;
  }
}

/// Notifier used to verify the Retry button invokes [retry].
class RetryTrackingNotifier extends InitialSyncNotifier {
  var retryCount = 0;

  @override
  Future<InitialSyncStatus> build() async {
    throw Exception('failed');
  }

  @override
  Future<void> retry() async {
    retryCount++;
    state = const AsyncValue.data(InitialSyncStatus.completed);
  }
}
