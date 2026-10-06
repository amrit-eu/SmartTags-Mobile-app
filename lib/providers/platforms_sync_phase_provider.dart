import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/models/platforms_sync_progress.dart';

/// Current Gateway sync phase for shared loading banners.
final platformsSyncPhaseProvider = NotifierProvider<PlatformsSyncPhaseNotifier, PlatformsSyncPhase>(
  PlatformsSyncPhaseNotifier.new,
);

/// Platform counts shown in sync banners (`N/M`).
final platformsSyncProgressProvider =
    NotifierProvider<PlatformsSyncProgressNotifier, PlatformsSyncProgress>(
  PlatformsSyncProgressNotifier.new,
);

/// Updates [PlatformsSyncPhase] during initial sync and pull-to-refresh.
class PlatformsSyncPhaseNotifier extends Notifier<PlatformsSyncPhase> {
  @override
  PlatformsSyncPhase build() => PlatformsSyncPhase.idle;

  /// Marks the Gateway download phase.
  void setDownloading() {
    ref.read(platformsSyncProgressProvider.notifier).reset();
    state = PlatformsSyncPhase.downloading;
  }

  /// Marks the local database write phase (clears download counts from the banner).
  void setSaving() {
    ref.read(platformsSyncProgressProvider.notifier).reset();
    state = PlatformsSyncPhase.saving;
  }

  /// Clears sync-phase UI.
  void setIdle() {
    state = PlatformsSyncPhase.idle;
    ref.read(platformsSyncProgressProvider.notifier).reset();
  }
}

/// Updates `N/M` progress during platform sync.
class PlatformsSyncProgressNotifier extends Notifier<PlatformsSyncProgress> {
  @override
  PlatformsSyncProgress build() => const PlatformsSyncProgress.empty();

  /// Clears counts.
  void reset() => state = const PlatformsSyncProgress.empty();

  /// Sets absolute progress.
  void setProgress({required int completed, required int total}) {
    state = PlatformsSyncProgress(completed: completed, total: total);
  }
}
