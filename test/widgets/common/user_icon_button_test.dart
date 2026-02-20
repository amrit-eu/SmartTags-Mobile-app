import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/widgets/common/user_icon_button.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<UserProfile?> build() async {
    return const UserProfile(
      fullName: 'Joe Bloggs',
      id: 123456,
      email: 'test@test.com',
    );
  }
}

void main() {
  testWidgets('User Icon Button directs to Login page if logged out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            body: const Center(child: UserIconButton()),
          ),
        ),
      )
    );

    // Ensure we're not on the profile screen yet
    expect(find.text('User ID'), findsNothing);

    await tester.pump();
    // Tap the user icon button and wait for navigation
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Verify navigation occurred by checking for login form elements
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('User Icon Button directs to Profile page if logged in', (tester) async {
    await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(FakeAuthNotifier.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(),
              body: const Center(child: UserIconButton()),
            ),
          ),
        )
    );

    // Ensure we're not on the profile screen yet
    expect(find.text('User ID'), findsNothing);

    await tester.pump();
    // Tap the user icon button and wait for navigation
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify navigation occurred by checking for profile content
    expect(find.text('User ID'), findsOneWidget);
    expect(find.text('My Profile'), findsWidgets);
    expect(find.text('Joe Bloggs'), findsWidgets);
  });
}
