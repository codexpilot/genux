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

import '../json/gux_color_codec.dart';

/// Visual styling for [GuxBadge].
class GuxBadgeStyle {
  /// Background color of the badge.
  final Color backgroundColor;

  /// Text color.
  final Color textColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius in pixels.
  final double borderRadius;

  /// Padding inside the badge.
  final EdgeInsets padding;

  /// Text size.
  final double fontSize;

  /// Font weight.
  final FontWeight fontWeight;

  const GuxBadgeStyle({
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.textColor = const Color(0xFF1F2937),
    this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    this.fontSize = 12.0,
    this.fontWeight = FontWeight.w500,
  });

  /// Creates a badge style from JSON.
  factory GuxBadgeStyle.fromJson(Map<String, dynamic> json) {
    return GuxBadgeStyle(
      backgroundColor: json['backgroundColor'] != null
          ? GuxColorCodec.parse(json['backgroundColor'] as String)
          : const Color(0xFFE5E7EB),
      textColor: json['textColor'] != null
          ? GuxColorCodec.parse(json['textColor'] as String)
          : const Color(0xFF1F2937),
      borderColor: json['borderColor'] != null
          ? GuxColorCodec.parse(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 4.0,
      padding: json['padding'] != null
          ? _parsePadding(json['padding'] as Map<String, dynamic>)
          : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 12.0,
      fontWeight: _parseFontWeight(json['fontWeight'] as String?),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': GuxColorCodec.toHex(backgroundColor),
      'textColor': GuxColorCodec.toHex(textColor),
      if (borderColor != null) 'borderColor': GuxColorCodec.toHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': {
        'horizontal': padding.horizontal / 2,
        'vertical': padding.vertical / 2,
      },
      'fontSize': fontSize,
      'fontWeight': _fontWeightToString(fontWeight),
    };
  }



  static EdgeInsets _parsePadding(Map<String, dynamic> json) {
    if (json.containsKey('horizontal') && json.containsKey('vertical')) {
      return EdgeInsets.symmetric(
        horizontal: (json['horizontal'] as num).toDouble(),
        vertical: (json['vertical'] as num).toDouble(),
      );
    }
    return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0);
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
        return FontWeight.w500;
    }
  }

  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.normal) return 'normal';
    if (weight == FontWeight.bold) return 'bold';
    return 'w${weight.value}';
  }
}

/// A small badge label for displaying status, count, or category.
///
/// Inspired by shadcn/ui Badge component. Commonly used for tags,
/// status indicators, or notification counts.
///
/// Example:
/// ```dart
/// GuxBadge(
///   label: 'New',
///   style: GuxBadgeStyle(
///     backgroundColor: Color(0xFF3B82F6),
///     textColor: Color(0xFFFFFFFF),
///   ),
/// )
/// ```
class GuxBadge extends StatelessWidget {
  /// Text label to display.
  final String label;

  /// Visual styling for the badge.
  final GuxBadgeStyle style;

  const GuxBadge({
    super.key,
    required this.label,
    required this.style,
  });

  /// Creates a badge from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxBadge.fromJson({
  ///   'label': 'New',
  ///   'style': {
  ///     'backgroundColor': '#3B82F6',
  ///     'textColor': '#FFFFFF',
  ///   },
  /// })
  /// ```
  factory GuxBadge.fromJson(Map<String, dynamic> json) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxBadge(
      label: json['label'] as String? ?? '',
      style: styleJson != null
          ? GuxBadgeStyle.fromJson(styleJson)
          : const GuxBadgeStyle(),
    );
  }

  /// Converts this badge to JSON.
  Map<String, dynamic> toJson() {
    return {
      'label': label,
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
      ),
      child: Text(
        label,
        style: TextStyle(
          color: style.textColor,
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          height: 1.0,
        ),
      ),
    );
  }
}
