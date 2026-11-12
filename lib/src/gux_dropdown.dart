import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A value and its localized display text in a [GuxDropdown].
class GuxDropdownOption<T> {
  const GuxDropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final bool enabled;
}

/// Colors and typography for a [GuxDropdown].
class GuxDropdownStyle {
  const GuxDropdownStyle({
    this.backgroundColor = const Color(0xFF292929),
    this.disabledBackgroundColor,
    this.menuColor = const Color(0xFF292929),
    this.borderColor = const Color(0xFF666666),
    this.focusColor = const Color(0xFFBBBBBB),
    this.highlightColor = const Color(0xFF444444),
    this.textColor = const Color(0xFFFFFFFF),
    this.selectedColor,
    this.subtitleColor,
    this.chevronColor,
    this.disabledColor = const Color(0xFF999999),
    this.errorColor = const Color(0xFFFF8888),
    this.textStyle = const TextStyle(fontSize: 14),
    this.subtitleTextStyle,
    this.borderRadius = 4,
    this.borderWidth = 1,
    this.fieldPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.menuPadding = EdgeInsets.zero,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 10),
    this.fieldGap = 6,
    this.chevronSize = const Size(10, 6),
    this.showDisabledChevron = false,
    this.compactItems = false,
    this.itemHeight = 44,
    this.maxMenuHeight = 280,
  }) : assert(borderRadius >= 0 && borderRadius < double.infinity),
       assert(borderWidth >= 0 && borderWidth < double.infinity),
       assert(fieldGap >= 0 && fieldGap < double.infinity),
       assert(itemHeight >= 0 && itemHeight < double.infinity),
       assert(maxMenuHeight > 0 && maxMenuHeight < double.infinity);

  final Color backgroundColor;
  final Color? disabledBackgroundColor;
  final Color menuColor;
  final Color borderColor;
  final Color focusColor;
  final Color highlightColor;
  final Color textColor;
  final Color? selectedColor;
  final Color? subtitleColor;
  final Color? chevronColor;
  final Color disabledColor;
  final Color errorColor;
  final TextStyle textStyle;
  final TextStyle? subtitleTextStyle;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry fieldPadding;
  final EdgeInsetsGeometry menuPadding;
  final EdgeInsetsGeometry itemPadding;
  final double fieldGap;
  final Size chevronSize;
  final bool showDisabledChevron;

  /// Sizes each item to its text and padding, subject to [itemHeight].
  final bool compactItems;
  final double itemHeight;
  final double maxMenuHeight;
}

/// A controlled, non-editable selection field with an anchored overlay menu.
///
/// The host supplies localized labels and updates [value] after [onChanged].
/// When an error and [onRetry] are provided, the field becomes a retry action.
/// The menu requires an ancestor [Overlay], typically supplied by a Navigator.
class GuxDropdown<T> extends StatefulWidget {
  const GuxDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.valueEquals,
    this.enabled = true,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.placeholder = 'Select',
    this.emptyMessage = 'No options available',
    this.loadingMessage = 'Loading…',
    this.retryLabel = 'Retry',
    this.semanticLabel,
    this.selectedMarker,
    this.selectedMarkerSize,
    this.chevron,
    this.wrapOptions = false,
    this.loadingLeading,
    this.loadingLeadingGap = 6,
    this.style = const GuxDropdownStyle(),
  }) : assert(
         !wrapOptions || selectedMarker == null || selectedMarkerSize != null,
       ),
       assert(loadingLeadingGap >= 0 && loadingLeadingGap < double.infinity);

  final List<GuxDropdownOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool Function(T option, T value)? valueEquals;
  final bool enabled;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String placeholder;
  final String emptyMessage;
  final String loadingMessage;
  final String retryLabel;
  final String? semanticLabel;

  /// Optional visual marker for the selected option; excluded from semantics.
  final Widget? selectedMarker;

  /// The marker's layout size; required with [wrapOptions] and a marker.
  final Size? selectedMarkerSize;

  /// Optional host-provided field chevron; excluded from semantics.
  final Widget? chevron;

  /// Wraps option text and measures row heights at the actual menu width.
  final bool wrapOptions;

  /// Optional leading visual in the loading state, excluded from semantics.
  final Widget? loadingLeading;
  final double loadingLeadingGap;
  final GuxDropdownStyle style;

  @override
  State<GuxDropdown<T>> createState() => _GuxDropdownState<T>();
}

class _GuxDropdownState<T> extends State<GuxDropdown<T>>
    with WidgetsBindingObserver {
  final _anchorKey = GlobalKey();
  final _link = LayerLink();
  final _scrollController = ScrollController();
  late final FocusNode _focusNode;
  OverlayEntry? _entry;
  int _highlighted = -1;
  List<double> _rowHeights = const [];
  double _menuWidth = 0;
  Locale? _menuLocale;
  bool _hasFocus = false;

  bool get _canOpen =>
      widget.enabled &&
      !widget.isLoading &&
      widget.errorMessage == null &&
      widget.onChanged != null &&
      widget.options.isNotEmpty;
  bool get _canRetry =>
      widget.enabled &&
      !widget.isLoading &&
      widget.errorMessage != null &&
      widget.onRetry != null;
  bool get _open => _entry != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode(debugLabel: 'Gux dropdown', onKeyEvent: _onKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A local text-scale or direction override may change independently of
    // window metrics. Close so the next opening captures its latest geometry.
    MediaQuery.maybeOf(context);
    Directionality.maybeOf(context);
    DefaultTextStyle.of(context);
    Localizations.maybeLocaleOf(context);
    _close(rebuild: false);
  }

  @override
  void didUpdateWidget(covariant GuxDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_open && !_canOpen) {
      _close(rebuild: false);
    } else if (_open) {
      _rowHeights = _calculateRowHeights();
      if (_highlighted >= widget.options.length ||
          (_highlighted >= 0 && !widget.options[_highlighted].enabled)) {
        _highlighted = _firstEnabled();
      }
      _entry?.markNeedsBuild();
    }
  }

  @override
  void didChangeMetrics() {
    // The opening geometry is no longer reliable after a resize, rotation or
    // keyboard inset change. Closing also removes the overlay hit-test barrier.
    _close();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _close(rebuild: false);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _selected(GuxDropdownOption<T> option) {
    final value = widget.value;
    if (value == null) return false;
    return widget.valueEquals?.call(option.value, value) ??
        option.value == value;
  }

  int _firstEnabled() => widget.options.indexWhere((option) => option.enabled);

  double get _itemHeight {
    final fontSize = widget.style.textStyle.fontSize ?? 14;
    final scaled = MediaQuery.textScalerOf(context).scale(fontSize);
    final lines = widget.options.any((item) => item.subtitle != null)
        ? 2.8
        : 1.4;
    return math.max(widget.style.itemHeight, scaled * lines + 12);
  }

  List<double> _calculateRowHeights() {
    final style = widget.style;
    if (widget.wrapOptions) {
      final direction = Directionality.of(context);
      final textScaler = MediaQuery.textScalerOf(context);
      final menuPadding = style.menuPadding.resolve(direction);
      final itemPadding = style.itemPadding.resolve(direction);
      final width = math.max(
        0.0,
        _menuWidth - menuPadding.horizontal - itemPadding.horizontal,
      );
      final defaultStyle = DefaultTextStyle.of(context).style;
      double measure(String text, TextStyle optionStyle, double maxWidth) {
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: optionStyle.inherit
                ? defaultStyle.merge(optionStyle)
                : optionStyle,
          ),
          textDirection: direction,
          textScaler: textScaler,
          locale: _menuLocale,
        )..layout(maxWidth: maxWidth);
        final height = painter.height;
        painter.dispose();
        return height;
      }

      return [
        for (final option in widget.options)
          () {
            final marker =
                _selected(option) &&
                widget.selectedMarker != null &&
                width >= style.fieldGap + 8;
            final markerWidth = marker
                ? math.min(
                    widget.selectedMarkerSize!.width,
                    math.max(0.0, width - style.fieldGap),
                  )
                : 0.0;
            final textWidth = math.max(
              0.0,
              width - (marker ? style.fieldGap + markerWidth : 0.0),
            );
            final textHeight =
                measure(option.label, _optionTextStyle(option), textWidth) +
                (option.subtitle == null
                    ? 0
                    : measure(
                        option.subtitle!,
                        _optionSubtitleStyle(option),
                        textWidth,
                      ));
            final markerHeight = marker
                ? widget.selectedMarkerSize!.height
                : 0.0;
            return math.max(
              style.itemHeight,
              itemPadding.vertical + math.max(textHeight, markerHeight),
            );
          }(),
      ];
    }
    if (!style.compactItems) {
      return List<double>.filled(widget.options.length, _itemHeight);
    }
    double measure(TextStyle textStyle) {
      final painter = TextPainter(
        text: TextSpan(text: 'M', style: textStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final titleHeight = measure(style.textStyle);
    final subtitleStyle =
        style.subtitleTextStyle ??
        style.textStyle.copyWith(
          fontSize: (style.textStyle.fontSize ?? 14) * .85,
        );
    final subtitleHeight = measure(subtitleStyle);
    final padding = style.itemPadding
        .resolve(Directionality.of(context))
        .vertical;
    return [
      for (final option in widget.options)
        math.max(
          style.itemHeight,
          padding +
              titleHeight +
              (option.subtitle == null ? 0 : subtitleHeight),
        ),
    ];
  }

  TextStyle _optionTextStyle(GuxDropdownOption<T> option) {
    final style = widget.style;
    final selected = _selected(option);
    final color = !option.enabled
        ? style.disabledColor
        : selected
        ? style.selectedColor ?? style.textColor
        : style.textColor;
    return style.textStyle.copyWith(
      color: color,
      fontWeight: selected ? FontWeight.w600 : null,
    );
  }

  TextStyle _optionSubtitleStyle(GuxDropdownOption<T> option) {
    final style = widget.style;
    final color = !option.enabled
        ? style.disabledColor
        : style.subtitleColor ?? _optionTextStyle(option).color;
    return (style.subtitleTextStyle ??
            style.textStyle.copyWith(
              fontSize: (style.textStyle.fontSize ?? 14) * .85,
            ))
        .copyWith(color: color);
  }

  double get _menuPaddingTop =>
      widget.style.menuPadding.resolve(Directionality.of(context)).top;

  double get _menuHeight =>
      _rowHeights.fold(0.0, (total, height) => total + height) +
      widget.style.menuPadding.resolve(Directionality.of(context)).vertical;

  void _openMenu() {
    if (!_canOpen || _open) return;
    final anchor = _anchorKey.currentContext?.findRenderObject();
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject();
    if (anchor is! RenderBox ||
        overlayBox is! RenderBox ||
        overlay == null ||
        !anchor.hasSize ||
        !overlayBox.hasSize) {
      return;
    }
    final position = anchor.localToGlobal(Offset.zero, ancestor: overlayBox);
    final overlayTop = overlayBox.localToGlobal(Offset.zero).dy;
    final media = MediaQuery.maybeOf(context);
    final direction = Directionality.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    _menuLocale = Localizations.maybeLocaleOf(context);
    _menuWidth = math.min(anchor.size.width, overlayBox.size.width);
    final usableBottom = media == null
        ? overlayBox.size.height
        : math.min(
            overlayBox.size.height,
            media.size.height - media.viewInsets.bottom - overlayTop,
          );
    final below = math.max(
      0.0,
      usableBottom - position.dy - anchor.size.height - 4,
    );
    final above = math.max(0.0, position.dy - 4);
    _rowHeights = _calculateRowHeights();
    final desired = math.min(widget.style.maxMenuHeight, _menuHeight);
    final showAbove = below < desired && above > below;
    final maxHeight = math.min(
      widget.style.maxMenuHeight,
      showAbove ? above : below,
    );
    if (maxHeight <= 0) return;
    _highlighted = widget.options.indexWhere(
      (option) => option.enabled && _selected(option),
    );
    if (_highlighted < 0) _highlighted = _firstEnabled();
    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: showAbove
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              followerAnchor: showAbove
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: Offset(0, showAbove ? -4 : 4),
              child: SizedBox(
                width: _menuWidth,
                child: Directionality(
                  textDirection: direction,
                  child: media == null
                      ? _menuWithTextStyle(maxHeight, defaultTextStyle)
                      : MediaQuery(
                          data: media,
                          child: _menuWithTextStyle(
                            maxHeight,
                            defaultTextStyle,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
    setState(() {});
    _scrollToHighlight();
  }

  Widget _menuWithTextStyle(double maxHeight, TextStyle defaultTextStyle) =>
      widget.wrapOptions
      ? DefaultTextStyle(style: defaultTextStyle, child: _buildMenu(maxHeight))
      : _buildMenu(maxHeight);

  void _close({bool rebuild = true}) {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    entry.remove();
    entry.dispose();
    _highlighted = -1;
    if (rebuild && mounted) setState(() {});
  }

  void _select(int index) {
    if (!_canOpen ||
        index < 0 ||
        index >= widget.options.length ||
        !widget.options[index].enabled) {
      return;
    }
    final value = widget.options[index].value;
    _close();
    widget.onChanged?.call(value);
  }

  void _move(int direction) {
    final length = widget.options.length;
    if (length == 0) return;
    for (var step = 1; step <= length; step++) {
      final start = _highlighted < 0 ? (direction > 0 ? -1 : 0) : _highlighted;
      final next = (start + step * direction) % length;
      if (widget.options[next].enabled) {
        _highlighted = next;
        _entry?.markNeedsBuild();
        _scrollToHighlight();
        return;
      }
    }
  }

  void _scrollToHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_open ||
          !_scrollController.hasClients ||
          _highlighted < 0) {
        return;
      }
      final position = _scrollController.position;
      var top = _menuPaddingTop;
      for (var i = 0; i < _highlighted; i++) {
        top += _rowHeights[i];
      }
      final bottom = top + _rowHeights[_highlighted];
      var target = position.pixels;
      if (_rowHeights[_highlighted] > position.viewportDimension ||
          top < target) {
        target = top;
      } else if (bottom > target + position.viewportDimension) {
        target = bottom - position.viewportDimension;
      }
      _scrollController.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.tab && _open) {
      _close();
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.escape && _open) {
      _close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (_canRetry) {
        widget.onRetry!();
      } else if (_open) {
        _select(_highlighted);
      } else {
        _openMenu();
      }
      return _canRetry || _canOpen
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    if ((key == LogicalKeyboardKey.arrowDown ||
            key == LogicalKeyboardKey.arrowUp) &&
        _canOpen) {
      if (_open) {
        _move(key == LogicalKeyboardKey.arrowDown ? 1 : -1);
      } else {
        _openMenu();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildMenu(double maxHeight) {
    final style = widget.style;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.menuColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: Border.all(color: style.borderColor, width: style.borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: SizedBox(
          height: math.min(maxHeight, _menuHeight),
          child: ListView.builder(
            controller: _scrollController,
            padding: style.menuPadding,
            itemExtentBuilder: (index, _) => _rowHeights[index],
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options[index];
              final selected = _selected(option);
              return Semantics(
                button: true,
                label: option.subtitle == null
                    ? option.label
                    : '${option.label}, ${option.subtitle}',
                enabled: option.enabled,
                selected: selected,
                onTap: option.enabled ? () => _select(index) : null,
                child: ExcludeSemantics(
                  child: MouseRegion(
                    cursor: option.enabled
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    onEnter: (_) {
                      if (!option.enabled) return;
                      _highlighted = index;
                      _entry?.markNeedsBuild();
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: option.enabled ? () => _select(index) : null,
                      child: ColoredBox(
                        color: index == _highlighted
                            ? style.highlightColor
                            : const Color(0x00000000),
                        child: Padding(
                          padding: style.itemPadding,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final marker =
                                  selected &&
                                  widget.selectedMarker != null &&
                                  constraints.maxWidth >= style.fieldGap + 8;
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.label,
                                          maxLines: widget.wrapOptions
                                              ? null
                                              : 1,
                                          softWrap: widget.wrapOptions
                                              ? true
                                              : null,
                                          overflow: widget.wrapOptions
                                              ? TextOverflow.clip
                                              : TextOverflow.ellipsis,
                                          locale: widget.wrapOptions
                                              ? _menuLocale
                                              : null,
                                          style: _optionTextStyle(option),
                                        ),
                                        if (option.subtitle != null)
                                          Text(
                                            option.subtitle!,
                                            maxLines: widget.wrapOptions
                                                ? null
                                                : 1,
                                            softWrap: widget.wrapOptions
                                                ? true
                                                : null,
                                            overflow: widget.wrapOptions
                                                ? TextOverflow.clip
                                                : TextOverflow.ellipsis,
                                            locale: widget.wrapOptions
                                                ? _menuLocale
                                                : null,
                                            style: _optionSubtitleStyle(option),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (marker) ...[
                                    SizedBox(width: style.fieldGap),
                                    if (widget.wrapOptions)
                                      SizedBox(
                                        width: math.min(
                                          widget.selectedMarkerSize!.width,
                                          math.max(
                                            0.0,
                                            constraints.maxWidth -
                                                style.fieldGap,
                                          ),
                                        ),
                                        height:
                                            widget.selectedMarkerSize!.height,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: widget.selectedMarker!,
                                        ),
                                      )
                                    else
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: widget.selectedMarker!,
                                        ),
                                      ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    assert(style.chevronSize.width >= 0 && style.chevronSize.width.isFinite);
    assert(style.chevronSize.height >= 0 && style.chevronSize.height.isFinite);
    assert(
      widget.selectedMarkerSize == null ||
          (widget.selectedMarkerSize!.width >= 0 &&
              widget.selectedMarkerSize!.width.isFinite &&
              widget.selectedMarkerSize!.height >= 0 &&
              widget.selectedMarkerSize!.height.isFinite),
    );
    final selected = widget.options.where(_selected).firstOrNull;
    final status = widget.isLoading
        ? widget.loadingMessage
        : widget.errorMessage ??
              (widget.options.isEmpty ? widget.emptyMessage : null);
    final text = status ?? selected?.label ?? widget.placeholder;
    final active = _canOpen || _canRetry;
    final foreground = widget.errorMessage != null && !widget.isLoading
        ? style.errorColor
        : active
        ? style.textColor
        : style.disabledColor;
    final semanticsLabel = widget.semanticLabel;
    return CompositedTransformTarget(
      link: _link,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) {
          setState(() => _hasFocus = focused);
          if (!focused) _close();
        },
        canRequestFocus: active,
        skipTraversal: !active,
        child: Semantics(
          button: true,
          enabled: active,
          label: _canRetry
              ? '${semanticsLabel == null ? '' : '$semanticsLabel, '}$text, ${widget.retryLabel}'
              : semanticsLabel,
          value: _canRetry ? null : text,
          expanded: _canOpen ? _open : null,
          onTap: active ? _activate : null,
          child: ExcludeSemantics(
            child: GestureDetector(
              key: _anchorKey,
              behavior: HitTestBehavior.opaque,
              onTap: active ? _activate : null,
              child: MouseRegion(
                cursor: active
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.enabled && status == null
                        ? style.backgroundColor
                        : style.disabledBackgroundColor ??
                              style.backgroundColor,
                    border: Border.all(
                      color: widget.errorMessage != null && !widget.isLoading
                          ? style.errorColor
                          : _hasFocus
                          ? style.focusColor
                          : style.borderColor,
                      width: style.borderWidth,
                    ),
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final requested = style.fieldPadding.resolve(
                        Directionality.of(context),
                      );
                      final scaleX =
                          constraints.hasBoundedWidth &&
                              requested.horizontal > 0
                          ? math.min(
                              1.0,
                              constraints.maxWidth / (requested.horizontal * 2),
                            )
                          : 1.0;
                      final scaleY =
                          constraints.hasBoundedHeight && requested.vertical > 0
                          ? math.min(
                              1.0,
                              constraints.maxHeight / (requested.vertical * 2),
                            )
                          : 1.0;
                      final showChevron =
                          status == null &&
                          (_canOpen || style.showDisabledChevron) &&
                          (!constraints.hasBoundedWidth ||
                              constraints.maxWidth >=
                                  requested.horizontal * scaleX +
                                      style.fieldGap +
                                      style.chevronSize.width);
                      final showLoadingLeading =
                          widget.isLoading &&
                          widget.loadingLeading != null &&
                          (!constraints.hasBoundedWidth ||
                              constraints.maxWidth >=
                                  requested.horizontal * scaleX +
                                      widget.loadingLeadingGap +
                                      8);
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          requested.left * scaleX,
                          requested.top * scaleY,
                          requested.right * scaleX,
                          requested.bottom * scaleY,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showLoadingLeading) ...[
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: widget.loadingLeading!,
                                ),
                              ),
                              SizedBox(width: widget.loadingLeadingGap),
                            ],
                            Flexible(
                              child: Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style.textStyle.copyWith(
                                  color: foreground,
                                ),
                              ),
                            ),
                            if (showChevron) ...[
                              SizedBox(width: style.fieldGap),
                              SizedBox.fromSize(
                                size: style.chevronSize,
                                child: widget.chevron == null
                                    ? CustomPaint(
                                        painter: _ChevronPainter(
                                          _canOpen
                                              ? style.chevronColor ?? foreground
                                              : style.disabledColor,
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: widget.chevron!,
                                      ),
                              ),
                            ],
                            if (_canRetry &&
                                (!constraints.hasBoundedWidth ||
                                    constraints.maxWidth >= 72)) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.retryLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.textStyle.copyWith(
                                    color: foreground,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _activate() {
    if (_canRetry) {
      widget.onRetry!();
    } else if (_canOpen) {
      _focusNode.requestFocus();
      if (_open) {
        _close();
      } else {
        _openMenu();
      }
    }
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
