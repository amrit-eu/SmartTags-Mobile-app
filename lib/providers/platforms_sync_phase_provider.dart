import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/models/platforms_sync_state.dart';

/// Current Gateway sync phase and download byte progress for shared loading banners.
final platformsSyncPhaseProvider = NotifierProvider<PlatformsSyncPhaseNotifier, PlatformsSyncState>(
  PlatformsSyncPhaseNotifier.new,
);

/// Updates sync UI during initial sync and pull-to-refresh.
class PlatformsSyncPhaseNotifier extends Notifier<PlatformsSyncState> {
  DateTime? _lastProgressNotify;

  @override
  PlatformsSyncState build() => const PlatformsSyncState();

  /// Marks the Gateway download phase (resets byte counters unless already downloading).
  void setDownloading({int? contentLength}) {
    if (state.phase == PlatformsSyncPhase.downloading) {
      if (contentLength != null && contentLength > 0) {
        updateDownloadProgress(bytesReceived: state.downloadBytesReceived, contentLength: contentLength);
      }
      return;
    }
    _lastProgressNotify = null;
    state = PlatformsSyncState(
      phase: PlatformsSyncPhase.downloading,
      downloadContentLength: contentLength,
    );
  }

  /// Incremental refresh (delta search); byte progress is not shown.
  void setChecking() {
    if (state.phase == PlatformsSyncPhase.downloading) {
      return;
    }
    state = const PlatformsSyncState(phase: PlatformsSyncPhase.checking);
  }

  void updateDownloadProgress({
    required int bytesReceived,
    int? contentLength,
  }) {
    if (state.phase != PlatformsSyncPhase.downloading) {
      return;
    }
    final mergedReceived = _mergedBytesReceived(bytesReceived, state.downloadBytesReceived);
    final knownLength = _mergeContentLength(contentLength, state.downloadContentLength);
    final lengthJustKnown =
        knownLength != null && knownLength > 0 && state.downloadContentLength == null;
    final downloadComplete = knownLength != null && knownLength > 0 && mergedReceived >= knownLength;
    final now = DateTime.now();
    if (!lengthJustKnown &&
        !downloadComplete &&
        _lastProgressNotify != null &&
        now.difference(_lastProgressNotify!) < const Duration(milliseconds: 80)) {
      return;
    }
    _lastProgressNotify = now;
    state = state.copyWith(
      phase: PlatformsSyncPhase.downloading,
      downloadBytesReceived: mergedReceived,
      downloadContentLength: knownLength,
    );
  }

  static int _mergedBytesReceived(int incoming, int current) =>
      incoming > current ? incoming : current;

  /// Marks the local database write phase.
  void setSaving() {
    _lastProgressNotify = null;
    state = state.copyWith(
      phase: PlatformsSyncPhase.saving,
      downloadBytesReceived: 0,
      clearDownloadContentLength: true,
    );
  }

  /// Clears sync-phase UI.
  void setIdle() {
    _lastProgressNotify = null;
    state = const PlatformsSyncState();
  }

  int? _mergeContentLength(int? incoming, int? current) {
    if (incoming != null && incoming > 0) {
      if (current != null && current > 0) {
        return incoming > current ? incoming : current;
      }
      return incoming;
    }
    return current;
  }
}
