import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/widgets/common/user_icon_button.dart';

void main() {
  testWidgets('User Icon Button directs to Profile page.', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          body: const Center(child: UserIconButton()),
        ),
      ),
    );

    // Ensure we're not on the profile screen yet
    expect(find.text('User ID'), findsNothing);

    // Tap the user icon button and wait for navigation
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify navigation occurred by checking for profile content
    expect(find.text('User ID'), findsOneWidget);
    expect(find.text('My Profile'), findsWidgets);
  });
}
