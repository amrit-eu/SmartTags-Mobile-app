import 'package:smart_tags/models/platforms_sync_phase.dart';

/// Counts for platform sync banners (`12/120`).
class PlatformsSyncProgress {
  /// Creates progress with optional [completed] and [total].
  const PlatformsSyncProgress({this.completed, this.total});

  /// No counts (indeterminate banner).
  const PlatformsSyncProgress.empty() : completed = null, total = null;

  /// Platforms processed so far.
  final int? completed;

  /// Total platforms in this sync pass.
  final int? total;

  /// Determinate progress `0..1`, or null when unknown.
  double? get fraction {
    final done = completed;
    final max = total;
    if (done == null || max == null || max <= 0) {
      return null;
    }
    return (done / max).clamp(0.0, 1.0);
  }

  /// Banner label for the current [phase].
  String bannerMessage(PlatformsSyncPhase phase) {
    final done = completed;
    final max = total;
    if (phase == PlatformsSyncPhase.downloading &&
        done != null &&
        max != null &&
        max > 0) {
      return 'Downloading platforms $done/$max';
    }
    return phase.bannerMessage ?? 'Downloading platforms…';
  }
}
