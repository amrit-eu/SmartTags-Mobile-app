import 'package:flutter/material.dart';
import 'package:smart_tags/screens/user_profile.dart';

class TopNavigation extends AppBar {
	TopNavigation({
		Key? key,
		Widget? title,
		Widget? leading,
		List<Widget>? actions,
    required BuildContext context
	}) : super(
					key: key,
					title: title ?? const Text('Smart Tags'),
					leading: leading ?? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
					actions: actions ?? [
						IconButton(
							icon: const Icon(Icons.person),
							onPressed: () => Navigator.of(context).push(
								MaterialPageRoute(builder: (ctx) => UserProfileScreen(user: UserProfile(id: 1, fullName: 'Joe Bloggs', email: 'jb@gmail.com'),),)
							),
						),
					],
				);
}
