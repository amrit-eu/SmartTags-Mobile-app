import 'dart:async';

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
  MenuController? _menuController;

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final largeTouchTargets = ref.watch(largeTouchTargetsProvider);
    final applyingTouchTargets = ref.watch(largeTouchTargetsTransitionProvider);

    Widget menuItem(Widget child) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 32),
        child: child
    );

    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        menuItem(SwitchListTile(
          title: const Text('Theme Mode: Use System Default'),
          value: ref.watch(themeProvider) == ThemeMode.system,
          onChanged: (checked) {
            if (checked) {
              ref.read(themeProvider.notifier).useSystem();
            } else {
              ref.read(themeProvider.notifier).useLight();
            }
          },
          secondary: const ExcludeSemantics(child: Icon(Icons.light_mode)),
        )),
        menuItem(SwitchListTile(
          title: const Text('Dark Mode'),
          secondary: const ExcludeSemantics(child: Icon(Icons.dark_mode)),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: ref.watch(themeProvider) == ThemeMode.system
              ? null // disables the switch
              : (value) {
                  if (value) {
                    ref.read(themeProvider.notifier).useDark();
                  } else {
                    ref.read(themeProvider.notifier).useLight();
                  }
                },
        )),
        menuItem(SwitchListTile(
          title: const Text('Larger buttons and links'),
          subtitle: const Text('Easier to tap with gloves at sea'),
          value: largeTouchTargets,
          onChanged: applyingTouchTargets
              ? null
              : (enabled) {
                  _menuController?.close();
                  unawaited(
                    ref.read(largeTouchTargetsTransitionProvider.notifier).apply(enabled: enabled),
                  );
                },
          secondary: const ExcludeSemantics(child: Icon(Icons.touch_app)),
        )),
      ],
      builder: (_, controller, child) {
        _menuController = controller;
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
