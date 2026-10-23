/// Coarse progress for Gateway → local platform sync.
enum PlatformsSyncPhase {
  /// No download/save in progress.
  idle,

  /// Incremental refresh (small delta POST); no byte progress expected.
  checking,

  /// Fetching passport data from the Gateway.
  downloading,

  /// Writing fetched platforms into the local database.
  saving;

  /// User-facing banner copy, or null when idle.
  String? get bannerMessage => switch (this) {
    PlatformsSyncPhase.idle => null,
    PlatformsSyncPhase.checking => 'Checking for updates…',
    PlatformsSyncPhase.downloading => 'Downloading platforms…',
    PlatformsSyncPhase.saving => 'Saving platforms…',
  };
}
