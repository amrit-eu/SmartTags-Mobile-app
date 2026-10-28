import 'package:flutter/material.dart';

/// Theme extension for enlarged control sizing (#46).
@immutable
class AppTouchTargetSizes extends ThemeExtension<AppTouchTargetSizes> {
  /// Creates touch-target sizing tokens.
  const AppTouchTargetSizes({
    required this.enlarged,
    required this.buttonMinHeight,
    required this.buttonIconSize,
    required this.inlineIconSize,
    required this.navigationBarHeight,
    required this.navigationIconSize,
  });

  /// Whether glove-friendly sizing is active.
  final bool enlarged;

  /// Minimum height for Material buttons (dp).
  final double buttonMinHeight;

  /// Icon size inside buttons (dp).
  final double buttonIconSize;

  /// Icons beside labels in compact rows (dp).
  final double inlineIconSize;

  /// Height of the main bottom [NavigationBar] (dp).
  final double navigationBarHeight;

  /// Icons in bottom navigation destinations (dp).
  final double navigationIconSize;

  /// Insets for platform catalogue cards and similar list tiles (dp).
  EdgeInsets get platformCardPadding => EdgeInsets.symmetric(
        horizontal: enlarged ? 20 : 16,
        vertical: enlarged ? 18 : 12,
      );

  /// Gap between catalogue cards in the masonry grid (dp).
  double get platformCardGridSpacing => enlarged ? 20 : 16;

  /// Base max cross-axis extent before text scaling (dp).
  double get platformCardMaxCrossAxisExtent => enlarged ? 480 : 400;

  /// Added to card title/body font sizes when [enlarged].
  double get platformCardTextSizeBump => enlarged ? 2 : 0;

  /// Default sizing when the setting is off.
  static const standard = AppTouchTargetSizes(
    enlarged: false,
    buttonMinHeight: 40,
    buttonIconSize: 24,
    inlineIconSize: 18,
    navigationBarHeight: 80,
    navigationIconSize: 24,
  );

  /// Enlarged sizing for field / gloved use.
  static const large = AppTouchTargetSizes(
    enlarged: true,
    buttonMinHeight: 56,
    buttonIconSize: 28,
    inlineIconSize: 22,
    navigationBarHeight: 96,
    navigationIconSize: 32,
  );

  @override
  AppTouchTargetSizes copyWith({
    bool? enlarged,
    double? buttonMinHeight,
    double? buttonIconSize,
    double? inlineIconSize,
    double? navigationBarHeight,
    double? navigationIconSize,
  }) {
    return AppTouchTargetSizes(
      enlarged: enlarged ?? this.enlarged,
      buttonMinHeight: buttonMinHeight ?? this.buttonMinHeight,
      buttonIconSize: buttonIconSize ?? this.buttonIconSize,
      inlineIconSize: inlineIconSize ?? this.inlineIconSize,
      navigationBarHeight: navigationBarHeight ?? this.navigationBarHeight,
      navigationIconSize: navigationIconSize ?? this.navigationIconSize,
    );
  }

  @override
  AppTouchTargetSizes lerp(AppTouchTargetSizes? other, double t) {
    if (other == null) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

/// Reads [AppTouchTargetSizes] from the current theme.
extension AppTouchTargetSizesContext on BuildContext {
  /// Touch-target tokens for the active theme.
  AppTouchTargetSizes get touchTargetSizes =>
      Theme.of(this).extension<AppTouchTargetSizes>() ?? AppTouchTargetSizes.standard;
}

/// Minimum touch target sizes (Material / field use at sea).
abstract final class TouchTargets {
  /// Default Material minimum (dp).
  static const double standardMin = 48;

  /// Enlarged targets for gloved use (dp).
  static const double largeMin = 56;

  /// Applies button, icon, and list tile sizing for easier tapping.
  static ThemeData apply(ThemeData theme, {required bool large}) {
    if (!large) {
      return theme;
    }

    const sizes = AppTouchTargetSizes.large;
    const iconButtonMin = Size(largeMin, largeMin);
    const buttonMin = Size(64, largeMin);

    final enlargedLabel = theme.textTheme.labelLarge?.copyWith(
      fontSize: (theme.textTheme.labelLarge?.fontSize ?? 14) + 2,
      height: 1.25,
    );

    ButtonStyle enlargedButton(ButtonStyle? base) {
      return (base ?? const ButtonStyle()).copyWith(
        minimumSize: WidgetStateProperty.all(buttonMin),
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textStyle: WidgetStatePropertyAll(enlargedLabel),
        iconSize: WidgetStateProperty.all(sizes.buttonIconSize),
      );
    }

    return theme.copyWith(
      extensions: [...theme.extensions.values, sizes],
      visualDensity: VisualDensity.standard,
      iconTheme: theme.iconTheme.copyWith(size: sizes.buttonIconSize),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: iconButtonMin,
          tapTargetSize: MaterialTapTargetSize.padded,
          iconSize: sizes.buttonIconSize,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: enlargedButton(theme.filledButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: enlargedButton(theme.elevatedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: enlargedButton(theme.textButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: enlargedButton(theme.outlinedButtonTheme.style),
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        height: sizes.navigationBarHeight,
        iconTheme: WidgetStatePropertyAll(IconThemeData(size: sizes.navigationIconSize)),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      chipTheme: theme.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        labelStyle: theme.textTheme.labelLarge,
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        extendedSizeConstraints: BoxConstraints(
          minWidth: 168,
          minHeight: sizes.buttonMinHeight,
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        extendedIconLabelSpacing: 12,
        extendedTextStyle: enlargedLabel,
        sizeConstraints: BoxConstraints.tightFor(
          width: sizes.buttonMinHeight,
          height: sizes.buttonMinHeight,
        ),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: largeMin,
          height: largeMin,
        ),
      ),
    );
  }
}
