/// Coarse progress for Gateway → local platform sync.
enum PlatformsSyncPhase {
  /// No download/save in progress.
  idle,

  /// Fetching passport data from the Gateway.
  downloading,

  /// Writing fetched platforms into the local database.
  saving;

  /// User-facing banner copy, or null when idle.
  String? get bannerMessage => switch (this) {
        PlatformsSyncPhase.idle => null,
        PlatformsSyncPhase.downloading => 'Downloading platforms…',
        PlatformsSyncPhase.saving => 'Saving platforms…',
      };
}
