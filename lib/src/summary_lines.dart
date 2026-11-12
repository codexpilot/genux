import 'package:flutter/widgets.dart';
import 'json/gux_json_utils.dart';

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

  /// Create a GuxSummaryLines from JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "primary": "John Doe",
  ///   "secondary": "Software Engineer",
  ///   "tertiary": "San Francisco, CA",
  ///   "primaryStyle": {
  ///     "fontSize": 16,
  ///     "fontWeight": "600",
  ///     "color": "#FFFFFF"
  ///   },
  ///   "secondaryStyle": {
  ///     "fontSize": 14,
  ///     "color": "#CCCCCC"
  ///   },
  ///   "tertiaryStyle": {
  ///     "fontSize": 12,
  ///     "color": "#888888"
  ///   },
  ///   "spacing": 4
  /// }
  /// ```
  factory GuxSummaryLines.fromJson(Map<String, dynamic> json) {
    final primaryStyleJson = json['primaryStyle'];
    final secondaryStyleJson = json['secondaryStyle'];
    final tertiaryStyleJson = json['tertiaryStyle'];

    final Map<String, dynamic>? primaryStyleMap;
    if (primaryStyleJson == null) {
      primaryStyleMap = null;
    } else if (primaryStyleJson is Map<String, dynamic>) {
      primaryStyleMap = primaryStyleJson;
    } else if (primaryStyleJson is Map) {
      primaryStyleMap = Map<String, dynamic>.from(primaryStyleJson);
    } else {
      primaryStyleMap = null;
    }

    final Map<String, dynamic>? secondaryStyleMap;
    if (secondaryStyleJson == null) {
      secondaryStyleMap = null;
    } else if (secondaryStyleJson is Map<String, dynamic>) {
      secondaryStyleMap = secondaryStyleJson;
    } else if (secondaryStyleJson is Map) {
      secondaryStyleMap = Map<String, dynamic>.from(secondaryStyleJson);
    } else {
      secondaryStyleMap = null;
    }

    final Map<String, dynamic>? tertiaryStyleMap;
    if (tertiaryStyleJson == null) {
      tertiaryStyleMap = null;
    } else if (tertiaryStyleJson is Map<String, dynamic>) {
      tertiaryStyleMap = tertiaryStyleJson;
    } else if (tertiaryStyleJson is Map) {
      tertiaryStyleMap = Map<String, dynamic>.from(tertiaryStyleJson);
    } else {
      tertiaryStyleMap = null;
    }

    return GuxSummaryLines(
      primary: json['primary'] as String? ?? '',
      secondary: json['secondary'] as String? ?? '',
      tertiary: json['tertiary'] as String? ?? '',
      primaryStyle: primaryStyleMap != null
          ? GuxJsonUtils.parseTextStyle(primaryStyleMap)
          : null,
      secondaryStyle: secondaryStyleMap != null
          ? GuxJsonUtils.parseTextStyle(secondaryStyleMap)
          : null,
      tertiaryStyle: tertiaryStyleMap != null
          ? GuxJsonUtils.parseTextStyle(tertiaryStyleMap)
          : null,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 4,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'tertiary': tertiary,
      if (primaryStyle != null)
        'primaryStyle': GuxJsonUtils.textStyleToJson(primaryStyle!),
      if (secondaryStyle != null)
        'secondaryStyle': GuxJsonUtils.textStyleToJson(secondaryStyle!),
      if (tertiaryStyle != null)
        'tertiaryStyle': GuxJsonUtils.textStyleToJson(tertiaryStyle!),
      'spacing': spacing,
    };
  }

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
