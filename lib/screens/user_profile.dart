import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that displays information about a [User].
///
/// Shows the user's avatar, ID, email, and full name.
class UserProfileScreen extends ConsumerStatefulWidget {
  /// Creates a [UserProfileScreen] for the given [user].
  const UserProfileScreen({required this.user, super.key});

  /// The profile to display.
  final User user;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  AsyncValue<User?>? _authState;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authProvider, (prev, next) async {
      _authState = next;
      unawaited(next.whenOrNull(
        data: (user) async {
          // If the user becomes null, it means they have logged out, so navigate back to the login screen.
          if (!context.mounted) return;
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<MainNavigation>(
                builder: (BuildContext ctx) => const UserLoginScreen(),
              )
            );
        },
        error: (err, _) {
          ref.read(errorNotificationProvider.notifier).setError('Logout failed: $err');
          return null;
        },
      ));
    });

    return Scaffold(
      appBar: TopNavigation(title: const Text('My Profile'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Icon(
                size: 64,
                Icons.person,
              ),
            ),
            SectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerRow(
                    label: 'User ID',
                    value: widget.user.id.toString(),
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Email',
                    value: widget.user.email,
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Full Name',
                    value: widget.user.fullName,
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  final authState = _authState;
                  if (context.mounted && authState is AsyncData<User?> && authState.value == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout successful')),
                    );
                  }
                },
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
