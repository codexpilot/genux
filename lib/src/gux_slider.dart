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

/// Visual styling for [GuxSlider].
class GuxSliderStyle {
  /// Track color (inactive portion).
  final Color trackColor;

  /// Active track color (filled portion).
  final Color activeTrackColor;

  /// Thumb color.
  final Color thumbColor;

  /// Track height in pixels.
  final double trackHeight;

  /// Thumb size (diameter) in pixels.
  final double thumbSize;

  /// Corner radius for track.
  final double borderRadius;

  const GuxSliderStyle({
    this.trackColor = const Color(0xFFE5E7EB),
    this.activeTrackColor = const Color(0xFF3B82F6),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.trackHeight = 4.0,
    this.thumbSize = 20.0,
    this.borderRadius = 2.0,
  });

  /// Creates a slider style from JSON.
  factory GuxSliderStyle.fromJson(Map<String, dynamic> json) {
    return GuxSliderStyle(
      trackColor: json['trackColor'] != null
          ? _parseColor(json['trackColor'] as String)
          : const Color(0xFFE5E7EB),
      activeTrackColor: json['activeTrackColor'] != null
          ? _parseColor(json['activeTrackColor'] as String)
          : const Color(0xFF3B82F6),
      thumbColor: json['thumbColor'] != null
          ? _parseColor(json['thumbColor'] as String)
          : const Color(0xFFFFFFFF),
      trackHeight: (json['trackHeight'] as num?)?.toDouble() ?? 4.0,
      thumbSize: (json['thumbSize'] as num?)?.toDouble() ?? 20.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 2.0,
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'trackColor': _colorToHex(trackColor),
      'activeTrackColor': _colorToHex(activeTrackColor),
      'thumbColor': _colorToHex(thumbColor),
      'trackHeight': trackHeight,
      'thumbSize': thumbSize,
      'borderRadius': borderRadius,
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

/// A slider for selecting a value from a range.
///
/// Inspired by shadcn/ui Slider component. Used for continuous value
/// selection within a defined range with visual feedback.
///
/// Example:
/// ```dart
/// GuxSlider(
///   value: 50.0,
///   min: 0.0,
///   max: 100.0,
///   style: GuxSliderStyle(
///     activeTrackColor: Color(0xFF3B82F6),
///     thumbColor: Color(0xFFFFFFFF),
///   ),
/// )
/// ```
class GuxSlider extends StatelessWidget {
  /// Current value of the slider.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Visual styling for the slider.
  final GuxSliderStyle style;

  const GuxSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    required this.style,
  });

  /// Creates a slider from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxSlider.fromJson({
  ///   'value': 50.0,
  ///   'min': 0.0,
  ///   'max': 100.0,
  ///   'style': {
  ///     'activeTrackColor': '#3B82F6',
  ///     'thumbColor': '#FFFFFF',
  ///   },
  /// })
  /// ```
  factory GuxSlider.fromJson(Map<String, dynamic> json) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxSlider(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 100.0,
      style: styleJson != null
          ? GuxSliderStyle.fromJson(styleJson)
          : const GuxSliderStyle(),
    );
  }

  /// Converts this slider to JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'min': min,
      'max': max,
      'style': style.toJson(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(min, max);
    final fraction = max > min ? (clampedValue - min) / (max - min) : 0.0;

    return SizedBox(
      height: style.thumbSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final thumbPosition = fraction * (trackWidth - style.thumbSize);

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Inactive track
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  height: style.trackHeight,
                  decoration: BoxDecoration(
                    color: style.trackColor,
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                ),
              ),
              // Active track
              Positioned(
                left: 0,
                child: Container(
                  width: (fraction * trackWidth).clamp(0.0, trackWidth),
                  height: style.trackHeight,
                  decoration: BoxDecoration(
                    color: style.activeTrackColor,
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                ),
              ),
              // Thumb
              Positioned(
                left: thumbPosition,
                child: Container(
                  width: style.thumbSize,
                  height: style.thumbSize,
                  decoration: BoxDecoration(
                    color: style.thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x26000000),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
