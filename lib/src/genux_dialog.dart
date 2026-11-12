import 'package:flutter/widgets.dart';

/// A host-styled dialog surface for use with a Navigator overlay.
///
/// Labels, colors, actions, and application behavior belong to the caller.
/// The content scrolls when the available height is smaller than its contents.
/// Scrollable children must be shrink-wrapped or given finite constraints.
class GenuxDialog extends StatelessWidget {
  const GenuxDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
    this.backgroundColor = const Color(0xFF252525),
    this.titleStyle,
    this.contentStyle,
    this.padding = const EdgeInsets.all(20),
    this.insetPadding = const EdgeInsets.all(24),
    this.minWidth = 0,
    this.maxWidth = 560,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : assert(minWidth >= 0 && minWidth <= maxWidth),
       assert(maxWidth > 0);

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;
  final Color backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry insetPadding;
  final double minWidth;
  final double maxWidth;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final inheritedStyle = DefaultTextStyle.of(context).style;
    final keyboardInsets =
        MediaQuery.maybeViewInsetsOf(context) ?? EdgeInsets.zero;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Center(
        child: Padding(
          padding: insetPadding.add(keyboardInsets),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
              child: Padding(
                padding: padding,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null) ...[
                        Semantics(
                          namesRoute: true,
                          child: DefaultTextStyle(
                            style: inheritedStyle.merge(titleStyle),
                            child: title!,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (content != null) ...[
                        DefaultTextStyle(
                          style: inheritedStyle.merge(contentStyle),
                          child: content!,
                        ),
                        if (actions.isNotEmpty) const SizedBox(height: 20),
                      ],
                      if (actions.isNotEmpty)
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 6,
                          runSpacing: 6,
                          children: actions,
                        ),
                    ],
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

/// Opens a dialog without coupling its content to a UI framework.
///
/// [barrierLabel] must be supplied by the host, including localization.
Future<T?> showGenuxDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String barrierLabel,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x80000000),
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, _, _) => builder(context),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    transitionDuration: const Duration(milliseconds: 150),
  );
}
