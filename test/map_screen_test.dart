import 'package:flutter/material.dart';
import 'package:flutter_amrit/screens/map_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MapScreen has title', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MapScreen()));
    final titleFinder = find.text('SmartTags');
    expect(titleFinder, findsOneWidget);
  });
  testWidgets('MapScreen has find my location icon', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MapScreen()));
    final iconFinder = find.byIcon(Icons.my_location);
    expect(iconFinder, findsOneWidget);
  });
}
