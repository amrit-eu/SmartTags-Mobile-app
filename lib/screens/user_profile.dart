import 'package:flutter/material.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that displays information about a [UserProfile].
///
/// Shows the user's avatar, ID, email, and full name.
class UserProfileScreen extends StatelessWidget {
  /// Creates a [UserProfileScreen] for the given [user].
  const UserProfileScreen({required this.user, super.key});

  /// The profile to display.
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
