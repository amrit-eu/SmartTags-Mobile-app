import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';

/// Current Gateway sync phase for shared loading banners.
final platformsSyncPhaseProvider =
    NotifierProvider<PlatformsSyncPhaseNotifier, PlatformsSyncPhase>(
  PlatformsSyncPhaseNotifier.new,
);

/// Updates [PlatformsSyncPhase] during initial sync and pull-to-refresh.
class PlatformsSyncPhaseNotifier extends Notifier<PlatformsSyncPhase> {
  @override
  PlatformsSyncPhase build() => PlatformsSyncPhase.idle;

  /// Marks the Gateway download phase.
  void setDownloading() => state = PlatformsSyncPhase.downloading;

  /// Marks the local database write phase.
  void setSaving() => state = PlatformsSyncPhase.saving;

  /// Clears sync-phase UI.
  void setIdle() => state = PlatformsSyncPhase.idle;
}
