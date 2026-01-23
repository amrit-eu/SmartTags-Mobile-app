import 'package:flutter/material.dart';
import 'package:flutter_amrit/database/db.dart';
import 'package:flutter_amrit/database/db_connection.dart' as conn;
import 'package:flutter_amrit/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final db = AppDatabase.executor(conn.inMemoryConnection());

    await tester.pumpWidget(MyApp(database: db));
    await tester.pump(const Duration(milliseconds: 500));
    // Verify that our app shows the SmartTags title.
    expect(find.text('SmartTags'), findsAtLeast(1));
    await db.close();
  });

  testWidgets('Test added content is visible on the Map', (WidgetTester tester) async {
    final db = AppDatabase.executor(conn.inMemoryConnection());

    // Add a test platform
    await db
        .into(db.platforms)
        .insert(
          PlatformsCompanion.insert(
            ref: 'MAP-TEST-001',
            model: 'Test Sensor',
            network: 'TestNet',
            lat: 45,
            lon: -5,
            status: 'Active',
            operationalStatus: 'Deployed',
            lastUpdated: DateTime.now(),
            operationLat: 45,
            operationLon: -5,
          ),
        );

    await tester.pumpWidget(MyApp(database: db));
    await tester.pump(const Duration(milliseconds: 500)); // Wait for StreamBuilder

    // Verify that the marker is visible (using the location_on icon)
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    await db.close();
  });
}
