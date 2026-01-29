import 'package:flutter/material.dart';

class SettingsIconButton extends StatefulWidget {
  /// Creates a [SettingsIconButton] displaying current app settings.
  const SettingsIconButton({super.key});

  @override
  State<SettingsIconButton> createState() => _SettingsIconButtonState();
}

class _SettingsIconButtonState extends State<SettingsIconButton> {
  OverlayEntry? overlayEntry;
  int currentPageIndex = 0;

  void createSettingsOverlay() {
    // Remove the existing OverlayEntry.
    removeSettingsOverlay();

    assert(overlayEntry == null);

    Widget builder(BuildContext context) {
      return const Column(
        children: <Widget>[
          Text('Test', style: TextStyle(color: Colors.green)),
          Icon(Icons.arrow_downward, color: Colors.green),
        ],
      );
    }

    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return SafeArea(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            heightFactor: 1.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              child: TapRegion(
                onTapOutside: (tap) {
                  removeSettingsOverlay();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Builder(builder: builder),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      height: 80.0,
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.amber[600],
                          child: const Icon(
                            size: 64,
                            Icons.dark_mode,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
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
      icon: const Icon(Icons.settings),
      onPressed: createSettingsOverlay,
    );
  }
}
