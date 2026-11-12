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

/// Visual styling for [GuxRadio].
class GuxRadioStyle {
  /// Border color when unchecked.
  final Color borderColor;

  /// Background color when checked.
  final Color checkedColor;

  /// Inner dot color when checked.
  final Color dotColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Size of the radio button (width and height).
  final double size;

  /// Size of the inner dot when checked.
  final double dotSize;

  const GuxRadioStyle({
    this.borderColor = const Color(0xFFD1D5DB),
    this.checkedColor = const Color(0xFF3B82F6),
    this.dotColor = const Color(0xFFFFFFFF),
    this.borderWidth = 2.0,
    this.size = 20.0,
    this.dotSize = 8.0,
  });

  /// Creates a radio style from JSON.
  factory GuxRadioStyle.fromJson(Map<String, dynamic> json) {
    return GuxRadioStyle(
      borderColor: json['borderColor'] != null
          ? _parseColor(json['borderColor'] as String)
          : const Color(0xFFD1D5DB),
      checkedColor: json['checkedColor'] != null
          ? _parseColor(json['checkedColor'] as String)
          : const Color(0xFF3B82F6),
      dotColor: json['dotColor'] != null
          ? _parseColor(json['dotColor'] as String)
          : const Color(0xFFFFFFFF),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2.0,
      size: (json['size'] as num?)?.toDouble() ?? 20.0,
      dotSize: (json['dotSize'] as num?)?.toDouble() ?? 8.0,
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'borderColor': _colorToHex(borderColor),
      'checkedColor': _colorToHex(checkedColor),
      'dotColor': _colorToHex(dotColor),
      'borderWidth': borderWidth,
      'size': size,
      'dotSize': dotSize,
    };
  }

  static Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// A radio button for selecting one option from a group.
///
/// Inspired by shadcn/ui Radio Group component. Used for mutually
/// exclusive selections where only one option can be chosen at a time.
///
/// Example:
/// ```dart
/// GuxRadio(
///   value: 'option1',
///   groupValue: 'option1',
///   onChanged: (value) => print('Selected: $value'),
///   style: GuxRadioStyle(
///     checkedColor: Color(0xFF3B82F6),
///     borderColor: Color(0xFFD1D5DB),
///   ),
/// )
/// ```
class GuxRadio extends StatelessWidget {
  /// The value represented by this radio button.
  final String value;

  /// The currently selected value for the radio group.
  final String? groupValue;

  /// Called when the radio button is tapped.
  final ValueChanged<String>? onChanged;

  /// Visual styling for the radio button.
  final GuxRadioStyle style;

  const GuxRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    required this.style,
  });

  /// Creates a radio button from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxRadio.fromJson({
  ///   'value': 'option1',
  ///   'groupValue': 'option1',
  ///   'style': {
  ///     'checkedColor': '#3B82F6',
  ///     'borderColor': '#D1D5DB',
  ///   },
  /// })
  /// ```
  factory GuxRadio.fromJson(
    Map<String, dynamic> json, {
    Map<String, VoidCallback>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxRadio(
      value: json['value'] as String? ?? '',
      groupValue: json['groupValue'] as String?,
      onChanged: actions?['onChanged'] != null
          ? (_) => actions!['onChanged']!()
          : null,
      style: styleJson != null
          ? GuxRadioStyle.fromJson(styleJson)
          : const GuxRadioStyle(),
    );
  }

  /// Converts this radio button to JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (groupValue != null) 'groupValue': groupValue,
      'style': style.toJson(),
    };
  }

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(value) : null,
      child: Container(
        width: style.size,
        height: style.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isSelected ? style.checkedColor : const Color(0x00000000),
          border: Border.all(
            color: _isSelected ? style.checkedColor : style.borderColor,
            width: style.borderWidth,
          ),
        ),
        child: _isSelected
            ? Center(
                child: Container(
                  width: style.dotSize,
                  height: style.dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.dotColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
