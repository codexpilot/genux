/// Theme system for Genux following shadcn/ui design principles.
///
/// Based on https://ui.shadcn.com/themes
library;

import 'package:flutter/widgets.dart';
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
