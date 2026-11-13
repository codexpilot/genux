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

/// Visual styling for [GuxSheet].
class GuxSheetStyle {
  /// Background color of the sheet.
  final Color backgroundColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius for top corners in pixels.
  final double borderRadius;

  /// Padding inside the sheet.
  final EdgeInsets padding;

  /// Shadow elevation (0 = no shadow).
  final double elevation;

  /// Shadow color.
  final Color shadowColor;

  /// Maximum height of the sheet as fraction of screen (0.0-1.0).
  final double maxHeightFraction;

  const GuxSheetStyle({
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 8.0,
    this.shadowColor = const Color(0x33000000),
    this.maxHeightFraction = 0.9,
  });

  /// Creates a sheet style from JSON.
  factory GuxSheetStyle.fromJson(Map<String, dynamic> json) {
    return GuxSheetStyle(
      backgroundColor: json['backgroundColor'] != null
          ? GuxColorCodec.parse(json['backgroundColor'] as String)
          : const Color(0xFFFFFFFF),
      borderColor: json['borderColor'] != null
          ? GuxColorCodec.parse(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 16.0,
      padding: json['padding'] != null
          ? _parsePadding(json['padding'] as Map<String, dynamic>)
          : const EdgeInsets.all(16.0),
      elevation: (json['elevation'] as num?)?.toDouble() ?? 8.0,
      shadowColor: json['shadowColor'] != null
          ? GuxColorCodec.parse(json['shadowColor'] as String)
          : const Color(0x33000000),
      maxHeightFraction:
          (json['maxHeightFraction'] as num?)?.toDouble() ?? 0.9,
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': GuxColorCodec.toHex(backgroundColor),
      if (borderColor != null) 'borderColor': GuxColorCodec.toHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'padding': {
        'left': padding.left,
        'top': padding.top,
        'right': padding.right,
        'bottom': padding.bottom,
      },
      'elevation': elevation,
      'shadowColor': GuxColorCodec.toHex(shadowColor),
      'maxHeightFraction': maxHeightFraction,
    };
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

/// A modal bottom sheet that slides up from the bottom of the screen.
///
/// Inspired by shadcn/ui Sheet component. Provides a container for
/// displaying contextual content, actions, or forms that overlay the
/// main interface.
///
/// Example:
/// ```dart
/// GuxSheet(
///   style: GuxSheetStyle(
///     backgroundColor: Color(0xFFFFFFFF),
///     borderRadius: 16.0,
///     elevation: 8.0,
///   ),
///   child: Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       Text('Sheet Title'),
///       Text('Sheet content goes here'),
///     ],
///   ),
/// )
/// ```
class GuxSheet extends StatelessWidget {
  /// Visual styling for the sheet.
  final GuxSheetStyle style;

  /// Child widget to display inside the sheet.
  final Widget child;

  const GuxSheet({
    super.key,
    required this.style,
    required this.child,
  });

  /// Creates a sheet from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxSheet.fromJson({
  ///   'style': {
  ///     'backgroundColor': '#FFFFFF',
  ///     'borderRadius': 16.0,
  ///     'elevation': 8.0,
  ///   },
  ///   'child': {'type': 'Text', 'data': 'Content'},
  /// })
  /// ```
  factory GuxSheet.fromJson(
    Map<String, dynamic> json, {
    Map<String, VoidCallback>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;
    final childJson = json['child'];

    return GuxSheet(
      style: styleJson != null
          ? GuxSheetStyle.fromJson(styleJson)
          : const GuxSheetStyle(),
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

  /// Converts this sheet to JSON.
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(style.borderRadius),
          topRight: Radius.circular(style.borderRadius),
        ),
        boxShadow: style.elevation > 0
            ? [
                BoxShadow(
                  color: style.shadowColor,
                  blurRadius: style.elevation * 2,
                  offset: Offset(0, -style.elevation / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
