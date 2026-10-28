/// Bundled first-install SQLite snapshot (#184).
abstract final class SeedDatabasePaths {
  /// Flutter asset path for the release seed database.
  static const assetPath = 'assets/database/seed.sqlite';

  /// Default output directory when building a seed in CI or locally.
  static const outputDirectory = 'assets/database';
}
