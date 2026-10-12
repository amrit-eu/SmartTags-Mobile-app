# Banner and transient-feedback guidelines

SmartTags uses two notification patterns:

- Top status banners for ongoing application conditions.
- Bottom SnackBars for short-lived feedback resulting from an event or user action.

Use the notification category to determine placement and dismissal behaviour. Use severity only to determine visual styling.

## Notification categories

| Category | Purpose | Placement | Dismissal |
| --- | --- | --- | --- |
| Progress status | A currently running operation | Top, below the app bar or safe area | Automatically when the operation ends; no manual dismissal |
| Persistent status | An ongoing condition affecting the current experience | Top, below the app bar or safe area | Close button where safe; hidden until the condition changes or the app/session restarts |
| Action-required warning | A problem requiring retry or another corrective action | Top, below the app bar or safe area | Corrective action plus a close button where safe; essential empty or blocked states may be non-dismissible |
| Transient feedback | The result of a recent event or user action | Bottom SnackBar | Automatic four-second timeout, with an optional relevant action |

Examples of essential states include explaining why a screen is empty. Do not provide a close button if dismissal would leave the user without the information needed to understand the screen.

## Shared components

### `AppStatusBanner`

Location:

```text
lib/widgets/common/app_status_banner.dart
```

Use `AppStatusBanner` for persistent, actionable or essential messages displayed at the top of a screen.

It provides:

- consistent layout and spacing;
- information, success, warning and error severity styles;
- an optional icon;
- an optional primary action;
- an optional close button;
- optional determinate or indeterminate progress.

Example persistent status:

```dart
AppStatusBanner(
  message: 'Offline — showing local data',
  severity: AppStatusBannerSeverity.warning,
  icon: Icons.wifi_off,
  onDismiss: dismissBanner,
);
```

Example action-required warning:

```dart
AppStatusBanner(
  message: 'Could not refresh platforms',
  severity: AppStatusBannerSeverity.error,
  icon: Icons.cloud_off,
  actionLabel: 'Retry',
  onAction: retry,
  onDismiss: dismissBanner,
);
```

`AppStatusBanner` is a presentation component. The owning widget remains responsible for:

- deciding when the banner is visible;
- storing whether it has been dismissed;
- resetting dismissal when the condition resolves and later recurs;
- resetting dismissal when the underlying state changes materially.

Do not add a close callback to progress banners or essential states.

### `PlatformsLoadingBanner`

Location:

```text
lib/widgets/platforms_loading_banner.dart
```

Use `PlatformsLoadingBanner` for platform download, save and display progress. It delegates presentation to `AppStatusBanner`.

```dart
const PlatformsLoadingBanner(
  message: 'Downloading platforms…',
);
```

Progress banners must disappear automatically when the operation finishes. They must not have a close button.

### `buildAppSnackBar`

Location:

```text
lib/widgets/common/app_snack_bar.dart
```

Use `buildAppSnackBar` for transient feedback at the bottom of the screen. Do not construct `SnackBar` directly in production code.

```dart
ScaffoldMessenger.of(context).showSnackBar(
  buildAppSnackBar(
    message: 'Platform updated.',
  ),
);
```

An optional action may be supplied when it is directly relevant to the message:

```dart
final messenger = ScaffoldMessenger.of(context);

messenger.showSnackBar(
  buildAppSnackBar(
    message: 'Unable to fetch current location',
    actionLabel: 'Close',
    onAction: messenger.hideCurrentSnackBar,
  ),
);
```

`actionLabel` and `onAction` must either both be supplied or both be omitted.

The shared factory applies the standard four-second duration. A SnackBar should not be made persistent. If information must remain visible until its condition is resolved, use a top status banner instead.

## Severity

Severity controls visual styling, not placement or dismissal.

| Severity | Use |
| --- | --- |
| `info` | Neutral application state or queued work |
| `success` | Successful state that must remain visible |
| `warning` | Degraded operation or a condition requiring attention |
| `error` | A failed operation or condition requiring corrective action |

Short-lived success feedback should normally remain a SnackBar rather than becoming a success banner.

## Placement

Top banners must be:

- directly below the app bar or safe area;
- above the current screen content;
- outside scrollable content, so they remain visible while the user scrolls.

Example screen structure:

```dart
Scaffold(
  appBar: const TopNavigation(
    title: Text('Example'),
  ),
  body: Column(
    children: [
      if (showBanner) const ExampleBanner(),
      Expanded(
        child: SingleChildScrollView(
          child: screenContent,
        ),
      ),
    ],
  ),
);
```

The main navigation shell owns global banners that must appear across the primary tabs.

Pushed routes are displayed above the main shell and therefore cannot rely on its banners being visible. A pushed route must render any relevant status banner locally, using the same shared components and placement rules.

## Dismissal lifetime

Dismissal belongs to the condition, not permanently to the banner type.

For a persistent condition:

1. Show the banner when the condition begins.
2. Allow dismissal where hiding it is safe.
3. Keep it hidden while that same condition remains unchanged.
4. Reset dismissal when the condition resolves.
5. Show it again if the condition later recurs.

For queued operations, a changed queue count, status, attempt count or error is a material state change and may cause a dismissed banner to reappear.

Essential empty-state information remains visible until the underlying condition changes.

## Choosing the correct pattern

Before displaying a notification, ask:

1. Is an operation currently running? Use a progress banner.
2. Does the condition continue to affect the current experience? Use a persistent top banner.
3. Must the user take corrective action? Use an action-required top banner. If the message is essential to understanding an empty or blocked screen, omit the close button.
4. Is this only feedback about a recent event or action? Use a bottom SnackBar.

Do not use a SnackBar solely because it is easier to invoke. The expected lifetime of the information determines the component.

## Testing

Tests for a new notification should verify the rules relevant to its category:

- the message is displayed;
- the correct severity is used;
- progress and essential-state banners do not have a close button;
- dismissible banners disappear when Close is selected;
- dismissed banners reappear after the condition resolves and recurs;
- corrective actions invoke the expected callback;
- top banners are outside scrollable content where applicable;
- SnackBars use `buildAppSnackBar` and disappear after `appSnackBarDuration`.