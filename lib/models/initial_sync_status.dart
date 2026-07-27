/// Outcome of the one-time initial Gateway sync on app startup.
enum InitialSyncStatus {
  /// Local database already contains platform rows.
  notNeeded,

  /// Database is empty and the device is offline — sync was not attempted.
  skippedOffline,

  /// Passport data was fetched and stored locally.
  completed,
}
