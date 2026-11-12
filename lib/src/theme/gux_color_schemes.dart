/// Shadcn/ui inspired color schemes for Genux.
///
/// Based on https://ui.shadcn.com/themes
library;

import 'package:flutter/widgets.dart';

/// A single color scheme following shadcn/ui design system.
class GuxColorScheme {
  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color border;
  final Color input;
  final Color ring;

  const GuxColorScheme({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
  });

  Map<String, dynamic> toJson() => {
        'background': _colorToHex(background),
        'foreground': _colorToHex(foreground),
        'card': _colorToHex(card),
        'cardForeground': _colorToHex(cardForeground),
        'popover': _colorToHex(popover),
        'popoverForeground': _colorToHex(popoverForeground),
        'primary': _colorToHex(primary),
        'primaryForeground': _colorToHex(primaryForeground),
        'secondary': _colorToHex(secondary),
        'secondaryForeground': _colorToHex(secondaryForeground),
        'muted': _colorToHex(muted),
        'mutedForeground': _colorToHex(mutedForeground),
        'accent': _colorToHex(accent),
        'accentForeground': _colorToHex(accentForeground),
        'destructive': _colorToHex(destructive),
        'destructiveForeground': _colorToHex(destructiveForeground),
        'border': _colorToHex(border),
        'input': _colorToHex(input),
        'ring': _colorToHex(ring),
      };

  factory GuxColorScheme.fromJson(Map<String, dynamic> json) {
    return GuxColorScheme(
      background: _hexToColor(json['background'] as String),
      foreground: _hexToColor(json['foreground'] as String),
      card: _hexToColor(json['card'] as String),
      cardForeground: _hexToColor(json['cardForeground'] as String),
      popover: _hexToColor(json['popover'] as String),
      popoverForeground: _hexToColor(json['popoverForeground'] as String),
      primary: _hexToColor(json['primary'] as String),
      primaryForeground: _hexToColor(json['primaryForeground'] as String),
      secondary: _hexToColor(json['secondary'] as String),
      secondaryForeground: _hexToColor(json['secondaryForeground'] as String),
      muted: _hexToColor(json['muted'] as String),
      mutedForeground: _hexToColor(json['mutedForeground'] as String),
      accent: _hexToColor(json['accent'] as String),
      accentForeground: _hexToColor(json['accentForeground'] as String),
      destructive: _hexToColor(json['destructive'] as String),
      destructiveForeground:
          _hexToColor(json['destructiveForeground'] as String),
      border: _hexToColor(json['border'] as String),
      input: _hexToColor(json['input'] as String),
      ring: _hexToColor(json['ring'] as String),
    );
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

/// Pre-defined color schemes based on shadcn/ui themes.
class GuxColorSchemes {
  // Zinc (default)
  static const zinc = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFF18181B),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFF18181B),
  );

  // Slate
  static const slate = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF020617),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF020617),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF020617),
    primary: Color(0xFF0F172A),
    primaryForeground: Color(0xFFF8FAFC),
    secondary: Color(0xFFF1F5F9),
    secondaryForeground: Color(0xFF0F172A),
    muted: Color(0xFFF1F5F9),
    mutedForeground: Color(0xFF64748B),
    accent: Color(0xFFF1F5F9),
    accentForeground: Color(0xFF0F172A),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFF8FAFC),
    border: Color(0xFFE2E8F0),
    input: Color(0xFFE2E8F0),
    ring: Color(0xFF0F172A),
  );

  // Stone
  static const stone = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF0C0A09),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF0C0A09),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF0C0A09),
    primary: Color(0xFF1C1917),
    primaryForeground: Color(0xFFFAFAF9),
    secondary: Color(0xFFF5F5F4),
    secondaryForeground: Color(0xFF1C1917),
    muted: Color(0xFFF5F5F4),
    mutedForeground: Color(0xFF78716C),
    accent: Color(0xFFF5F5F4),
    accentForeground: Color(0xFF1C1917),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAF9),
    border: Color(0xFFE7E5E4),
    input: Color(0xFFE7E5E4),
    ring: Color(0xFF1C1917),
  );

  // Gray
  static const gray = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF030712),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF030712),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF030712),
    primary: Color(0xFF111827),
    primaryForeground: Color(0xFFF9FAFB),
    secondary: Color(0xFFF3F4F6),
    secondaryForeground: Color(0xFF111827),
    muted: Color(0xFFF3F4F6),
    mutedForeground: Color(0xFF6B7280),
    accent: Color(0xFFF3F4F6),
    accentForeground: Color(0xFF111827),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFF9FAFB),
    border: Color(0xFFE5E7EB),
    input: Color(0xFFE5E7EB),
    ring: Color(0xFF111827),
  );

  // Neutral
  static const neutral = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF0A0A0A),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF0A0A0A),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF0A0A0A),
    primary: Color(0xFF171717),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF5F5F5),
    secondaryForeground: Color(0xFF171717),
    muted: Color(0xFFF5F5F5),
    mutedForeground: Color(0xFF737373),
    accent: Color(0xFFF5F5F5),
    accentForeground: Color(0xFF171717),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE5E5E5),
    input: Color(0xFFE5E5E5),
    ring: Color(0xFF171717),
  );

  // Red
  static const red = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFFDC2626),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFFDC2626),
  );

  // Rose
  static const rose = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFFE11D48),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFFE11D48),
  );

  // Orange
  static const orange = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFFEA580C),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFFEA580C),
  );

  // Green
  static const green = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFF16A34A),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFF16A34A),
  );

  // Blue
  static const blue = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFF2563EB),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFF2563EB),
  );

  // Yellow
  static const yellow = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFFEAB308),
    primaryForeground: Color(0xFF18181B),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFFEAB308),
  );

  // Violet
  static const violet = GuxColorScheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFF7C3AED),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    destructiveForeground: Color(0xFFFAFAFA),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFF7C3AED),
  );

  /// All available color schemes.
  static const Map<String, GuxColorScheme> all = {
    'zinc': zinc,
    'slate': slate,
    'stone': stone,
    'gray': gray,
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
