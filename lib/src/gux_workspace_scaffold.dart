import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
