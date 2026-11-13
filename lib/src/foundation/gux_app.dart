import 'package:flutter/widgets.dart';

/// A framework-independent application root widget.
///
/// GuxApp provides basic application infrastructure (routing, text direction,
/// navigation) without depending on Material, Cupertino, or Fluent design
/// systems. The host supplies all styling through [textStyle] and [color].
///
/// This is a thin wrapper around [WidgetsApp] with Gux conventions:
/// - Single [home] route by default
/// - Optional [onGenerateRoute] for custom routing
/// - [builder] wraps the child in a [DefaultTextStyle]
class GuxApp extends StatelessWidget {
  const GuxApp({
    super.key,
    required this.title,
    required this.home,
    required this.color,
    required this.textStyle,
    this.onGenerateRoute,
    this.debugShowCheckedModeBanner = true,
    this.builder,
  });

  final String title;
  final Widget home;
  final Color color;
  final TextStyle textStyle;
  final RouteFactory? onGenerateRoute;
  final bool debugShowCheckedModeBanner;
  final TransitionBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: title,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      color: color,
      textStyle: textStyle,
      builder: (context, child) {
        final wrappedChild = DefaultTextStyle(
          style: textStyle,
          child: child ?? const SizedBox(),
        );
        return builder != null ? builder!(context, wrappedChild) : wrappedChild;
      },
      onGenerateRoute: onGenerateRoute ??
          (settings) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => home,
            );
          },
      onUnknownRoute: (settings) {
        // Explicit unknown route handling: fall back to home
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => home,
        );
      },
    );
  }
}
