/// Theme system for Genux following shadcn/ui design principles.
///
/// Based on https://ui.shadcn.com/themes
library;

import 'package:flutter/widgets.dart';

import 'display/gux_accordion.dart';
import 'display/gux_tabs.dart';
import 'forms/gux_date_time_picker.dart';
import 'forms/gux_file_picker.dart';
import 'theme/gux_color_schemes.dart';

export 'theme/gux_color_schemes.dart';

/// Border radius presets following shadcn/ui conventions.
enum GuxRadius {
  none(0.0),
  small(0.3),
  medium(0.5),
  large(0.75),
  full(1.0);

  final double value;
  const GuxRadius(this.value);

  String toJson() => name;

  static GuxRadius fromJson(String json) {
    return GuxRadius.values.firstWhere(
      (e) => e.name == json,
      orElse: () => GuxRadius.medium,
    );
  }
}

/// Complete theme configuration for Genux applications.
///
/// Combines color scheme and radius settings with JSON serialization support.
class GuxTheme {
  final String name;
  final GuxColorScheme colorScheme;
  final GuxRadius radius;

  const GuxTheme({
    required this.name,
    required this.colorScheme,
    required this.radius,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'colorScheme': colorScheme.toJson(),
    'radius': radius.toJson(),
  };

  factory GuxTheme.fromJson(Map<String, dynamic> json) {
    return GuxTheme(
      name: json['name'] as String,
      colorScheme: GuxColorScheme.fromJson(
        json['colorScheme'] as Map<String, dynamic>,
      ),
      radius: GuxRadius.fromJson(json['radius'] as String),
    );
  }

  /// Get border radius for the theme.
  BorderRadius getBorderRadius() {
    return BorderRadius.circular(radius.value * 8);
  }
}

/// Explicit mapping from theme tokens to component styles.
///
/// Themes do not change existing widgets implicitly. Hosts pass these styles
/// to each widget, so overrides remain local and predictable.
class GuxThemeStyles {
  const GuxThemeStyles(this.theme);
  final GuxTheme theme;

  GuxDateTimePickerStyle get dateTimePicker => GuxDateTimePickerStyle(
    backgroundColor: theme.colorScheme.background,
    textColor: theme.colorScheme.foreground,
    selectedColor: theme.colorScheme.primary,
    selectedTextColor: theme.colorScheme.primaryForeground,
    disabledColor: theme.colorScheme.mutedForeground,
    borderColor: theme.colorScheme.border,
    hoverColor: theme.colorScheme.muted,
    borderRadius: theme.radius.value * 8,
  );

  GuxFilePickerStyle get filePicker => GuxFilePickerStyle(
    backgroundColor: theme.colorScheme.background,
    textColor: theme.colorScheme.foreground,
    disabledColor: theme.colorScheme.mutedForeground,
    borderColor: theme.colorScheme.border,
    hoverColor: theme.colorScheme.muted,
    borderRadius: theme.radius.value * 8,
  );

  GuxTabsStyle get tabs => GuxTabsStyle(
    backgroundColor: theme.colorScheme.muted,
    activeTabColor: theme.colorScheme.background,
    activeTextColor: theme.colorScheme.foreground,
    inactiveTextColor: theme.colorScheme.mutedForeground,
    borderColor: theme.colorScheme.border,
    indicatorColor: theme.colorScheme.primary,
    borderRadius: theme.radius.value * 8,
  );

  GuxAccordionStyle get accordion => GuxAccordionStyle(
    backgroundColor: theme.colorScheme.background,
    expandedBackgroundColor: theme.colorScheme.muted,
    borderColor: theme.colorScheme.border,
    headerTextColor: theme.colorScheme.foreground,
    contentTextColor: theme.colorScheme.foreground,
    iconColor: theme.colorScheme.foreground,
    borderRadius: theme.radius.value * 8,
  );
}

/// Pre-built themes based on shadcn/ui color schemes.
class GuxThemes {
  static const defaultTheme = GuxTheme(
    name: 'default',
    colorScheme: GuxColorSchemes.zinc,
    radius: GuxRadius.medium,
  );

  static const slate = GuxTheme(
    name: 'slate',
    colorScheme: GuxColorSchemes.slate,
    radius: GuxRadius.medium,
  );

  static const stone = GuxTheme(
    name: 'stone',
    colorScheme: GuxColorSchemes.stone,
    radius: GuxRadius.medium,
  );

  static const gray = GuxTheme(
    name: 'gray',
    colorScheme: GuxColorSchemes.gray,
    radius: GuxRadius.medium,
  );

  static const zinc = GuxTheme(
    name: 'zinc',
    colorScheme: GuxColorSchemes.zinc,
    radius: GuxRadius.medium,
  );

  static const neutral = GuxTheme(
    name: 'neutral',
    colorScheme: GuxColorSchemes.neutral,
    radius: GuxRadius.medium,
  );

  static const red = GuxTheme(
    name: 'red',
    colorScheme: GuxColorSchemes.red,
    radius: GuxRadius.medium,
  );

  static const rose = GuxTheme(
    name: 'rose',
    colorScheme: GuxColorSchemes.rose,
    radius: GuxRadius.medium,
  );

  static const orange = GuxTheme(
    name: 'orange',
    colorScheme: GuxColorSchemes.orange,
    radius: GuxRadius.medium,
  );

  static const green = GuxTheme(
    name: 'green',
    colorScheme: GuxColorSchemes.green,
    radius: GuxRadius.medium,
  );

  static const blue = GuxTheme(
    name: 'blue',
    colorScheme: GuxColorSchemes.blue,
    radius: GuxRadius.medium,
  );

  static const yellow = GuxTheme(
    name: 'yellow',
    colorScheme: GuxColorSchemes.yellow,
    radius: GuxRadius.medium,
  );

  static const violet = GuxTheme(
    name: 'violet',
    colorScheme: GuxColorSchemes.violet,
    radius: GuxRadius.medium,
  );

  /// All available pre-built themes.
  static const Map<String, GuxTheme> all = {
    'default': defaultTheme,
    'slate': slate,
    'stone': stone,
    'gray': gray,
    'zinc': zinc,
    'neutral': neutral,
    'red': red,
    'rose': rose,
    'orange': orange,
    'green': green,
    'blue': blue,
    'yellow': yellow,
    'violet': violet,
  };
}
