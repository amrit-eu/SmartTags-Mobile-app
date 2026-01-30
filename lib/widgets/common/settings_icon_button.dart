import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/settings_providers.dart';

/// A button to open a list of settings overlaying the current screen.
class SettingsIconButton extends StatefulWidget {
  /// Creates a [SettingsIconButton] displaying current app settings.
  const SettingsIconButton({super.key});

  @override
  State<SettingsIconButton> createState() => _SettingsIconButtonState();
}

class _SettingsIconButtonState extends State<SettingsIconButton> {
  OverlayEntry? overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  void toggleSettingsOverlay() {
    if (overlayEntry == null) {
      createSettingsOverlay();
    } else {
      removeSettingsOverlay();
    }
  }

  void createSettingsOverlay() {
    // Remove the existing OverlayEntry.
    removeSettingsOverlay();

    assert(
    overlayEntry == null,'Found an existing overlay when there should be none',
    );

    final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);

    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return SafeArea(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            heightFactor: 1,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: removeSettingsOverlay,
                    child: Container(color: Colors.transparent),
                  ),
                  Positioned(
                    top: buttonPosition.dy + buttonSize.height,
                    right: MediaQuery.of(context).size.width - buttonPosition.dx - buttonSize.width,
                    width: MediaQuery.of(context).size.width / 3,
                    height: 80,
                    child: Center(
                      child: Card(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final isDark = Theme.of(context).brightness == Brightness.dark;

                            return SwitchListTile(
                              title: const Text('Dark Mode'),
                              secondary: const Icon(Icons.dark_mode),
                              value: isDark,
                              onChanged: (bool value) {
                                if (value) {
                                  ref.read(themeProvider.notifier).toggleDark();
                                } else {
                                  ref.read(themeProvider.notifier).toggleLight();
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  // Remove the OverlayEntry.
  void removeSettingsOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  void dispose() {
    // Make sure to remove OverlayEntry when the widget is disposed.
    removeSettingsOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _buttonKey,
      icon: const Icon(Icons.settings),
      onPressed: toggleSettingsOverlay,
    );
  }
}
