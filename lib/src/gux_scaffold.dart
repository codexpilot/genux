import 'package:flutter/widgets.dart';

/// A framework-independent scaffold for simple screen layouts.
///
/// GuxScaffold provides basic screen structure (app bar, body, bottom bar)
/// without depending on Material, Cupertino, or Fluent design systems.
///
/// Use this for simple login/setup screens. For complex workspaces,
/// use [GuxWorkspaceScaffold] instead.
///
/// Example:
/// ```dart
/// GuxScaffold(
///   appBar: GuxAppBar(
///     title: Text('Login'),
///   ),
///   body: LoginForm(),
/// )
/// ```
class GuxScaffold extends StatelessWidget {
  const GuxScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomBar,
    this.backgroundColor = const Color(0xFF1E1E1E),
  });

  final Widget? appBar;
  final Widget body;
  final Widget? bottomBar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          appBar,
          Expanded(child: body),
          bottomBar,
        ].whereType<Widget>().toList(),
      ),
    );
  }
}

/// A framework-independent app bar.
///
/// GuxAppBar provides a simple top bar with title and optional actions
/// without depending on Material, Cupertino, or Fluent design systems.
class GuxAppBar extends StatelessWidget {
  const GuxAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions = const [],
    this.height = 56.0,
    this.backgroundColor = const Color(0xFF2D2D2D),
    this.foregroundColor = const Color(0xFFFFFFFF),
  });

  final Widget? leading;
  final Widget? title;
  final List<Widget> actions;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: foregroundColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: leading!,
            ),
            const SizedBox(width: 8),
          ],
          if (title != null)
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                child: title!,
              ),
            ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              ),
            ),
        ],
      ),
    );
  }
}
