import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/map_skeleton_loader.dart';

void main() {
  testWidgets('MapSkeletonLoader renders a map icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MapSkeletonLoader(),
        ),
      ),
    );

    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
  });
}
