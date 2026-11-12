import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

const options = [
  GuxDropdownOption(value: 1, label: 'One'),
  GuxDropdownOption(value: 2, label: 'Unavailable', enabled: false),
  GuxDropdownOption(value: 3, label: 'Three', subtitle: 'Third choice'),
];

Widget host(Widget child, {Alignment alignment = Alignment.topLeft}) =>
    WidgetsApp(
      color: const Color(0xFF000000),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, _, _) => builder(context),
      ),
      home: Align(
        alignment: alignment,
        child: SizedBox(width: 160, child: child),
      ),
    );

void main() {
  testWidgets('pointer selection updates value and closes menu', (
    tester,
  ) async {
    int? selected = 1;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, update) => GuxDropdown<int>(
            options: options,
            value: selected,
            onChanged: (value) => update(() => selected = value),
            semanticLabel: 'Choice',
          ),
        ),
      ),
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(find.text('Three'), findsOneWidget);
    await tester.tap(find.text('Three'));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard skips disabled options and Escape dismisses', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      host(
        GuxDropdown<int>(
          options: options,
          value: 1,
          onChanged: (value) => selected = value,
        ),
      ),
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 3);
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismisses on outside tap and presents semantic state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        GuxDropdown<int>(
          options: options,
          value: 1,
          onChanged: (_) {},
          semanticLabel: 'Pick a value',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Pick a value'), findsOneWidget);
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(find.text('Unavailable'), findsOneWidget);
    await tester.tapAt(const Offset(600, 400));
    await tester.pumpAndSettle();
    expect(find.text('Unavailable'), findsNothing);
    semantics.dispose();
  });

  testWidgets('shows loading, empty and retry states', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      host(
        const GuxDropdown<int>(
          options: [],
          value: null,
          onChanged: null,
          isLoading: true,
        ),
      ),
    );
    expect(find.text('Loading…'), findsOneWidget);
    await tester.pumpWidget(
      host(const GuxDropdown<int>(options: [], value: null, onChanged: null)),
    );
    expect(find.text('No options available'), findsOneWidget);
    await tester.pumpWidget(
      host(
        GuxDropdown<int>(
          options: const [],
          value: null,
          onChanged: null,
          errorMessage: 'Could not load',
          onRetry: () => retries++,
        ),
      ),
    );
    expect(find.text('Could not load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens above bottom anchors', (tester) async {
    tester.view.physicalSize = const Size(320, 240);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      host(
        const GuxDropdown<int>(
          options: options,
          value: null,
          onChanged: _noop,
        ),
        alignment: Alignment.bottomLeft,
      ),
    );
    final anchor = tester.getRect(find.text('Select'));
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    final menu = tester.getRect(find.byType(ListView));
    expect(menu.bottom, lessThan(anchor.top));
    expect(menu.top, greaterThanOrEqualTo(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text and narrow widths avoid overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      host(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 400),
            textScaler: TextScaler.linear(3),
          ),
          child: GuxDropdown<int>(
            options: options,
            value: null,
            onChanged: _noop,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 30,
            child: GuxDropdown<int>(
              options: [],
              value: null,
              onChanged: null,
              errorMessage: 'An error',
              retryLabel: 'An extremely long retry label',
              onRetry: _retry,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'closes after viewport metrics change and retains keyboard focus',
    (tester) async {
      tester.view.physicalSize = const Size(320, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(
          const GuxDropdown<int>(
            options: options,
            value: null,
            onChanged: _noop,
          ),
        ),
      );
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(find.text('Unavailable'), findsOneWidget);

      tester.view.physicalSize = const Size(320, 140);
      await tester.pumpAndSettle();
      expect(find.text('Unavailable'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      expect(
        tester.getRect(find.byType(ListView)).bottom,
        lessThanOrEqualTo(140),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'menu inherits local direction and text scaling, including updates',
    (tester) async {
      var direction = TextDirection.rtl;
      var scale = 2.0;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: MediaQueryData(
                    size: const Size(800, 600),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: const GuxDropdown<int>(
                    options: options,
                    value: null,
                    onChanged: _noop,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      var optionContext = tester.element(find.text('Three'));
      expect(Directionality.of(optionContext), TextDirection.rtl);
      expect(MediaQuery.textScalerOf(optionContext).scale(14), 28);
      update(() {
        direction = TextDirection.ltr;
        scale = 3;
      });
      await tester.pumpAndSettle();
      expect(find.text('Three'), findsNothing);
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      optionContext = tester.element(find.text('Three'));
      expect(Directionality.of(optionContext), TextDirection.ltr);
      expect(MediaQuery.textScalerOf(optionContext).scale(14), 42);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('configures reference-style selected and disabled visuals', (
    tester,
  ) async {
    const activeBackground = Color(0xFF303030);
    const statusBackground = Color(0xFF252525);
    const selectedColor = Color(0xFF3B82F6);
    const optionSubtitle = Color(0xFFB4B4B4);
    const marker = Key('selected marker');
    const chevron = Key('custom chevron');
    const referenceStyle = GuxDropdownStyle(
      backgroundColor: activeBackground,
      disabledBackgroundColor: statusBackground,
      borderColor: Color(0xFF333333),
      borderWidth: 0.5,
      selectedColor: selectedColor,
      subtitleColor: optionSubtitle,
      textStyle: TextStyle(fontSize: 14, height: 1.25),
      subtitleTextStyle: TextStyle(fontSize: 12, height: 1.25),
      borderRadius: 6,
      fieldPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      menuPadding: EdgeInsets.symmetric(vertical: 4),
      itemPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      fieldGap: 4,
      chevronSize: Size(14, 14),
      showDisabledChevron: true,
      itemHeight: 0,
      compactItems: true,
    );
    await tester.pumpWidget(
      host(
        const GuxDropdown<int>(
          options: options,
          value: 1,
          onChanged: _noop,
          style: referenceStyle,
          selectedMarker: SizedBox(key: marker, width: 14, height: 14),
          chevron: SizedBox(key: chevron, width: 14, height: 14),
        ),
      ),
    );
    BoxDecoration fieldDecoration() =>
        tester
                .widget<DecoratedBox>(
                  find
                      .ancestor(
                        of: find.text('One').first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(fieldDecoration().color, activeBackground);
    expect((fieldDecoration().border! as Border).top.width, 0.5);
    expect(tester.getSize(find.byKey(chevron)), const Size(14, 14));
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(find.byKey(marker), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('One').last).style!.color,
      selectedColor,
    );
    expect(
      tester.widget<Text>(find.text('Third choice')).style!.color,
      optionSubtitle,
    );
    final distance =
        tester.getTopLeft(find.text('Three')).dy -
        tester.getTopLeft(find.text('Unavailable')).dy;
    expect(distance, lessThan(44));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      host(
        const GuxDropdown<int>(
          options: options,
          value: 1,
          enabled: false,
          onChanged: null,
          style: referenceStyle,
          chevron: SizedBox(key: chevron, width: 14, height: 14),
        ),
      ),
    );
    expect(fieldDecoration().color, statusBackground);
    expect(find.byKey(chevron), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact rows scale for subtitles and scroll after resizing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 400),
            textScaler: TextScaler.linear(2),
          ),
          child: GuxDropdown<int>(
            options: List.generate(
              15,
              (i) => GuxDropdownOption(
                value: i,
                label: 'Item $i',
                subtitle: i.isEven ? 'Subtitle' : null,
              ),
            ),
            value: 0,
            onChanged: _noop,
            style: const GuxDropdownStyle(
              compactItems: true,
              itemHeight: 0,
              itemPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Item 0'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    await tester.pump();
    expect(find.text('Item 10'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(320, 220);
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps measured labels and subtitles and scrolls by keyboard', (
    tester,
  ) async {
    const longLabel = 'A long label with several wrapped words';
    const longSubtitle = 'A descriptive subtitle with more words';
    int? selected;
    final wrappedOptions = List.generate(
      18,
      (i) => GuxDropdownOption(
        value: i,
        label: i == 0 ? longLabel : 'Entry $i',
        subtitle: i == 0 ? longSubtitle : (i.isEven ? longSubtitle : null),
      ),
    );
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 600),
            textScaler: TextScaler.linear(1.5),
          ),
          child: GuxDropdown<int>(
            options: wrappedOptions,
            value: 0,
            onChanged: (value) => selected = value,
            wrapOptions: true,
            selectedMarkerSize: const Size(14, 14),
            selectedMarker: const SizedBox(width: 14, height: 14),
            style: const GuxDropdownStyle(
              compactItems: true,
              itemHeight: 0,
              maxMenuHeight: 500,
              textStyle: TextStyle(fontSize: 14, height: 1.25),
              subtitleTextStyle: TextStyle(fontSize: 12, height: 1.25),
              itemPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text(longLabel));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.text(longLabel).last).height, greaterThan(35));
    expect(
      tester.getSize(find.text(longSubtitle).first).height,
      greaterThan(30),
    );
    expect(
      tester.getTopLeft(find.text('Entry 1')).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.text(longSubtitle).first).dy,
      ),
    );
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 12; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    await tester.pump();
    expect(find.text('Entry 12'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading leading widget reserves its configured gap', (
    tester,
  ) async {
    const leadingKey = Key('loading lead');
    await tester.pumpWidget(
      host(
        const GuxDropdown<int>(
          options: [],
          value: null,
          onChanged: null,
          isLoading: true,
          loadingLeading: SizedBox(key: leadingKey, width: 14, height: 14),
          loadingLeadingGap: 6,
        ),
      ),
    );
    expect(tester.getSize(find.byKey(leadingKey)), const Size(14, 14));
    final right = tester.getBottomRight(find.byKey(leadingKey)).dx;
    final left = tester.getTopLeft(find.text('Loading…')).dx;
    expect(left - right, 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard scrolling reaches options outside the first viewport', (
    tester,
  ) async {
    int? selected;
    final many = List.generate(
      40,
      (i) => GuxDropdownOption(value: i, label: 'Option $i'),
    );
    await tester.pumpWidget(
      host(
        GuxDropdown<int>(
          options: many,
          value: 0,
          onChanged: (value) => selected = value,
          style: const GuxDropdownStyle(maxMenuHeight: 88),
        ),
      ),
    );
    await tester.tap(find.text('Option 0'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 25; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    await tester.pump();
    expect(find.text('Option 25'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 25);
    expect(tester.takeException(), isNull);
  });
}

void _noop(int _) {}

void _retry() {}
