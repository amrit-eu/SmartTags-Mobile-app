import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/screens/deploy_platform_screen.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A fake Platform to use in tests.
final testPlatform = Platform(
  platformRef: 'TEST-001',
  model: 'Model 1',
  network: 'Network 1',
  latestPosition: const LatLng(0, 0),
  operationLocation: const LatLng(0, 0),
  status: PlatformStatus.active,
  operationalStatus: OperationalStatus.deployed,
  lastUpdated: DateTime(2025),
);

void main() {
  testWidgets('Deploy Platform has correct title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(TopNavigation, 'Deploy Platform'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(TopNavigation, 'Recover Platform'), findsOneWidget);
  });
  testWidgets('Deploy Platform has correct fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.platformRef && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.model && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Latitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Longitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Deployment Time (UTC)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.platformRef && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextFormField && widget.initialValue == testPlatform.model && !widget.enabled,
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Latitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Longitude'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Recovery Time (UTC)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });
  testWidgets('Deploy Platform has correct button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.deploy,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(ElevatedButton, 'Deploy Platform'), findsOneWidget);
  });
  testWidgets('Recover Platform has correct button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DeployPlatformScreen(
            platform: testPlatform,
            action: DeployAction.recover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.widgetWithText(ElevatedButton, 'Recover Platform'), findsOneWidget);
  });
}
