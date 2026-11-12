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

  /// Color when disabled.
  final Color disabledColor;

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
    this.disabledColor = const Color(0xFFD1D5DB),
  });

  /// Creates a switch style from JSON.
  factory GuxSwitchStyle.fromJson(Map<String, dynamic> json) {
    return GuxSwitchStyle(
      offColor: json['offColor'] != null
          ? GuxColorCodec.parse(json['offColor'] as String)
          : const Color(0xFFE5E7EB),
      onColor: json['onColor'] != null
          ? GuxColorCodec.parse(json['onColor'] as String)
          : const Color(0xFF3B82F6),
      thumbColor: json['thumbColor'] != null
          ? GuxColorCodec.parse(json['thumbColor'] as String)
          : const Color(0xFFFFFFFF),
      borderColor: json['borderColor'] != null
          ? GuxColorCodec.parse(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 12.0,
      width: (json['width'] as num?)?.toDouble() ?? 44.0,
      height: (json['height'] as num?)?.toDouble() ?? 24.0,
      thumbSize: (json['thumbSize'] as num?)?.toDouble() ?? 20.0,
      thumbPadding: (json['thumbPadding'] as num?)?.toDouble() ?? 2.0,
      disabledColor: json['disabledColor'] != null
          ? GuxColorCodec.parse(json['disabledColor'] as String)
          : const Color(0xFFD1D5DB),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'offColor': GuxColorCodec.toHex(offColor),
      'onColor': GuxColorCodec.toHex(onColor),
      'thumbColor': GuxColorCodec.toHex(thumbColor),
      if (borderColor != null) 'borderColor': GuxColorCodec.toHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'width': width,
      'height': height,
      'thumbSize': thumbSize,
      'thumbPadding': thumbPadding,
      'disabledColor': GuxColorCodec.toHex(disabledColor),
    };
  }


}

/// A toggle switch for on/off state.
///
/// Inspired by shadcn/ui Switch component. Supports keyboard activation
/// (Space/Enter), visible focus indication, and proper accessibility semantics.
///
/// Example:
/// ```dart
/// GuxSwitch(
///   value: true,
///   onChanged: (newValue) => setState(() => value = newValue),
///   style: GuxSwitchStyle(
///     onColor: Color(0xFF3B82F6),
///     offColor: Color(0xFFE5E7EB),
///   ),
/// )
/// ```
class GuxSwitch extends StatefulWidget {
  /// Current state of the switch.
  final bool value;

  /// Callback when switch is toggled.
  final ValueChanged<bool>? onChanged;

  /// Visual styling for the switch.
  final GuxSwitchStyle style;

  /// Semantic label for accessibility.
  final String? semanticsLabel;

  const GuxSwitch({
    super.key,
    required this.value,
    this.onChanged,
    required this.style,
    this.semanticsLabel,
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
      semanticsLabel: json['semanticsLabel'] as String?,
    );
  }

  /// Converts this switch to JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'style': style.toJson(),
      if (semanticsLabel != null) 'semanticsLabel': semanticsLabel,
    };
  }

  @override
  State<GuxSwitch> createState() => _GuxSwitchState();
}

class _GuxSwitchState extends State<GuxSwitch> {
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

  void _handleToggle() {
    if (_isEnabled) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isEnabled
        ? (widget.value ? widget.style.onColor : widget.style.offColor)
        : widget.style.disabledColor;
    final thumbOffset = widget.value
        ? widget.style.width - widget.style.thumbSize - widget.style.thumbPadding
        : widget.style.thumbPadding;

    return Semantics(
      toggled: widget.value,
      enabled: _isEnabled,
      label: widget.semanticsLabel,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (!_isEnabled) return KeyEventResult.ignored;
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              _handleToggle();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _isEnabled ? _handleToggle : null,
          child: Container(
            width: widget.style.width,
            height: widget.style.height,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: _isFocused && _isEnabled
                  ? Border.all(
                      color: widget.style.onColor,
                      width: 2.0,
                    )
                  : widget.style.borderWidth > 0 && widget.style.borderColor != null
                      ? Border.all(
                          color: widget.style.borderColor!,
                          width: widget.style.borderWidth,
                        )
                      : null,
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: thumbOffset,
                  top: widget.style.thumbPadding,
                  child: Container(
                    width: widget.style.thumbSize,
                    height: widget.style.thumbSize,
                    decoration: BoxDecoration(
                      color: widget.style.thumbColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
