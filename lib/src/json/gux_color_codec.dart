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

/// Shared color codec for consistent JSON serialization across all components.
///
/// Version 1: Supports #RRGGBB and #AARRGGBB formats.
/// - Preserves alpha channel including transparent black (#00000000)
/// - Handles semi-transparent values correctly
/// - Returns consistent errors for malformed input
class GuxColorCodec {
  /// Codec version for compatibility tracking.
  static const int version = 1;

  /// Parses a hex color string to a Color.
  ///
  /// Accepts:
  /// - `#RRGGBB` format (6 hex digits, assumes full opacity FF)
  /// - `#AARRGGBB` format (8 hex digits, includes alpha)
  ///
  /// Examples:
  /// - `#FF0000` → Color(0xFFFF0000) - red
  /// - `#80FF0000` → Color(0x80FF0000) - semi-transparent red
  /// - `#00000000` → Color(0x00000000) - fully transparent black
  ///
  /// Throws [FormatException] if:
  /// - Input is null or empty
  /// - Missing leading `#`
  /// - Invalid hex digit
  /// - Wrong length (not 6 or 8 hex digits after #)
  static Color parse(String hex) {
    if (hex.isEmpty) {
      throw const FormatException('Color string cannot be empty');
    }

    if (!hex.startsWith('#')) {
      throw FormatException('Color must start with #, got: $hex');
    }

    final hexCode = hex.substring(1);

    if (hexCode.length != 6 && hexCode.length != 8) {
      throw FormatException(
        'Color hex must be 6 or 8 digits after #, got ${hexCode.length}: $hex',
      );
    }

    // Validate all characters are valid hex digits
    for (int i = 0; i < hexCode.length; i++) {
      final char = hexCode[i];
      if (!_isHexDigit(char)) {
        throw FormatException(
          'Invalid hex digit at position ${i + 1}: $char in $hex',
        );
      }
    }

    try {
      if (hexCode.length == 6) {
        // #RRGGBB - prepend FF for full opacity
        return Color(int.parse('FF$hexCode', radix: 16));
      } else {
        // #AARRGGBB - use as-is
        return Color(int.parse(hexCode, radix: 16));
      }
    } on FormatException {
      throw FormatException('Failed to parse color hex: $hex');
    }
  }

  /// Converts a Color to hex string format.
  ///
  /// Returns:
  /// - `#RRGGBB` if alpha is 0xFF (fully opaque)
  /// - `#AARRGGBB` if alpha is not 0xFF (includes transparency)
  ///
  /// Examples:
  /// - Color(0xFFFF0000) → "#FF0000" (opaque red)
  /// - Color(0x80FF0000) → "#80FF0000" (semi-transparent red)
  /// - Color(0x00000000) → "#00000000" (transparent black)
  static String toHex(Color color) {
    final argb = color.toARGB32();
    final alpha = (argb >> 24) & 0xFF;

    if (alpha == 0xFF) {
      // Fully opaque - use short form #RRGGBB
      final rgb = argb & 0xFFFFFF;
      return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
    } else {
      // Has transparency - use full form #AARRGGBB
      return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
  }

  static bool _isHexDigit(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 48 && code <= 57) ||  // 0-9
           (code >= 65 && code <= 70) ||  // A-F
           (code >= 97 && code <= 102);   // a-f
  }
}
