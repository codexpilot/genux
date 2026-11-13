import 'package:flutter/widgets.dart';

/// Utilities for parsing and serializing common Flutter types to/from JSON.
///
/// Used by all Gux components for JSON serialization support.
class GuxJsonUtils {
  GuxJsonUtils._();

  // ============================================================================
  // Color Parsing
  // ============================================================================

  /// Parse a color from various formats:
  /// - Hex string: '#RRGGBB', '#AARRGGBB', '0xRRGGBB', '0xAARRGGBB'
  /// - RGB string: 'rgb(r, g, b)'
  /// - RGBA string: 'rgba(r, g, b, a)'
  /// - Named color: 'red', 'blue', 'transparent', etc.
  /// - Number: 0xAARRGGBB
  ///
  /// Returns null if value is null or cannot be parsed.
  static Color? parseColor(dynamic value) {
    if (value == null) return null;

    if (value is Color) return value;
    if (value is int) return Color(value);

    if (value is String) {
      final trimmed = value.trim().toLowerCase();

      // Hex format: #RRGGBB or #AARRGGBB
      if (trimmed.startsWith('#')) {
        final hex = trimmed.substring(1);
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }

      // 0x format: 0xRRGGBB or 0xAARRGGBB
      if (trimmed.startsWith('0x')) {
        final hex = trimmed.substring(2);
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }

      // rgb(r, g, b)
      final rgbMatch = RegExp(r'rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)')
          .firstMatch(trimmed);
      if (rgbMatch != null) {
        final r = int.parse(rgbMatch.group(1)!);
        final g = int.parse(rgbMatch.group(2)!);
        final b = int.parse(rgbMatch.group(3)!);
        return Color.fromARGB(255, r, g, b);
      }

      // rgba(r, g, b, a)
      final rgbaMatch = RegExp(
              r'rgba\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)')
          .firstMatch(trimmed);
      if (rgbaMatch != null) {
        final r = int.parse(rgbaMatch.group(1)!);
        final g = int.parse(rgbaMatch.group(2)!);
        final b = int.parse(rgbaMatch.group(3)!);
        final a = (double.parse(rgbaMatch.group(4)!) * 255).round();
        return Color.fromARGB(a, r, g, b);
      }

      // Named colors
      return _namedColors[trimmed];
    }

    return null;
  }

  /// Convert a Color to hex string format: #AARRGGBB
  static String colorToString(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static final Map<String, Color> _namedColors = {
    'transparent': const Color(0x00000000),
    'black': const Color(0xFF000000),
    'white': const Color(0xFFFFFFFF),
    'red': const Color(0xFFFF0000),
    'green': const Color(0xFF00FF00),
    'blue': const Color(0xFF0000FF),
    'yellow': const Color(0xFFFFFF00),
    'cyan': const Color(0xFF00FFFF),
    'magenta': const Color(0xFFFF00FF),
    'gray': const Color(0xFF808080),
    'grey': const Color(0xFF808080),
    'orange': const Color(0xFFFFA500),
    'purple': const Color(0xFF800080),
    'pink': const Color(0xFFFFC0CB),
    'brown': const Color(0xFFA52A2A),
  };

  // ============================================================================
  // EdgeInsets Parsing
  // ============================================================================

  /// Parse EdgeInsets from various formats:
  /// - Number: all sides (e.g., 16.0 -> EdgeInsets.all(16.0))
  /// - Object with 'all': EdgeInsets.all(value)
  /// - Object with 'horizontal', 'vertical': EdgeInsets.symmetric()
  /// - Object with 'left', 'top', 'right', 'bottom': EdgeInsets.only()
  ///
  /// Returns null if value is null.
  static EdgeInsets? parseEdgeInsets(dynamic value) {
    if (value == null) return null;

    if (value is EdgeInsets) return value;

    // Number: all sides
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }

    if (value is Map<String, dynamic>) {
      // {all: 16}
      if (value.containsKey('all')) {
        return EdgeInsets.all((value['all'] as num).toDouble());
      }

      // {horizontal: 16, vertical: 8}
      if (value.containsKey('horizontal') || value.containsKey('vertical')) {
        return EdgeInsets.symmetric(
          horizontal: (value['horizontal'] as num?)?.toDouble() ?? 0.0,
          vertical: (value['vertical'] as num?)?.toDouble() ?? 0.0,
        );
      }

      // {left: 8, top: 4, right: 8, bottom: 4}
      return EdgeInsets.only(
        left: (value['left'] as num?)?.toDouble() ?? 0.0,
        top: (value['top'] as num?)?.toDouble() ?? 0.0,
        right: (value['right'] as num?)?.toDouble() ?? 0.0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return null;
  }

  /// Convert EdgeInsets to JSON object
  static Map<String, dynamic> edgeInsetsToJson(EdgeInsetsGeometry insets) {
    if (insets is EdgeInsets) {
      // Check if all sides are equal
      if (insets.left == insets.top &&
          insets.left == insets.right &&
          insets.left == insets.bottom) {
        return {'all': insets.left};
      }

      // Check if symmetric
      if (insets.left == insets.right && insets.top == insets.bottom) {
        return {
          'horizontal': insets.left,
          'vertical': insets.top,
        };
      }

      // Full specification
      return {
        'left': insets.left,
        'top': insets.top,
        'right': insets.right,
        'bottom': insets.bottom,
      };
    }

    // Fallback for EdgeInsetsDirectional or other types
    return {'all': 0.0};
  }

  // ============================================================================
  // BorderRadius Parsing
  // ============================================================================

  /// Parse BorderRadius from various formats:
  /// - Number: circular with given radius
  /// - Object with 'circular': BorderRadius.circular(value)
  /// - Object with 'topLeft', 'topRight', 'bottomLeft', 'bottomRight': BorderRadius.only()
  ///
  /// Returns null if value is null.
  static BorderRadius? parseBorderRadius(dynamic value) {
    if (value == null) return null;

    if (value is BorderRadius) return value;

    // Number: circular
    if (value is num) {
      return BorderRadius.circular(value.toDouble());
    }

    if (value is Map<String, dynamic>) {
      // {circular: 8}
      if (value.containsKey('circular')) {
        return BorderRadius.circular((value['circular'] as num).toDouble());
      }

      // {topLeft: 8, topRight: 8, bottomLeft: 0, bottomRight: 0}
      return BorderRadius.only(
        topLeft: Radius.circular((value['topLeft'] as num?)?.toDouble() ?? 0.0),
        topRight:
            Radius.circular((value['topRight'] as num?)?.toDouble() ?? 0.0),
        bottomLeft:
            Radius.circular((value['bottomLeft'] as num?)?.toDouble() ?? 0.0),
        bottomRight:
            Radius.circular((value['bottomRight'] as num?)?.toDouble() ?? 0.0),
      );
    }

    return null;
  }

  /// Convert BorderRadius to JSON object
  static Map<String, dynamic> borderRadiusToJson(BorderRadiusGeometry radius) {
    if (radius is BorderRadius) {
      // Check if all corners are circular with same radius
      if (radius.topLeft == radius.topRight &&
          radius.topLeft == radius.bottomLeft &&
          radius.topLeft == radius.bottomRight &&
          radius.topLeft.x == radius.topLeft.y) {
        return {'circular': radius.topLeft.x};
      }

      // Full specification
      return {
        'topLeft': radius.topLeft.x,
        'topRight': radius.topRight.x,
        'bottomLeft': radius.bottomLeft.x,
        'bottomRight': radius.bottomRight.x,
      };
    }

    return {'circular': 0.0};
  }

  // ============================================================================
  // TextStyle Parsing
  // ============================================================================

  /// Parse TextStyle from JSON object
  static TextStyle? parseTextStyle(Map<String, dynamic>? json) {
    if (json == null) return null;

    return TextStyle(
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontWeight: _parseFontWeight(json['fontWeight']),
      fontStyle: json['fontStyle'] == 'italic'
          ? FontStyle.italic
          : json['fontStyle'] == 'normal'
              ? FontStyle.normal
              : null,
      color: parseColor(json['color']),
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
      wordSpacing: (json['wordSpacing'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      decoration: _parseTextDecoration(json['decoration']),
      decorationColor: parseColor(json['decorationColor']),
      fontFamily: json['fontFamily'] as String?,
    );
  }

  /// Convert TextStyle to JSON object
  static Map<String, dynamic> textStyleToJson(TextStyle style) {
    final json = <String, dynamic>{};

    if (style.fontSize != null) json['fontSize'] = style.fontSize;
    if (style.fontWeight != null) {
      json['fontWeight'] = _fontWeightToString(style.fontWeight!);
    }
    if (style.fontStyle != null) {
      json['fontStyle'] =
          style.fontStyle == FontStyle.italic ? 'italic' : 'normal';
    }
    if (style.color != null) json['color'] = colorToString(style.color!);
    if (style.letterSpacing != null) json['letterSpacing'] = style.letterSpacing;
    if (style.wordSpacing != null) json['wordSpacing'] = style.wordSpacing;
    if (style.height != null) json['height'] = style.height;
    if (style.decoration != null) {
      json['decoration'] = _textDecorationToString(style.decoration!);
    }
    if (style.decorationColor != null) {
      json['decorationColor'] = colorToString(style.decorationColor!);
    }
    if (style.fontFamily != null) json['fontFamily'] = style.fontFamily;

    return json;
  }

  static FontWeight? _parseFontWeight(dynamic value) {
    if (value == null) return null;
    if (value is FontWeight) return value;

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'thin':
        case '100':
          return FontWeight.w100;
        case 'extralight':
        case '200':
          return FontWeight.w200;
        case 'light':
        case '300':
          return FontWeight.w300;
        case 'normal':
        case 'regular':
        case '400':
          return FontWeight.w400;
        case 'medium':
        case '500':
          return FontWeight.w500;
        case 'semibold':
        case '600':
          return FontWeight.w600;
        case 'bold':
        case '700':
          return FontWeight.w700;
        case 'extrabold':
        case '800':
          return FontWeight.w800;
        case 'black':
        case '900':
          return FontWeight.w900;
      }
    }

    if (value is int) {
      return FontWeight.values[(value ~/ 100 - 1).clamp(0, 8)];
    }

    return null;
  }

  static String _fontWeightToString(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100:
        return '100';
      case FontWeight.w200:
        return '200';
      case FontWeight.w300:
        return '300';
      case FontWeight.w400:
        return '400';
      case FontWeight.w500:
        return '500';
      case FontWeight.w600:
        return '600';
      case FontWeight.w700:
        return '700';
      case FontWeight.w800:
        return '800';
      case FontWeight.w900:
        return '900';
      default:
        return '400';
    }
  }

  static TextDecoration? _parseTextDecoration(dynamic value) {
    if (value == null) return null;
    if (value is TextDecoration) return value;

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'none':
          return TextDecoration.none;
        case 'underline':
          return TextDecoration.underline;
        case 'overline':
          return TextDecoration.overline;
        case 'linethrough':
        case 'line-through':
          return TextDecoration.lineThrough;
      }
    }

    return null;
  }

  static String _textDecorationToString(TextDecoration decoration) {
    if (decoration == TextDecoration.none) return 'none';
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.overline) return 'overline';
    if (decoration == TextDecoration.lineThrough) return 'linethrough';
    return 'none';
  }

  // ============================================================================
  // Size Parsing
  // ============================================================================

  /// Parse Size from various formats:
  /// - Object with 'width', 'height': Size(width, height)
  ///
  /// Returns null if value is null.
  static Size? parseSize(dynamic value) {
    if (value == null) return null;

    if (value is Size) return value;

    if (value is Map<String, dynamic>) {
      return Size(
        (value['width'] as num?)?.toDouble() ?? 0.0,
        (value['height'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return null;
  }

  /// Convert Size to JSON object
  static Map<String, dynamic> sizeToJson(Size size) {
    return {
      'width': size.width,
      'height': size.height,
    };
  }

  // ============================================================================
  // Duration Parsing
  // ============================================================================

  /// Parse Duration from various formats:
  /// - Number: milliseconds
  /// - String: '500ms', '1s', '1.5s'
  ///
  /// Returns null if value is null.
  static Duration? parseDuration(dynamic value) {
    if (value == null) return null;

    if (value is Duration) return value;

    if (value is num) {
      return Duration(milliseconds: value.toInt());
    }

    if (value is String) {
      final trimmed = value.trim().toLowerCase();

      // milliseconds: '500ms'
      if (trimmed.endsWith('ms')) {
        final ms = int.tryParse(trimmed.substring(0, trimmed.length - 2));
        if (ms != null) return Duration(milliseconds: ms);
      }

      // seconds: '1s', '1.5s'
      if (trimmed.endsWith('s')) {
        final s = double.tryParse(trimmed.substring(0, trimmed.length - 1));
        if (s != null) return Duration(milliseconds: (s * 1000).toInt());
      }
    }

    return null;
  }

  /// Convert Duration to string format: '500ms'
  static String durationToString(Duration duration) {
    return '${duration.inMilliseconds}ms';
  }
}
