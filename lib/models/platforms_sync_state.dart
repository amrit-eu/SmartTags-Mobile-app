import 'package:smart_tags/models/platforms_sync_phase.dart';

/// Gateway sync phase plus optional byte progress for the download step.
class PlatformsSyncState {
  const PlatformsSyncState({
    this.phase = PlatformsSyncPhase.idle,
    this.downloadBytesReceived = 0,
    this.downloadContentLength,
  });

  final PlatformsSyncPhase phase;
  final int downloadBytesReceived;
  final int? downloadContentLength;

  /// Determinate download progress in `0..1`, when [downloadContentLength] is known.
  double? get downloadProgress {
    final length = downloadContentLength;
    if (length == null || length <= 0) {
      return null;
    }
    return (downloadBytesReceived / length).clamp(0.0, 1.0);
  }

  /// User-facing banner copy, or null when idle.
  String? get bannerMessage {
    return switch (phase) {
      PlatformsSyncPhase.idle => null,
      PlatformsSyncPhase.checking => PlatformsSyncPhase.checking.bannerMessage,
      PlatformsSyncPhase.downloading => () {
        final progress = downloadProgress;
        if (progress != null) {
          return 'Downloading platforms… ${(progress * 100).round()}%';
        }
        if (downloadBytesReceived > 0) {
          return 'Downloading platforms… ${_formatReceivedBytes(downloadBytesReceived)}';
        }
        return 'Downloading platforms…';
      }(),
      PlatformsSyncPhase.saving => 'Saving platforms…',
    };
  }

  static String _formatReceivedBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(mb >= 10 ? 0 : 1)} MB';
    }
    if (bytes >= 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
    }
    return '$bytes B';
  }

  PlatformsSyncState copyWith({
    PlatformsSyncPhase? phase,
    int? downloadBytesReceived,
    int? downloadContentLength,
    bool clearDownloadContentLength = false,
  }) {
    return PlatformsSyncState(
      phase: phase ?? this.phase,
      downloadBytesReceived: downloadBytesReceived ?? this.downloadBytesReceived,
      downloadContentLength: clearDownloadContentLength
          ? null
          : (downloadContentLength ?? this.downloadContentLength),
    );
  }
}
