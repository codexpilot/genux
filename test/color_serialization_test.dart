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
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  group('Color serialization', () {
    testWidgets('handles colors with leading zeros in hex', (tester) async {
      // Color(0xFF000001) has leading zeros: #000001
      const style = GuxBadgeStyle(
        backgroundColor: Color(0xFF000001),
        textColor: Color(0xFF00FF00),
      );

      final json = style.toJson();
      final restored = GuxBadgeStyle.fromJson(json);

      expect(restored.backgroundColor.toARGB32(), equals(style.backgroundColor.toARGB32()));
      expect(restored.textColor.toARGB32(), equals(style.textColor.toARGB32()));
    });

    testWidgets('roundtrips tabs style with various colors', (tester) async {
      const style = GuxTabsStyle(
        activeTabColor: Color(0xFF0000FF), // Blue
        inactiveTabColor: Color(0xFF808080), // Gray
        activeTextColor: Color(0xFFFFFFFF), // White
        inactiveTextColor: Color(0xFF000000), // Black
      );

      final json = style.toJson();
      final restored = GuxTabsStyle.fromJson(json);

      expect(restored.activeTabColor.toARGB32(), equals(style.activeTabColor.toARGB32()));
      expect(restored.inactiveTabColor.toARGB32(), equals(style.inactiveTabColor.toARGB32()));
      expect(restored.activeTextColor.toARGB32(), equals(style.activeTextColor.toARGB32()));
      expect(restored.inactiveTextColor.toARGB32(), equals(style.inactiveTextColor.toARGB32()));
    });

    testWidgets('handles all components with color serialization', (tester) async {
      // Test a few representative components with simpler approach
      const sliderStyle = GuxSliderStyle(thumbColor: Color(0xFF010203));
      final sliderJson = sliderStyle.toJson();
      final restoredSlider = GuxSliderStyle.fromJson(sliderJson);
      expect(restoredSlider.thumbColor.toARGB32(), equals(sliderStyle.thumbColor.toARGB32()));

      const cardStyle = GuxCardStyle(backgroundColor: Color(0xFF0A0B0C));
      final cardJson = cardStyle.toJson();
      final restoredCard = GuxCardStyle.fromJson(cardJson);
      expect(restoredCard.backgroundColor.toARGB32(), equals(cardStyle.backgroundColor.toARGB32()));

      const alertStyle = GuxAlertStyle(backgroundColor: Color(0xFF0D0E0F));
      final alertJson = alertStyle.toJson();
      final restoredAlert = GuxAlertStyle.fromJson(alertJson);
      expect(restoredAlert.backgroundColor.toARGB32(), equals(alertStyle.backgroundColor.toARGB32()));
    });

    testWidgets('preserves RGB values exactly', (tester) async {
      // Test exact RGB preservation through serialization
      const testColors = [
        Color(0xFF000000), // Black
        Color(0xFFFFFFFF), // White
        Color(0xFF123456), // Arbitrary
        Color(0xFF001122), // Leading zeros
        Color(0xFFF0F0F0), // High values
      ];

      for (final color in testColors) {
        final style = GuxBadgeStyle(
          backgroundColor: const Color(0xFFE5E7EB), // Default
          textColor: color,
        );

        final json = style.toJson();
        final restored = GuxBadgeStyle.fromJson(json);

        expect(
          restored.textColor.toARGB32(),
          equals(color.toARGB32()),
          reason: 'Color ${color.toARGB32().toRadixString(16)} should roundtrip exactly',
        );
      }
    });
  });
}
