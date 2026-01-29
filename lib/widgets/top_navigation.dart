import 'package:flutter/material.dart';
import 'package:smart_tags/widgets/common/settings_icon_button.dart';
import 'package:smart_tags/widgets/common/user_icon_button.dart';

/// A custom AppBar widget for the Smart Tags app.
class TopNavigation extends AppBar {
  /// Creates a [TopNavigation] widget with an optional [title], [leading]
  /// widget and [actions] widgets.
  /// [leading] defaults to a user icon button if not provided.
  /// A settings icon button is displayed as one of the actions if not provided.
  TopNavigation({super.key, Widget? title, Widget? leading, List<Widget>? actions})
    : super(
        title: title ?? const Text('Smart Tags'),
        leading: leading ?? const UserIconButton(),
        actions: actions ?? [const SettingsIconButton()]
      );
}
