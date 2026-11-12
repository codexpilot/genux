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

import 'gux_radio.dart';

/// Provides arrow key navigation handler to descendant GuxRadio widgets.
///
/// This is used internally by GuxRadioGroup and should not be used directly.
/// @nodoc
class RadioGroupScope extends InheritedWidget {
  final bool Function(LogicalKeyboardKey) onArrowKey;

  const RadioGroupScope({
    required this.onArrowKey,
    required super.child,
  });

  static RadioGroupScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RadioGroupScope>();
  }

  @override
  bool updateShouldNotify(RadioGroupScope oldWidget) => false;
}

/// A group of radio buttons with coordinated keyboard navigation.
///
/// Provides arrow-key navigation between radio options following standard
/// radio group accessibility patterns:
/// - Arrow keys (Up/Down, Left/Right) move focus and selection between radios
/// - Disabled radios are skipped during arrow navigation
/// - Wraps at boundaries (last -> first, first -> last)
///
/// Example:
/// ```dart
/// GuxRadioGroup<String>(
///   value: selectedValue,
///   onChanged: (value) => setState(() => selectedValue = value),
///   children: [
///     GuxRadio(value: 'small', groupValue: selectedValue, ...),
///     GuxRadio(value: 'medium', groupValue: selectedValue, ...),
///     GuxRadio(value: 'large', groupValue: selectedValue, ...),
///   ],
/// )
/// ```
class GuxRadioGroup<T> extends StatefulWidget {
  /// The currently selected value.
  final T? value;

  /// Called when the selection changes.
  final ValueChanged<T>? onChanged;

  /// Radio buttons to display in the group.
  final List<Widget> children;

  /// Layout axis for the radio group.
  final Axis axis;

  /// Spacing between radio buttons.
  final double spacing;

  const GuxRadioGroup({
    super.key,
    required this.value,
    this.onChanged,
    required this.children,
    this.axis = Axis.vertical,
    this.spacing = 8.0,
  });

  @override
  State<GuxRadioGroup<T>> createState() => _GuxRadioGroupState<T>();
}

class _GuxRadioGroupState<T> extends State<GuxRadioGroup<T>> {
  bool _isRadioEnabled(int index) {
    if (index < 0 || index >= widget.children.length) return false;
    final child = widget.children[index];
    if (child is GuxRadio) {
      return child.onChanged != null;
    }
    return false;
  }

  int _findCurrentIndex() {
    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      if (child is GuxRadio && child.value == widget.value) {
        return i;
      }
    }
    return 0; // Default to first if none selected
  }

  void _moveFocus(int delta) {
    if (widget.children.isEmpty) return;

    final currentIndex = _findCurrentIndex();
    int nextIndex = currentIndex;
    int attempts = 0;
    final maxAttempts = widget.children.length;

    // Find next enabled radio
    do {
      nextIndex = (nextIndex + delta) % widget.children.length;
      if (nextIndex < 0) {
        nextIndex = widget.children.length - 1;
      }
      attempts++;

      if (attempts >= maxAttempts) {
        // No enabled radios found
        return;
      }
    } while (!_isRadioEnabled(nextIndex));

    // Trigger selection change
    final child = widget.children[nextIndex];
    if (child is GuxRadio && widget.onChanged != null) {
      widget.onChanged!(child.value as T);
    }
  }

  bool _handleArrowKey(LogicalKeyboardKey key) {
    // Vertical navigation (Up/Down)
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return true;
    }

    // Horizontal navigation (Left/Right)
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveFocus(Directionality.of(context) == TextDirection.rtl ? 1 : -1);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveFocus(Directionality.of(context) == TextDirection.rtl ? -1 : 1);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroupScope(
      onArrowKey: _handleArrowKey,
      child: Flex(
        direction: widget.axis,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widget.children.length; i++) ...[
            if (i > 0)
              SizedBox(
                width: widget.axis == Axis.horizontal ? widget.spacing : 0,
                height: widget.axis == Axis.vertical ? widget.spacing : 0,
              ),
            widget.children[i],
          ],
        ],
      ),
    );
  }
}
