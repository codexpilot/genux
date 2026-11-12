import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A checkbox with checked, unchecked, and indeterminate states.
///
/// The host supplies all styling through [GenuxCheckboxStyle]. Supports pointer,
/// keyboard (Space/Enter), and semantic activation.
class GenuxCheckbox extends StatefulWidget {
  const GenuxCheckbox({
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
  final GenuxCheckboxStyle style;
  final bool tristate;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<GenuxCheckbox> createState() => _GenuxCheckboxState();
}

class _GenuxCheckboxState extends State<GenuxCheckbox> {
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

/// Visual properties for [GenuxCheckbox].
@immutable
class GenuxCheckboxStyle {
  const GenuxCheckboxStyle({
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
