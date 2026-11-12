import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A compact circular progress indicator without a UI framework dependency.
///
/// A null [value] indicates indeterminate progress. Pass a localized
/// [semanticsLabel] and optionally [semanticsValue] for accessibility.
class GuxProgressIndicator extends StatefulWidget {
  const GuxProgressIndicator({
    super.key,
    required this.color,
    required this.trackColor,
    this.size = 16,
    this.strokeWidth = 2,
    this.value,
    this.semanticsLabel,
    this.semanticsValue,
  }) : assert(size > 0),
       assert(strokeWidth > 0 && strokeWidth <= size),
       assert(value == null || (value >= 0 && value <= 1));

  final Color color;
  final Color trackColor;
  final double size;
  final double strokeWidth;
  final double? value;
  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  State<GuxProgressIndicator> createState() => _GuxProgressIndicatorState();
}

class _GuxProgressIndicatorState extends State<GuxProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant GuxProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.value == null && !_reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    return Semantics(
      label: widget.semanticsLabel,
      value:
          widget.semanticsValue ??
          (value == null ? null : '${(value * 100).round()}%'),
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: _ProgressPainter(
              color: widget.color,
              trackColor: widget.trackColor,
              strokeWidth: widget.strokeWidth,
              value: value,
              phase: _reduceMotion ? 0.5 : _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter({
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.value,
    required this.phase,
  });

  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double? value;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.max(0.0, (size.shortestSide - strokeWidth) / 2);
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
    paint
      ..color = color
      ..strokeCap = StrokeCap.round;
    final sweep = value == null ? math.pi / 2 * phase : 2 * math.pi * value!;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) =>
      color != oldDelegate.color ||
      trackColor != oldDelegate.trackColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      value != oldDelegate.value ||
      phase != oldDelegate.phase;
}
