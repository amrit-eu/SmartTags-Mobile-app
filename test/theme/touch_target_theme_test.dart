import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/theme/touch_target_theme.dart';

void main() {
  test('TouchTargets.apply leaves theme unchanged when large is false', () {
    final base = ThemeData(useMaterial3: true);
    expect(identical(TouchTargets.apply(base, large: false), base), isTrue);
  });

  test('TouchTargets.apply enlarges icon button minimum size', () {
    final large = TouchTargets.apply(ThemeData(useMaterial3: true), large: true);
    final minSize = large.iconButtonTheme.style?.minimumSize?.resolve(<WidgetState>{});
    expect(minSize, const Size(TouchTargets.largeMin, TouchTargets.largeMin));
  });

  test('TouchTargets.apply enlarges filled button height and label style', () {
    final large = TouchTargets.apply(ThemeData(useMaterial3: true), large: true);
    final buttonMin = large.filledButtonTheme.style?.minimumSize?.resolve(<WidgetState>{});
    expect(buttonMin?.height, TouchTargets.largeMin);

    final labelSize = large.filledButtonTheme.style?.textStyle?.resolve(<WidgetState>{})?.fontSize;
    expect(labelSize, greaterThan(14));

    expect(large.extension<AppTouchTargetSizes>()?.enlarged, isTrue);
  });

  test('TouchTargets.apply enlarges extended floating action buttons', () {
    final large = TouchTargets.apply(ThemeData(useMaterial3: true), large: true);
    expect(
      large.floatingActionButtonTheme.extendedSizeConstraints?.minHeight,
      AppTouchTargetSizes.large.buttonMinHeight,
    );
    expect(large.floatingActionButtonTheme.extendedTextStyle?.fontSize, greaterThan(14));
  });

  test('TouchTargets.apply enlarges bottom navigation bar', () {
    final large = TouchTargets.apply(ThemeData(useMaterial3: true), large: true);
    expect(large.navigationBarTheme.height, AppTouchTargetSizes.large.navigationBarHeight);
    final navIconTheme = large.navigationBarTheme.iconTheme?.resolve(<WidgetState>{});
    expect(navIconTheme?.size, AppTouchTargetSizes.large.navigationIconSize);
  });
}
