import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';

/// Applies byte progress on the next event-loop turn so the UI can paint
/// between bursty chunks (common on localhost).
void schedulePlatformsDownloadProgress(
  Ref ref, {
  required int bytesReceived,
  int? contentLength,
}) {
  void apply() {
    if (!ref.mounted) {
      return;
    }
    ref.read(platformsSyncPhaseProvider.notifier).updateDownloadProgress(
      bytesReceived: bytesReceived,
      contentLength: contentLength,
    );
  }

  final downloadComplete =
      contentLength != null && contentLength > 0 && bytesReceived >= contentLength;
  // Seed 0% and final 100% synchronously so localhost single-chunk downloads still paint.
  if (downloadComplete ||
      (bytesReceived == 0 && contentLength != null && contentLength > 0)) {
    apply();
    return;
  }
  scheduleMicrotask(apply);
}

/// Ensures **Downloading… 100%** paints once before switching to [PlatformsSyncPhase.saving].
Future<void> paintFullDownloadProgressBeforeSave(Ref ref) async {
  if (!ref.mounted) {
    return;
  }
  final phase = ref.read(platformsSyncPhaseProvider);
  if (phase.phase != PlatformsSyncPhase.downloading) {
    return;
  }
  final length = phase.downloadContentLength;
  if (length == null || length <= 0) {
    return;
  }
  ref.read(platformsSyncPhaseProvider.notifier).updateDownloadProgress(
    bytesReceived: length,
    contentLength: length,
  );
  await yieldForDownloadProgressUi();
}

/// Yields so a frame can show early progress (0%) before reading the body.
Future<void> yieldForDownloadProgressUi() => Future<void>.delayed(Duration.zero);
