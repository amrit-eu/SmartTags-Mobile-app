import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that displays information about a [UserProfile].
///
/// Shows the user's avatar, ID, email, and full name.
class UserProfileScreen extends ConsumerWidget {
  /// Creates a [UserProfileScreen] for the given [user].
  const UserProfileScreen({required this.user, super.key});

  /// The profile to display.
  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<UserProfile?>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          if (user == null) {
            // logout success
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout successful')),
              );
            }
          }
        },
        error: (err, stack) {
          // logout failed
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Logout failed: $err')),
            );
          }
        },
      );
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
                    value: user.id.toString(),
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(height: 16),
                  ContainerRow(
                    label: 'Full Name',
                    value: user.fullName,
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;

                  await Navigator.of(context).push(
                    MaterialPageRoute<MainNavigation>(
                      builder: (BuildContext ctx) => const MainNavigation(),
                    )
                  );
                },
                child: const Text('Log Out'),
              ),
            ),
            ElevatedButton(
                    onPressed: () async { await ref.read(authProvider.notifier).getMe(); },
                    child: const Text('Get Me'),),
            ElevatedButton(
                    onPressed: () async { 
                      await ref.read(authProvider.notifier).getMeForcedRefresh(); 
                      },
                    child: const Text('Get Me (forced refresh)'),),
            ElevatedButton(
                    onPressed: () async { 
                      await ref.read(authProvider.notifier).getMeFailedRefresh(); 
                      },
                    child: const Text('Get Me (forced refresh fail)'),)
          ],
        ),
      ),
    );
  }
}
