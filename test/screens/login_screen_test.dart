import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/services/auth_service.dart';

import '../utils/test_user.dart';

class FakeAuthSuccessNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;

  @override
  Future<void> login(String email, String password) async {
    state = AsyncData(createTestUser());
  }
}

class FakeAuthFailureNotifier extends AuthNotifier {
  @override
  Future<User?> build() async => null;

  @override
  Future<void> login(String email, String password) async {
    state = AsyncError(
      const AuthException('Invalid Credentials'),
      StackTrace.current,
    );
  }
}

void main() {
  testWidgets(
      'Login screen redirects to profile page on login success', (tester) async {
    await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(FakeAuthSuccessNotifier.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(),
              body: const Center(child: UserLoginScreen()),
            ),
          ),
        )
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('emailField')), 'test@test.com',);
    await tester.enterText(find.byKey(const Key('passwordField')), 'password',);
    await tester.tap(find.byKey(const Key('logInButton')));
    await tester.pumpAndSettle();

    // Verify profile screen shown
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Joe Bloggs'), findsOneWidget);
  });

  testWidgets(
      'Login screen shows error and does not redirect on login failure', (tester) async {
    await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(FakeAuthFailureNotifier.new),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(),
              body: Consumer(
                builder: (context, ref, _) {
                  ref.listen(errorNotificationProvider, (_, next) {
                    if (next != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(next.message)),
                      );
                    }
                  });
                  return const Center(child: UserLoginScreen());
                },
              ),
            ),
          ),
        )
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('emailField')), 'test@test.com',);
    await tester.enterText(find.byKey(const Key('passwordField')), 'password',);
    await tester.tap(find.byKey(const Key('logInButton')));
    await tester.pumpAndSettle();

    expect(find.text('Login failed: Invalid Credentials'), findsOneWidget);

    // Verify no profile screen
    expect(find.text('Joe Bloggs'), findsNothing);
  });
}
