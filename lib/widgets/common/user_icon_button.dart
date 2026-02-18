import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/settings_providers.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/screens/user_profile.dart';


/// A button widget that displays a user icon and navigates to the user profile screen when pressed.
class UserIconButton extends ConsumerWidget {
  /// Creates a [UserIconButton].
  const UserIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: ref.watch(loginProvider)
            ? const Icon(Icons.person)
            : const Icon(Icons.person_outline),
      onPressed: () => Navigator.of(context).push(
          ref.watch(loginProvider)
            ? MaterialPageRoute<UserProfileScreen>(
                builder: (BuildContext ctx) => const UserProfileScreen(
                  user: UserProfile(id: 1, fullName: 'Joe Bloggs', email: 'jb@gmail.com'),
                ),
              )
            : MaterialPageRoute<UserLoginScreen>(
                builder: (BuildContext ctx) => const UserLoginScreen(),
              ),
      ),
    );
  }
}
