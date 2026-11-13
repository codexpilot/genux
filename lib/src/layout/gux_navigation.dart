import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../json/gux_json_utils.dart';
import '../json/gux_json_renderer.dart';

/// A destination or action displayed in a [GuxNavigation] rail.
///
/// [label] identifies the icon to assistive technologies. Set [onSelected] to
/// null to disable the item. Selection is controlled by the caller.
class GuxNavigationItem {
  const GuxNavigationItem({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.selected = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onSelected;
  final bool selected;

  /// Create a GuxNavigationItem from JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "icon": {"type": "Icon", "data": "home"},
  ///   "label": "Home",
  ///   "onSelected": "handleHomeSelected",
  ///   "selected": true
  /// }
  /// ```
  factory GuxNavigationItem.fromJson(
    Map<String, dynamic> json, {
    required Map<String, VoidCallback> actions,
  }) {
    final onSelectedKey = json['onSelected'] as String?;
    return GuxNavigationItem(
      icon: GuxJsonRenderer.parseChild(json['icon'], actions: actions),
      label: json['label'] as String? ?? '',
      onSelected: onSelectedKey != null ? actions[onSelectedKey] : null,
      selected: json['selected'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'selected': selected,
      // Note: icon and onSelected cannot be serialized
    };
  }
}

/// A vertical icon navigation rail with optionally bottom-aligned actions.
///
/// Items scroll when their total height exceeds the available height. The
/// caller supplies colors and icons so the rail remains independent of a
/// particular design system. A bounded height allows bottom items to align to
/// the bottom; under unbounded height they follow the other items.
class GuxNavigation extends StatelessWidget {
  const GuxNavigation({
    super.key,
    required this.items,
    this.bottomItems = const [],
    this.width = 44,
    this.itemExtent = 40,
    this.itemSpacing = 2,
    this.backgroundColor = const Color(0x00000000),
    this.selectedColor = const Color(0x22000000),
    this.hoverColor = const Color(0x11000000),
    this.focusColor = const Color(0x66000000),
    this.borderRadius = 4,
  }) : assert(width >= 0 && width < double.infinity),
       assert(itemExtent >= 0 && itemExtent < double.infinity),
       assert(itemSpacing >= 0 && itemSpacing < double.infinity),
       assert(borderRadius >= 0 && borderRadius < double.infinity);

  final List<GuxNavigationItem> items;
  final List<GuxNavigationItem> bottomItems;
  final double width;
  final double itemExtent;
  final double itemSpacing;
  final Color backgroundColor;
  final Color selectedColor;
  final Color hoverColor;
  final Color focusColor;
  final double borderRadius;

  /// Create a GuxNavigation from JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "items": [
  ///     {
  ///       "icon": {"type": "Text", "data": "🏠"},
  ///       "label": "Home",
  ///       "onSelected": "handleHome",
  ///       "selected": true
  ///     }
  ///   ],
  ///   "bottomItems": [
  ///     {
  ///       "icon": {"type": "Text", "data": "⚙️"},
  ///       "label": "Settings",
  ///       "onSelected": "handleSettings"
  ///     }
  ///   ],
  ///   "width": 44,
  ///   "itemExtent": 40,
  ///   "itemSpacing": 2,
  ///   "backgroundColor": "#252525",
  ///   "selectedColor": "#3B82F6",
  ///   "hoverColor": "#383838",
  ///   "focusColor": "#60A5FA",
  ///   "borderRadius": 4
  /// }
  /// ```
  factory GuxNavigation.fromJson(
    Map<String, dynamic> json, {
    required Map<String, VoidCallback> actions,
  }) {
    final itemsList = json['items'] as List<dynamic>?;
    final bottomItemsList = json['bottomItems'] as List<dynamic>?;

    return GuxNavigation(
      items: itemsList
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return GuxNavigationItem.fromJson(item, actions: actions);
                } else if (item is Map) {
                  return GuxNavigationItem.fromJson(
                    Map<String, dynamic>.from(item),
                    actions: actions,
                  );
                }
                throw ArgumentError('Invalid item type');
              })
              .toList() ??
          [],
      bottomItems: bottomItemsList
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return GuxNavigationItem.fromJson(item, actions: actions);
                } else if (item is Map) {
                  return GuxNavigationItem.fromJson(
                    Map<String, dynamic>.from(item),
                    actions: actions,
                  );
                }
                throw ArgumentError('Invalid item type');
              })
              .toList() ??
          [],
      width: (json['width'] as num?)?.toDouble() ?? 44,
      itemExtent: (json['itemExtent'] as num?)?.toDouble() ?? 40,
      itemSpacing: (json['itemSpacing'] as num?)?.toDouble() ?? 2,
      backgroundColor:
          GuxJsonUtils.parseColor(json['backgroundColor']) ??
              const Color(0x00000000),
      selectedColor: GuxJsonUtils.parseColor(json['selectedColor']) ??
          const Color(0x22000000),
      hoverColor: GuxJsonUtils.parseColor(json['hoverColor']) ??
          const Color(0x11000000),
      focusColor: GuxJsonUtils.parseColor(json['focusColor']) ??
          const Color(0x66000000),
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 4,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'bottomItems': bottomItems.map((item) => item.toJson()).toList(),
      'width': width,
      'itemExtent': itemExtent,
      'itemSpacing': itemSpacing,
      'backgroundColor': GuxJsonUtils.colorToString(backgroundColor),
      'selectedColor': GuxJsonUtils.colorToString(selectedColor),
      'hoverColor': GuxJsonUtils.colorToString(hoverColor),
      'focusColor': GuxJsonUtils.colorToString(focusColor),
      'borderRadius': borderRadius,
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget buildItem(GuxNavigationItem item) => _NavigationButton(
      item: item,
      extent: itemExtent,
      spacing: itemSpacing,
      selectedColor: selectedColor,
      hoverColor: hoverColor,
      focusColor: focusColor,
      borderRadius: borderRadius,
    );

    return SizedBox(
      width: width,
      child: ColoredBox(
        color: backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : 0,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in items) buildItem(item),
                    if (constraints.hasBoundedHeight) const Spacer(),
                    for (final item in bottomItems) buildItem(item),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatefulWidget {
  const _NavigationButton({
    required this.item,
    required this.extent,
    required this.spacing,
    required this.selectedColor,
    required this.hoverColor,
    required this.focusColor,
    required this.borderRadius,
  });

  final GuxNavigationItem item;
  final double extent;
  final double spacing;
  final Color selectedColor;
  final Color hoverColor;
  final Color focusColor;
  final double borderRadius;

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  final FocusNode _focusNode = FocusNode();
  bool _hovered = false;
  bool _focused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final enabled = item.onSelected != null;
    final color = item.selected
        ? widget.selectedColor
        : _hovered && enabled
        ? widget.hoverColor
        : const Color(0x00000000);
    return Padding(
      padding: EdgeInsets.all(widget.spacing),
      child: Semantics(
        button: true,
        label: item.label,
        selected: item.selected,
        enabled: enabled,
        onTap: item.onSelected,
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: _focusNode,
          mouseCursor: enabled
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
                item.onSelected?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (_) => _focusNode.requestFocus() : null,
            onTap: item.onSelected,
            child: Container(
              width: widget.extent,
              height: widget.extent,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: _focused ? Border.all(color: widget.focusColor) : null,
              ),
              child: ExcludeSemantics(
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: item.icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
