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

    Widget _fullWidthMenuItem(Widget child) => SizedBox(
        width: MediaQuery.of(context).size.width, child: child
    );

    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        _fullWidthMenuItem(SwitchListTile(
          title: const Text('Theme Mode: Use System Default'),
          value: ref.watch(themeProvider) == ThemeMode.system,
          onChanged: (bool? checked) {
            if (checked ?? false) {
              ref.read(themeProvider.notifier).useSystem();
            } else {
              ref.read(themeProvider.notifier).useLight();
            }
          },
          secondary: const ExcludeSemantics(child: Icon(Icons.light_mode)),
        )),
        _fullWidthMenuItem(SwitchListTile(
          title: const Text('Dark Mode'),
          secondary: const ExcludeSemantics(child: Icon(Icons.dark_mode)),
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
        )),
        _fullWidthMenuItem(SwitchListTile(
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
        )),
        _fullWidthMenuItem(Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ExcludeSemantics(
                child: Icon(
                  Icons.text_decrease,
                  color: textFollowSystem ? Theme.of(context).disabledColor : null,
                ),
              )
            ),
            Expanded(
              child: Slider(
                value: sliderValue,
                min: AppTextScale.min,
                max: AppTextScale.max,
                divisions: 6,
                label: '${(sliderValue * 100).round()}%',
                onChanged: textFollowSystem
                    ? null
                    : (value) => ref.read(textScaleProvider.notifier).set(value),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(right: 32),
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.text_increase,
                    color: textFollowSystem ? Theme.of(context).disabledColor : null,
                  ),
                )
            ),
          ],
        )),
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
