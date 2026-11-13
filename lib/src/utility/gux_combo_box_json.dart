import 'package:flutter/widgets.dart';

import '../forms/gux_combo_box.dart';
import 'gux_json_utils.dart';

extension GuxComboBoxStyleJson on GuxComboBoxStyle {
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fieldStyle': fieldStyle?.toJson(),
      'menuBackgroundColor': GuxJsonUtils.colorToString(menuBackgroundColor),
      'itemHighlightColor': GuxJsonUtils.colorToString(itemHighlightColor),
      'itemDisabledColor': GuxJsonUtils.colorToString(itemDisabledColor),
      'textStyle': GuxJsonUtils.textStyleToJson(textStyle),
      'subtitleStyle': GuxJsonUtils.textStyleToJson(subtitleStyle),
      'itemPadding': GuxJsonUtils.edgeInsetsToJson(itemPadding),
      'menuElevation': menuElevation,
      'overlayElevation': overlayElevation,
      'overlayDimColor': GuxJsonUtils.colorToString(overlayDimColor),
    };
  }

  /// Create from JSON
  static GuxComboBoxStyle fromJson(Map<String, dynamic> json) {
    return GuxComboBoxStyle(
      menuBackgroundColor: GuxJsonUtils.parseColor(json['menuBackgroundColor']) ??
          const Color(0xFF292929),
      itemHighlightColor: GuxJsonUtils.parseColor(json['itemHighlightColor']) ??
          const Color(0xFF444444),
      itemDisabledColor: GuxJsonUtils.parseColor(json['itemDisabledColor']) ??
          const Color(0xFF666666),
      textStyle: GuxJsonUtils.parseTextStyle(
              json['textStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
      subtitleStyle: GuxJsonUtils.parseTextStyle(
              json['subtitleStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 14, color: Color(0xFF999999)),
      itemPadding: GuxJsonUtils.parseEdgeInsets(json['itemPadding']) ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      menuElevation: (json['menuElevation'] as num?)?.toDouble() ?? 4.0,
      overlayElevation: (json['overlayElevation'] as num?)?.toDouble() ?? 8.0,
      overlayDimColor: GuxJsonUtils.parseColor(json['overlayDimColor']) ??
          const Color(0x40000000),
    );
  }
}
