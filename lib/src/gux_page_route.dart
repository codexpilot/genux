import 'package:flutter/widgets.dart';

/// A framework-independent page route builder.
///
/// GuxPageRoute creates page transitions without depending on Material,
/// Cupertino, or Fluent design systems. Use this instead of MaterialPageRoute
/// or CupertinoPageRoute to maintain framework independence.
///
/// Example:
/// ```dart
/// Navigator.of(context).push(
///   GuxPageRoute(
///     builder: (context) => MyScreen(),
///   ),
/// );
/// ```
class GuxPageRoute<T> extends PageRoute<T> {
  GuxPageRoute({
    required this.builder,
    super.settings,
    this.transitionType = GuxTransitionType.fade,
  });

  final WidgetBuilder builder;
  final GuxTransitionType transitionType;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case GuxTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case GuxTransitionType.slide:
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      case GuxTransitionType.none:
        return child;
    }
  }
}

/// Transition types for GuxPageRoute
enum GuxTransitionType {
  /// Fade in/out transition
  fade,

  /// Slide from right to left
  slide,

  /// No transition
  none,
}
