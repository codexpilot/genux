import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/json/gux_json_utils.dart';
import 'package:flutter/widgets.dart';

void main() {
  group('GuxJsonUtils - Color Parsing', () {
    test('parses hex colors with #', () {
      expect(GuxJsonUtils.parseColor('#FF0000'), const Color(0xFFFF0000));
      expect(GuxJsonUtils.parseColor('#00FF00'), const Color(0xFF00FF00));
      expect(GuxJsonUtils.parseColor('#0000FF'), const Color(0xFF0000FF));
    });

    test('parses hex colors with alpha', () {
      expect(GuxJsonUtils.parseColor('#80FF0000'), const Color(0x80FF0000));
      expect(GuxJsonUtils.parseColor('#FF00FF00'), const Color(0xFF00FF00));
    });

    test('parses hex colors with 0x', () {
      expect(GuxJsonUtils.parseColor('0xFF0000'), const Color(0xFFFF0000));
      expect(GuxJsonUtils.parseColor('0x80FF0000'), const Color(0x80FF0000));
    });

    test('parses rgb() format', () {
      expect(GuxJsonUtils.parseColor('rgb(255, 0, 0)'), const Color(0xFFFF0000));
      expect(GuxJsonUtils.parseColor('rgb(0, 255, 0)'), const Color(0xFF00FF00));
      expect(GuxJsonUtils.parseColor('rgb(0, 0, 255)'), const Color(0xFF0000FF));
    });

    test('parses rgba() format', () {
      expect(
          GuxJsonUtils.parseColor('rgba(255, 0, 0, 0.5)'), const Color(0x80FF0000));
      expect(
          GuxJsonUtils.parseColor('rgba(0, 255, 0, 1.0)'), const Color(0xFF00FF00));
      expect(
          GuxJsonUtils.parseColor('rgba(0, 0, 255, 0.0)'), const Color(0x000000FF));
    });

    test('parses named colors', () {
      expect(GuxJsonUtils.parseColor('red'), const Color(0xFFFF0000));
      expect(GuxJsonUtils.parseColor('blue'), const Color(0xFF0000FF));
      expect(GuxJsonUtils.parseColor('transparent'), const Color(0x00000000));
      expect(GuxJsonUtils.parseColor('white'), const Color(0xFFFFFFFF));
      expect(GuxJsonUtils.parseColor('black'), const Color(0xFF000000));
    });

    test('parses Color objects', () {
      const color = Color(0xFF123456);
      expect(GuxJsonUtils.parseColor(color), color);
    });

    test('parses int values', () {
      expect(GuxJsonUtils.parseColor(0xFFFF0000), const Color(0xFFFF0000));
    });

    test('returns null for null input', () {
      expect(GuxJsonUtils.parseColor(null), null);
    });

    test('returns null for invalid input', () {
      expect(GuxJsonUtils.parseColor('invalid'), null);
      expect(GuxJsonUtils.parseColor(''), null);
    });

    test('converts color to hex string', () {
      expect(GuxJsonUtils.colorToString(const Color(0xFFFF0000)), '#ffff0000');
      expect(GuxJsonUtils.colorToString(const Color(0x80FF0000)), '#80ff0000');
    });
  });

  group('GuxJsonUtils - EdgeInsets Parsing', () {
    test('parses number as all sides', () {
      expect(GuxJsonUtils.parseEdgeInsets(16), const EdgeInsets.all(16));
      expect(GuxJsonUtils.parseEdgeInsets(8.5), const EdgeInsets.all(8.5));
    });

    test('parses object with all', () {
      expect(GuxJsonUtils.parseEdgeInsets({'all': 16}), const EdgeInsets.all(16));
    });

    test('parses object with horizontal/vertical', () {
      expect(
        GuxJsonUtils.parseEdgeInsets({'horizontal': 16, 'vertical': 8}),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });

    test('parses object with individual sides', () {
      expect(
        GuxJsonUtils.parseEdgeInsets({
          'left': 1,
          'top': 2,
          'right': 3,
          'bottom': 4,
        }),
        const EdgeInsets.only(left: 1, top: 2, right: 3, bottom: 4),
      );
    });

    test('parses EdgeInsets objects', () {
      const insets = EdgeInsets.all(10);
      expect(GuxJsonUtils.parseEdgeInsets(insets), insets);
    });

    test('returns null for null input', () {
      expect(GuxJsonUtils.parseEdgeInsets(null), null);
    });

    test('converts EdgeInsets to JSON - all equal', () {
      final json = GuxJsonUtils.edgeInsetsToJson(const EdgeInsets.all(16));
      expect(json, {'all': 16.0});
    });

    test('converts EdgeInsets to JSON - symmetric', () {
      final json = GuxJsonUtils.edgeInsetsToJson(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      expect(json, {'horizontal': 16.0, 'vertical': 8.0});
    });

    test('converts EdgeInsets to JSON - individual', () {
      final json = GuxJsonUtils.edgeInsetsToJson(
          const EdgeInsets.only(left: 1, top: 2, right: 3, bottom: 4));
      expect(json, {'left': 1.0, 'top': 2.0, 'right': 3.0, 'bottom': 4.0});
    });
  });

  group('GuxJsonUtils - BorderRadius Parsing', () {
    test('parses number as circular', () {
      expect(GuxJsonUtils.parseBorderRadius(8),
          const BorderRadius.all(Radius.circular(8)));
    });

    test('parses object with circular', () {
      expect(GuxJsonUtils.parseBorderRadius({'circular': 8}),
          const BorderRadius.all(Radius.circular(8)));
    });

    test('parses object with individual corners', () {
      expect(
        GuxJsonUtils.parseBorderRadius({
          'topLeft': 1,
          'topRight': 2,
          'bottomLeft': 3,
          'bottomRight': 4,
        }),
        const BorderRadius.only(
          topLeft: Radius.circular(1),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(4),
        ),
      );
    });

    test('returns null for null input', () {
      expect(GuxJsonUtils.parseBorderRadius(null), null);
    });
  });

  group('GuxJsonUtils - TextStyle Parsing', () {
    test('parses complete TextStyle', () {
      final style = GuxJsonUtils.parseTextStyle({
        'fontSize': 16,
        'fontWeight': 'bold',
        'fontStyle': 'italic',
        'color': '#FF0000',
        'letterSpacing': 1.5,
        'height': 1.2,
      });

      expect(style?.fontSize, 16);
      expect(style?.fontWeight, FontWeight.w700);
      expect(style?.fontStyle, FontStyle.italic);
      expect(style?.color, const Color(0xFFFF0000));
      expect(style?.letterSpacing, 1.5);
      expect(style?.height, 1.2);
    });

    test('parses font weights', () {
      expect(
          GuxJsonUtils.parseTextStyle({'fontWeight': '100'})?.fontWeight,
          FontWeight.w100);
      expect(
          GuxJsonUtils.parseTextStyle({'fontWeight': 'thin'})?.fontWeight,
          FontWeight.w100);
      expect(
          GuxJsonUtils.parseTextStyle({'fontWeight': 'bold'})?.fontWeight,
          FontWeight.w700);
      expect(
          GuxJsonUtils.parseTextStyle({'fontWeight': '900'})?.fontWeight,
          FontWeight.w900);
    });

    test('returns null for null input', () {
      expect(GuxJsonUtils.parseTextStyle(null), null);
    });

    test('converts TextStyle to JSON', () {
      const style = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF0000),
      );

      final json = GuxJsonUtils.textStyleToJson(style);
      expect(json['fontSize'], 16);
      expect(json['fontWeight'], '700');
      expect(json['color'], '#ffff0000');
    });
  });

  group('GuxJsonUtils - Size Parsing', () {
    test('parses Size from object', () {
      expect(
        GuxJsonUtils.parseSize({'width': 100, 'height': 50}),
        const Size(100, 50),
      );
    });

    test('returns null for null input', () {
      expect(GuxJsonUtils.parseSize(null), null);
    });

    test('converts Size to JSON', () {
      final json = GuxJsonUtils.sizeToJson(const Size(100, 50));
      expect(json, {'width': 100.0, 'height': 50.0});
    });
  });

  group('GuxJsonUtils - Duration Parsing', () {
    test('parses number as milliseconds', () {
      expect(GuxJsonUtils.parseDuration(500), const Duration(milliseconds: 500));
    });

    test('parses string with ms suffix', () {
      expect(
          GuxJsonUtils.parseDuration('500ms'), const Duration(milliseconds: 500));
    });

    test('parses string with s suffix', () {
      expect(GuxJsonUtils.parseDuration('1s'), const Duration(milliseconds: 1000));
      expect(
          GuxJsonUtils.parseDuration('1.5s'), const Duration(milliseconds: 1500));
    });

    test('returns null for null input', () {
      expect(GuxJsonUtils.parseDuration(null), null);
    });

    test('converts Duration to string', () {
      expect(GuxJsonUtils.durationToString(const Duration(milliseconds: 500)),
          '500ms');
    });
  });
}
