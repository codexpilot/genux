import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../json/gux_json_utils.dart';

/// A checkbox with checked, unchecked, and indeterminate states.
///
/// The host supplies all styling through [GuxCheckboxStyle]. Supports pointer,
/// keyboard (Space/Enter), and semantic activation.
class GuxCheckbox extends StatefulWidget {
  const GuxCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.style,
    this.tristate = false,
    this.focusNode,
    this.autofocus = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final GuxCheckboxStyle style;
  final bool tristate;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Create a GuxCheckbox from JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "value": true,
  ///   "onChanged": "handleCheckboxChange",
  ///   "tristate": false,
  ///   "autofocus": false,
  ///   "style": {
  ///     "checkedBackgroundColor": "#3B82F6",
  ///     "uncheckedBackgroundColor": "#252525",
  ///     "checkColor": "#FFFFFF"
  ///   }
  /// }
  /// ```
  factory GuxCheckbox.fromJson(
    Map<String, dynamic> json, {
    required Map<String, ValueChanged<bool?>> actions,
    FocusNode? focusNode,
  }) {
    // Parse style
    final styleJson = json['style'];
    final Map<String, dynamic> styleMap;
    if (styleJson == null) {
      styleMap = {};
    } else if (styleJson is Map<String, dynamic>) {
      styleMap = styleJson;
    } else if (styleJson is Map) {
      styleMap = Map<String, dynamic>.from(styleJson);
    } else {
      styleMap = {};
    }

    final onChangedKey = json['onChanged'] as String?;

    return GuxCheckbox(
      value: json['value'] as bool?,
      onChanged: onChangedKey != null ? actions[onChangedKey] : null,
      style: GuxCheckboxStyle.fromJson(styleMap),
      tristate: json['tristate'] as bool? ?? false,
      focusNode: focusNode,
      autofocus: json['autofocus'] as bool? ?? false,
    );
  }

  @override
  State<GuxCheckbox> createState() => _GuxCheckboxState();
}

class _GuxCheckboxState extends State<GuxCheckbox> {
  final FocusNode _internalFocusNode = FocusNode();
  bool _focused = false;
  bool _hovered = false;

  bool get _enabled => widget.onChanged != null;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  void _handleTap() {
    if (_enabled) {
      if (widget.tristate) {
        if (widget.value == null) {
          widget.onChanged!(true);
        } else if (widget.value!) {
          widget.onChanged!(false);
        } else {
          widget.onChanged!(null);
        }
      } else {
        widget.onChanged!(widget.value != true);
      }
      _focusNode.requestFocus();
    }
  }

  void _handleKey(KeyEvent event) {
    if (!_enabled) return;
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      _handleTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !_enabled
        ? widget.style.disabledBackgroundColor
        : widget.value == true
            ? widget.style.checkedBackgroundColor
            : _hovered
                ? widget.style.hoverBackgroundColor
                : widget.style.uncheckedBackgroundColor;

    final borderColor = !_enabled
        ? widget.style.disabledBorderColor
        : widget.value == true
            ? widget.style.checkedBorderColor
            : widget.style.uncheckedBorderColor;

    final checkColor = !_enabled
        ? widget.style.disabledCheckColor
        : widget.style.checkColor;

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: _enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: _enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: _enabled ? _handleTap : null,
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onKeyEvent: (node, event) {
            _handleKey(event);
            return KeyEventResult.handled;
          },
          child: Semantics(
            checked: widget.value == true,
            mixed: widget.value == null,
            enabled: _enabled,
            child: Container(
              width: widget.style.size,
              height: widget.style.size,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(
                  color: _focused ? widget.style.focusColor : borderColor,
                  width: _focused ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(widget.style.borderRadius),
              ),
              child: widget.value == null
                  ? Center(
                      child: Container(
                        width: widget.style.size * 0.5,
                        height: 2,
                        color: checkColor,
                      ),
                    )
                  : widget.value == true
                      ? CustomPaint(
                          painter: _CheckmarkPainter(
                            color: checkColor,
                            strokeWidth: widget.style.checkStrokeWidth,
                          ),
                        )
                      : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual properties for [GuxCheckbox].
@immutable
class GuxCheckboxStyle {
  const GuxCheckboxStyle({
    required this.checkedBackgroundColor,
    required this.uncheckedBackgroundColor,
    required this.hoverBackgroundColor,
    required this.disabledBackgroundColor,
    required this.checkedBorderColor,
    required this.uncheckedBorderColor,
    required this.disabledBorderColor,
    required this.checkColor,
    required this.disabledCheckColor,
    required this.focusColor,
    this.size = 18.0,
    this.borderRadius = 3.0,
    this.checkStrokeWidth = 2.0,
  });

  final Color checkedBackgroundColor;
  final Color uncheckedBackgroundColor;
  final Color hoverBackgroundColor;
  final Color disabledBackgroundColor;
  final Color checkedBorderColor;
  final Color uncheckedBorderColor;
  final Color disabledBorderColor;
  final Color checkColor;
  final Color disabledCheckColor;
  final Color focusColor;
  final double size;
  final double borderRadius;
  final double checkStrokeWidth;

  /// Create from JSON
  factory GuxCheckboxStyle.fromJson(Map<String, dynamic> json) {
    return GuxCheckboxStyle(
      checkedBackgroundColor:
          GuxJsonUtils.parseColor(json['checkedBackgroundColor']) ??
              const Color(0xFF3B82F6),
      uncheckedBackgroundColor:
          GuxJsonUtils.parseColor(json['uncheckedBackgroundColor']) ??
              const Color(0xFF252525),
      hoverBackgroundColor:
          GuxJsonUtils.parseColor(json['hoverBackgroundColor']) ??
              const Color(0xFF383838),
      disabledBackgroundColor:
          GuxJsonUtils.parseColor(json['disabledBackgroundColor']) ??
              const Color(0xFF1F1F1F),
      checkedBorderColor:
          GuxJsonUtils.parseColor(json['checkedBorderColor']) ??
              const Color(0xFF3B82F6),
      uncheckedBorderColor:
          GuxJsonUtils.parseColor(json['uncheckedBorderColor']) ??
              const Color(0xFF484848),
      disabledBorderColor:
          GuxJsonUtils.parseColor(json['disabledBorderColor']) ??
              const Color(0xFF383838),
      checkColor: GuxJsonUtils.parseColor(json['checkColor']) ??
          const Color(0xFFFFFFFF),
      disabledCheckColor:
          GuxJsonUtils.parseColor(json['disabledCheckColor']) ??
              const Color(0xFF888888),
      focusColor: GuxJsonUtils.parseColor(json['focusColor']) ??
          const Color(0xFF3B82F6),
      size: (json['size'] as num?)?.toDouble() ?? 18.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 3.0,
      checkStrokeWidth: (json['checkStrokeWidth'] as num?)?.toDouble() ?? 2.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'checkedBackgroundColor':
          GuxJsonUtils.colorToString(checkedBackgroundColor),
      'uncheckedBackgroundColor':
          GuxJsonUtils.colorToString(uncheckedBackgroundColor),
      'hoverBackgroundColor': GuxJsonUtils.colorToString(hoverBackgroundColor),
      'disabledBackgroundColor':
          GuxJsonUtils.colorToString(disabledBackgroundColor),
      'checkedBorderColor': GuxJsonUtils.colorToString(checkedBorderColor),
      'uncheckedBorderColor': GuxJsonUtils.colorToString(uncheckedBorderColor),
      'disabledBorderColor': GuxJsonUtils.colorToString(disabledBorderColor),
      'checkColor': GuxJsonUtils.colorToString(checkColor),
      'disabledCheckColor': GuxJsonUtils.colorToString(disabledCheckColor),
      'focusColor': GuxJsonUtils.colorToString(focusColor),
      'size': size,
      'borderRadius': borderRadius,
      'checkStrokeWidth': checkStrokeWidth,
    };
  }
}

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Checkmark path
    path.moveTo(w * 0.2, h * 0.5);
    path.lineTo(w * 0.4, h * 0.7);
    path.lineTo(w * 0.8, h * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
