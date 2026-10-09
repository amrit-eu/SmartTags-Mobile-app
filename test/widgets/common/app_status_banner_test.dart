import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

void main() {
  testWidgets('shows the message and optional icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStatusBanner(
            message: 'Offline',
            icon: Icons.wifi_off,
          ),
        ),
      ),
    );

    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });

  testWidgets('invokes action and dismissal callbacks', (tester) async {
    var actionPressed = false;
    var dismissPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStatusBanner(
            message: 'Could not synchronise',
            severity: AppStatusBannerSeverity.error,
            icon: Icons.sync_problem,
            actionLabel: 'Retry',
            onAction: () {
              actionPressed = true;
            },
            onDismiss: () {
              dismissPressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.tap(find.byTooltip('Dismiss banner'));

    expect(actionPressed, isTrue);
    expect(dismissPressed, isTrue);
  });

  testWidgets('does not show optional controls by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStatusBanner(message: 'Downloading platforms…'),
        ),
      ),
    );

    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('supports indeterminate and determinate progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStatusBanner(
            message: 'Downloading platforms…',
            showProgress: true,
          ),
        ),
      ),
    );

    var indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStatusBanner(
            message: 'Downloading platforms…',
            showProgress: true,
            progress: 0.5,
          ),
        ),
      ),
    );

    indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, 0.5);
  });
}
