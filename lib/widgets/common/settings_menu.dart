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
    final customTextScale = ref.watch(textScaleProvider);
    final textFollowSystem = customTextScale == null;
    final systemTextScale = MediaQuery.textScalerOf(context).scale(1.0);
    final sliderValue = (customTextScale ?? systemTextScale)
        .clamp(AppTextScale.min, AppTextScale.max);

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
                    ref.read(themeProvider.notifier).useDark();
                  } else {
                    ref.read(themeProvider.notifier).useLight();
                  }
                },
        ),
        SwitchListTile(
          title: const Text('Theme Mode: Use System Default'),
          value: ref.watch(themeProvider) == ThemeMode.system,
          onChanged: (bool? checked) {
            if (checked ?? false) {
              ref.read(themeProvider.notifier).useSystem();
            } else {
              ref.read(themeProvider.notifier).useLight();
            }
          },
          secondary: const Icon(Icons.light_mode),
        ),
        Slider(
          value: sliderValue,
          min: AppTextScale.min,
          max: AppTextScale.max,
          divisions: 12, // 0.1 steps between 0.8 and 2.0
          label: '${(sliderValue * 100).round()}%',
          onChanged: textFollowSystem
              ? null // disable the slider
              : (double value) => ref.read(textScaleProvider.notifier).set(value),
        ),
        SwitchListTile(
          title: const Text('Text Size: Use System Default'),
          value: textFollowSystem,
          onChanged: (bool? checked) {
            if (checked ?? false) {
              ref.read(textScaleProvider.notifier).useSystem();
            } else {
              ref.read(textScaleProvider.notifier).set(sliderValue);
            }
          },
          secondary: const Icon(Icons.format_size),
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
