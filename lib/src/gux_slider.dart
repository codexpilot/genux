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

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'json/gux_color_codec.dart';

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

  /// Color when disabled.
  final Color disabledColor;

  const GuxSliderStyle({
    this.trackColor = const Color(0xFFE5E7EB),
    this.activeTrackColor = const Color(0xFF3B82F6),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.trackHeight = 4.0,
    this.thumbSize = 20.0,
    this.borderRadius = 2.0,
    this.disabledColor = const Color(0xFFD1D5DB),
  });

  /// Creates a slider style from JSON.
  factory GuxSliderStyle.fromJson(Map<String, dynamic> json) {
    return GuxSliderStyle(
      trackColor: json['trackColor'] != null
          ? GuxColorCodec.parse(json['trackColor'] as String)
          : const Color(0xFFE5E7EB),
      activeTrackColor: json['activeTrackColor'] != null
          ? GuxColorCodec.parse(json['activeTrackColor'] as String)
          : const Color(0xFF3B82F6),
      thumbColor: json['thumbColor'] != null
          ? GuxColorCodec.parse(json['thumbColor'] as String)
          : const Color(0xFFFFFFFF),
      trackHeight: (json['trackHeight'] as num?)?.toDouble() ?? 4.0,
      thumbSize: (json['thumbSize'] as num?)?.toDouble() ?? 20.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 2.0,
      disabledColor: json['disabledColor'] != null
          ? GuxColorCodec.parse(json['disabledColor'] as String)
          : const Color(0xFFD1D5DB),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'trackColor': GuxColorCodec.toHex(trackColor),
      'activeTrackColor': GuxColorCodec.toHex(activeTrackColor),
      'thumbColor': GuxColorCodec.toHex(thumbColor),
      'trackHeight': trackHeight,
      'thumbSize': thumbSize,
      'borderRadius': borderRadius,
      'disabledColor': GuxColorCodec.toHex(disabledColor),
    };
  }


}

/// A slider for selecting a value from a range.
///
/// Inspired by shadcn/ui Slider component. Supports mouse/touch drag,
/// tap to set value, keyboard adjustments (arrow keys), disabled state,
/// and accessibility semantics.
///
/// Example:
/// ```dart
/// GuxSlider(
///   value: 50.0,
///   min: 0.0,
///   max: 100.0,
///   onChanged: (newValue) => setState(() => value = newValue),
///   style: GuxSliderStyle(
///     activeTrackColor: Color(0xFF3B82F6),
///     thumbColor: Color(0xFFFFFFFF),
///   ),
/// )
/// ```
class GuxSlider extends StatefulWidget {
  /// Current value of the slider.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Number of discrete divisions (null for continuous).
  final int? divisions;

  /// Called when the value changes.
  final ValueChanged<double>? onChanged;

  /// Visual styling for the slider.
  final GuxSliderStyle style;

  /// Semantic label for accessibility.
  final String? semanticsLabel;

  const GuxSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.onChanged,
    required this.style,
    this.semanticsLabel,
  }) : assert(min <= max, 'min must be <= max'),
       assert(value >= min && value <= max, 'value must be between min and max');

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
  factory GuxSlider.fromJson(
    Map<String, dynamic> json, {
    Map<String, ValueChanged<double>>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;
    final actionKey = json['onChanged'] as String?;

    return GuxSlider(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 100.0,
      divisions: json['divisions'] as int?,
      onChanged: (actionKey != null && actions != null) ? actions[actionKey] : null,
      style: styleJson != null
          ? GuxSliderStyle.fromJson(styleJson)
          : const GuxSliderStyle(),
      semanticsLabel: json['semanticsLabel'] as String?,
    );
  }

  /// Converts this slider to JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'min': min,
      'max': max,
      if (divisions != null) 'divisions': divisions,
      'style': style.toJson(),
      if (semanticsLabel != null) 'semanticsLabel': semanticsLabel,
    };
  }

  @override
  State<GuxSlider> createState() => _GuxSliderState();
}

class _GuxSliderState extends State<GuxSlider> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  bool get _isEnabled => widget.onChanged != null;

  void _handleTap(Offset localPosition, double trackWidth) {
    if (!_isEnabled) return;

    final fraction = (localPosition.dx / trackWidth).clamp(0.0, 1.0);
    final newValue = widget.min + fraction * (widget.max - widget.min);
    final clampedValue = _snapToGrid(newValue);
    widget.onChanged!(clampedValue);
  }

  void _handleDrag(Offset localPosition, double trackWidth) {
    if (!_isEnabled) return;

    final fraction = (localPosition.dx / trackWidth).clamp(0.0, 1.0);
    final newValue = widget.min + fraction * (widget.max - widget.min);
    final clampedValue = _snapToGrid(newValue);
    widget.onChanged!(clampedValue);
  }

  double _snapToGrid(double value) {
    if (widget.divisions == null) {
      return value.clamp(widget.min, widget.max);
    }
    final step = (widget.max - widget.min) / widget.divisions!;
    // Snap relative to min, not zero
    final offsetFromMin = value - widget.min;
    final snappedOffset = (offsetFromMin / step).round() * step;
    final snapped = widget.min + snappedOffset;
    return snapped.clamp(widget.min, widget.max);
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (!_isEnabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final step = widget.divisions != null
        ? (widget.max - widget.min) / widget.divisions!
        : (widget.max - widget.min) / 20;

    double? newValue;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      newValue = isRtl ? widget.value - step : widget.value + step;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      newValue = isRtl ? widget.value + step : widget.value - step;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      newValue = widget.value + step;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      newValue = widget.value - step;
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      newValue = widget.min;
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      newValue = widget.max;
    }

    if (newValue != null) {
      widget.onChanged!(_snapToGrid(newValue.clamp(widget.min, widget.max)));
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = widget.value.clamp(widget.min, widget.max);
    final range = widget.max - widget.min;
    final fraction = range > 0 ? (clampedValue - widget.min) / range : 0.0;

    final effectiveActiveColor = _isEnabled ? widget.style.activeTrackColor : widget.style.disabledColor;
    final effectiveTrackColor = _isEnabled ? widget.style.trackColor : widget.style.disabledColor;

    final step = widget.divisions != null
        ? (widget.max - widget.min) / widget.divisions!
        : (widget.max - widget.min) / 20;

    final increasedValue = (widget.value + step).clamp(widget.min, widget.max);
    final decreasedValue = (widget.value - step).clamp(widget.min, widget.max);

    return Semantics(
      slider: true,
      enabled: _isEnabled,
      value: clampedValue.toStringAsFixed(1),
      increasedValue: increasedValue.toStringAsFixed(1),
      decreasedValue: decreasedValue.toStringAsFixed(1),
      label: widget.semanticsLabel,
      onIncrease: _isEnabled ? () {
        widget.onChanged!(_snapToGrid(increasedValue));
      } : null,
      onDecrease: _isEnabled ? () {
        widget.onChanged!(_snapToGrid(decreasedValue));
      } : null,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          return _handleKeyEvent(event);
        },
        child: SizedBox(
          height: widget.style.thumbSize,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final thumbPosition = fraction * (trackWidth - widget.style.thumbSize);

              return GestureDetector(
                onTapDown: (details) {
                  _focusNode.requestFocus();
                  _handleTap(details.localPosition, trackWidth);
                },
                onHorizontalDragUpdate: (details) {
                  _handleDrag(details.localPosition, trackWidth);
                },
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Inactive track
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Container(
                        height: widget.style.trackHeight,
                        decoration: BoxDecoration(
                          color: effectiveTrackColor,
                          borderRadius: BorderRadius.circular(widget.style.borderRadius),
                        ),
                      ),
                    ),
                    // Active track
                    Positioned(
                      left: 0,
                      child: Container(
                        width: (fraction * trackWidth).clamp(0.0, trackWidth),
                        height: widget.style.trackHeight,
                        decoration: BoxDecoration(
                          color: effectiveActiveColor,
                          borderRadius: BorderRadius.circular(widget.style.borderRadius),
                        ),
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: thumbPosition,
                      child: Container(
                        width: widget.style.thumbSize,
                        height: widget.style.thumbSize,
                        decoration: BoxDecoration(
                          color: widget.style.thumbColor,
                          shape: BoxShape.circle,
                          border: _isFocused && _isEnabled
                              ? Border.all(
                                  color: widget.style.activeTrackColor,
                                  width: 2.0,
                                )
                              : null,
                          boxShadow: _isEnabled ? [
                            BoxShadow(
                              color: const Color(0x26000000),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
