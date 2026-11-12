import 'package:flutter/widgets.dart';

/// Three single-line text values arranged vertically for a compact summary.
///
/// Labels and fallback values are supplied by the caller so the widget is
/// independent of an application's domain and localization. The full text
/// remains available to accessibility services when it is visually truncated.
class GuxSummaryLines extends StatelessWidget {
  const GuxSummaryLines({
    super.key,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    this.primaryStyle,
    this.secondaryStyle,
    this.tertiaryStyle,
    this.spacing = 4,
  }) : assert(spacing >= 0);

  final String primary;
  final String secondary;
  final String tertiary;
  final TextStyle? primaryStyle;
  final TextStyle? secondaryStyle;
  final TextStyle? tertiaryStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(primary, primaryStyle),
        SizedBox(height: spacing),
        _line(secondary, secondaryStyle),
        SizedBox(height: spacing),
        _line(tertiary, tertiaryStyle),
      ],
    );
  }

  Widget _line(String value, TextStyle? style) => Text(
    value,
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
    style: style,
  );
}
