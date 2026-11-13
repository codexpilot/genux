import 'package:flutter/widgets.dart';

/// A modal overlay that displays content centered on screen with a backdrop.
///
/// Unlike GuxDialog which is optimized for dialog patterns, GuxModal is a
/// general-purpose overlay container for any modal content.
class GuxModal extends StatelessWidget {
  const GuxModal({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF252525),
    this.padding = const EdgeInsets.all(24),
    this.insetPadding = const EdgeInsets.all(40),
    this.minWidth = 0,
    this.maxWidth = 800,
    this.minHeight = 0,
    this.maxHeight = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  })  : assert(minWidth >= 0 && minWidth <= maxWidth),
        assert(maxWidth > 0),
        assert(minHeight >= 0),
        assert(maxHeight > 0 && maxHeight >= minHeight);

  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry insetPadding;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    // Use View.of for framework-free keyboard insets access
    final view = View.of(context);
    final keyboardInsets = EdgeInsets.fromViewPadding(
      view.viewInsets,
      view.devicePixelRatio,
    );

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: Center(
        child: Padding(
          padding: insetPadding.add(keyboardInsets),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: maxWidth,
              minHeight: minHeight,
              maxHeight: maxHeight,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a modal overlay without coupling its content to a UI framework.
///
/// [barrierLabel] must be supplied by the host, including localization.
Future<T?> showGuxModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required String barrierLabel,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x80000000),
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, _, __) => builder(context),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    transitionDuration: const Duration(milliseconds: 150),
  );
}
