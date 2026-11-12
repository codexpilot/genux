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

/// Visual styling for [GuxCard].
class GuxCardStyle {
  /// Background color of the card.
  final Color backgroundColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius in pixels.
  final double borderRadius;

  /// Padding inside the card.
  final EdgeInsets padding;

  /// Shadow elevation (0 = no shadow).
  final double elevation;

  /// Shadow color.
  final Color shadowColor;

  const GuxCardStyle({
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 2.0,
    this.shadowColor = const Color(0x1A000000),
  });

  /// Creates a card style from JSON.
  factory GuxCardStyle.fromJson(Map<String, dynamic> json) {
    return GuxCardStyle(
      backgroundColor: json['backgroundColor'] != null
          ? _parseColor(json['backgroundColor'] as String)
          : const Color(0xFFFFFFFF),
      borderColor: json['borderColor'] != null
          ? _parseColor(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      padding: json['padding'] != null
          ? _parsePadding(json['padding'] as Map<String, dynamic>)
          : const EdgeInsets.all(16.0),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 2.0,
      shadowColor: json['shadowColor'] != null
          ? _parseColor(json['shadowColor'] as String)
          : const Color(0x1A000000),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': _colorToHex(backgroundColor),
      if (borderColor != null) 'borderColor': _colorToHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': {
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom,
      },
      'elevation': elevation,
      'shadowColor': _colorToHex(shadowColor),
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
}

/// A card container with border, padding, and optional shadow.
///
/// Inspired by shadcn/ui Card component. Provides a styled container
/// for grouping related content with consistent visual treatment.
///
/// Example:
/// ```dart
/// GuxCard(
///   style: GuxCardStyle(
///     backgroundColor: Color(0xFFFFFFFF),
///     borderRadius: 8.0,
///     elevation: 2.0,
///   ),
///   child: Column(
///     children: [
///       Text('Card Title'),
///       Text('Card content goes here'),
///     ],
///   ),
/// )
/// ```
class GuxCard extends StatelessWidget {
  /// Visual styling for the card.
  final GuxCardStyle style;

  /// Child widget to display inside the card.
  final Widget child;

  const GuxCard({
    super.key,
    required this.style,
    required this.child,
  });

  /// Creates a card from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxCard.fromJson({
  ///   'style': {
  ///     'backgroundColor': '#FFFFFF',
  ///     'borderRadius': 8.0,
  ///     'elevation': 2.0,
  ///   },
  ///   'child': {'type': 'Text', 'data': 'Content'},
  /// })
  /// ```
  factory GuxCard.fromJson(
    Map<String, dynamic> json, {
    Map<String, VoidCallback>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;
    final childJson = json['child'];

    return GuxCard(
      style: styleJson != null
          ? GuxCardStyle.fromJson(styleJson)
          : const GuxCardStyle(),
      child: childJson != null && childJson is Map<String, dynamic>
          ? _buildChildFromJson(childJson)
          : const SizedBox.shrink(),
    );
  }

  static Widget _buildChildFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'Text') {
      return Text(json['data'] as String? ?? '');
    }
    // Add more widget types as needed
    return const SizedBox.shrink();
  }

  /// Converts this card to JSON.
  Map<String, dynamic> toJson() {
    return {
      'style': style.toJson(),
      'child': {
        'type': 'Widget',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget result = Container(
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
      child: child,
    );

    return result;
  }
}
