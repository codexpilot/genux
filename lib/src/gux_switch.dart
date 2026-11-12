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

/// Visual styling for [GuxSwitch].
class GuxSwitchStyle {
  /// Background color when switch is off.
  final Color offColor;

  /// Background color when switch is on.
  final Color onColor;

  /// Thumb (toggle) color.
  final Color thumbColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius in pixels.
  final double borderRadius;

  /// Width of the switch track.
  final double width;

  /// Height of the switch track.
  final double height;

  /// Size of the thumb (toggle circle).
  final double thumbSize;

  /// Padding between thumb and track edge.
  final double thumbPadding;

  const GuxSwitchStyle({
    this.offColor = const Color(0xFFE5E7EB),
    this.onColor = const Color(0xFF3B82F6),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderWidth = 0.0,
    this.borderRadius = 12.0,
    this.width = 44.0,
    this.height = 24.0,
    this.thumbSize = 20.0,
    this.thumbPadding = 2.0,
  });

  /// Creates a switch style from JSON.
  factory GuxSwitchStyle.fromJson(Map<String, dynamic> json) {
    return GuxSwitchStyle(
      offColor: json['offColor'] != null
          ? _parseColor(json['offColor'] as String)
          : const Color(0xFFE5E7EB),
      onColor: json['onColor'] != null
          ? _parseColor(json['onColor'] as String)
          : const Color(0xFF3B82F6),
      thumbColor: json['thumbColor'] != null
          ? _parseColor(json['thumbColor'] as String)
          : const Color(0xFFFFFFFF),
      borderColor: json['borderColor'] != null
          ? _parseColor(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 12.0,
      width: (json['width'] as num?)?.toDouble() ?? 44.0,
      height: (json['height'] as num?)?.toDouble() ?? 24.0,
      thumbSize: (json['thumbSize'] as num?)?.toDouble() ?? 20.0,
      thumbPadding: (json['thumbPadding'] as num?)?.toDouble() ?? 2.0,
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'offColor': _colorToHex(offColor),
      'onColor': _colorToHex(onColor),
      'thumbColor': _colorToHex(thumbColor),
      if (borderColor != null) 'borderColor': _colorToHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'width': width,
      'height': height,
      'thumbSize': thumbSize,
      'thumbPadding': thumbPadding,
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

/// A toggle switch for on/off state.
///
/// Inspired by shadcn/ui Switch component. Used for binary settings
/// and preference toggles.
///
/// Example:
/// ```dart
/// GuxSwitch(
///   value: true,
///   onChanged: (newValue) => print('Switch: $newValue'),
///   style: GuxSwitchStyle(
///     onColor: Color(0xFF3B82F6),
///     offColor: Color(0xFFE5E7EB),
///   ),
/// )
/// ```
class GuxSwitch extends StatelessWidget {
  /// Current state of the switch.
  final bool value;

  /// Callback when switch is toggled.
  final ValueChanged<bool>? onChanged;

  /// Visual styling for the switch.
  final GuxSwitchStyle style;

  const GuxSwitch({
    super.key,
    required this.value,
    this.onChanged,
    required this.style,
  });

  /// Creates a switch from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxSwitch.fromJson({
  ///   'value': true,
  ///   'style': {
  ///     'onColor': '#3B82F6',
  ///     'offColor': '#E5E7EB',
  ///   },
  /// })
  /// ```
  factory GuxSwitch.fromJson(
    Map<String, dynamic> json, {
    Map<String, ValueChanged<bool>>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;
    final actionKey = json['action'] as String?;

    return GuxSwitch(
      value: json['value'] as bool? ?? false,
      onChanged: (actionKey != null && actions != null) ? actions[actionKey] : null,
      style: styleJson != null
          ? GuxSwitchStyle.fromJson(styleJson)
          : const GuxSwitchStyle(),
    );
  }

  /// Converts this switch to JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'style': style.toJson(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = value ? style.onColor : style.offColor;
    final thumbOffset = value
        ? style.width - style.thumbSize - style.thumbPadding
        : style.thumbPadding;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Container(
        width: style.width,
        height: style.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: style.borderWidth > 0 && style.borderColor != null
              ? Border.all(
                  color: style.borderColor!,
                  width: style.borderWidth,
                )
              : null,
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: thumbOffset,
              top: style.thumbPadding,
              child: Container(
                width: style.thumbSize,
                height: style.thumbSize,
                decoration: BoxDecoration(
                  color: style.thumbColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
