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

import 'package:flutter/widgets.dart';

import '../utility/gux_color_codec.dart';

/// Visual styling for [GuxTabs].
class GuxTabsStyle {
  /// Background color of the tab bar.
  final Color backgroundColor;

  /// Background color of active tab.
  final Color activeTabColor;

  /// Background color of inactive tabs.
  final Color inactiveTabColor;

  /// Text color for active tab.
  final Color activeTextColor;

  /// Text color for inactive tabs.
  final Color inactiveTextColor;

  /// Border color for the tab bar.
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius for tabs.
  final double borderRadius;

  /// Padding inside each tab.
  final EdgeInsets tabPadding;

  /// Font size for tab labels.
  final double fontSize;

  /// Font weight for active tab.
  final FontWeight activeFontWeight;

  /// Font weight for inactive tabs.
  final FontWeight inactiveFontWeight;

  /// Height of the tab bar.
  final double tabBarHeight;

  /// Indicator color (underline or highlight).
  final Color? indicatorColor;

  /// Indicator height in pixels.
  final double indicatorHeight;

  const GuxTabsStyle({
    this.backgroundColor = const Color(0xFFF9FAFB),
    this.activeTabColor = const Color(0xFFFFFFFF),
    this.inactiveTabColor = const Color(0x00000000),
    this.activeTextColor = const Color(0xFF1F2937),
    this.inactiveTextColor = const Color(0xFF6B7280),
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 6.0,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.fontSize = 14.0,
    this.activeFontWeight = FontWeight.w600,
    this.inactiveFontWeight = FontWeight.normal,
    this.tabBarHeight = 44.0,
    this.indicatorColor,
    this.indicatorHeight = 2.0,
  });

  /// Creates a tabs style from JSON.
  factory GuxTabsStyle.fromJson(Map<String, dynamic> json) {
    return GuxTabsStyle(
      backgroundColor: json['backgroundColor'] != null
          ? GuxColorCodec.parse(json['backgroundColor'] as String)
          : const Color(0xFFF9FAFB),
      activeTabColor: json['activeTabColor'] != null
          ? GuxColorCodec.parse(json['activeTabColor'] as String)
          : const Color(0xFFFFFFFF),
      inactiveTabColor: json['inactiveTabColor'] != null
          ? GuxColorCodec.parse(json['inactiveTabColor'] as String)
          : const Color(0x00000000),
      activeTextColor: json['activeTextColor'] != null
          ? GuxColorCodec.parse(json['activeTextColor'] as String)
          : const Color(0xFF1F2937),
      inactiveTextColor: json['inactiveTextColor'] != null
          ? GuxColorCodec.parse(json['inactiveTextColor'] as String)
          : const Color(0xFF6B7280),
      borderColor: json['borderColor'] != null
          ? GuxColorCodec.parse(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 6.0,
      tabPadding: json['tabPadding'] != null
          ? _parsePadding(json['tabPadding'] as Map<String, dynamic>)
          : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      activeFontWeight: _parseFontWeight(json['activeFontWeight'] as String?),
      inactiveFontWeight: _parseFontWeight(json['inactiveFontWeight'] as String?),
      tabBarHeight: (json['tabBarHeight'] as num?)?.toDouble() ?? 44.0,
      indicatorColor: json['indicatorColor'] != null
          ? GuxColorCodec.parse(json['indicatorColor'] as String)
          : null,
      indicatorHeight: (json['indicatorHeight'] as num?)?.toDouble() ?? 2.0,
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': GuxColorCodec.toHex(backgroundColor),
      'activeTabColor': GuxColorCodec.toHex(activeTabColor),
      'inactiveTabColor': GuxColorCodec.toHex(inactiveTabColor),
      'activeTextColor': GuxColorCodec.toHex(activeTextColor),
      'inactiveTextColor': GuxColorCodec.toHex(inactiveTextColor),
      if (borderColor != null) 'borderColor': GuxColorCodec.toHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'tabPadding': {
        'horizontal': tabPadding.horizontal / 2,
        'vertical': tabPadding.vertical / 2,
      },
      'fontSize': fontSize,
      'activeFontWeight': _fontWeightToString(activeFontWeight),
      'inactiveFontWeight': _fontWeightToString(inactiveFontWeight),
      'tabBarHeight': tabBarHeight,
      if (indicatorColor != null) 'indicatorColor': GuxColorCodec.toHex(indicatorColor!),
      'indicatorHeight': indicatorHeight,
    };
  }

  static EdgeInsets _parsePadding(Map<String, dynamic> json) {
    if (json.containsKey('horizontal') && json.containsKey('vertical')) {
      return EdgeInsets.symmetric(
        horizontal: (json['horizontal'] as num).toDouble(),
        vertical: (json['vertical'] as num).toDouble(),
      );
    }
    return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  }

  static FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case 'normal':
        return FontWeight.normal;
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.normal) return 'normal';
    if (weight == FontWeight.bold) return 'bold';
    return 'w${weight.value}';
  }
}

/// A tab item definition.
class GuxTab {
  /// Unique identifier for the tab.
  final String id;

  /// Label text displayed on the tab.
  final String label;

  /// Optional icon data (not implemented in this version).
  final String? icon;

  const GuxTab({
    required this.id,
    required this.label,
    this.icon,
  });

  /// Creates a tab from JSON.
  factory GuxTab.fromJson(Map<String, dynamic> json) {
    return GuxTab(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String?,
    );
  }

  /// Converts this tab to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      if (icon != null) 'icon': icon,
    };
  }
}

/// A tabbed interface for switching between panels.
///
/// Inspired by shadcn/ui Tabs component. Provides a clean, accessible
/// way to organize content into separate views that users can switch between.
///
/// Example:
/// ```dart
/// GuxTabs(
///   tabs: [
///     GuxTab(id: 'home', label: 'Home'),
///     GuxTab(id: 'profile', label: 'Profile'),
///     GuxTab(id: 'settings', label: 'Settings'),
///   ],
///   initialTabId: 'home',
///   onTabChanged: (tabId) => print('Switched to $tabId'),
///   style: GuxTabsStyle(
///     activeTabColor: Color(0xFFFFFFFF),
///     activeTextColor: Color(0xFF1F2937),
///   ),
///   children: {
///     'home': Text('Home content'),
///     'profile': Text('Profile content'),
///     'settings': Text('Settings content'),
///   },
/// )
/// ```
class GuxTabs extends StatefulWidget {
  /// List of tab definitions.
  final List<GuxTab> tabs;

  /// Initially selected tab ID.
  final String? initialTabId;

  /// Callback when tab selection changes.
  final ValueChanged<String>? onTabChanged;

  /// Visual styling for the tabs.
  final GuxTabsStyle style;

  /// Content widgets for each tab, keyed by tab ID.
  final Map<String, Widget> children;

  const GuxTabs({
    super.key,
    required this.tabs,
    this.initialTabId,
    this.onTabChanged,
    required this.style,
    required this.children,
  });

  /// Creates tabs from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxTabs.fromJson({
  ///   'tabs': [
  ///     {'id': 'home', 'label': 'Home'},
  ///     {'id': 'profile', 'label': 'Profile'},
  ///   ],
  ///   'initialTabId': 'home',
  ///   'style': {
  ///     'activeTabColor': '#FFFFFF',
  ///     'activeTextColor': '#1F2937',
  ///   },
  ///   'children': {
  ///     'home': {'type': 'Text', 'data': 'Home content'},
  ///     'profile': {'type': 'Text', 'data': 'Profile content'},
  ///   },
  /// })
  /// ```
  factory GuxTabs.fromJson(
    Map<String, dynamic> json, {
    Map<String, VoidCallback>? actions,
  }) {
    final tabsJson = json['tabs'] as List<dynamic>?;
    final styleJson = json['style'] as Map<String, dynamic>?;
    final childrenJson = json['children'] as Map<String, dynamic>?;

    final tabs = tabsJson
            ?.map((t) => GuxTab.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];

    final children = <String, Widget>{};
    if (childrenJson != null) {
      for (final entry in childrenJson.entries) {
        final childJson = entry.value;
        if (childJson is Map<String, dynamic>) {
          children[entry.key] = _buildChildFromJson(childJson);
        }
      }
    }

    return GuxTabs(
      tabs: tabs,
      initialTabId: json['initialTabId'] as String?,
      style: styleJson != null
          ? GuxTabsStyle.fromJson(styleJson)
          : const GuxTabsStyle(),
      children: children,
    );
  }

  static Widget _buildChildFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'Text') {
      return Text(json['data'] as String? ?? '');
    }
    // Add more widget types as needed
    return const SizedBox.shrink();
  }

  /// Converts this tabs widget to JSON.
  Map<String, dynamic> toJson() {
    return {
      'tabs': tabs.map((t) => t.toJson()).toList(),
      if (initialTabId != null) 'initialTabId': initialTabId,
      'style': style.toJson(),
      'children': children.keys.map((key) => key).toList(),
    };
  }

  @override
  State<GuxTabs> createState() => _GuxTabsState();
}

class _GuxTabsState extends State<GuxTabs> {
  late String _selectedTabId;

  @override
  void initState() {
    super.initState();
    _selectedTabId = widget.initialTabId ??
        (widget.tabs.isNotEmpty ? widget.tabs.first.id : '');
  }

  void _handleTabTap(String tabId) {
    if (_selectedTabId != tabId) {
      setState(() {
        _selectedTabId = tabId;
      });
      widget.onTabChanged?.call(tabId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab bar
        Container(
          height: widget.style.tabBarHeight,
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            border: widget.style.borderWidth > 0 && widget.style.borderColor != null
                ? Border(
                    bottom: BorderSide(
                      color: widget.style.borderColor!,
                      width: widget.style.borderWidth,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: widget.tabs.map((tab) {
              final isActive = tab.id == _selectedTabId;
              return GestureDetector(
                onTap: () => _handleTabTap(tab.id),
                child: Container(
                  padding: widget.style.tabPadding,
                  decoration: BoxDecoration(
                    color: isActive
                        ? widget.style.activeTabColor
                        : widget.style.inactiveTabColor,
                    borderRadius: BorderRadius.circular(widget.style.borderRadius),
                    border: isActive &&
                            widget.style.indicatorColor != null &&
                            widget.style.indicatorHeight > 0
                        ? Border(
                            bottom: BorderSide(
                              color: widget.style.indicatorColor!,
                              width: widget.style.indicatorHeight,
                            ),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tab.label,
                      style: TextStyle(
                        color: isActive
                            ? widget.style.activeTextColor
                            : widget.style.inactiveTextColor,
                        fontSize: widget.style.fontSize,
                        fontWeight: isActive
                            ? widget.style.activeFontWeight
                            : widget.style.inactiveFontWeight,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Tab content
        Expanded(
          child: widget.children[_selectedTabId] ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}
