import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A toggle switch with on/off states.
///
/// The host supplies all styling through [GuxToggleStyle]. Supports pointer,
/// keyboard (Space/Enter), and semantic activation. The switch animates between
/// states over 150ms.
class GuxToggle extends StatefulWidget {
  const GuxToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.style,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final GuxToggleStyle style;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<GuxToggle> createState() => _GuxToggleState();
}

class _GuxToggleState extends State<GuxToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _position;
  final FocusNode _internalFocusNode = FocusNode();
  bool _focused = false;

  bool get _enabled => widget.onChanged != null;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      value: widget.value ? 1.0 : 0.0,
      vsync: this,
    );
    _position = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(GuxToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  void _handleTap() {
    if (_enabled) {
      widget.onChanged!(!widget.value);
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
    final trackColor = !_enabled
        ? widget.style.disabledTrackColor
        : widget.value
            ? widget.style.activeTrackColor
            : widget.style.inactiveTrackColor;

    final thumbColor = !_enabled
        ? widget.style.disabledThumbColor
        : widget.value
            ? widget.style.activeThumbColor
            : widget.style.inactiveThumbColor;

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
            toggled: widget.value,
            enabled: _enabled,
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, child) {
                return Container(
                  width: widget.style.width,
                  height: widget.style.height,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(widget.style.height / 2),
                    border: _focused
                        ? Border.all(
                            color: widget.style.focusColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(widget.style.thumbPadding),
                    child: Align(
                      alignment: Alignment.lerp(
                        Alignment.centerLeft,
                        Alignment.centerRight,
                        _position.value,
                      )!,
                      child: Container(
                        width: widget.style.thumbSize,
                        height: widget.style.thumbSize,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual properties for [GuxToggle].
@immutable
class GuxToggleStyle {
  const GuxToggleStyle({
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.disabledTrackColor,
    required this.activeThumbColor,
    required this.inactiveThumbColor,
    required this.disabledThumbColor,
    required this.focusColor,
    this.width = 40.0,
    this.height = 20.0,
    this.thumbSize = 14.0,
    this.thumbPadding = 2.0,
  });

  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color disabledTrackColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;
  final Color disabledThumbColor;
  final Color focusColor;
  final double width;
  final double height;
  final double thumbSize;
  final double thumbPadding;
}
