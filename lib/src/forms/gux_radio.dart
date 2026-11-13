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

import '../utility/gux_color_codec.dart';
import 'gux_radio_group.dart';

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

  /// Color when disabled.
  final Color disabledColor;

  const GuxRadioStyle({
    this.borderColor = const Color(0xFFD1D5DB),
    this.checkedColor = const Color(0xFF3B82F6),
    this.dotColor = const Color(0xFFFFFFFF),
    this.borderWidth = 2.0,
    this.size = 20.0,
    this.dotSize = 8.0,
    this.disabledColor = const Color(0xFFD1D5DB),
  });

  /// Creates a radio style from JSON.
  factory GuxRadioStyle.fromJson(Map<String, dynamic> json) {
    return GuxRadioStyle(
      borderColor: json['borderColor'] != null
          ? GuxColorCodec.parse(json['borderColor'] as String)
          : const Color(0xFFD1D5DB),
      checkedColor: json['checkedColor'] != null
          ? GuxColorCodec.parse(json['checkedColor'] as String)
          : const Color(0xFF3B82F6),
      dotColor: json['dotColor'] != null
          ? GuxColorCodec.parse(json['dotColor'] as String)
          : const Color(0xFFFFFFFF),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2.0,
      size: (json['size'] as num?)?.toDouble() ?? 20.0,
      dotSize: (json['dotSize'] as num?)?.toDouble() ?? 8.0,
      disabledColor: json['disabledColor'] != null
          ? GuxColorCodec.parse(json['disabledColor'] as String)
          : const Color(0xFFD1D5DB),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'borderColor': GuxColorCodec.toHex(borderColor),
      'checkedColor': GuxColorCodec.toHex(checkedColor),
      'dotColor': GuxColorCodec.toHex(dotColor),
      'borderWidth': borderWidth,
      'size': size,
      'dotSize': dotSize,
      'disabledColor': GuxColorCodec.toHex(disabledColor),
    };
  }
}

/// A radio button for selecting one option from a group.
///
/// Inspired by shadcn/ui Radio Group component. Supports keyboard activation
/// (Space/Enter), visible focus indication, and proper accessibility semantics
/// for mutually exclusive selections.
///
/// Example:
/// ```dart
/// GuxRadio(
///   value: 'option1',
///   groupValue: selectedValue,
///   onChanged: (value) => setState(() => selectedValue = value),
///   style: GuxRadioStyle(
///     checkedColor: Color(0xFF3B82F6),
///     borderColor: Color(0xFFD1D5DB),
///   ),
/// )
/// ```
class GuxRadio extends StatefulWidget {
  /// The value represented by this radio button.
  final String value;

  /// The currently selected value for the radio group.
  final String? groupValue;

  /// Called when the radio button is selected.
  final ValueChanged<String>? onChanged;

  /// Visual styling for the radio button.
  final GuxRadioStyle style;

  /// Semantic label for accessibility.
  final String? semanticsLabel;

  /// Optional callback for arrow key navigation (used by GuxRadioGroup).
  ///
  /// When provided, arrow key events are delegated to this handler for
  /// group-level navigation. Should not be set directly by users - this
  /// is automatically configured by GuxRadioGroup.
  final bool Function(LogicalKeyboardKey)? onArrowKey;

  const GuxRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    required this.style,
    this.semanticsLabel,
    this.onArrowKey,
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
    Map<String, ValueChanged<String>>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;
    final actionKey = json['onChanged'] as String?;

    return GuxRadio(
      value: json['value'] as String? ?? '',
      groupValue: json['groupValue'] as String?,
      onChanged: (actionKey != null && actions != null) ? actions[actionKey] : null,
      style: styleJson != null
          ? GuxRadioStyle.fromJson(styleJson)
          : const GuxRadioStyle(),
      semanticsLabel: json['semanticsLabel'] as String?,
    );
  }

  /// Converts this radio button to JSON.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (groupValue != null) 'groupValue': groupValue,
      'style': style.toJson(),
      if (semanticsLabel != null) 'semanticsLabel': semanticsLabel,
    };
  }

  @override
  State<GuxRadio> createState() => _GuxRadioState();
}

class _GuxRadioState extends State<GuxRadio> {
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

  bool get _isSelected => widget.value == widget.groupValue;
  bool get _isEnabled => widget.onChanged != null;

  void _handleSelect() {
    if (_isEnabled && !_isSelected) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're in a radio group for arrow key navigation
    final groupScope = RadioGroupScope.of(context);

    final effectiveBorderColor = _isEnabled
        ? (_isSelected ? widget.style.checkedColor : widget.style.borderColor)
        : widget.style.disabledColor;

    final effectiveBackgroundColor = _isEnabled
        ? (_isSelected ? widget.style.checkedColor : const Color(0x00000000))
        : Color.fromARGB((0.3 * 255).round(),
            (widget.style.disabledColor.r * 255).round(),
            (widget.style.disabledColor.g * 255).round(),
            (widget.style.disabledColor.b * 255).round());

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: _isSelected,
      enabled: _isEnabled,
      label: widget.semanticsLabel,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (!_isEnabled) return KeyEventResult.ignored;
          if (event is KeyDownEvent) {
            // Handle Space/Enter for selection
            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              _handleSelect();
              return KeyEventResult.handled;
            }

            // Delegate arrow keys to group if present
            if (groupScope != null) {
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.arrowUp ||
                  key == LogicalKeyboardKey.arrowDown ||
                  key == LogicalKeyboardKey.arrowLeft ||
                  key == LogicalKeyboardKey.arrowRight) {
                final handled = groupScope.onArrowKey(key);
                return handled ? KeyEventResult.handled : KeyEventResult.ignored;
              }
            }

            // Also check explicit onArrowKey callback (for backward compatibility)
            if (widget.onArrowKey != null) {
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.arrowUp ||
                  key == LogicalKeyboardKey.arrowDown ||
                  key == LogicalKeyboardKey.arrowLeft ||
                  key == LogicalKeyboardKey.arrowRight) {
                final handled = widget.onArrowKey!(key);
                return handled ? KeyEventResult.handled : KeyEventResult.ignored;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _isEnabled
              ? () {
                  _focusNode.requestFocus();
                  _handleSelect();
                }
              : null,
          child: Container(
            width: widget.style.size,
            height: widget.style.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveBackgroundColor,
              border: Border.all(
                color: _isFocused && _isEnabled
                    ? widget.style.checkedColor
                    : effectiveBorderColor,
                width: _isFocused && _isEnabled
                    ? widget.style.borderWidth + 1.0
                    : widget.style.borderWidth,
              ),
            ),
            child: _isSelected
                ? Center(
                    child: Container(
                      width: widget.style.dotSize,
                      height: widget.style.dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isEnabled
                            ? widget.style.dotColor
                            : Color.fromARGB((0.5 * 255).round(),
                                (widget.style.dotColor.r * 255).round(),
                                (widget.style.dotColor.g * 255).round(),
                                (widget.style.dotColor.b * 255).round()),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
