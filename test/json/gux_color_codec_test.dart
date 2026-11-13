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

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/utility/gux_color_codec.dart';
import 'package:flutter/widgets.dart';

void main() {
  group('GuxColorCodec.parse', () {
    test('parses opaque colors in #RRGGBB format', () {
      expect(GuxColorCodec.parse('#FF0000'), const Color(0xFFFF0000));
      expect(GuxColorCodec.parse('#00FF00'), const Color(0xFF00FF00));
      expect(GuxColorCodec.parse('#0000FF'), const Color(0xFF0000FF));
      expect(GuxColorCodec.parse('#FFFFFF'), const Color(0xFFFFFFFF));
      expect(GuxColorCodec.parse('#000000'), const Color(0xFF000000));
    });

    test('parses colors with alpha in #AARRGGBB format', () {
      expect(GuxColorCodec.parse('#80FF0000'), const Color(0x80FF0000));
      expect(GuxColorCodec.parse('#00000000'), const Color(0x00000000));
      expect(GuxColorCodec.parse('#7F00FF00'), const Color(0x7F00FF00));
      expect(GuxColorCodec.parse('#FF0000FF'), const Color(0xFF0000FF));
    });

    test('handles lowercase hex digits', () {
      expect(GuxColorCodec.parse('#ff0000'), const Color(0xFFFF0000));
      expect(GuxColorCodec.parse('#80ff0000'), const Color(0x80FF0000));
      expect(GuxColorCodec.parse('#aAbBcC'), const Color(0xFFAABBCC));
    });

    test('preserves transparent black', () {
      expect(GuxColorCodec.parse('#00000000'), const Color(0x00000000));
      expect((GuxColorCodec.parse('#00000000').a * 255).round(), 0);
    });

    test('preserves semi-transparent values', () {
      final semiTransparent = GuxColorCodec.parse('#80FF0000');
      expect((semiTransparent.a * 255).round(), 0x80);
      expect((semiTransparent.r * 255).round(), 0xFF);
      expect((semiTransparent.g * 255).round(), 0x00);
      expect((semiTransparent.b * 255).round(), 0x00);
    });

    test('throws on empty string', () {
      expect(
        () => GuxColorCodec.parse(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on missing # prefix', () {
      expect(
        () => GuxColorCodec.parse('FF0000'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws on wrong length', () {
      expect(() => GuxColorCodec.parse('#FFF'), throwsA(isA<FormatException>()));
      expect(() => GuxColorCodec.parse('#FFFFF'), throwsA(isA<FormatException>()));
      expect(() => GuxColorCodec.parse('#FFFFFFF'), throwsA(isA<FormatException>()));
      expect(() => GuxColorCodec.parse('#FFFFFFFFF'), throwsA(isA<FormatException>()));
    });

    test('throws on invalid hex digits', () {
      expect(() => GuxColorCodec.parse('#GGGGGG'), throwsA(isA<FormatException>()));
      expect(() => GuxColorCodec.parse('#FF00ZZ'), throwsA(isA<FormatException>()));
      expect(() => GuxColorCodec.parse('#12345G'), throwsA(isA<FormatException>()));
    });

    test('handles leading zeros in hex', () {
      expect(GuxColorCodec.parse('#000001'), const Color(0xFF000001));
      expect(GuxColorCodec.parse('#00000001'), const Color(0x00000001));
    });
  });

  group('GuxColorCodec.toHex', () {
    test('converts opaque colors to #RRGGBB format', () {
      expect(GuxColorCodec.toHex(const Color(0xFFFF0000)), '#FF0000');
      expect(GuxColorCodec.toHex(const Color(0xFF00FF00)), '#00FF00');
      expect(GuxColorCodec.toHex(const Color(0xFF0000FF)), '#0000FF');
      expect(GuxColorCodec.toHex(const Color(0xFFFFFFFF)), '#FFFFFF');
      expect(GuxColorCodec.toHex(const Color(0xFF000000)), '#000000');
    });

    test('converts colors with alpha to #AARRGGBB format', () {
      expect(GuxColorCodec.toHex(const Color(0x80FF0000)), '#80FF0000');
      expect(GuxColorCodec.toHex(const Color(0x00000000)), '#00000000');
      expect(GuxColorCodec.toHex(const Color(0x7F00FF00)), '#7F00FF00');
    });

    test('preserves transparent black', () {
      expect(GuxColorCodec.toHex(const Color(0x00000000)), '#00000000');
    });

    test('preserves semi-transparent values', () {
      expect(GuxColorCodec.toHex(const Color(0x80FFFFFF)), '#80FFFFFF');
      expect(GuxColorCodec.toHex(const Color(0x01000000)), '#01000000');
    });

    test('pads leading zeros correctly', () {
      expect(GuxColorCodec.toHex(const Color(0xFF000001)), '#000001');
      expect(GuxColorCodec.toHex(const Color(0x00000001)), '#00000001');
      expect(GuxColorCodec.toHex(const Color(0xFF001122)), '#001122');
    });

    test('uses uppercase hex digits', () {
      final hex = GuxColorCodec.toHex(const Color(0xFFAABBCC));
      expect(hex, '#AABBCC');
      expect(hex, isNot(contains(RegExp('[a-f]'))));
    });
  });

  group('GuxColorCodec roundtrip', () {
    test('roundtrips opaque colors', () {
      const colors = [
        Color(0xFFFF0000),
        Color(0xFF00FF00),
        Color(0xFF0000FF),
        Color(0xFFFFFFFF),
        Color(0xFF000000),
        Color(0xFF123456),
        Color(0xFFABCDEF),
      ];

      for (final color in colors) {
        final hex = GuxColorCodec.toHex(color);
        final parsed = GuxColorCodec.parse(hex);
        expect(parsed, color, reason: 'Roundtrip failed for $color');
      }
    });

    test('roundtrips transparent and semi-transparent colors', () {
      const colors = [
        Color(0x00000000), // fully transparent black
        Color(0x80FF0000), // semi-transparent red
        Color(0x7F00FF00), // semi-transparent green
        Color(0x01FFFFFF), // almost transparent white
        Color(0xFEFFFFFF), // almost opaque white
      ];

      for (final color in colors) {
        final hex = GuxColorCodec.toHex(color);
        final parsed = GuxColorCodec.parse(hex);
        expect(parsed, color, reason: 'Roundtrip failed for $color');
      }
    });
  });
}
