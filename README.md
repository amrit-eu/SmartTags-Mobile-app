# SmartTags - Oceanographic Platform Monitoring

SmartTags is a cross-platform Flutter application designed for monitoring and tracking oceanographic platforms (e.g., Argo floats, gliders). It provides a visualization of platform locations on an interactive ocean map, with detailed status information and QR code integration for easier platform identification.

## Key Features

- **Interactive Ocean Map**: View platform locations on a specialized ocean base map with reference layers.
- **Platform Management**: Detailed view for each platform including its status (Active/Inactive), model, network, and operational status.
- **Offline Support**: Local database integration using Drift for persistent storage and offline access.
- **QR Scanning**: Integrated mobile scanner for quick access to platform details via QR codes.


## Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **Database**: [Drift](https://drift.simonbinder.eu/) (formerly Moor) for cross-platform reactive persistence.
- **Mapping**: [flutter_map](https://pub.dev/packages/flutter_map) with ArcGIS Ocean Basemaps.
- **Location**: [geolocator](https://pub.dev/packages/geolocator) for real-time positioning of the user.
- **Scanner**: [mobile_scanner](https://pub.dev/packages/mobile_scanner) for QR code processing.

## Project Structure

```text
lib/
├── database/   # Drift database definition and platform-specific connections
├── helpers/    # Utility functions and helpers
├── models/     # Domain data models
├── screens/    # App screens (Map, Detail, QR Scanner)
├── services/   # API repositories and data synchronization logic
├── theme.dart  # Global theme and styling
└── main.dart   # Application entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for native development)

### Run the App

1.  **Clone the repository**.
2.  **Get dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Generate database code**:
    ```bash
    flutter pub run build_runner build
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```

### Local database (DBeaver)

The app stores SQLite in the platform app sandbox. For development, scripts copy or link it to a stable path:

**DBeaver path (all platforms):** `<repo>/.dev/db.sqlite` (gitignored)

#### macOS — iOS Simulator

```bash
./scripts/link-simulator-db.sh          # link only
./scripts/smartrun.sh                   # boot sim if needed + link + flutter run
./scripts/smartrun.sh -d "iPhone 17"    # specific simulator
```

`smartrun.sh` opens and boots the iOS Simulator when it is shutdown. Re-run after deleting/reinstalling the app. Optional: `SIMULATOR_NAME` or `SIMULATOR_DEVICE_ID`.

#### macOS — physical iPhone (USB)

Simulator DB linking is skipped for real devices. Use your Apple **Development Team** via a local, gitignored file (not committed):

```bash
cp ios/Flutter/Local.xcconfig.example ios/Flutter/Local.xcconfig
# Set DEVELOPMENT_TEAM to your Team ID (Xcode → Settings → Accounts, or Signing & Capabilities)
```

Then run on the device (use the id from `flutter devices`):

```bash
./scripts/smartrun.sh -d 00008130-000925DE02D1001C
./scripts/smartrun.sh -d 00008130-000925DE02D1001C --release   # offline QA without debug attach
# or: flutter run -d <device-id> [--release]
```

First install: unlock the phone, trust the Mac, enable **Developer Mode** if prompted, and trust the developer certificate under **Settings → General → VPN & Device Management**. Free Apple IDs are limited to **3 sideloaded apps** at once.

**Gateway / VPN:** the phone uses its own network (Wi‑Fi/cellular), not the Mac’s VPN over USB. Use VPN on the iPhone or test Gateway sync on the **simulator** while the Mac is on VPN.

#### Linux / Windows WSL / Android emulator

Requires [adb](https://developer.android.com/tools/adb) and a connected emulator or device (debug build):

```bash
./scripts/link-android-db.sh            # pull only
./scripts/smartrun-android.sh         # boot/connect emulator + pull + flutter run
./scripts/smartrun-android.sh -d emulator-5554
```

**Linux (native):** `smartrun-android.sh` launches the first available AVD (or `ANDROID_AVD`) if no device is connected.

**WSL + emulator on Windows:** by default the script tries `adb connect` to the Windows host — start the emulator in Android Studio first, or leave it running.

**WSL experimental (one-command cold start):** devs can try launching the emulator on Windows from WSL:

```bash
WSL_LAUNCH_EMULATOR=1 \
ANDROID_AVD=Pixel_7_API_34 \
WINDOWS_ANDROID_SDK=/mnt/c/Users/you/AppData/Local/Android/Sdk \
./scripts/smartrun-android.sh
```

Or uncomment the block marked `WSL experimental` in `scripts/boot-android-emulator.sh`. Paths and AVD names vary — feedback welcome.

Manual fallback:

```bash
adb connect 127.0.0.1:5555
# or use the Windows host IP from /etc/resolv.conf
adb connect $(awk '/nameserver/ { print $2; exit }' /etc/resolv.conf):5555
```

Optional: `ANDROID_AVD`, `ANDROID_PACKAGE` (default `com.example.flutter_amrit`), `WSL_ADB_HOST`, `WSL_LAUNCH_EMULATOR`, `WINDOWS_ANDROID_SDK`.

#### Cursor / VS Code tasks

Command Palette → **Tasks: Run Task**:

- **flutter: run iOS (with db link)** — macOS iOS Simulator
- **flutter: run Android (with db link)** — Linux, WSL, macOS Android emulator
- **link-simulator-db** / **link-android-db** — refresh DBeaver path only

---

*Note: For Android testing, ensure location permissions are enabled in the app settings or via the system prompt.*
