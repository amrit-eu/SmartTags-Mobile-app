import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/settings_providers.dart';

/// A button to open a list of settings overlaying the current screen.
class SettingsMenu extends ConsumerStatefulWidget {
  /// Creates a [SettingsMenu] displaying current app settings.
  const SettingsMenu({super.key});

  @override
  ConsumerState<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends ConsumerState<SettingsMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        SwitchListTile(
          title: const Text('Dark Mode'),
          secondary: const Icon(Icons.dark_mode),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: ref.watch(themeProvider) == ThemeMode.system
              ? null // disables the switch
              : (bool value) {
            if (value) {
              ref.read(themeProvider.notifier).toggleDark();
            } else {
              ref.read(themeProvider.notifier).toggleLight();
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Use system default'),
          value: ref.watch(themeProvider) == ThemeMode.system,
          onChanged: (bool? checked) {
            if (checked ?? false) {
              ref.read(themeProvider.notifier).toggleSystem();
            } else {
              ref.read(themeProvider.notifier).toggleLight();
            }
          },
          secondary: const Icon(Icons.light_mode),
        ),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return IconButton(
          focusNode: _buttonFocusNode,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
    );
  }
}
