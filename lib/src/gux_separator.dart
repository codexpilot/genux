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

/// Visual styling for [GuxSeparator].
class GuxSeparatorStyle {
  /// Color of the separator line.
  final Color color;

  /// Thickness of the separator line in pixels.
  final double thickness;

  /// Spacing around the separator (top and bottom for horizontal, left and right for vertical).
  final double spacing;

  /// Orientation of the separator.
  final Axis orientation;

  const GuxSeparatorStyle({
    this.color = const Color(0xFFE5E7EB),
    this.thickness = 1.0,
    this.spacing = 0.0,
    this.orientation = Axis.horizontal,
  });

  /// Creates a separator style from JSON.
  factory GuxSeparatorStyle.fromJson(Map<String, dynamic> json) {
    return GuxSeparatorStyle(
      color: json['color'] != null
          ? _parseColor(json['color'] as String)
          : const Color(0xFFE5E7EB),
      thickness: (json['thickness'] as num?)?.toDouble() ?? 1.0,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0.0,
      orientation: _parseOrientation(json['orientation'] as String?),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'color': _colorToHex(color),
      'thickness': thickness,
      'spacing': spacing,
      'orientation': _orientationToString(orientation),
    };
  }

  static Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  static Axis _parseOrientation(String? orientation) {
    if (orientation == 'vertical') {
      return Axis.vertical;
    }
    return Axis.horizontal;
  }

  static String _orientationToString(Axis orientation) {
    return orientation == Axis.vertical ? 'vertical' : 'horizontal';
  }
}

/// A visual divider between sections.
///
/// Inspired by shadcn/ui Separator component. Used to create visual
/// separation between content sections with minimal styling.
///
/// Example:
/// ```dart
/// GuxSeparator(
///   style: GuxSeparatorStyle(
///     color: Color(0xFFE5E7EB),
///     thickness: 1.0,
///     spacing: 16.0,
///     orientation: Axis.horizontal,
///   ),
/// )
/// ```
class GuxSeparator extends StatelessWidget {
  /// Visual styling for the separator.
  final GuxSeparatorStyle style;

  const GuxSeparator({
    super.key,
    required this.style,
  });

  /// Creates a separator from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxSeparator.fromJson({
  ///   'style': {
  ///     'color': '#E5E7EB',
  ///     'thickness': 1.0,
  ///     'spacing': 16.0,
  ///     'orientation': 'horizontal',
  ///   },
  /// })
  /// ```
  factory GuxSeparator.fromJson(Map<String, dynamic> json) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxSeparator(
      style: styleJson != null
          ? GuxSeparatorStyle.fromJson(styleJson)
          : const GuxSeparatorStyle(),
    );
  }

  /// Converts this separator to JSON.
  Map<String, dynamic> toJson() {
    return {
      'style': style.toJson(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (style.orientation == Axis.horizontal) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: style.spacing),
        child: Container(
          height: style.thickness,
          color: style.color,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: style.spacing),
        child: Container(
          width: style.thickness,
          color: style.color,
        ),
      );
    }
  }
}
