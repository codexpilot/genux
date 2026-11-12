import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'gux_text_field.dart';

/// A labeled text input field with validation display.
///
/// Built on [GuxTextField] with consistent label, placeholder, and error
/// message layout. The host supplies all styling through [GuxTextInputStyle].
class GuxTextInput extends StatelessWidget {
  const GuxTextInput({
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
  final GuxTextInputStyle style;
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
        GuxTextField(
          controller: controller,
          style: errorMessage != null ? style.errorFieldStyle : style.fieldStyle,
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
          semanticsLabel: labelText ?? '',
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
class GuxTextInputStyle {
  const GuxTextInputStyle({
    required this.fieldStyle,
    required this.errorFieldStyle,
    required this.labelStyle,
    required this.errorTextStyle,
    this.labelSpacing = 4.0,
    this.errorSpacing = 4.0,
  });

  final GuxTextFieldStyle fieldStyle;
  final GuxTextFieldStyle errorFieldStyle;
  final TextStyle labelStyle;
  final TextStyle errorTextStyle;
  final double labelSpacing;
  final double errorSpacing;
}
