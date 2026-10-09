import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/screens/user_profile.dart';

/// App-bar account control: signed-in initials avatar vs signed-out outline.
class UserIconButton extends ConsumerWidget {
  /// Creates a [UserIconButton].
  const UserIconButton({super.key});

  static const double _avatarSize = 32;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value;
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);

    final tooltip = switch (user) {
      final User u => 'Account — ${u.fullName}',
      null when isLoading => 'Checking sign-in…',
      null => 'Sign in',
    };

    return IconButton(
      tooltip: tooltip,
      onPressed: isLoading
          ? null
          : () async {
              if (user != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute<UserProfileScreen>(
                    builder: (BuildContext ctx) => UserProfileScreen(
                      user: user,
                    ),
                  ),
                );
              } else {
                await Navigator.of(context).push(
                  MaterialPageRoute<UserLoginScreen>(
                    builder: (BuildContext ctx) => const UserLoginScreen(),
                  ),
                );
              }
            },
      icon: _AccountAvatar(
        user: user,
        isLoading: isLoading,
        theme: theme,
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({
    required this.user,
    required this.isLoading,
    required this.theme,
  });

  final User? user;
  final bool isLoading;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: UserIconButton._avatarSize,
        height: UserIconButton._avatarSize,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (user != null) {
      return CircleAvatar(
        radius: UserIconButton._avatarSize / 2,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Text(
          _initialsFor(user!),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: UserIconButton._avatarSize,
      height: UserIconButton._avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.person_outline,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

String _initialsFor(User user) {
  final first = user.firstName.trim();
  final last = user.lastName.trim();
  if (first.isNotEmpty && last.isNotEmpty) {
    return '${first[0]}${last[0]}'.toUpperCase();
  }
  final full = user.fullName.trim();
  if (full.isEmpty) {
    return '?';
  }
  final parts = full.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return parts.first[0].toUpperCase();
}
