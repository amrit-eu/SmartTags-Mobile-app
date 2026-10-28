# Release overview

SmartTags ships on **Android** and **iOS** from the same Flutter codebase. Versioning and the bundled [seed database](release_seed_database.md) are shared; signing, distribution, and CI workflows are **platform-specific**.

## Version and tags

1. Set `version` in `pubspec.yaml`, for example `1.0.0+1`.
   - Before `+`: marketing version (`1.0.0`) — used for the Git tag and display name.
   - After `+`: build number (`1`) — must increase every store/release build (Android `versionCode`, iOS `CFBundleVersion`).
2. Merge to `main` (or tag a feature-branch commit for a prerelease) with CI green.
3. Create and push an annotated tag **without** the build suffix:

   ```bash
   git tag -a v1.0.0 -m "SmartTags 1.0.0 (build 1)"
   git push origin v1.0.0
   ```

Examples: `version: 1.2.0+7` → tag `v1.2.0`; `version: 1.2.0-rc.1+7` → tag `v1.2.0-rc.1`.

Pushing a tag starts the platform release workflows (below). Do not create a GitHub Release manually; the Android workflow creates it after verification.

## Workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| [Release Android APK](../.github/workflows/release-android.yml) | Tag `v*.*.*` | Seed DB → signed APK → GitHub Release |
| [Release iOS app](../.github/workflows/release-ios.yml) | Tag `v*.*.*` | Seed DB → unsigned iOS build → Actions artifact |
| [Generate release seed database](../.github/workflows/release-seed-database.yml) | Called by the workflows above | Gateway export → `seed.sqlite` |

Both platform workflows call the same reusable seed job so each release build embeds a fresh snapshot. See [Release seed database](release_seed_database.md) for details.

## Platform documentation

- [Android releases](android_releases.md) — keystore secrets, APK install, GitHub download links, device checks.
- [iOS releases](ios_releases.md) — Apple Developer Program, codesigning, TestFlight, CI limits, Mac/Xcode builds.

## Prereleases

Use SemVer prerelease suffixes in `pubspec.yaml` and the tag (`-alpha.1`, `-beta.1`, `-rc.1`). The Android workflow marks GitHub Releases as prerelease (`--latest=false`) so they do not replace the stable “latest” APK link.
