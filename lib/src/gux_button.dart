import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Visual properties for a [GuxButton], independent of an app theme.
@immutable
class GuxButtonStyle {
  const GuxButtonStyle({
    required this.backgroundColor,
    required this.hoverColor,
    required this.pressedColor,
    required this.disabledColor,
    required this.foregroundColor,
    required this.disabledForegroundColor,
    this.focusColor = const Color(0xFF3B82F6),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.minimumSize = const Size(0, 28),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.textStyle = const TextStyle(fontSize: 14),
  });

  final Color backgroundColor;
  final Color hoverColor;
  final Color pressedColor;
  final Color disabledColor;
  final Color foregroundColor;
  final Color disabledForegroundColor;
  final Color focusColor;
  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final BorderRadiusGeometry borderRadius;
  final TextStyle textStyle;
}

/// A focusable, accessible button styled by its embedding application.
///
/// The child supplies the accessible label. Space and Enter activate the
/// button, and a null [onPressed] disables pointer and keyboard activation.
class GuxButton extends StatefulWidget {
  const GuxButton({
    super.key,
    required this.onPressed,
    required this.style,
    required this.child,
    this.focusNode,
    this.autofocus = false,
  });

  final VoidCallback? onPressed;
  final GuxButtonStyle style;
  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<GuxButton> createState() => _GuxButtonState();
}

class _GuxButtonState extends State<GuxButton> {
  final FocusNode _internalFocusNode = FocusNode();
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GuxButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) {
      _hovered = false;
      _pressed = false;
      _focused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final color = !_enabled
        ? style.disabledColor
        : _pressed
        ? style.pressedColor
        : _hovered
        ? style.hoverColor
        : style.backgroundColor;
    final foreground = _enabled
        ? style.foregroundColor
        : style.disabledForegroundColor;

    return Semantics(
      button: true,
      enabled: _enabled,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: widget.focusNode ?? _internalFocusNode,
        autofocus: widget.autofocus,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onPressed,
          onTapDown: _enabled
              ? (_) {
                  (widget.focusNode ?? _internalFocusNode).requestFocus();
                  setState(() => _pressed = true);
                }
              : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled
              ? () {
                  if (_pressed) setState(() => _pressed = false);
                }
              : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: style.borderRadius,
              border: _focused ? Border.all(color: style.focusColor) : null,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: style.minimumSize.width,
                minHeight: style.minimumSize.height,
              ),
              child: Padding(
                padding: style.padding,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: style.textStyle.copyWith(color: foreground),
                    child: IconTheme.merge(
                      data: IconThemeData(color: foreground),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
