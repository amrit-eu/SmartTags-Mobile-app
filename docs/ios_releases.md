# iOS releases

iOS distribution requires a **paid [Apple Developer Program](https://developer.apple.com/programs/)** membership, codesigning, and **App Store Connect** for TestFlight or the App Store. Shared tagging and the [seed database](release_seed_database.md) are described in [Release overview](release_overview.md).

Workflow: **[Release iOS app](../.github/workflows/release-ios.yml)** (same version tags as Android).

## Two CI modes

Controlled by repository variable **`IOS_ENABLE_TESTFLIGHT`** (Settings → Secrets and variables → Actions → **Variables**):

| `IOS_ENABLE_TESTFLIGHT` | Behaviour |
| --- | --- |
| unset or `false` | `flutter build ios --no-codesign` → artifact `smart-tags-ios-app.tar.gz` (unsigned; local/Xcode use only). |
| `true` | Import signing assets → `flutter build ipa` → artifact `smart-tags.ipa` → **upload to TestFlight** via App Store Connect API. |

Until Apple credentials are configured, leave the variable **unset** (or `false`). The workflow keeps working as an unsigned build.

## One-time Apple setup (org admin)

Do this once per Apple Developer team before turning TestFlight CI on:

1. **Enroll** in the [Apple Developer Program](https://developer.apple.com/programs/) (paid, annual).
2. **Register a Bundle ID** in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) matching the app (update Xcode `PRODUCT_BUNDLE_IDENTIFIER` — today the repo may still show a placeholder such as `com.example.flutterAmrit`; use your real AMRIT identifier before store upload).
3. **Create an App Store Connect app** linked to that Bundle ID ([App Store Connect](https://appstoreconnect.apple.com/) → Apps).
4. **Apple Distribution certificate** (.p12): create in the Apple portal, export from Keychain Access on a Mac, keep password safe.
5. **App Store provisioning profile** for that Bundle ID: type **App Store**, download `.mobileprovision`.
6. **App Store Connect API key** (for CI upload, no Apple ID password in GitHub):
   - App Store Connect → Users and Access → **Integrations** → **App Store Connect API** → generate key with role **App Manager** or **Developer** (must upload builds).
   - Download the `.p8` file once (only shown once).
   - Note **Issuer ID** (team UUID at top of Keys page) and **Key ID**.

TestFlight **internal** testers: add people under Users and Access (same org). **External** testers: create a group in TestFlight; first build often needs **Beta App Review** (usually 24–48 h).

## GitHub Actions configuration

### Repository variables (non-secret)

Settings → Secrets and variables → Actions → **Variables**:

| Variable | Example | Required when TestFlight enabled |
| --- | --- | --- |
| `IOS_ENABLE_TESTFLIGHT` | `true` | Yes — turns on signed IPA + upload |
| `APPLE_DEVELOPER_TEAM_ID` | `AB12CD34EF` | Yes — 10-character Team ID (Membership details in Apple Developer) |
| `IOS_BUNDLE_IDENTIFIER` | `eu.amrit.smarttags` | Yes — must match Bundle ID and provisioning profile |

Optional override for seed generation (shared with Android): `SMART_TAGS_GATEWAY_BASE_URL`.

### Repository secrets

Settings → Secrets and variables → Actions → **Secrets**:

| Secret | What to put there |
| --- | --- |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64 of the **Apple Distribution** `.p12` file |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` |
| `IOS_APPSTORE_PROVISIONING_PROFILE_BASE64` | Base64 of the **App Store** `.mobileprovision` for `IOS_BUNDLE_IDENTIFIER` |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect API keys page |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID (e.g. `2X9R432HLC`) |
| `APP_STORE_CONNECT_API_KEY` | **Full text** of the `AuthKey_XXXX.p8` file (paste including `BEGIN/END` lines) |

**Encode binary files for secrets** (macOS):

```bash
base64 -i Certificates.p12 | tr -d '\n' | pbcopy
base64 -i SmartTags_AppStore.mobileprovision | tr -d '\n' | pbcopy
```

No Apple ID password or 2FA codes belong in GitHub. Upload uses the API key only.

### Checklist before first TestFlight tag

- [ ] Bundle ID in Xcode / `IOS_BUNDLE_IDENTIFIER` / Apple portal all match  
- [ ] App record exists in App Store Connect  
- [ ] Distribution cert + App Store profile are valid (not expired)  
- [ ] All six secrets and three variables above are set  
- [ ] `IOS_ENABLE_TESTFLIGHT` = `true`  
- [ ] `pubspec.yaml` version/build bumped; tag pushed (`v1.0.0` style, see [Release overview](release_overview.md))  
- [ ] After upload: App Store Connect → TestFlight → build processing (~5–30 min) → add internal testers  

## What happens on a tag push

1. **Seed database** job (shared with Android).  
2. **Build** on `macos-15`: analyze, test, then either unsigned app tarball or signed IPA.  
3. **`upload-testflight`** job (only if `IOS_ENABLE_TESTFLIGHT=true`): uploads `smart-tags.ipa` with [Apple-Actions/upload-testflight-build](https://github.com/Apple-Actions/upload-testflight-build).

Artifacts: **Actions → Release iOS app →** run for your tag (`smart-tags.ipa` or unsigned tarball). iOS builds are **not** attached to the GitHub Release (Android APK only).

## Local development

Simulator (no paid account):

```bash
./scripts/smartrun.sh
```

Physical device: Xcode signing with your Team. Manual TestFlight from Mac: **Product → Archive** in `ios/Runner.xcworkspace`.

## Distribution expectations

TestFlight is for **pilots** (TestFlight app + Apple ID). It is not as simple as the Android APK link. See [Release overview](release_overview.md) for recommended Android vs iOS rollout.

## Seed database

Same bundled `seed.sqlite` as Android ([Release seed database](release_seed_database.md)).

## Failed runs

Fix locally, bump version/build if needed, push a **new tag**. Do not reuse a tag that already uploaded to App Store Connect with the same build number.
