import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/src/gux_navigation.dart';
import 'package:genux/src/json/gux_json_renderer.dart';

void main() {
  setUpAll(() {
    // Register Text widget for JSON rendering in tests
    GuxJsonRenderer.register('Text', (json, actions) {
      return Text(json['data'] as String? ?? '');
    });
  });

  tearDownAll(() {
    GuxJsonRenderer.clear();
  });

  group('GuxNavigationItem.fromJson', () {
    test('creates item with minimal JSON', () {
      final json = {
        'icon': {'type': 'Text', 'data': '🏠'},
        'label': 'Home',
      };

      final item = GuxNavigationItem.fromJson(json, actions: {});

      expect(item.label, 'Home');
      expect(item.selected, false);
      expect(item.onSelected, null);
    });

    test('binds onSelected action', () {
      bool actionCalled = false;
      final actions = <String, VoidCallback>{
        'handleHome': () => actionCalled = true,
      };

      final json = {
        'icon': {'type': 'Text', 'data': '🏠'},
        'label': 'Home',
        'onSelected': 'handleHome',
      };

      final item = GuxNavigationItem.fromJson(json, actions: actions);

      item.onSelected?.call();
      expect(actionCalled, true);
    });

    test('parses selected flag', () {
      final json = {
        'icon': {'type': 'Text', 'data': '🏠'},
        'label': 'Home',
        'selected': true,
      };

      final item = GuxNavigationItem.fromJson(json, actions: {});

      expect(item.selected, true);
    });

    test('defaults to empty label when missing', () {
      final json = {
        'icon': {'type': 'Text', 'data': '🏠'},
      };

      final item = GuxNavigationItem.fromJson(json, actions: {});

      expect(item.label, '');
    });

    test('parses icon as widget', () {
      final json = {
        'icon': {'type': 'Text', 'data': '🏠'},
        'label': 'Home',
      };

      final item = GuxNavigationItem.fromJson(json, actions: {});

      expect(item.icon, isA<Text>());
    });
  });

  group('GuxNavigationItem.toJson', () {
    test('serializes label and selected', () {
      const item = GuxNavigationItem(
        icon: Text('🏠'),
        label: 'Home',
        onSelected: null,
        selected: true,
      );

      final json = item.toJson();

      expect(json['label'], 'Home');
      expect(json['selected'], true);
      // icon and onSelected are not serialized
      expect(json.containsKey('icon'), false);
      expect(json.containsKey('onSelected'), false);
    });
  });

  group('GuxNavigation.fromJson', () {
    testWidgets('creates navigation with minimal JSON', (tester) async {
      final json = {
        'items': [
          {
            'icon': {'type': 'Text', 'data': '🏠'},
            'label': 'Home',
          }
        ],
      };

      final navigation = GuxNavigation.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: navigation,
        ),
      );

      expect(find.byType(GuxNavigation), findsOneWidget);
      expect(navigation.items.length, 1);
      expect(navigation.items[0].label, 'Home');
    });

    testWidgets('parses items and bottomItems', (tester) async {
      final json = {
        'items': [
          {
            'icon': {'type': 'Text', 'data': '🏠'},
            'label': 'Home',
          },
          {
            'icon': {'type': 'Text', 'data': '📄'},
            'label': 'Documents',
          },
        ],
        'bottomItems': [
          {
            'icon': {'type': 'Text', 'data': '⚙️'},
            'label': 'Settings',
          }
        ],
      };

      final navigation = GuxNavigation.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: navigation,
        ),
      );

      expect(navigation.items.length, 2);
      expect(navigation.items[0].label, 'Home');
      expect(navigation.items[1].label, 'Documents');
      expect(navigation.bottomItems.length, 1);
      expect(navigation.bottomItems[0].label, 'Settings');
    });

    testWidgets('binds actions to items', (tester) async {
      bool homePressed = false;
      bool settingsPressed = false;

      final actions = <String, VoidCallback>{
        'handleHome': () => homePressed = true,
        'handleSettings': () => settingsPressed = true,
      };

      final json = {
        'items': [
          {
            'icon': {'type': 'Text', 'data': '🏠'},
            'label': 'Home',
            'onSelected': 'handleHome',
          }
        ],
        'bottomItems': [
          {
            'icon': {'type': 'Text', 'data': '⚙️'},
            'label': 'Settings',
            'onSelected': 'handleSettings',
          }
        ],
      };

      final navigation = GuxNavigation.fromJson(json, actions: actions);

      navigation.items[0].onSelected?.call();
      expect(homePressed, true);

      navigation.bottomItems[0].onSelected?.call();
      expect(settingsPressed, true);
    });

    testWidgets('parses dimensions', (tester) async {
      final json = {
        'items': [
          {
            'icon': {'type': 'Text', 'data': '🏠'},
            'label': 'Home',
          }
        ],
        'width': 50.0,
        'itemExtent': 48.0,
        'itemSpacing': 4.0,
        'borderRadius': 6.0,
      };

      final navigation = GuxNavigation.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: navigation,
        ),
      );

      expect(navigation.width, 50.0);
      expect(navigation.itemExtent, 48.0);
      expect(navigation.itemSpacing, 4.0);
      expect(navigation.borderRadius, 6.0);
    });

    testWidgets('parses colors', (tester) async {
      final json = {
        'items': [
          {
            'icon': {'type': 'Text', 'data': '🏠'},
            'label': 'Home',
          }
        ],
        'backgroundColor': '#252525',
        'selectedColor': '#3B82F6',
        'hoverColor': '#383838',
        'focusColor': '#60A5FA',
      };

      final navigation = GuxNavigation.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: navigation,
        ),
      );

      expect(navigation.backgroundColor, const Color(0xFF252525));
      expect(navigation.selectedColor, const Color(0xFF3B82F6));
      expect(navigation.hoverColor, const Color(0xFF383838));
      expect(navigation.focusColor, const Color(0xFF60A5FA));
    });

    testWidgets('uses defaults for missing properties', (tester) async {
      final json = {
        'items': [
          {
            'icon': {'type': 'Text', 'data': '🏠'},
            'label': 'Home',
          }
        ],
      };

      final navigation = GuxNavigation.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: navigation,
        ),
      );

      expect(navigation.width, 44);
      expect(navigation.itemExtent, 40);
      expect(navigation.itemSpacing, 2);
      expect(navigation.backgroundColor, const Color(0x00000000));
      expect(navigation.selectedColor, const Color(0x22000000));
      expect(navigation.hoverColor, const Color(0x11000000));
      expect(navigation.focusColor, const Color(0x66000000));
      expect(navigation.borderRadius, 4);
    });

    testWidgets('handles empty items list', (tester) async {
      final json = {
        'items': [],
      };

      final navigation = GuxNavigation.fromJson(json, actions: {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: navigation,
        ),
      );

      expect(navigation.items.length, 0);
      expect(navigation.bottomItems.length, 0);
    });
  });

  group('GuxNavigation.toJson', () {
    test('serializes all properties', () {
      const navigation = GuxNavigation(
        items: [
          GuxNavigationItem(
            icon: Text('🏠'),
            label: 'Home',
            onSelected: null,
            selected: true,
          ),
        ],
        bottomItems: [
          GuxNavigationItem(
            icon: Text('⚙️'),
            label: 'Settings',
            onSelected: null,
          ),
        ],
        width: 50,
        itemExtent: 48,
        itemSpacing: 4,
        backgroundColor: Color(0xFF252525),
        selectedColor: Color(0xFF3B82F6),
        hoverColor: Color(0xFF383838),
        focusColor: Color(0xFF60A5FA),
        borderRadius: 6,
      );

      final json = navigation.toJson();

      expect(json['items'], isA<List>());
      expect((json['items'] as List).length, 1);
      expect((json['items'] as List)[0]['label'], 'Home');
      expect(json['bottomItems'], isA<List>());
      expect((json['bottomItems'] as List).length, 1);
      expect((json['bottomItems'] as List)[0]['label'], 'Settings');
      expect(json['width'], 50.0);
      expect(json['itemExtent'], 48.0);
      expect(json['itemSpacing'], 4.0);
      expect(json['backgroundColor'], '#FF252525');
      expect(json['selectedColor'], '#FF3B82F6');
      expect(json['hoverColor'], '#FF383838');
      expect(json['focusColor'], '#FF60A5FA');
      expect(json['borderRadius'], 6.0);
    });

    test('roundtrip serialization preserves values', () {
      const original = GuxNavigation(
        items: [
          GuxNavigationItem(
            icon: Text('🏠'),
            label: 'Home',
            onSelected: null,
            selected: true,
          ),
        ],
        width: 50,
        itemExtent: 48,
        backgroundColor: Color(0xFF252525),
      );

      final json = original.toJson();
      final restored = GuxNavigation.fromJson(json, actions: {});

      expect(restored.items.length, original.items.length);
      expect(restored.items[0].label, original.items[0].label);
      expect(restored.items[0].selected, original.items[0].selected);
      expect(restored.width, original.width);
      expect(restored.itemExtent, original.itemExtent);
      expect(restored.backgroundColor, original.backgroundColor);
    });
  });
}
