import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/screens/catalogue_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.executor(conn.inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> populateDb() async {
    await db.insertPlatforms([
      PlatformsCompanion.insert(
        ref: 'PLT-001',
        model: 'Argo Float',
        network: 'Argo',
        lat: 10,
        lon: 10,
        status: 'Active',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.now(),
        operationLat: 10,
        operationLon: 10,
      ),
      PlatformsCompanion.insert(
        ref: 'PLT-002',
        model: 'Drifting Buoy',
        network: 'DBCP',
        lat: 20,
        lon: 20,
        status: 'Inactive',
        operationalStatus: 'Recovered',
        lastUpdated: DateTime.now(),
        operationLat: 20,
        operationLon: 20,
      ),
    ]);
  }

  testWidgets('CatalogueScreen shows prompt initially', (tester) async {
    await populateDb();

    await tester.pumpWidget(MaterialApp(home: CatalogueScreen(database: db)));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('CatalogueScreen filters platforms by text', (tester) async {
    await populateDb();

    await tester.pumpWidget(MaterialApp(home: CatalogueScreen(database: db)));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify initial state
    expect(find.text('Enter a platform ID or model to search'), findsOneWidget);

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Argo');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify filtered state
    expect(find.text('Argo Float'), findsOneWidget);
    expect(find.text('Drifting Buoy'), findsNothing);
  });

  testWidgets('CatalogueScreen shows no results message', (tester) async {
    await populateDb();

    await tester.pumpWidget(MaterialApp(home: CatalogueScreen(database: db)));
    await tester.pumpAndSettle();

    // Enter search text that matches nothing
    await tester.enterText(find.byType(TextField), 'NonExistent');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });
}
