import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/common/app_snack_bar.dart';

Future<SnackBar> _showSnackBar(
  WidgetTester tester, {
  String message = 'Feedback',
  AppSnackBarSeverity severity = AppSnackBarSeverity.info,
  ThemeData? theme,
  String? actionLabel,
  VoidCallback? onAction,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              buildAppSnackBar(
                context: context,
                message: message,
                severity: severity,
                actionLabel: actionLabel,
                onAction: onAction,
              ),
            ),
            child: const Text('Show feedback'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Show feedback'));
  await tester.pumpAndSettle();
  return tester.widget<SnackBar>(find.byType(SnackBar));
}

void main() {
  testWidgets('defaults to informational feedback and expires after four seconds', (tester) async {
    final snackBar = await _showSnackBar(tester, message: 'Queued');

    expect(find.text('Queued'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(snackBar.duration, appSnackBarDuration);
    expect(snackBar.persist, isFalse);
    expect(snackBar.dismissDirection, isNot(DismissDirection.none));
    expect(snackBar.action, isNull);

    await tester.pump(appSnackBarDuration);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SnackBar), findsNothing);
  });

  for (final brightness in Brightness.values) {
    for (final severity in AppSnackBarSeverity.values) {
      testWidgets('$severity uses the expected colours and icon in $brightness mode', (tester) async {
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness),
        );
        final snackBar = await _showSnackBar(tester, theme: theme, severity: severity);
        final content = find.descendant(of: find.byType(SnackBar), matching: find.text('Feedback'));
        final foreground = tester.widget<Text>(content).style!.color!;
        final background = snackBar.backgroundColor!;

        final icon = switch (severity) {
          AppSnackBarSeverity.info => Icons.info_outline,
          AppSnackBarSeverity.success => Icons.check_circle_outline,
          AppSnackBarSeverity.warning => Icons.warning_amber_outlined,
          AppSnackBarSeverity.error => Icons.error_outline,
        };
        expect(find.byIcon(icon), findsOneWidget);
        expect(tester.widget<Icon>(find.byIcon(icon)).color, foreground);
        switch (severity) {
          case AppSnackBarSeverity.info:
            expect(background, theme.colorScheme.inverseSurface);
          case AppSnackBarSeverity.success:
            final successColors = ColorScheme.fromSeed(seedColor: Colors.green, brightness: brightness);
            expect(background, successColors.primaryContainer);
          case AppSnackBarSeverity.warning:
            final warningColors = ColorScheme.fromSeed(seedColor: Colors.amber, brightness: brightness);
            expect(background, warningColors.primaryContainer);
          case AppSnackBarSeverity.error:
            expect(background, theme.colorScheme.errorContainer);
        }
      });
    }
  }

  testWidgets('styles the optional action and invokes its callback', (tester) async {
    var actionCalled = false;
    final snackBar = await _showSnackBar(
      tester,
      severity: AppSnackBarSeverity.error,
      actionLabel: 'Retry',
      onAction: () => actionCalled = true,
    );

    final content = tester.widget<Text>(find.text('Feedback'));
    expect(snackBar.action!.textColor, content.style!.color);
    await tester.tap(find.text('Retry'));
    expect(actionCalled, isTrue);
  });

  testWidgets('feedback with an action still expires after four seconds', (tester) async {
    var actionCalled = false;
    final snackBar = await _showSnackBar(
      tester,
      severity: AppSnackBarSeverity.error,
      actionLabel: 'Retry',
      onAction: () => actionCalled = true,
    );

    expect(snackBar.persist, isFalse);
    await tester.pump(appSnackBarDuration);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SnackBar), findsNothing);
    expect(actionCalled, isFalse);
  });

  testWidgets('wraps long feedback on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const message =
        'Platform paired to QR code. Refresh to update the local data before continuing with your next task.';

    await _showSnackBar(tester, message: message, severity: AppSnackBarSeverity.warning);

    expect(find.text(message), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
