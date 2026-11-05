# Android releases

Distribution outside Google Play uses a **signed APK** published as a **GitHub Release** asset. For shared versioning, tags, and the bundled seed database, see [Release overview](release_overview.md) and [Release seed database](release_seed_database.md).

Workflow: **[Release Android APK](../.github/workflows/release-android.yml)** (runs on tags such as `v1.0.0`).

## One-time signing setup

_GitHub Actions signing secrets are already configured. Normal releases can skip this section. Reuse the existing signing keystore for future releases._

Use the same private signing key for every release so Android can install subsequent releases as updates. Back up the keystore and passwords securely. If a release key already exists, reuse it.

To create a key, use Android Studio's keystore wizard or run this command with a JDK's `keytool` (one line works in PowerShell, Bash, or cmd):

```text
keytool -genkeypair -v -keystore android/smart-tags-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias smart-tags
```

Keep the keystore outside source control. `android/key.properties`, `android/**/*.jks`, and `android/**/*.keystore` are already gitignored. When creating the key in the repository, create it under `android/`.

Add these **repository Actions secrets** under **Settings > Secrets and variables > Actions**:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded contents of the release keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias, e.g. `smart-tags` |
| `ANDROID_KEY_PASSWORD` | Password for that key |

Copy the Base64 value to your clipboard in PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\path\to\smart-tags-release.jks')) | Set-Clipboard
```

On Linux, use `base64 -w 0 /path/to/smart-tags-release.jks`; on macOS, use `base64 -i /path/to/smart-tags-release.jks | tr -d '\n'`.

The workflow uses the automatic `GITHUB_TOKEN` to create releases; a personal access token is unnecessary. Only the publish job has `contents: write`. The build job has read access. Signing credentials are exposed only to the keystore restoration and APK build steps, and the temporary keystore is removed after the build.

## Create a release

1. Set the agreed application version in `pubspec.yaml`, for example `version: 1.0.0+1`. `1.0.0` becomes Android `versionName`; `1` becomes `versionCode`. Use a positive integer build number and increase it for each new release, even when the version changes.
2. Merge the version change into `main`, and let CI pass.
3. Tag that commit and push the tag (see [Release overview](release_overview.md)).
4. Open **Actions → Release Android APK**. When jobs finish, the workflow creates the GitHub Release with `smart-tags.apk` and `smart-tags.apk.sha256`.

Do not create a GitHub Release in advance: the workflow creates it after verification.

The release title and notes identify the application version, build number, source commit, minimum Android API level, included architectures, and seed database stats. The version and build number are also embedded in the APK.

## Test a feature branch with a prerelease

A tag can point to a feature-branch commit; merging into `main` is not required. The tagged commit must contain the workflow, signing configuration, and the matching application version. Uncommitted changes are not included in a tag.

1. Configure the same four repository signing secrets described above.
2. On the feature branch, set `pubspec.yaml` to `version: 0.0.1-alpha.1+1` and commit. Use an increasing build number if test devices already have an APK signed with the same key.
3. Push the branch and tag that commit (see [Release overview](release_overview.md) for tag rules).
4. Follow **Actions → Release Android APK**. The APK passes the same build, test, and signature checks as a stable release.

Prerelease tags use SemVer suffixes such as `-alpha.1`, `-rc.1`. The workflow publishes with `--prerelease --latest=false`. Download an alpha APK by tag:

```text
https://github.com/amrit-eu/SmartTags-Mobile-app/releases/download/v0.0.1-alpha.1/smart-tags.apk
```

## Build verification and manual device checks

The workflow pins Flutter **3.47.0** and Java **17**, installs the committed dependency lockfile, runs `flutter analyze` and `flutter test`, and builds one release APK containing `armeabi-v7a`, `arm64-v8a`, and `x86_64`.

Before publication it verifies the APK signature, embedded version/build number, Internet permission, included architectures, and that debugging is disabled. The publish job verifies the download checksum again.

Installation and runtime behavior are checked manually on supported Android devices (Android 7.0 / API 24 or newer). The app's external data endpoint currently requires VPN access, so test data downloads on a device connected to that VPN. For the first release and significant Android/plugin changes, check the downloaded APK on a supported physical device:

1. Download `smart-tags.apk` from the GitHub Release. Verify its checksum against `smart-tags.apk.sha256` (`Get-FileHash .\smart-tags.apk -Algorithm SHA256` on PowerShell, or `sha256sum --check smart-tags.apk.sha256` on Linux).
2. Open the APK and allow the browser/file manager to **install unknown apps**, or install with `adb install -r smart-tags.apk`.
3. Connect the VPN on the Android device and confirm it can reach the data endpoint.
4. Launch SmartTags and check the key functionality.
5. For a subsequent release, install over the previous release and verify local data is retained. Android requires the same application ID and signing key, and an increasing build number.

A previously installed debug-signed development build cannot be upgraded to this release key. Uninstall that development build before installing the first release; uninstalling removes its local app data.

## Release links

Latest release APK:

```text
https://github.com/amrit-eu/SmartTags-Mobile-app/releases/latest/download/smart-tags.apk
```

Release notes and assets:

```text
https://github.com/amrit-eu/SmartTags-Mobile-app/releases/latest
```

## Failed runs and retries

A failed build, test, or APK verification step does not publish a release. Correct missing secrets and rerun the failed jobs for the same tag. If source changes are needed, make a new version/build and tag that corrected commit; do not move a released tag or replace a published APK.

If an interrupted upload leaves a draft GitHub Release, remove that incomplete draft before rerunning the publish job. A rerun fails when a release with the same tag already exists, preserving previously published assets. Build artifacts remain available on the workflow run for 14 days; published release assets remain available through the release.

## Local signed release

Create the gitignored file `android/key.properties`:

```properties
storeFile=C:/path/to/smart-tags-release.jks
storePassword=your-keystore-password
keyAlias=smart-tags
keyPassword=your-key-password
```

Use forward slashes for Windows paths. Relative keystore paths are resolved from `android/`. Build with the pinned Flutter version:

```bash
flutter pub get --enforce-lockfile
flutter build apk --release
```

The result is `build/app/outputs/flutter-apk/app-release.apk`. CI supplies `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD` through environment variables instead of writing a password properties file. These environment variables take precedence over `key.properties`.

Debug builds still use Android's normal development key. Release builds require the configured release key and never fall back to debug signing. See [Flutter's Android release documentation](https://docs.flutter.dev/deployment/android) for details on signing and versioning.
