import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'json/gux_json_utils.dart';
import 'json/gux_json_renderer.dart';

/// A workspace layout with optional top, bottom, and leading side regions.
///
/// The scaffold fills its bounded parent. Slot dimensions are constrained to
/// the available space on very small windows, with the top bar taking priority
/// over the bottom bar. Content inside the slots is responsible for adapting
/// to its own constraints.
class GuxWorkspaceScaffold extends StatelessWidget {
  const GuxWorkspaceScaffold({
    super.key,
    required this.body,
    required this.topBarHeight,
    required this.bottomBarHeight,
    required this.sideBarWidth,
    this.topBar,
    this.bottomBar,
    this.sideBar,
    this.backgroundColor,
    this.textStyle,
  }) : assert(topBarHeight >= 0),
       assert(bottomBarHeight >= 0),
       assert(sideBarWidth >= 0);

  final Widget body;
  final Widget? topBar;
  final Widget? bottomBar;
  final Widget? sideBar;
  final double topBarHeight;
  final double bottomBarHeight;
  final double sideBarWidth;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  /// Create a GuxWorkspaceScaffold from JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "body": {"type": "Text", "data": "Main content"},
  ///   "topBar": {"type": "Text", "data": "Top bar"},
  ///   "bottomBar": {"type": "Text", "data": "Bottom bar"},
  ///   "sideBar": {"type": "Text", "data": "Side bar"},
  ///   "topBarHeight": 48,
  ///   "bottomBarHeight": 32,
  ///   "sideBarWidth": 44,
  ///   "backgroundColor": "#1E1E1E",
  ///   "textStyle": {
  ///     "color": "#FFFFFF",
  ///     "fontSize": 14
  ///   }
  /// }
  /// ```
  factory GuxWorkspaceScaffold.fromJson(
    Map<String, dynamic> json, {
    Map<String, VoidCallback> actions = const {},
  }) {
    final textStyleJson = json['textStyle'];
    final Map<String, dynamic>? textStyleMap;
    if (textStyleJson == null) {
      textStyleMap = null;
    } else if (textStyleJson is Map<String, dynamic>) {
      textStyleMap = textStyleJson;
    } else if (textStyleJson is Map) {
      textStyleMap = Map<String, dynamic>.from(textStyleJson);
    } else {
      textStyleMap = null;
    }

    return GuxWorkspaceScaffold(
      body: GuxJsonRenderer.parseChild(json['body'], actions: actions),
      topBar: json['topBar'] != null
          ? GuxJsonRenderer.parseChild(json['topBar'], actions: actions)
          : null,
      bottomBar: json['bottomBar'] != null
          ? GuxJsonRenderer.parseChild(json['bottomBar'], actions: actions)
          : null,
      sideBar: json['sideBar'] != null
          ? GuxJsonRenderer.parseChild(json['sideBar'], actions: actions)
          : null,
      topBarHeight: (json['topBarHeight'] as num?)?.toDouble() ?? 0,
      bottomBarHeight: (json['bottomBarHeight'] as num?)?.toDouble() ?? 0,
      sideBarWidth: (json['sideBarWidth'] as num?)?.toDouble() ?? 0,
      backgroundColor: GuxJsonUtils.parseColor(json['backgroundColor']),
      textStyle: textStyleMap != null
          ? GuxJsonUtils.parseTextStyle(textStyleMap)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'topBarHeight': topBarHeight,
      'bottomBarHeight': bottomBarHeight,
      'sideBarWidth': sideBarWidth,
      if (backgroundColor != null)
        'backgroundColor': GuxJsonUtils.colorToString(backgroundColor!),
      if (textStyle != null) 'textStyle': GuxJsonUtils.textStyleToJson(textStyle!),
      // Note: body, topBar, bottomBar, sideBar widgets cannot be serialized
    };
  }

  @override
  Widget build(BuildContext context) {
    final layout = ColoredBox(
      color: backgroundColor ?? const Color(0x00000000),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final topHeight = topBar == null
              ? 0.0
              : math.min(topBarHeight, constraints.maxHeight);
          final bottomHeight = bottomBar == null
              ? 0.0
              : math.min(bottomBarHeight, constraints.maxHeight - topHeight);
          final sideWidth = sideBar == null
              ? 0.0
              : math.min(sideBarWidth, constraints.maxWidth);

          return Column(
            children: [
              if (topBar != null) SizedBox(height: topHeight, child: topBar),
              Expanded(
                child: Row(
                  children: [
                    if (sideBar != null)
                      SizedBox(width: sideWidth, child: sideBar),
                    Expanded(child: body),
                  ],
                ),
              ),
              if (bottomBar != null)
                SizedBox(height: bottomHeight, child: bottomBar),
            ],
          );
        },
      ),
    );

    return textStyle == null
        ? layout
        : DefaultTextStyle.merge(style: textStyle, child: layout);
  }
}
