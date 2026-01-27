import 'package:flutter/material.dart';
import 'package:smart_tags/widgets/common/user_icon_button.dart';

/// A custom AppBar widget for the Smart Tags app.
class TopNavigation extends AppBar {
  /// Creates a [TopNavigation] widget with an optional [title], [leading] widget.
  /// [leading] defaults to a user icon button if not provided.
  TopNavigation({super.key, Widget? title, Widget? leading, super.actions})
    : super(
        title: title ?? const Text('Smart Tags'),
        leading: leading ?? const UserIconButton(),
      );
}
