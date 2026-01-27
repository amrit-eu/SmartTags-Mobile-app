import 'package:flutter/material.dart';
import 'package:smart_tags/components/common/container.dart';
import 'package:smart_tags/components/top_navigation.dart';

/// A dataclass representing a user's profile.
///
/// Contains the user's unique identifier, full name, and email address.
class UserProfile {

  /// Creates a [UserProfile].
  ///
  /// All fields are required and must be non-null.
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
  });

  /// The user's unique numeric identifier.
  final int id;

  /// The user's full display name.
  final String fullName;

  /// The user's primary email address.
  final String email;

}

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
      appBar: TopNavigation(title: Text('My Profile'), context: context, actions: [],),
      body:  SingleChildScrollView(
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
            SectionContainer(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerRow(label: 'User ID', value: user.id.toString(),),
                const Divider(height: 16),
                ContainerRow(label: 'Email', value: user.email,),
                const Divider(height: 16),
                ContainerRow(label: 'Full Name', value: user.fullName,),
              ],
            ))
          ],
        )
      )
    );
  }
}
