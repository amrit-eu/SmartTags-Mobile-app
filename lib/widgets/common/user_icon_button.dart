import 'package:flutter/material.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/screens/user_profile.dart';

/// A button widget that displays a user icon and navigates to the user profile screen when pressed.
class UserIconButton extends StatelessWidget {
  /// Creates a [UserIconButton].
  const UserIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<UserProfileScreen>(
          builder: (BuildContext ctx) => const UserProfileScreen(
            user: UserProfile(id: 1, fullName: 'Joe Bloggs', email: 'jb@gmail.com'),
          ),
        ),
      ),
    );
  }
}
