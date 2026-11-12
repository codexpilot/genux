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

/// Visual styling for [GuxAlert].
class GuxAlertStyle {
  /// Background color of the alert.
  final Color backgroundColor;

  /// Text color for the message.
  final Color textColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius in pixels.
  final double borderRadius;

  /// Padding inside the alert.
  final EdgeInsets padding;

  /// Font size for the message.
  final double fontSize;

  /// Font weight for the message.
  final FontWeight fontWeight;

  /// Icon color (if icon is present).
  final Color? iconColor;

  /// Icon size in pixels.
  final double iconSize;

  const GuxAlertStyle({
    this.backgroundColor = const Color(0xFFF3F4F6),
    this.textColor = const Color(0xFF1F2937),
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w400,
    this.iconColor,
    this.iconSize = 20.0,
  });

  /// Creates an alert style from JSON.
  factory GuxAlertStyle.fromJson(Map<String, dynamic> json) {
    return GuxAlertStyle(
      backgroundColor: json['backgroundColor'] != null
          ? _parseColor(json['backgroundColor'] as String)
          : const Color(0xFFF3F4F6),
      textColor: json['textColor'] != null
          ? _parseColor(json['textColor'] as String)
          : const Color(0xFF1F2937),
      borderColor: json['borderColor'] != null
          ? _parseColor(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      padding: json['padding'] != null
          ? _parsePadding(json['padding'] as Map<String, dynamic>)
          : const EdgeInsets.all(16.0),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      fontWeight: _parseFontWeight(json['fontWeight'] as String?),
      iconColor: json['iconColor'] != null
          ? _parseColor(json['iconColor'] as String)
          : null,
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 20.0,
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
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom,
      },
      'fontSize': fontSize,
      'fontWeight': _fontWeightToString(fontWeight),
      if (iconColor != null) 'iconColor': _colorToHex(iconColor!),
      'iconSize': iconSize,
    };
  }

  static Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  static EdgeInsets _parsePadding(Map<String, dynamic> json) {
    if (json.containsKey('all')) {
      return EdgeInsets.all((json['all'] as num).toDouble());
    }
    return EdgeInsets.only(
      left: (json['left'] as num?)?.toDouble() ?? 0,
      top: (json['top'] as num?)?.toDouble() ?? 0,
      right: (json['right'] as num?)?.toDouble() ?? 0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
    );
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

/// A prominent message box for displaying important information.
///
/// Inspired by shadcn/ui Alert component. Used for notifications,
/// warnings, errors, or informational messages that need user attention.
///
/// Example:
/// ```dart
/// GuxAlert(
///   message: 'Your changes have been saved successfully.',
///   style: GuxAlertStyle(
///     backgroundColor: Color(0xFFDCFCE7),
///     textColor: Color(0xFF166534),
///     borderColor: Color(0xFF86EFAC),
///   ),
/// )
/// ```
class GuxAlert extends StatelessWidget {
  /// The message text to display.
  final String message;

  /// Optional title text displayed above the message.
  final String? title;

  /// Optional icon widget to display before the message.
  final Widget? icon;

  /// Visual styling for the alert.
  final GuxAlertStyle style;

  const GuxAlert({
    super.key,
    required this.message,
    this.title,
    this.icon,
    required this.style,
  });

  /// Creates an alert from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxAlert.fromJson({
  ///   'message': 'Your changes have been saved.',
  ///   'title': 'Success',
  ///   'style': {
  ///     'backgroundColor': '#DCFCE7',
  ///     'textColor': '#166534',
  ///     'borderColor': '#86EFAC',
  ///   },
  /// })
  /// ```
  factory GuxAlert.fromJson(Map<String, dynamic> json) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxAlert(
      message: json['message'] as String? ?? '',
      title: json['title'] as String?,
      style: styleJson != null
          ? GuxAlertStyle.fromJson(styleJson)
          : const GuxAlertStyle(),
    );
  }

  /// Converts this alert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (title != null) 'title': title,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: SizedBox(
                width: style.iconSize,
                height: style.iconSize,
                child: icon,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      title!,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: style.fontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: style.fontSize,
                    fontWeight: style.fontWeight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
