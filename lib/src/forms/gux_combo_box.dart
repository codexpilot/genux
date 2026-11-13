import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'gux_text_field.dart';
import 'gux_text_input.dart';

/// An option in a [GuxComboBox] menu.
///
/// Each option has a [value] (the data returned when selected), a [label]
/// (displayed text), an optional [subtitle] (secondary text shown below the
/// label), and an [enabled] flag to allow/prevent selection.
///
/// Example:
/// ```dart
/// const GuxComboBoxOption(
///   value: 'us',
///   label: 'United States',
///   subtitle: 'North America',
///   enabled: true,
/// )
/// ```
class GuxComboBoxOption<T> {
  const GuxComboBoxOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  /// The value returned when this option is selected.
  final T value;

  /// The primary text displayed for this option.
  final String label;

  /// Optional secondary text displayed below the label.
  final String? subtitle;

  /// Whether this option can be selected. Defaults to true.
  final bool enabled;
}

/// Visual properties for [GuxComboBox].
///
/// Controls the appearance of the combo box field, menu, and items.
/// All colors, spacing, and elevation can be customized.
///
/// Example:
/// ```dart
/// const GuxComboBoxStyle(
///   menuBackgroundColor: Color(0xFF1E1E1E),
///   itemHighlightColor: Color(0xFF0078D4),
///   textStyle: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
///   itemPadding: EdgeInsets.all(12),
///   menuElevation: 8.0,
/// )
/// ```
@immutable
class GuxComboBoxStyle {
  const GuxComboBoxStyle({
    this.fieldStyle,
    this.menuBackgroundColor = const Color(0xFF292929),
    this.itemHighlightColor = const Color(0xFF444444),
    this.itemDisabledColor = const Color(0xFF666666),
    this.textStyle = const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
    this.subtitleStyle = const TextStyle(fontSize: 14, color: Color(0xFF999999)),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.menuElevation = 4.0,
    this.overlayElevation = 8.0,
    this.overlayDimColor = const Color(0x40000000),
  });

  /// Optional custom style for the text field. If null, uses default styling.
  final GuxTextFieldStyle? fieldStyle;

  /// Background color of the menu popup.
  final Color menuBackgroundColor;

  /// Color when hovering or navigating to an item with keyboard.
  final Color itemHighlightColor;

  /// Color used for disabled items.
  final Color itemDisabledColor;

  /// Text style for option labels.
  final TextStyle textStyle;

  /// Text style for option subtitles.
  final TextStyle subtitleStyle;

  /// Padding around each menu item.
  final EdgeInsets itemPadding;

  /// Elevation (shadow depth) for editable mode menu.
  final double menuElevation;

  /// Elevation (shadow depth) for non-editable overlay mode.
  final double overlayElevation;

  /// Background dim color for non-editable overlay mode.
  final Color overlayDimColor;
}

/// Menu positioning behavior.
enum MenuBehavior {
  /// Automatically position below field, or above if no space.
  auto,

  /// Always position below the field.
  alwaysBelow,

  /// Always position above the field.
  alwaysAbove,
}

/// Menu animation style.
enum MenuAnimation {
  /// No animation.
  none,

  /// Fade in.
  fade,

  /// Slide from top/bottom.
  slide,

  /// Both fade and slide.
  both,
}

/// A combo box supporting both dropdown and editable modes.
///
/// [GuxComboBox] provides two distinct interaction patterns controlled by the
/// [editable] parameter:
///
/// ## Non-editable mode (dropdown)
/// When [editable] is `false` (default), behaves as a traditional dropdown:
/// - Click to open menu
/// - Menu overlays centered over the field with dimmed background
/// - Select from list only, no typing
/// - Best for: predefined choices, status selection, category pickers
///
/// ## Editable mode (autocomplete)
/// When [editable] is `true`, allows typing to filter options:
/// - Type to filter options by label text
/// - Menu appears beneath field (or above if insufficient space below)
/// - Can select from filtered results or type freely
/// - Best for: large lists, country/city selectors, searchable catalogs
///
/// ## Features
/// - Generic type support for any value type
/// - Keyboard navigation (Arrow keys, Enter, Escape)
/// - Disabled options
/// - Optional subtitles for options
/// - Configurable filtering function
/// - Customizable animations (fade, slide, both, none)
/// - Material Design 48px item height (configurable)
/// - Maximum visible items (default 5, scrollable beyond)
///
/// ## Example - Non-editable dropdown
/// ```dart
/// String? selectedCountry;
///
/// GuxComboBox<String>(
///   options: [
///     GuxComboBoxOption(value: 'us', label: 'United States'),
///     GuxComboBoxOption(value: 'ca', label: 'Canada'),
///     GuxComboBoxOption(value: 'mx', label: 'Mexico'),
///   ],
///   value: selectedCountry,
///   onChanged: (value) => setState(() => selectedCountry = value),
///   labelText: 'Country',
///   placeholder: 'Select a country',
///   editable: false,  // Dropdown mode
///   style: const GuxComboBoxStyle(),
/// )
/// ```
///
/// ## Example - Editable with custom filter
/// ```dart
/// GuxComboBox<String>(
///   options: cities,
///   value: selectedCity,
///   onChanged: (value) => setState(() => selectedCity = value),
///   labelText: 'City',
///   placeholder: 'Type to search',
///   editable: true,  // Autocomplete mode
///   filterOptions: (options, query) {
///     // Custom filter: starts with query (case-insensitive)
///     final lower = query.toLowerCase();
///     return options
///       .where((opt) => opt.label.toLowerCase().startsWith(lower))
///       .toList();
///   },
///   maxVisibleItems: 8,
///   menuAnimation: MenuAnimation.both,
///   style: const GuxComboBoxStyle(),
/// )
/// ```
///
/// ## Example - With subtitles and disabled options
/// ```dart
/// GuxComboBox<String>(
///   options: [
///     GuxComboBoxOption(
///       value: 'premium',
///       label: 'Premium Plan',
///       subtitle: '\$29/month',
///     ),
///     GuxComboBoxOption(
///       value: 'enterprise',
///       label: 'Enterprise Plan',
///       subtitle: 'Contact sales',
///       enabled: false,  // Disabled option
///     ),
///   ],
///   value: selectedPlan,
///   onChanged: (value) => setState(() => selectedPlan = value),
///   labelText: 'Subscription',
///   style: const GuxComboBoxStyle(),
/// )
/// ```
class GuxComboBox<T> extends StatefulWidget {
  const GuxComboBox({
    super.key,
    required this.options,
    this.value,
    required this.onChanged,
    this.editable = false,
    this.labelText,
    this.placeholder,
    this.errorMessage,
    this.filterOptions,
    this.maxVisibleItems = 5,
    this.maxMenuHeight,
    this.itemHeight = 48.0,
    this.menuBehavior = MenuBehavior.auto,
    this.menuAnimation = MenuAnimation.both,
    this.style = const GuxComboBoxStyle(),
  });

  /// The list of selectable options.
  final List<GuxComboBoxOption<T>> options;

  /// The currently selected value, or null if nothing is selected.
  final T? value;

  /// Called when the user selects an option.
  final ValueChanged<T>? onChanged;

  /// When true, allows typing to filter options (autocomplete mode).
  /// When false, select-only dropdown with overlay menu. Defaults to false.
  final bool editable;

  /// Optional label displayed above the field.
  final String? labelText;

  /// Placeholder text shown when no value is selected.
  final String? placeholder;

  /// Optional error message displayed below the field.
  final String? errorMessage;

  /// Custom filter function for editable mode.
  ///
  /// Receives the full list of options and the current query text.
  /// Returns the filtered list to display. If null, uses default
  /// case-insensitive contains matching on option labels.
  ///
  /// Example:
  /// ```dart
  /// filterOptions: (options, query) {
  ///   final lower = query.toLowerCase();
  ///   return options
  ///     .where((opt) => opt.label.toLowerCase().startsWith(lower))
  ///     .toList();
  /// }
  /// ```
  final List<GuxComboBoxOption<T>> Function(
    List<GuxComboBoxOption<T>> options,
    String query,
  )? filterOptions;

  /// Maximum number of visible items before scrolling. Defaults to 5.
  ///
  /// The menu height is calculated as `maxVisibleItems * itemHeight`.
  /// If the filtered results have fewer items, the menu shrinks to fit.
  final int maxVisibleItems;

  /// Maximum menu height in pixels.
  ///
  /// Overrides [maxVisibleItems] if set. Useful for precise control
  /// over menu size regardless of item height.
  final double? maxMenuHeight;

  /// Height of each menu item in pixels.
  ///
  /// Defaults to 48.0 (Material Design standard). Increase if using
  /// larger fonts or Myanmar text that needs more vertical space.
  final double itemHeight;

  /// How to position the menu relative to the field.
  ///
  /// - [MenuBehavior.auto]: Automatically position below field, or above if
  ///   insufficient space below (editable mode only).
  /// - [MenuBehavior.alwaysBelow]: Always position below (editable mode only).
  /// - [MenuBehavior.alwaysAbove]: Always position above (editable mode only).
  ///
  /// Non-editable mode always uses centered overlay positioning.
  final MenuBehavior menuBehavior;

  /// Animation style for menu appearance.
  ///
  /// - [MenuAnimation.none]: No animation, instant display.
  /// - [MenuAnimation.fade]: Fade in/out.
  /// - [MenuAnimation.slide]: Slide from above/below.
  /// - [MenuAnimation.both]: Fade and slide combined (default).
  final MenuAnimation menuAnimation;

  /// Visual styling for the combo box.
  final GuxComboBoxStyle style;

  @override
  State<GuxComboBox<T>> createState() => _GuxComboBoxState<T>();
}

class _GuxComboBoxState<T> extends State<GuxComboBox<T>>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  final _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  int _highlightedIndex = -1;
  List<GuxComboBoxOption<T>> _filteredOptions = [];
  bool _showAbove = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _updateTextFromValue();
    _focusNode.addListener(_onFocusChange);

    if (widget.menuAnimation != MenuAnimation.none) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      if (widget.menuAnimation == MenuAnimation.fade ||
          widget.menuAnimation == MenuAnimation.both) {
        _fadeAnimation = CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOut,
        );
      }

      if (widget.menuAnimation == MenuAnimation.slide ||
          widget.menuAnimation == MenuAnimation.both) {
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOut,
        ));
      }
    }
  }

  @override
  void didUpdateWidget(covariant GuxComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateTextFromValue();
    }
    if (oldWidget.options != widget.options) {
      _updateFilteredOptions(_controller.text);
    }
  }

  @override
  void dispose() {
    _closeMenu();
    _controller.dispose();
    _focusNode.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _updateTextFromValue() {
    if (widget.value == null) {
      _controller.text = '';
      return;
    }

    final option = widget.options.cast<GuxComboBoxOption<T>?>().firstWhere(
      (opt) => opt?.value == widget.value,
      orElse: () => null,
    );

    if (option != null) {
      _controller.text = option.label;
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      if (!widget.editable) {
        // Non-editable: open full menu on focus
        _showMenu();
      }
    } else {
      _closeMenu();
    }
  }

  void _onTextChanged(String text) {
    if (!widget.editable) return;

    _updateFilteredOptions(text);

    if (text.isNotEmpty) {
      _showMenu();
    } else {
      _closeMenu();
    }
  }

  void _updateFilteredOptions(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredOptions = widget.options;
      } else if (widget.filterOptions != null) {
        _filteredOptions = widget.filterOptions!(widget.options, text);
      } else {
        // Default: case-insensitive contains
        final lower = text.toLowerCase();
        _filteredOptions = widget.options
            .where((opt) => opt.label.toLowerCase().contains(lower))
            .toList();
      }

      _highlightedIndex = _filteredOptions.isEmpty ? -1 : 0;
    });
  }

  void _showMenu() {
    if (_overlayEntry != null) return; // Already showing
    if (_filteredOptions.isEmpty) return;

    // Calculate positioning
    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final fieldSize = renderBox.size;
    final fieldPosition = renderBox.localToGlobal(Offset.zero);

    // Use View.of for framework-free screen size access
    final view = View.of(context);
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    final paddingTop = view.padding.top / view.devicePixelRatio;
    final paddingBottom = view.padding.bottom / view.devicePixelRatio;

    final spaceBelow = screenHeight - fieldPosition.dy - fieldSize.height - paddingBottom - 8;
    final spaceAbove = fieldPosition.dy - paddingTop - 8;

    final menuHeight = _calculateMenuHeight();

    // Decide position based on mode and available space
    if (widget.editable) {
      // Editable: prefer below, use above if no space
      if (widget.menuBehavior == MenuBehavior.alwaysAbove) {
        _showAbove = true;
      } else if (widget.menuBehavior == MenuBehavior.alwaysBelow) {
        _showAbove = false;
      } else {
        _showAbove = spaceBelow < menuHeight && spaceAbove > spaceBelow;
      }
    } else {
      // Non-editable: overlay centered (ignore _showAbove)
      _showAbove = false;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _MenuOverlay<T>(
        link: _layerLink,
        options: _filteredOptions,
        highlightedIndex: _highlightedIndex,
        onSelect: _selectOption,
        onHighlight: (index) {
          setState(() => _highlightedIndex = index);
          _overlayEntry?.markNeedsBuild();
        },
        fieldKey: _fieldKey,
        isEditableMode: widget.editable,
        showAbove: _showAbove,
        maxHeight: _showAbove ? spaceAbove : spaceBelow,
        style: widget.style,
        itemHeight: widget.itemHeight,
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController?.forward(from: 0.0);
  }

  void _closeMenu() {
    _animationController?.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });

    if (_animationController == null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _selectOption(int index) {
    if (index < 0 || index >= _filteredOptions.length) return;

    final option = _filteredOptions[index];
    if (!option.enabled) return;

    widget.onChanged?.call(option.value);
    _controller.text = option.label;
    _closeMenu();

    if (widget.editable) {
      _focusNode.unfocus();
    }
  }

  double _calculateMenuHeight() {
    final itemCount = math.min(_filteredOptions.length, widget.maxVisibleItems);
    final calculatedHeight = widget.itemHeight * itemCount;

    if (widget.maxMenuHeight != null) {
      return math.min(calculatedHeight, widget.maxMenuHeight!);
    }

    return calculatedHeight;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      if (_overlayEntry == null && !widget.editable) {
        _showMenu();
      } else if (_filteredOptions.isNotEmpty) {
        setState(() {
          _highlightedIndex = (_highlightedIndex + 1) % _filteredOptions.length;
        });
        _overlayEntry?.markNeedsBuild();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (_overlayEntry == null && !widget.editable) {
        _showMenu();
      } else if (_filteredOptions.isNotEmpty) {
        setState(() {
          _highlightedIndex =
            (_highlightedIndex - 1 + _filteredOptions.length) % _filteredOptions.length;
        });
        _overlayEntry?.markNeedsBuild();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (_overlayEntry != null && _highlightedIndex >= 0) {
        _selectOption(_highlightedIndex);
        return KeyEventResult.handled;
      } else if (!widget.editable) {
        _showMenu();
        return KeyEventResult.handled;
      }
    }

    if (key == LogicalKeyboardKey.escape) {
      if (_overlayEntry != null) {
        _closeMenu();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _fieldKey,
      link: _layerLink,
      child: Focus(
        onKeyEvent: _handleKey,
        child: widget.editable
          ? GuxTextField(
              controller: _controller,
              focusNode: _focusNode,
              labelText: widget.labelText,
              placeholder: widget.placeholder,
              errorMessage: widget.errorMessage,
              enabled: widget.onChanged != null,
              onChanged: _onTextChanged,
              style: widget.style.fieldStyle ?? _defaultFieldStyle(),
            )
          : GestureDetector(
              onTap: () {
                _focusNode.requestFocus();
                if (_overlayEntry == null) {
                  _showMenu();
                }
              },
              child: GuxTextField(
                controller: _controller,
                focusNode: _focusNode,
                labelText: widget.labelText,
                placeholder: widget.placeholder,
                errorMessage: widget.errorMessage,
                enabled: widget.onChanged != null,
                style: widget.style.fieldStyle ?? _defaultFieldStyle(),
              ),
            ),
      ),
    );
  }

  GuxTextFieldStyle _defaultFieldStyle() {
    const inputStyle = GuxTextInputStyle(
      textStyle: TextStyle(fontSize: 16, color: Color(0xFFECECEC)),
      backgroundColor: Color(0xFF252525),
      disabledBackgroundColor: Color(0xFF1F1F1F),
      borderColor: Color(0xFF484848),
      focusedBorderColor: Color(0xFF3B82F6),
      errorBorderColor: Color(0xFFFF453A),
      cursorColor: Color(0xFF3B82F6),
      selectionColor: Color(0x803B82F6),
      placeholderStyle: TextStyle(fontSize: 16, color: Color(0xFF8E8E8E)),
      errorStyle: TextStyle(fontSize: 12, color: Color(0xFFFF453A)),
    );

    return const GuxTextFieldStyle(
      inputStyle: inputStyle,
      errorInputStyle: inputStyle,
      labelStyle: TextStyle(fontSize: 14, color: Color(0xFFECECEC)),
      errorTextStyle: TextStyle(fontSize: 12, color: Color(0xFFFF453A)),
      labelSpacing: 4.0,
      errorSpacing: 4.0,
    );
  }
}

class _MenuOverlay<T> extends StatelessWidget {
  const _MenuOverlay({
    required this.link,
    required this.options,
    required this.highlightedIndex,
    required this.onSelect,
    required this.onHighlight,
    required this.fieldKey,
    required this.isEditableMode,
    required this.showAbove,
    required this.maxHeight,
    required this.style,
    required this.itemHeight,
    this.fadeAnimation,
    this.slideAnimation,
  });

  final LayerLink link;
  final List<GuxComboBoxOption<T>> options;
  final int highlightedIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onHighlight;
  final GlobalKey fieldKey;
  final bool isEditableMode;
  final bool showAbove;
  final double maxHeight;
  final GuxComboBoxStyle style;
  final double itemHeight;
  final Animation<double>? fadeAnimation;
  final Animation<Offset>? slideAnimation;

  @override
  Widget build(BuildContext context) {
    Widget menu = _buildMenuContent(context);

    // Apply animations
    if (fadeAnimation != null) {
      menu = FadeTransition(
        opacity: fadeAnimation!,
        child: menu,
      );
    }

    if (slideAnimation != null) {
      menu = SlideTransition(
        position: slideAnimation!,
        child: menu,
      );
    }

    if (isEditableMode) {
      return _buildEditableMenu(context, menu);
    } else {
      return _buildOverlayMenu(context, menu);
    }
  }

  Widget _buildEditableMenu(BuildContext context, Widget menu) {
    final renderBox = fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final fieldSize = renderBox.size;

    return CompositedTransformFollower(
      link: link,
      targetAnchor: showAbove ? Alignment.topLeft : Alignment.bottomLeft,
      followerAnchor: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
      child: Container(
        width: fieldSize.width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: menu,
      ),
    );
  }

  Widget _buildOverlayMenu(BuildContext context, Widget menu) {
    final renderBox = fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final fieldSize = renderBox.size;
    final fieldPosition = renderBox.localToGlobal(Offset.zero);
    final menuHeight = math.min(itemHeight * options.length, maxHeight);

    // Center the menu over the field
    final menuTop = fieldPosition.dy + (fieldSize.height / 2) - (menuHeight / 2);

    return Stack(
      children: [
        // Dim background
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              // Close menu when tapping outside
            },
            child: Container(
              color: style.overlayDimColor,
            ),
          ),
        ),
        // Centered menu
        Positioned(
          left: fieldPosition.dx,
          width: fieldSize.width,
          top: menuTop,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: menu,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    final elevation = isEditableMode ? style.menuElevation : style.overlayElevation;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.menuBackgroundColor,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isHighlighted = index == highlightedIndex;
          final isEnabled = option.enabled;

          return GestureDetector(
            onTap: isEnabled ? () => onSelect(index) : null,
            child: MouseRegion(
              onEnter: (_) {
                if (isEnabled) onHighlight(index);
              },
              cursor: isEnabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Container(
                height: itemHeight,
                color: isHighlighted && isEnabled
                    ? style.itemHighlightColor
                    : const Color(0x00000000), // Transparent
                padding: style.itemPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            option.label,
                            style: style.textStyle.copyWith(
                              color: isEnabled
                                ? style.textStyle.color
                                : style.itemDisabledColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (option.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle!,
                              style: style.subtitleStyle.copyWith(
                                color: isEnabled
                                  ? style.subtitleStyle.color
                                  : style.itemDisabledColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
