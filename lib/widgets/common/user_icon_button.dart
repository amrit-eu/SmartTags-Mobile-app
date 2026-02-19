import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/screens/user_profile.dart';


/// A button widget that displays a user icon and navigates to the user profile screen when pressed.
class UserIconButton extends ConsumerWidget {
  /// Creates a [UserIconButton].
  const UserIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    final isLoading = authState.isLoading;
    return IconButton(
      icon: user != null
            ? const Icon(Icons.person)
            : const Icon(Icons.person_outline),
      onPressed: isLoading 
        ? null
        : () async {
        if (user != null) {
          await Navigator.of(context).push(
              MaterialPageRoute<UserProfileScreen>(
                builder: (BuildContext ctx) =>
                    UserProfileScreen(
                      user: user,
                    ),
              )
          );
        } else {
          await Navigator.of(context).push(
              MaterialPageRoute<UserLoginScreen>(
                builder: (BuildContext ctx) => const UserLoginScreen(),
              )
          );
        }
      }
    );
  }
}
