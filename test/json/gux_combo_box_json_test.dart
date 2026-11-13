import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/forms/gux_combo_box.dart';
import 'package:genux/src/utility/gux_combo_box_json.dart';

void main() {
  group('GuxComboBoxStyle.fromJson', () {
    test('creates style with all colors', () {
      final json = {
        'backgroundColor': '#292929',
        'disabledBackgroundColor': '#1E1E1E',
        'menuColor': '#333333',
        'borderColor': '#666666',
        'focusColor': '#BBBBBB',
        'highlightColor': '#444444',
        'textColor': '#FFFFFF',
        'selectedColor': '#3B82F6',
        'subtitleColor': '#CCCCCC',
        'chevronColor': '#888888',
        'disabledColor': '#999999',
        'errorColor': '#FF8888',
      };

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(style.backgroundColor, const Color(0xFF292929));
      expect(style.disabledBackgroundColor, const Color(0xFF1E1E1E));
      expect(style.menuColor, const Color(0xFF333333));
      expect(style.borderColor, const Color(0xFF666666));
      expect(style.focusColor, const Color(0xFFBBBBBB));
      expect(style.highlightColor, const Color(0xFF444444));
      expect(style.textColor, const Color(0xFFFFFFFF));
      expect(style.selectedColor, const Color(0xFF3B82F6));
      expect(style.subtitleColor, const Color(0xFFCCCCCC));
      expect(style.chevronColor, const Color(0xFF888888));
      expect(style.disabledColor, const Color(0xFF999999));
      expect(style.errorColor, const Color(0xFFFF8888));
    });

    test('creates style with text styles', () {
      final json = {
        'textStyle': {
          'fontSize': 14.0,
          'fontWeight': '600',
          'color': '#FFFFFF',
        },
        'subtitleTextStyle': {
          'fontSize': 12.0,
          'color': '#CCCCCC',
        },
      };

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(style.textStyle.fontSize, 14.0);
      expect(style.textStyle.fontWeight, FontWeight.w600);
      expect(style.textStyle.color, const Color(0xFFFFFFFF));
      expect(style.subtitleTextStyle, isNotNull);
      expect(style.subtitleTextStyle!.fontSize, 12.0);
      expect(style.subtitleTextStyle!.color, const Color(0xFFCCCCCC));
    });

    test('creates style with dimensions', () {
      final json = {
        'borderRadius': 8.0,
        'borderWidth': 2.0,
        'fieldGap': 10.0,
        'itemHeight': 48.0,
        'maxMenuHeight': 320.0,
      };

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(style.borderRadius, 8.0);
      expect(style.borderWidth, 2.0);
      expect(style.fieldGap, 10.0);
      expect(style.itemHeight, 48.0);
      expect(style.maxMenuHeight, 320.0);
    });

    test('creates style with padding', () {
      final json = {
        'fieldPadding': {'left': 12.0, 'top': 10.0, 'right': 12.0, 'bottom': 10.0},
        'menuPadding': {'all': 4.0},
        'itemPadding': {'horizontal': 16.0},
      };

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(
        style.fieldPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
      expect(style.menuPadding, const EdgeInsets.all(4));
      expect(style.itemPadding, const EdgeInsets.symmetric(horizontal: 16));
    });

    test('creates style with chevron size', () {
      final json = {
        'chevronSize': {'width': 12.0, 'height': 8.0},
      };

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(style.chevronSize.width, 12.0);
      expect(style.chevronSize.height, 8.0);
    });

    test('creates style with boolean flags', () {
      final json = {
        'showDisabledChevron': true,
        'compactItems': true,
      };

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(style.showDisabledChevron, true);
      expect(style.compactItems, true);
    });

    test('uses defaults for missing properties', () {
      final json = <String, dynamic>{};

      final style = GuxComboBoxStyleJson.fromJson(json);

      expect(style.backgroundColor, const Color(0xFF292929));
      expect(style.menuColor, const Color(0xFF292929));
      expect(style.borderColor, const Color(0xFF666666));
      expect(style.focusColor, const Color(0xFFBBBBBB));
      expect(style.highlightColor, const Color(0xFF444444));
      expect(style.textColor, const Color(0xFFFFFFFF));
      expect(style.disabledColor, const Color(0xFF999999));
      expect(style.errorColor, const Color(0xFFFF8888));
      expect(style.textStyle.fontSize, 14);
      expect(style.borderRadius, 4);
      expect(style.borderWidth, 1);
      expect(style.fieldGap, 6);
      expect(style.chevronSize, const Size(10, 6));
      expect(style.showDisabledChevron, false);
      expect(style.compactItems, false);
      expect(style.itemHeight, 44);
      expect(style.maxMenuHeight, 280);
    });
  });

  group('GuxComboBoxStyle.toJson', () {
    test('serializes all colors', () {
      const style = GuxComboBoxStyle(
        backgroundColor: Color(0xFF292929),
        disabledBackgroundColor: Color(0xFF1E1E1E),
        menuColor: Color(0xFF333333),
        borderColor: Color(0xFF666666),
        focusColor: Color(0xFFBBBBBB),
        highlightColor: Color(0xFF444444),
        textColor: Color(0xFFFFFFFF),
        selectedColor: Color(0xFF3B82F6),
        subtitleColor: Color(0xFFCCCCCC),
        chevronColor: Color(0xFF888888),
        disabledColor: Color(0xFF999999),
        errorColor: Color(0xFFFF8888),
      );

      final json = style.toJson();

      expect(json['backgroundColor'], '#FF292929');
      expect(json['disabledBackgroundColor'], '#FF1E1E1E');
      expect(json['menuColor'], '#FF333333');
      expect(json['borderColor'], '#FF666666');
      expect(json['focusColor'], '#FFBBBBBB');
      expect(json['highlightColor'], '#FF444444');
      expect(json['textColor'], '#FFFFFFFF');
      expect(json['selectedColor'], '#FF3B82F6');
      expect(json['subtitleColor'], '#FFCCCCCC');
      expect(json['chevronColor'], '#FF888888');
      expect(json['disabledColor'], '#FF999999');
      expect(json['errorColor'], '#FFFF8888');
    });

    test('serializes text styles', () {
      const style = GuxComboBoxStyle(
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        subtitleTextStyle: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
      );

      final json = style.toJson();

      expect(json['textStyle'], isA<Map>());
      expect(json['textStyle']['fontSize'], 14.0);
      expect(json['subtitleTextStyle'], isA<Map>());
      expect(json['subtitleTextStyle']['fontSize'], 12.0);
    });

    test('omits null optional colors', () {
      const style = GuxComboBoxStyle();

      final json = style.toJson();

      expect(json.containsKey('disabledBackgroundColor'), false);
      expect(json.containsKey('selectedColor'), false);
      expect(json.containsKey('subtitleColor'), false);
      expect(json.containsKey('chevronColor'), false);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxComboBoxStyle(
        backgroundColor: Color(0xFF292929),
        menuColor: Color(0xFF333333),
        borderColor: Color(0xFF666666),
        textStyle: TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
        borderRadius: 8,
        borderWidth: 2,
        fieldGap: 10,
        itemHeight: 48,
        maxMenuHeight: 320,
      );

      final json = original.toJson();
      final restored = GuxComboBoxStyleJson.fromJson(json);

      expect(restored.backgroundColor, original.backgroundColor);
      expect(restored.menuColor, original.menuColor);
      expect(restored.borderColor, original.borderColor);
      expect(restored.textStyle.fontSize, original.textStyle.fontSize);
      expect(restored.textStyle.color, original.textStyle.color);
      expect(restored.borderRadius, original.borderRadius);
      expect(restored.borderWidth, original.borderWidth);
      expect(restored.fieldGap, original.fieldGap);
      expect(restored.itemHeight, original.itemHeight);
      expect(restored.maxMenuHeight, original.maxMenuHeight);
    });
  });

  group('GuxComboBoxStringJson.fromJson', () {
    testWidgets('creates dropdown with minimal JSON', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
          {'value': 'option2', 'label': 'Option 2'},
        ],
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(GuxComboBox<String>), findsOneWidget);
      expect(dropdown.options.length, 2);
      expect(dropdown.options[0].value, 'option1');
      expect(dropdown.options[0].label, 'Option 1');
      expect(dropdown.options[1].value, 'option2');
      expect(dropdown.options[1].label, 'Option 2');
    });

    testWidgets('parses all option properties', (tester) async {
      final json = {
        'options': [
          {
            'value': 'option1',
            'label': 'Option 1',
            'subtitle': 'Description 1',
            'enabled': true,
          },
          {
            'value': 'option2',
            'label': 'Option 2',
            'subtitle': 'Description 2',
            'enabled': false,
          },
        ],
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.options[0].subtitle, 'Description 1');
      expect(dropdown.options[0].enabled, true);
      expect(dropdown.options[1].subtitle, 'Description 2');
      expect(dropdown.options[1].enabled, false);
    });

    testWidgets('parses value and binds onChanged action', (tester) async {
      var changedValue = '';
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
          {'value': 'option2', 'label': 'Option 2'},
        ],
        'value': 'option1',
        'onChanged': 'handleChange',
      };

      final dropdown = GuxComboBoxStringJson.fromJson(
        json,
        actions: {
          'handleChange': (value) => changedValue = value,
        },
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.value, 'option1');
      expect(dropdown.onChanged, isNotNull);

      dropdown.onChanged!('option2');
      expect(changedValue, 'option2');
    });

    testWidgets('parses enabled flag', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
        ],
        'enabled': false,
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.enabled, false);
    });

    testWidgets('parses isLoading flag', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
        ],
        'isLoading': true,
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.isLoading, true);
    });

    testWidgets('parses errorMessage', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
        ],
        'errorMessage': 'Failed to load options',
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.errorMessage, 'Failed to load options');
    });

    testWidgets('parses text properties', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
        ],
        'placeholder': 'Choose one',
        'emptyMessage': 'No data',
        'loadingMessage': 'Please wait...',
        'semanticLabel': 'Select a value',
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.placeholder, 'Choose one');
      expect(dropdown.emptyMessage, 'No data');
      expect(dropdown.loadingMessage, 'Please wait...');
      expect(dropdown.semanticLabel, 'Select a value');
    });

    testWidgets('parses wrapOptions flag', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
        ],
        'wrapOptions': true,
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.wrapOptions, true);
    });

    testWidgets('parses style object', (tester) async {
      final json = {
        'options': [
          {'value': 'option1', 'label': 'Option 1'},
        ],
        'style': {
          'backgroundColor': '#1E1E1E',
          'textColor': '#FFFFFF',
          'borderRadius': 8.0,
        },
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.style.backgroundColor, const Color(0xFF1E1E1E));
      expect(dropdown.style.textColor, const Color(0xFFFFFFFF));
      expect(dropdown.style.borderRadius, 8.0);
    });

    testWidgets('uses defaults for missing properties', (tester) async {
      final json = {
        'options': [],
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.options, isEmpty);
      expect(dropdown.value, null);
      expect(dropdown.onChanged, null);
      expect(dropdown.enabled, true);
      expect(dropdown.isLoading, false);
      expect(dropdown.errorMessage, null);
      expect(dropdown.placeholder, 'Select');
      expect(dropdown.emptyMessage, 'No options available');
      expect(dropdown.loadingMessage, 'Loading…');
      expect(dropdown.wrapOptions, false);
    });

    testWidgets('handles empty options list', (tester) async {
      final json = {
        'options': [],
      };

      final dropdown = GuxComboBoxStringJson.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => dropdown,
              ),
            ],
          ),
        ),
      );

      expect(dropdown.options, isEmpty);
    });
  });

  group('GuxComboBoxStringJson.toJson', () {
    test('serializes options', () {
      const dropdown = GuxComboBox<String>(
        options: [
          GuxComboBoxOption(value: 'opt1', label: 'Option 1', enabled: true),
          GuxComboBoxOption(
            value: 'opt2',
            label: 'Option 2',
            subtitle: 'Description',
            enabled: false,
          ),
        ],
        value: null,
        onChanged: null,
      );

      final json = GuxComboBoxStringJson.toJson(dropdown);

      expect(json['options'], isA<List>());
      expect(json['options'].length, 2);
      expect(json['options'][0]['value'], 'opt1');
      expect(json['options'][0]['label'], 'Option 1');
      expect(json['options'][0]['enabled'], true);
      expect(json['options'][1]['subtitle'], 'Description');
      expect(json['options'][1]['enabled'], false);
    });

    test('serializes value when present', () {
      const dropdown = GuxComboBox<String>(
        options: [
          GuxComboBoxOption(value: 'opt1', label: 'Option 1', enabled: true),
        ],
        value: 'opt1',
        onChanged: null,
      );

      final json = GuxComboBoxStringJson.toJson(dropdown);

      expect(json['value'], 'opt1');
    });

    test('omits value when null', () {
      const dropdown = GuxComboBox<String>(
        options: [
          GuxComboBoxOption(value: 'opt1', label: 'Option 1', enabled: true),
        ],
        value: null,
        onChanged: null,
      );

      final json = GuxComboBoxStringJson.toJson(dropdown);

      expect(json.containsKey('value'), false);
    });

    test('serializes boolean flags', () {
      const dropdown = GuxComboBox<String>(
        options: [],
        value: null,
        onChanged: null,
        enabled: false,
        isLoading: true,
        wrapOptions: true,
      );

      final json = GuxComboBoxStringJson.toJson(dropdown);

      expect(json['enabled'], false);
      expect(json['isLoading'], true);
      expect(json['wrapOptions'], true);
    });

    test('serializes text properties', () {
      const dropdown = GuxComboBox<String>(
        options: [],
        value: null,
        onChanged: null,
        placeholder: 'Choose',
        emptyMessage: 'No data',
        loadingMessage: 'Loading...',
        semanticLabel: 'Picker',
        errorMessage: 'Error occurred',
      );

      final json = GuxComboBoxStringJson.toJson(dropdown);

      expect(json['placeholder'], 'Choose');
      expect(json['emptyMessage'], 'No data');
      expect(json['loadingMessage'], 'Loading...');
      expect(json['semanticLabel'], 'Picker');
      expect(json['errorMessage'], 'Error occurred');
    });

    test('serializes style', () {
      const dropdown = GuxComboBox<String>(
        options: [],
        value: null,
        onChanged: null,
        style: GuxComboBoxStyle(
          backgroundColor: Color(0xFF1E1E1E),
          borderRadius: 8,
        ),
      );

      final json = GuxComboBoxStringJson.toJson(dropdown);

      expect(json['style'], isA<Map>());
      expect(json['style']['backgroundColor'], '#FF1E1E1E');
      expect(json['style']['borderRadius'], 8.0);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxComboBox<String>(
        options: [
          GuxComboBoxOption(
            value: 'opt1',
            label: 'Option 1',
            subtitle: 'Description',
            enabled: true,
          ),
        ],
        value: 'opt1',
        onChanged: null,
        enabled: true,
        isLoading: false,
        placeholder: 'Select one',
        wrapOptions: false,
        style: GuxComboBoxStyle(backgroundColor: Color(0xFF1E1E1E)),
      );

      final json = GuxComboBoxStringJson.toJson(original);
      final restored = GuxComboBoxStringJson.fromJson(json, actions: {});

      expect(restored.options.length, original.options.length);
      expect(restored.options[0].value, original.options[0].value);
      expect(restored.options[0].label, original.options[0].label);
      expect(restored.options[0].subtitle, original.options[0].subtitle);
      expect(restored.value, original.value);
      expect(restored.enabled, original.enabled);
      expect(restored.isLoading, original.isLoading);
      expect(restored.placeholder, original.placeholder);
      expect(restored.wrapOptions, original.wrapOptions);
      expect(
        restored.style.backgroundColor,
        original.style.backgroundColor,
      );
    });
  });
}
