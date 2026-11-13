import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import '../utility/gux_json_utils.dart';

/// Host-provided labels and colors for the text selection menu.
@immutable
class GuxTextSelectionMenuStyle {
  const GuxTextSelectionMenuStyle({
    this.cutLabel = 'Cut',
    this.copyLabel = 'Copy',
    this.pasteLabel = 'Paste',
    this.selectAllLabel = 'Select all',
    this.backgroundColor = const Color(0xFF252525),
    this.foregroundColor = const Color(0xFFECECEC),
    this.hoverColor = const Color(0xFF383838),
    this.focusColor = const Color(0xFF3B82F6),
    this.textStyle = const TextStyle(fontSize: 14),
  });

  final String cutLabel;
  final String copyLabel;
  final String pasteLabel;
  final String selectAllLabel;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color hoverColor;
  final Color focusColor;
  final TextStyle textStyle;

  /// Create from JSON
  factory GuxTextSelectionMenuStyle.fromJson(Map<String, dynamic> json) {
    return GuxTextSelectionMenuStyle(
      cutLabel: json['cutLabel'] as String? ?? 'Cut',
      copyLabel: json['copyLabel'] as String? ?? 'Copy',
      pasteLabel: json['pasteLabel'] as String? ?? 'Paste',
      selectAllLabel: json['selectAllLabel'] as String? ?? 'Select all',
      backgroundColor: GuxJsonUtils.parseColor(json['backgroundColor']) ??
          const Color(0xFF252525),
      foregroundColor: GuxJsonUtils.parseColor(json['foregroundColor']) ??
          const Color(0xFFECECEC),
      hoverColor:
          GuxJsonUtils.parseColor(json['hoverColor']) ?? const Color(0xFF383838),
      focusColor:
          GuxJsonUtils.parseColor(json['focusColor']) ?? const Color(0xFF3B82F6),
      textStyle: GuxJsonUtils.parseTextStyle(
              json['textStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 14),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cutLabel': cutLabel,
      'copyLabel': copyLabel,
      'pasteLabel': pasteLabel,
      'selectAllLabel': selectAllLabel,
      'backgroundColor': GuxJsonUtils.colorToString(backgroundColor),
      'foregroundColor': GuxJsonUtils.colorToString(foregroundColor),
      'hoverColor': GuxJsonUtils.colorToString(hoverColor),
      'focusColor': GuxJsonUtils.colorToString(focusColor),
      'textStyle': GuxJsonUtils.textStyleToJson(textStyle),
    };
  }
}

/// Visual properties supplied by the embedding application for a text field.
@immutable
class GuxTextFieldStyle {
  const GuxTextFieldStyle({
    required this.textStyle,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.errorBorderColor,
    required this.cursorColor,
    required this.selectionColor,
    required this.placeholderStyle,
    required this.errorStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  final TextStyle textStyle;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final Color cursorColor;
  final Color selectionColor;
  final TextStyle placeholderStyle;
  final TextStyle errorStyle;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  /// Create from JSON
  factory GuxTextFieldStyle.fromJson(Map<String, dynamic> json) {
    return GuxTextFieldStyle(
      textStyle: GuxJsonUtils.parseTextStyle(
              json['textStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 14, color: Color(0xFFECECEC)),
      backgroundColor: GuxJsonUtils.parseColor(json['backgroundColor']) ??
          const Color(0xFF252525),
      disabledBackgroundColor:
          GuxJsonUtils.parseColor(json['disabledBackgroundColor']) ??
              const Color(0xFF1F1F1F),
      borderColor:
          GuxJsonUtils.parseColor(json['borderColor']) ?? const Color(0xFF484848),
      focusedBorderColor: GuxJsonUtils.parseColor(json['focusedBorderColor']) ??
          const Color(0xFF3B82F6),
      errorBorderColor: GuxJsonUtils.parseColor(json['errorBorderColor']) ??
          const Color(0xFFFF453A),
      cursorColor:
          GuxJsonUtils.parseColor(json['cursorColor']) ?? const Color(0xFF3B82F6),
      selectionColor: GuxJsonUtils.parseColor(json['selectionColor']) ??
          const Color(0x803B82F6),
      placeholderStyle: GuxJsonUtils.parseTextStyle(
              json['placeholderStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 14, color: Color(0xFF8E8E8E)),
      errorStyle: GuxJsonUtils.parseTextStyle(
              json['errorStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 12, color: Color(0xFFFF453A)),
      padding: GuxJsonUtils.parseEdgeInsets(json['padding']) ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      borderRadius: GuxJsonUtils.parseBorderRadius(json['borderRadius']) ??
          const BorderRadius.all(Radius.circular(6)),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'textStyle': GuxJsonUtils.textStyleToJson(textStyle),
      'backgroundColor': GuxJsonUtils.colorToString(backgroundColor),
      'disabledBackgroundColor':
          GuxJsonUtils.colorToString(disabledBackgroundColor),
      'borderColor': GuxJsonUtils.colorToString(borderColor),
      'focusedBorderColor': GuxJsonUtils.colorToString(focusedBorderColor),
      'errorBorderColor': GuxJsonUtils.colorToString(errorBorderColor),
      'cursorColor': GuxJsonUtils.colorToString(cursorColor),
      'selectionColor': GuxJsonUtils.colorToString(selectionColor),
      'placeholderStyle': GuxJsonUtils.textStyleToJson(placeholderStyle),
      'errorStyle': GuxJsonUtils.textStyleToJson(errorStyle),
      'padding': GuxJsonUtils.edgeInsetsToJson(padding),
      'borderRadius': GuxJsonUtils.borderRadiusToJson(borderRadius),
    };
  }
}

/// A framework-independent editable field with host-owned text and styling.
///
/// The caller owns and disposes [controller] and any supplied [focusNode].
/// [semanticsLabel], [placeholder] and [errorText] are supplied by the host.
/// The error text communicates a validation result; validation itself remains
/// the caller's responsibility. Text selection uses Flutter's low-level
/// gesture handling and a host-configurable selection menu.
class GuxTextField extends StatefulWidget {
  const GuxTextField({
    super.key,
    required this.controller,
    required this.style,
    required this.semanticsLabel,
    this.focusNode,
    this.placeholder,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.selectionMenuStyle = const GuxTextSelectionMenuStyle(),
  }) : assert(maxLines > 0),
       assert(!obscureText || maxLines == 1);

  final TextEditingController controller;
  final FocusNode? focusNode;
  final GuxTextFieldStyle style;
  final String semanticsLabel;
  final String? placeholder;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool autofocus;
  final GuxTextSelectionMenuStyle selectionMenuStyle;

  /// Create a GuxTextField from JSON
  ///
  /// Note: The controller must be provided separately as it requires
  /// stateful lifecycle management. This factory is primarily for
  /// style and configuration serialization.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "style": {
  ///     "backgroundColor": "#252525",
  ///     "borderColor": "#484848",
  ///     "textStyle": {"fontSize": 14, "color": "#ECECEC"}
  ///   },
  ///   "semanticsLabel": "Email input",
  ///   "placeholder": "Enter your email",
  ///   "enabled": true,
  ///   "maxLines": 1,
  ///   "onChanged": "handleEmailChange"
  /// }
  /// ```
  factory GuxTextField.fromJson(
    Map<String, dynamic> json, {
    required TextEditingController controller,
    required Map<String, ValueChanged<String>> actions,
    FocusNode? focusNode,
  }) {
    // Parse style with proper type handling
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

    // Parse selection menu style
    final selectionMenuJson = json['selectionMenuStyle'];
    final Map<String, dynamic> selectionMenuMap;
    if (selectionMenuJson == null) {
      selectionMenuMap = {};
    } else if (selectionMenuJson is Map<String, dynamic>) {
      selectionMenuMap = selectionMenuJson;
    } else if (selectionMenuJson is Map) {
      selectionMenuMap = Map<String, dynamic>.from(selectionMenuJson);
    } else {
      selectionMenuMap = {};
    }

    // Parse keyboard type
    TextInputType? keyboardType;
    final keyboardTypeStr = json['keyboardType'] as String?;
    if (keyboardTypeStr != null) {
      switch (keyboardTypeStr) {
        case 'text':
          keyboardType = TextInputType.text;
          break;
        case 'multiline':
          keyboardType = TextInputType.multiline;
          break;
        case 'number':
          keyboardType = TextInputType.number;
          break;
        case 'phone':
          keyboardType = TextInputType.phone;
          break;
        case 'email':
          keyboardType = TextInputType.emailAddress;
          break;
        case 'url':
          keyboardType = TextInputType.url;
          break;
      }
    }

    // Parse text input action
    TextInputAction? textInputAction;
    final actionStr = json['textInputAction'] as String?;
    if (actionStr != null) {
      switch (actionStr) {
        case 'done':
          textInputAction = TextInputAction.done;
          break;
        case 'go':
          textInputAction = TextInputAction.go;
          break;
        case 'search':
          textInputAction = TextInputAction.search;
          break;
        case 'send':
          textInputAction = TextInputAction.send;
          break;
        case 'next':
          textInputAction = TextInputAction.next;
          break;
        case 'previous':
          textInputAction = TextInputAction.previous;
          break;
      }
    }

    final onChangedKey = json['onChanged'] as String?;
    final onSubmittedKey = json['onSubmitted'] as String?;

    return GuxTextField(
      controller: controller,
      focusNode: focusNode,
      style: GuxTextFieldStyle.fromJson(styleMap),
      semanticsLabel: json['semanticsLabel'] as String? ?? '',
      placeholder: json['placeholder'] as String?,
      errorText: json['errorText'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      readOnly: json['readOnly'] as bool? ?? false,
      obscureText: json['obscureText'] as bool? ?? false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChangedKey != null ? actions[onChangedKey] : null,
      onSubmitted: onSubmittedKey != null ? actions[onSubmittedKey] : null,
      maxLines: json['maxLines'] as int? ?? 1,
      autofocus: json['autofocus'] as bool? ?? false,
      selectionMenuStyle: selectionMenuMap.isEmpty
          ? const GuxTextSelectionMenuStyle()
          : GuxTextSelectionMenuStyle.fromJson(selectionMenuMap),
    );
  }

  @override
  State<GuxTextField> createState() => _GuxTextFieldState();
}

class _GuxTextFieldState extends State<GuxTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final FocusNode _internalFocusNode = FocusNode();
  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey();
  late final TextSelectionGestureDetectorBuilder _selectionBuilder =
      _GuxSelectionGestureBuilder(delegate: this);

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;
  bool _showHandles = false;

  @override
  bool get forcePressEnabled => false;
  @override
  bool get selectionEnabled => widget.enabled;

  @override
  void didUpdateWidget(covariant GuxTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) _focusNode.unfocus();
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    return ListenableBuilder(
      listenable: Listenable.merge([_focusNode, widget.controller]),
      builder: (context, _) {
        final borderColor = widget.errorText != null
            ? style.errorBorderColor
            : _focusNode.hasFocus
            ? style.focusedBorderColor
            : style.borderColor;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Semantics(
                label: widget.semanticsLabel,
                hint: widget.controller.text.isEmpty
                    ? widget.placeholder
                    : null,
                enabled: widget.enabled,
                textField: true,
                obscured: widget.obscureText,
                value: widget.enabled || widget.obscureText
                    ? null
                    : widget.controller.text,
                validationResult: widget.errorText == null
                    ? SemanticsValidationResult.none
                    : SemanticsValidationResult.invalid,
                child: ExcludeSemantics(
                  excluding: !widget.enabled,
                  child: Focus(
                    canRequestFocus: false,
                    descendantsAreFocusable: widget.enabled,
                    child: IgnorePointer(
                      ignoring: !widget.enabled,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.enabled
                              ? style.backgroundColor
                              : style.disabledBackgroundColor,
                          border: Border.all(color: borderColor),
                          borderRadius: style.borderRadius,
                        ),
                        child: Padding(
                          padding: style.padding,
                          child: _selectionBuilder.buildGestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: [
                                if (widget.placeholder != null)
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: widget.controller,
                                    builder: (context, value, _) =>
                                        value.text.isEmpty
                                        ? ExcludeSemantics(
                                            child: Text(
                                              widget.placeholder!,
                                              style: style.placeholderStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                EditableText(
                                  key: editableTextKey,
                                  controller: widget.controller,
                                  focusNode: _focusNode,
                                  style: style.textStyle,
                                  cursorColor: style.cursorColor,
                                  backgroundCursorColor: style.cursorColor,
                                  selectionColor: style.selectionColor,
                                  readOnly: widget.readOnly || !widget.enabled,
                                  obscureText: widget.obscureText,
                                  keyboardType: widget.keyboardType,
                                  textInputAction: widget.textInputAction,
                                  onChanged: widget.onChanged,
                                  onSubmitted: widget.onSubmitted,
                                  inputFormatters: widget.inputFormatters,
                                  maxLines: widget.maxLines,
                                  autofocus: widget.autofocus && widget.enabled,
                                  selectionControls: _GuxSelectionControls(
                                    style.cursorColor,
                                  ),
                                  showSelectionHandles: _showHandles,
                                  onSelectionChanged: (selection, cause) {
                                    final show =
                                        widget.enabled &&
                                        (cause ==
                                                SelectionChangedCause
                                                    .longPress ||
                                            cause ==
                                                SelectionChangedCause.drag) &&
                                        !selection.isCollapsed;
                                    if (show != _showHandles) {
                                      setState(() => _showHandles = show);
                                    }
                                  },
                                  contextMenuBuilder: (context, editable) =>
                                      _GuxSelectionMenu(
                                        editable: editable,
                                        style: widget.selectionMenuStyle,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(widget.errorText!, style: style.errorStyle),
              ),
          ],
        );
      },
    );
  }
}

class _GuxSelectionGestureBuilder
    extends TextSelectionGestureDetectorBuilder {
  _GuxSelectionGestureBuilder({required super.delegate});

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    debugPrint('LONG START ${delegate.selectionEnabled}');
    if (delegate.selectionEnabled) editableText.requestKeyboard();
    super.onSingleLongTapStart(details);
    debugPrint('SHOULD $shouldShowSelectionToolbar');
    if (shouldShowSelectionToolbar && delegate.selectionEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = delegate.editableTextKey.currentState;
        if (state != null && state.mounted && state.widget.focusNode.hasFocus) {
          state.showToolbar();
        }
      });
    }
  }
}

class _GuxSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  _GuxSelectionControls(this.color);
  final Color color;

  @override
  Size getHandleSize(double textLineHeight) => const Size.square(24);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      switch (type) {
        TextSelectionHandleType.left => const Offset(24, 0),
        TextSelectionHandleType.right => Offset.zero,
        TextSelectionHandleType.collapsed => const Offset(12, 0),
      };

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) => SizedBox.square(
    dimension: 24,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: CustomPaint(painter: _HandlePainter(color, type)),
    ),
  );
}

class _HandlePainter extends CustomPainter {
  const _HandlePainter(this.color, this.type);
  final Color color;
  final TextSelectionHandleType type;

  @override
  void paint(Canvas canvas, Size size) {
    final x = switch (type) {
      TextSelectionHandleType.left => size.width - 6,
      TextSelectionHandleType.right => 6.0,
      TextSelectionHandleType.collapsed => size.width / 2,
    };
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 1, 0, 2, 12),
        const Radius.circular(1),
      ),
      paint,
    );
    canvas.drawCircle(Offset(x, 14), 6, paint);
  }

  @override
  bool shouldRepaint(_HandlePainter oldDelegate) =>
      color != oldDelegate.color || type != oldDelegate.type;
}

class _GuxSelectionMenu extends StatelessWidget {
  const _GuxSelectionMenu({required this.editable, required this.style});
  final EditableTextState editable;
  final GuxTextSelectionMenuStyle style;

  String? _label(ContextMenuButtonItem item) =>
      item.label ??
      switch (item.kind) {
        ContextMenuButtonKind.cut => style.cutLabel,
        ContextMenuButtonKind.copy => style.copyLabel,
        ContextMenuButtonKind.paste => style.pasteLabel,
        ContextMenuButtonKind.selectAll => style.selectAllLabel,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final items = editable.contextMenuButtonItems
        .where((item) => item.onPressed != null && _label(item) != null)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final anchors = editable.contextMenuAnchors;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    return CustomSingleChildLayout(
      delegate: _MenuLayout(
        overlayBox.globalToLocal(anchors.primaryAnchor),
        overlayBox.globalToLocal(
          anchors.secondaryAnchor ?? anchors.primaryAnchor,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: style.focusColor),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
          child: IntrinsicWidth(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    _SelectionMenuItem(
                      label: _label(item)!,
                      onPressed: item.onPressed!,
                      style: style,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout(this.above, this.below);
  final Offset above;
  final Offset below;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = (size.width - childSize.width).clamp(0.0, double.infinity);
    final maxY = (size.height - childSize.height).clamp(0.0, double.infinity);
    final y = above.dy >= childSize.height
        ? above.dy - childSize.height
        : below.dy;
    return Offset(
      (above.dx - childSize.width / 2).clamp(0.0, maxX),
      y.clamp(0.0, maxY),
    );
  }

  @override
  bool shouldRelayout(_MenuLayout oldDelegate) =>
      above != oldDelegate.above || below != oldDelegate.below;
}

class _SelectionMenuItem extends StatefulWidget {
  const _SelectionMenuItem({
    required this.label,
    required this.onPressed,
    required this.style,
  });
  final String label;
  final VoidCallback onPressed;
  final GuxTextSelectionMenuStyle style;
  @override
  State<_SelectionMenuItem> createState() => _SelectionMenuItemState();
}

class _SelectionMenuItemState extends State<_SelectionMenuItem> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    onTap: widget.onPressed,
    child: FocusableActionDetector(
      onShowHoverHighlight: (value) => setState(() => _hover = value),
      onShowFocusHighlight: (value) => setState(() => _focus = value),
      mouseCursor: SystemMouseCursors.click,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: widget.onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _hover ? widget.style.hoverColor : const Color(0x00000000),
            border: _focus ? Border.all(color: widget.style.focusColor) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ExcludeSemantics(
              child: Text(
                widget.label,
                style: widget.style.textStyle.copyWith(
                  color: widget.style.foregroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
