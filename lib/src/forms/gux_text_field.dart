import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'gux_text_input.dart';
import '../utility/gux_json_utils.dart';

/// A labeled text input field with validation display.
///
/// Built on [GuxTextInput] with consistent label, placeholder, and error
/// message layout. This is the recommended text input component for most
/// use cases - use [GuxTextInput] directly only when you need a primitive
/// without labels.
///
/// The host supplies all styling through [GuxTextFieldStyle], which includes
/// separate styles for normal and error states. The field displays an optional
/// label above the input and an optional error message below it, with
/// configurable spacing.
class GuxTextField extends StatelessWidget {
  const GuxTextField({
    super.key,
    required this.controller,
    required this.style,
    this.labelText,
    this.placeholder,
    this.errorMessage,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final GuxTextFieldStyle style;
  final String? labelText;
  final String? placeholder;
  final String? errorMessage;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Create a GuxTextField from JSON
  ///
  /// Note: The controller must be provided separately as it requires
  /// stateful lifecycle management.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "labelText": "Email Address",
  ///   "placeholder": "Enter your email",
  ///   "keyboardType": "email",
  ///   "enabled": true,
  ///   "onChanged": "handleEmailChange",
  ///   "style": {
  ///     "fieldStyle": {...},
  ///     "labelStyle": {"fontSize": 14, "color": "#ECECEC"}
  ///   }
  /// }
  /// ```
  factory GuxTextField.fromJson(
    Map<String, dynamic> json, {
    required TextEditingController controller,
    required Map<String, ValueChanged<String>> actions,
    FocusNode? focusNode,
  }) {
    // Parse style
    final styleJson = json['style'];
    final Map<String, dynamic> styleMap;
    if (styleJson == null) {
      styleMap = {};
    } else if (styleJson is Map<String, dynamic>) {
      styleMap = styleJson;
    } else if (styleJson is Map) {
      styleMap = Map<String, dynamic>.from(styleJson);
    } else {
      styleMap = {};
    }

    // Parse keyboard type
    TextInputType? keyboardType;
    final keyboardTypeStr = json['keyboardType'] as String?;
    if (keyboardTypeStr != null) {
      switch (keyboardTypeStr) {
        case 'text':
          keyboardType = TextInputType.text;
          break;
        case 'multiline':
          keyboardType = TextInputType.multiline;
          break;
        case 'number':
          keyboardType = TextInputType.number;
          break;
        case 'phone':
          keyboardType = TextInputType.phone;
          break;
        case 'email':
          keyboardType = TextInputType.emailAddress;
          break;
        case 'url':
          keyboardType = TextInputType.url;
          break;
      }
    }

    // Parse text input action
    TextInputAction? textInputAction;
    final actionStr = json['textInputAction'] as String?;
    if (actionStr != null) {
      switch (actionStr) {
        case 'done':
          textInputAction = TextInputAction.done;
          break;
        case 'go':
          textInputAction = TextInputAction.go;
          break;
        case 'search':
          textInputAction = TextInputAction.search;
          break;
        case 'send':
          textInputAction = TextInputAction.send;
          break;
        case 'next':
          textInputAction = TextInputAction.next;
          break;
        case 'previous':
          textInputAction = TextInputAction.previous;
          break;
      }
    }

    final onChangedKey = json['onChanged'] as String?;
    final onSubmittedKey = json['onSubmitted'] as String?;

    return GuxTextField(
      controller: controller,
      focusNode: focusNode,
      style: GuxTextFieldStyle.fromJson(styleMap),
      labelText: json['labelText'] as String?,
      placeholder: json['placeholder'] as String?,
      errorMessage: json['errorMessage'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      obscureText: json['obscureText'] as bool? ?? false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChangedKey != null ? actions[onChangedKey] : null,
      onSubmitted: onSubmittedKey != null ? actions[onSubmittedKey] : null,
      maxLines: json['maxLines'] as int? ?? 1,
      autofocus: json['autofocus'] as bool? ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: style.labelStyle,
          ),
          SizedBox(height: style.labelSpacing),
        ],
        GuxTextInput(
          controller: controller,
          semanticsLabel: labelText ?? placeholder ?? "",
          style: errorMessage != null ? style.errorInputStyle : style.inputStyle,
          placeholder: placeholder ?? '',
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
        if (errorMessage != null) ...[
          SizedBox(height: style.errorSpacing),
          Text(
            errorMessage!,
            style: style.errorTextStyle,
          ),
        ],
      ],
    );
  }
}

/// Visual properties for [GuxTextInput].
@immutable
class GuxTextFieldStyle {
  const GuxTextFieldStyle({
    required this.inputStyle,
    required this.errorInputStyle,
    required this.labelStyle,
    required this.errorTextStyle,
    this.labelSpacing = 4.0,
    this.errorSpacing = 4.0,
  });

  final GuxTextInputStyle inputStyle;
  final GuxTextInputStyle errorInputStyle;
  final TextStyle labelStyle;
  final TextStyle errorTextStyle;
  final double labelSpacing;
  final double errorSpacing;

  /// Create from JSON
  factory GuxTextFieldStyle.fromJson(Map<String, dynamic> json) {
    // Parse fieldStyle
    final inputStyleJson = json['inputStyle'];
    final Map<String, dynamic> inputStyleMap;
    if (inputStyleJson == null) {
      inputStyleMap = {};
    } else if (inputStyleJson is Map<String, dynamic>) {
      inputStyleMap = inputStyleJson;
    } else if (inputStyleJson is Map) {
      inputStyleMap = Map<String, dynamic>.from(inputStyleJson);
    } else {
      inputStyleMap = {};
    }

    // Parse errorFieldStyle
    final errorFieldStyleJson = json['errorInputStyle'];
    final Map<String, dynamic> errorFieldStyleMap;
    if (errorFieldStyleJson == null) {
      errorFieldStyleMap = {};
    } else if (errorFieldStyleJson is Map<String, dynamic>) {
      errorFieldStyleMap = errorFieldStyleJson;
    } else if (errorFieldStyleJson is Map) {
      errorFieldStyleMap = Map<String, dynamic>.from(errorFieldStyleJson);
    } else {
      errorFieldStyleMap = {};
    }

    return GuxTextFieldStyle(
      inputStyle: GuxTextInputStyle.fromJson(inputStyleMap),
      errorInputStyle: GuxTextInputStyle.fromJson(errorFieldStyleMap),
      labelStyle: GuxJsonUtils.parseTextStyle(
              json['labelStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 14, color: Color(0xFFECECEC)),
      errorTextStyle: GuxJsonUtils.parseTextStyle(
              json['errorTextStyle'] as Map<String, dynamic>?) ??
          const TextStyle(fontSize: 12, color: Color(0xFFFF453A)),
      labelSpacing: (json['labelSpacing'] as num?)?.toDouble() ?? 4.0,
      errorSpacing: (json['errorSpacing'] as num?)?.toDouble() ?? 4.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'inputStyle': inputStyle.toJson(),
      'errorInputStyle': errorInputStyle.toJson(),
      'labelStyle': GuxJsonUtils.textStyleToJson(labelStyle),
      'errorTextStyle': GuxJsonUtils.textStyleToJson(errorTextStyle),
      'labelSpacing': labelSpacing,
      'errorSpacing': errorSpacing,
    };
  }
}
