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

---

*Note: For Android testing, ensure location permissions are enabled in the app settings or via the system prompt.*
