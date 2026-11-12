// Copyright 2025 AIX Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';

/// Visual styling for [GuxToast].
class GuxToastStyle {
  /// Background color of the toast.
  final Color backgroundColor;

  /// Text color for the message.
  final Color textColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius in pixels.
  final double borderRadius;

  /// Padding inside the toast.
  final EdgeInsets padding;

  /// Font size for the message.
  final double fontSize;

  /// Font weight for the message.
  final FontWeight fontWeight;

  /// Shadow elevation (0 = no shadow).
  final double elevation;

  /// Shadow color.
  final Color shadowColor;

  const GuxToastStyle({
    this.backgroundColor = const Color(0xFF1F2937),
    this.textColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w400,
    this.elevation = 4.0,
    this.shadowColor = const Color(0x33000000),
  });

  /// Creates a toast style from JSON.
  factory GuxToastStyle.fromJson(Map<String, dynamic> json) {
    return GuxToastStyle(
      backgroundColor: json['backgroundColor'] != null
          ? _parseColor(json['backgroundColor'] as String)
          : const Color(0xFF1F2937),
      textColor: json['textColor'] != null
          ? _parseColor(json['textColor'] as String)
          : const Color(0xFFFFFFFF),
      borderColor: json['borderColor'] != null
          ? _parseColor(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 6.0,
      padding: json['padding'] != null
          ? _parsePadding(json['padding'] as Map<String, dynamic>)
          : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      fontWeight: _parseFontWeight(json['fontWeight'] as String?),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 4.0,
      shadowColor: json['shadowColor'] != null
          ? _parseColor(json['shadowColor'] as String)
          : const Color(0x33000000),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': _colorToHex(backgroundColor),
      'textColor': _colorToHex(textColor),
      if (borderColor != null) 'borderColor': _colorToHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': {
        'horizontal': padding.horizontal / 2,
        'vertical': padding.vertical / 2,
      },
      'fontSize': fontSize,
      'fontWeight': _fontWeightToString(fontWeight),
      'elevation': elevation,
      'shadowColor': _colorToHex(shadowColor),
    };
  }

  static Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${argb.substring(2)}'; // Remove alpha channel
  }

  static EdgeInsets _parsePadding(Map<String, dynamic> json) {
    if (json.containsKey('horizontal') && json.containsKey('vertical')) {
      return EdgeInsets.symmetric(
        horizontal: (json['horizontal'] as num).toDouble(),
        vertical: (json['vertical'] as num).toDouble(),
      );
    }
    return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  }

  static FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case 'normal':
        return FontWeight.normal;
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.normal) return 'normal';
    if (weight == FontWeight.bold) return 'bold';
    return 'w${weight.value}';
  }
}

/// A temporary notification message displayed as a toast.
///
/// Inspired by shadcn/ui Toast component. Used for brief notifications,
/// success messages, errors, or informational updates that appear temporarily.
///
/// Example:
/// ```dart
/// GuxToast(
///   message: 'Item saved successfully',
///   style: GuxToastStyle(
///     backgroundColor: Color(0xFF10B981),
///     textColor: Color(0xFFFFFFFF),
///   ),
/// )
/// ```
class GuxToast extends StatelessWidget {
  /// Message text to display.
  final String message;

  /// Visual styling for the toast.
  final GuxToastStyle style;

  const GuxToast({
    super.key,
    required this.message,
    required this.style,
  });

  /// Creates a toast from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxToast.fromJson({
  ///   'message': 'Item saved successfully',
  ///   'style': {
  ///     'backgroundColor': '#10B981',
  ///     'textColor': '#FFFFFF',
  ///   },
  /// })
  /// ```
  factory GuxToast.fromJson(Map<String, dynamic> json) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxToast(
      message: json['message'] as String? ?? '',
      style: styleJson != null
          ? GuxToastStyle.fromJson(styleJson)
          : const GuxToastStyle(),
    );
  }

  /// Converts this toast to JSON.
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'style': style.toJson(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: style.padding,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        border: style.borderWidth > 0 && style.borderColor != null
            ? Border.all(
                color: style.borderColor!,
                width: style.borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(style.borderRadius),
        boxShadow: style.elevation > 0
            ? [
                BoxShadow(
                  color: style.shadowColor,
                  blurRadius: style.elevation * 2,
                  offset: Offset(0, style.elevation),
                ),
              ]
            : null,
      ),
      child: Text(
        message,
        style: TextStyle(
          color: style.textColor,
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          height: 1.2,
        ),
      ),
    );
  }
}
