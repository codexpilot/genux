import 'package:flutter/widgets.dart';
import '../forms/gux_combo_box.dart';
import 'gux_json_utils.dart';

/// JSON serialization support for GuxComboBox components.
///
/// Since GuxComboBox uses generic types, JSON serialization requires:
/// 1. A value serializer/deserializer (toJson/fromJson for the value type T)
/// 2. String-based value representation for options
///
/// This helper provides serialization for GuxComboBoxStyle and utilities
/// for building dropdown JSON with string-based values.

/// Extension to add JSON serialization to GuxComboBoxStyle
extension GuxComboBoxStyleJson on GuxComboBoxStyle {
  /// Convert GuxComboBoxStyle to JSON
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': GuxJsonUtils.colorToString(backgroundColor),
      if (disabledBackgroundColor != null)
        'disabledBackgroundColor':
            GuxJsonUtils.colorToString(disabledBackgroundColor!),
      'menuColor': GuxJsonUtils.colorToString(menuColor),
      'borderColor': GuxJsonUtils.colorToString(borderColor),
      'focusColor': GuxJsonUtils.colorToString(focusColor),
      'highlightColor': GuxJsonUtils.colorToString(highlightColor),
      'textColor': GuxJsonUtils.colorToString(textColor),
      if (selectedColor != null)
        'selectedColor': GuxJsonUtils.colorToString(selectedColor!),
      if (subtitleColor != null)
        'subtitleColor': GuxJsonUtils.colorToString(subtitleColor!),
      if (chevronColor != null)
        'chevronColor': GuxJsonUtils.colorToString(chevronColor!),
      'disabledColor': GuxJsonUtils.colorToString(disabledColor),
      'errorColor': GuxJsonUtils.colorToString(errorColor),
      'textStyle': GuxJsonUtils.textStyleToJson(textStyle),
      if (subtitleTextStyle != null)
        'subtitleTextStyle': GuxJsonUtils.textStyleToJson(subtitleTextStyle!),
      'borderRadius': borderRadius,
      'borderWidth': borderWidth,
      'fieldPadding': GuxJsonUtils.edgeInsetsToJson(fieldPadding),
      'menuPadding': GuxJsonUtils.edgeInsetsToJson(menuPadding),
      'itemPadding': GuxJsonUtils.edgeInsetsToJson(itemPadding),
      'fieldGap': fieldGap,
      'chevronSize': {
        'width': chevronSize.width,
        'height': chevronSize.height,
      },
      'showDisabledChevron': showDisabledChevron,
      'compactItems': compactItems,
      'itemHeight': itemHeight,
      'maxMenuHeight': maxMenuHeight,
    };
  }

  /// Create GuxComboBoxStyle from JSON
  static GuxComboBoxStyle fromJson(Map<String, dynamic> json) {
    final textStyleJson = json['textStyle'];
    final Map<String, dynamic>? textStyleMap;
    if (textStyleJson == null) {
      textStyleMap = null;
    } else if (textStyleJson is Map<String, dynamic>) {
      textStyleMap = textStyleJson;
    } else if (textStyleJson is Map) {
      textStyleMap = Map<String, dynamic>.from(textStyleJson);
    } else {
      textStyleMap = null;
    }

    final subtitleTextStyleJson = json['subtitleTextStyle'];
    final Map<String, dynamic>? subtitleTextStyleMap;
    if (subtitleTextStyleJson == null) {
      subtitleTextStyleMap = null;
    } else if (subtitleTextStyleJson is Map<String, dynamic>) {
      subtitleTextStyleMap = subtitleTextStyleJson;
    } else if (subtitleTextStyleJson is Map) {
      subtitleTextStyleMap = Map<String, dynamic>.from(subtitleTextStyleJson);
    } else {
      subtitleTextStyleMap = null;
    }

    final chevronSizeJson = json['chevronSize'];
    final Map<String, dynamic>? chevronSizeMap;
    if (chevronSizeJson == null) {
      chevronSizeMap = null;
    } else if (chevronSizeJson is Map<String, dynamic>) {
      chevronSizeMap = chevronSizeJson;
    } else if (chevronSizeJson is Map) {
      chevronSizeMap = Map<String, dynamic>.from(chevronSizeJson);
    } else {
      chevronSizeMap = null;
    }

    return GuxComboBoxStyle(
      backgroundColor: GuxJsonUtils.parseColor(json['backgroundColor']) ??
          const Color(0xFF292929),
      disabledBackgroundColor:
          GuxJsonUtils.parseColor(json['disabledBackgroundColor']),
      menuColor:
          GuxJsonUtils.parseColor(json['menuColor']) ?? const Color(0xFF292929),
      borderColor: GuxJsonUtils.parseColor(json['borderColor']) ??
          const Color(0xFF666666),
      focusColor:
          GuxJsonUtils.parseColor(json['focusColor']) ?? const Color(0xFFBBBBBB),
      highlightColor: GuxJsonUtils.parseColor(json['highlightColor']) ??
          const Color(0xFF444444),
      textColor:
          GuxJsonUtils.parseColor(json['textColor']) ?? const Color(0xFFFFFFFF),
      selectedColor: GuxJsonUtils.parseColor(json['selectedColor']),
      subtitleColor: GuxJsonUtils.parseColor(json['subtitleColor']),
      chevronColor: GuxJsonUtils.parseColor(json['chevronColor']),
      disabledColor: GuxJsonUtils.parseColor(json['disabledColor']) ??
          const Color(0xFF999999),
      errorColor:
          GuxJsonUtils.parseColor(json['errorColor']) ?? const Color(0xFFFF8888),
      textStyle: textStyleMap != null
          ? (GuxJsonUtils.parseTextStyle(textStyleMap) ??
              const TextStyle(fontSize: 14))
          : const TextStyle(fontSize: 14),
      subtitleTextStyle: subtitleTextStyleMap != null
          ? GuxJsonUtils.parseTextStyle(subtitleTextStyleMap)
          : null,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 4,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1,
      fieldPadding: GuxJsonUtils.parseEdgeInsets(json['fieldPadding']) ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      menuPadding:
          GuxJsonUtils.parseEdgeInsets(json['menuPadding']) ?? EdgeInsets.zero,
      itemPadding: GuxJsonUtils.parseEdgeInsets(json['itemPadding']) ??
          const EdgeInsets.symmetric(horizontal: 10),
      fieldGap: (json['fieldGap'] as num?)?.toDouble() ?? 6,
      chevronSize: chevronSizeMap != null
          ? Size(
              (chevronSizeMap['width'] as num?)?.toDouble() ?? 10,
              (chevronSizeMap['height'] as num?)?.toDouble() ?? 6,
            )
          : const Size(10, 6),
      showDisabledChevron: json['showDisabledChevron'] as bool? ?? false,
      compactItems: json['compactItems'] as bool? ?? false,
      itemHeight: (json['itemHeight'] as num?)?.toDouble() ?? 44,
      maxMenuHeight: (json['maxMenuHeight'] as num?)?.toDouble() ?? 280,
    );
  }
}

/// Helper for creating `GuxComboBox<String>` from JSON
///
/// This is the most common use case for JSON-driven UI where dropdown
/// values are string-based.
class GuxComboBoxStringJson {
  /// Create a `GuxComboBox<String>` from JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "options": [
  ///     {"value": "option1", "label": "Option 1", "subtitle": "Description", "enabled": true},
  ///     {"value": "option2", "label": "Option 2"}
  ///   ],
  ///   "value": "option1",
  ///   "onChanged": "handleChange",
  ///   "enabled": true,
  ///   "placeholder": "Select an option",
  ///   "style": { ... }
  /// }
  /// ```
  static GuxComboBox<String> fromJson(
    Map<String, dynamic> json, {
    required Map<String, void Function(String)> actions,
  }) {
    final optionsList = json['options'] as List<dynamic>?;
    final styleJson = json['style'];

    final Map<String, dynamic>? styleMap;
    if (styleJson == null) {
      styleMap = null;
    } else if (styleJson is Map<String, dynamic>) {
      styleMap = styleJson;
    } else if (styleJson is Map) {
      styleMap = Map<String, dynamic>.from(styleJson);
    } else {
      styleMap = null;
    }

    final onChangedKey = json['onChanged'] as String?;

    return GuxComboBox<String>(
      options: optionsList
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return _optionFromJson(item);
                } else if (item is Map) {
                  return _optionFromJson(Map<String, dynamic>.from(item));
                }
                throw ArgumentError('Invalid option type');
              })
              .toList() ??
          [],
      value: json['value'] as String?,
      onChanged: onChangedKey != null ? actions[onChangedKey] : null,
      enabled: json['enabled'] as bool? ?? true,
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      placeholder: json['placeholder'] as String? ?? 'Select',
      emptyMessage: json['emptyMessage'] as String? ?? 'No options available',
      loadingMessage: json['loadingMessage'] as String? ?? 'Loading…',
      semanticLabel: json['semanticLabel'] as String?,
      wrapOptions: json['wrapOptions'] as bool? ?? false,
      style: styleMap != null
          ? GuxComboBoxStyleJson.fromJson(styleMap)
          : const GuxComboBoxStyle(),
    );
  }

  static GuxComboBoxOption<String> _optionFromJson(Map<String, dynamic> json) {
    return GuxComboBoxOption<String>(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// Convert `GuxComboBox<String>` to JSON
  ///
  /// Note: This only serializes the data, not callbacks or widgets
  static Map<String, dynamic> toJson(GuxComboBox<String> dropdown) {
    return {
      'options': dropdown.options
          .map((option) => {
                'value': option.value,
                'label': option.label,
                if (option.subtitle != null) 'subtitle': option.subtitle,
                'enabled': option.enabled,
              })
          .toList(),
      if (dropdown.value != null) 'value': dropdown.value,
      'enabled': dropdown.enabled,
      'isLoading': dropdown.isLoading,
      if (dropdown.errorMessage != null) 'errorMessage': dropdown.errorMessage,
      'placeholder': dropdown.placeholder,
      'emptyMessage': dropdown.emptyMessage,
      'loadingMessage': dropdown.loadingMessage,
      if (dropdown.semanticLabel != null)
        'semanticLabel': dropdown.semanticLabel,
      'wrapOptions': dropdown.wrapOptions,
      'style': dropdown.style.toJson(),
    };
  }
}
