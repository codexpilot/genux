// Copyright 2025 AIX Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';

/// Visual styling for [GuxAvatar].
class GuxAvatarStyle {
  /// Background color (used when no image is provided).
  final Color backgroundColor;

  /// Text color for initials.
  final Color textColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Size of the avatar (width and height).
  final double size;

  /// Font size for initials.
  final double fontSize;

  /// Font weight for initials.
  final FontWeight fontWeight;

  const GuxAvatarStyle({
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.textColor = const Color(0xFF1F2937),
    this.borderColor,
    this.borderWidth = 0.0,
    this.size = 40.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
  });

  /// Creates an avatar style from JSON.
  factory GuxAvatarStyle.fromJson(Map<String, dynamic> json) {
    return GuxAvatarStyle(
      backgroundColor: json['backgroundColor'] != null
          ? _parseColor(json['backgroundColor'] as String)
          : const Color(0xFFE5E7EB),
      textColor: json['textColor'] != null
          ? _parseColor(json['textColor'] as String)
          : const Color(0xFF1F2937),
      borderColor: json['borderColor'] != null
          ? _parseColor(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 40.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontWeight: _parseFontWeight(json['fontWeight'] as String?),
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': _colorToHex(backgroundColor),
      'textColor': _colorToHex(textColor),
      if (borderColor != null) 'borderColor': _colorToHex(borderColor!),
      'borderWidth': borderWidth,
      'size': size,
      'fontSize': fontSize,
      'fontWeight': _fontWeightToString(fontWeight),
    };
  }

  static Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  static FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case 'normal':
        return FontWeight.normal;
      case 'bold':
        return FontWeight.bold;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      default:
        return FontWeight.w500;
    }
  }

  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.normal) return 'normal';
    if (weight == FontWeight.bold) return 'bold';
    return 'w${weight.value}';
  }
}

/// A circular avatar displaying initials or an image.
///
/// Inspired by shadcn/ui Avatar component. Used for user profiles,
/// contact lists, or any circular representation of identity.
///
/// Example:
/// ```dart
/// GuxAvatar(
///   initials: 'JD',
///   style: GuxAvatarStyle(
///     backgroundColor: Color(0xFF3B82F6),
///     textColor: Color(0xFFFFFFFF),
///     size: 40.0,
///   ),
/// )
/// ```
class GuxAvatar extends StatelessWidget {
  /// User initials to display (if no imageUrl provided).
  final String? initials;

  /// Optional image URL (not implemented in this version).
  final String? imageUrl;

  /// Visual styling for the avatar.
  final GuxAvatarStyle style;

  const GuxAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    required this.style,
  });

  /// Creates an avatar from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxAvatar.fromJson({
  ///   'initials': 'JD',
  ///   'style': {
  ///     'backgroundColor': '#3B82F6',
  ///     'textColor': '#FFFFFF',
  ///     'size': 40.0,
  ///   },
  /// })
  /// ```
  factory GuxAvatar.fromJson(Map<String, dynamic> json) {
    final styleJson = json['style'] as Map<String, dynamic>?;

    return GuxAvatar(
      initials: json['initials'] as String?,
      imageUrl: json['imageUrl'] as String?,
      style: styleJson != null
          ? GuxAvatarStyle.fromJson(styleJson)
          : const GuxAvatarStyle(),
    );
  }

  /// Converts this avatar to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (initials != null) 'initials': initials,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'style': style.toJson(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: style.size,
      height: style.size,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        shape: BoxShape.circle,
        border: style.borderWidth > 0 && style.borderColor != null
            ? Border.all(
                color: style.borderColor!,
                width: style.borderWidth,
              )
            : null,
      ),
      child: Center(
        child: initials != null
            ? Text(
                initials!,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: style.fontSize,
                  fontWeight: style.fontWeight,
                  height: 1.0,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
