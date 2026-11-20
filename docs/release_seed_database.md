# Release seed database (#184)

Release builds bundle a pre-built SQLite snapshot of unclosed missions so first install avoids downloading the large Gateway JSON export on device. The mechanism is **the same on Android and iOS**; only the surrounding release pipelines differ ([Android](android_releases.md), [iOS](ios_releases.md)).

## How it works

1. **Seed job** ([`release-seed-database.yml`](../.github/workflows/release-seed-database.yml)), invoked by each platform release workflow:
   - Runs `dart run tool/build_seed_database.dart`
   - Downloads `enriched-goos-passport-not-closed` from the Gateway
   - Writes `assets/database/seed.sqlite` and `assets/database/seed.manifest.json`
   - Uploads them as a workflow artifact
2. **Platform build jobs** download that artifact and compile it into the app bundle (APK / iOS app).
3. **First launch** copies the bundled file to `db.sqlite` in app documents when no local database file exists yet (`installBundledSeedDatabaseIfNeeded` in `main.dart`).
4. **Initial sync** skips the bulk download when platform rows already exist; delta refresh catches changes since the seed was generated.

## Local development

PR CI and local debug builds use a **schema-only** placeholder seed (no platforms):

```bash
dart run tool/build_seed_database.dart --schema-only
```

To reproduce a full release seed locally (requires network access to the Gateway):

```bash
dart run tool/build_seed_database.dart
# optional: SMART_TAGS_GATEWAY_BASE_URL=https://… dart run tool/build_seed_database.dart
```

Optional repository variable: **`SMART_TAGS_GATEWAY_BASE_URL`** (defaults to production Isival Gateway).

## Tagging

Push a version tag as described in [Release overview](release_overview.md). That triggers **Release Android APK** and **Release iOS app**; each run generates its own seed artifact for that tag.
