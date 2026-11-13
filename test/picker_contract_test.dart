import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  testWidgets('date picker only reports a selected date within bounds', (
    tester,
  ) async {
    final received = <dynamic>[];
    DateTime? result;
    final lower = DateTime(2025, 1, 1);
    final upper = DateTime(2025, 12, 31);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GuxDateTimePicker(
          value: null,
          minDate: lower,
          maxDate: upper,
          onChanged: received.add,
          selectDateTime: (context, value, mode, min, max) async {
            expect(min, lower);
            expect(max, upper);
            return result;
          },
        ),
      ),
    );
    await tester.tap(find.byType(GuxDateTimePicker));
    await tester.pump();
    expect(received, isEmpty);
    result = DateTime(2026);
    await tester.tap(find.byType(GuxDateTimePicker));
    await tester.pump();
    expect(received, isEmpty);
    result = DateTime(2025, 5, 1);
    await tester.tap(find.byType(GuxDateTimePicker));
    await tester.pump();
    expect(received, [result]);
  });

  testWidgets(
    'file adapter receives constraints and cancellation does not clear value',
    (tester) async {
      final received = <List<String>?>[];
      List<String>? result;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            value: const ['existing'],
            allowMultiple: true,
            acceptedExtensions: const ['pdf'],
            onChanged: received.add,
            selectFiles: (context, multiple, extensions) async {
              expect(multiple, isTrue);
              expect(extensions, ['pdf']);
              return result;
            },
          ),
        ),
      );
      await tester.tap(find.byType(GuxFilePicker));
      await tester.pump();
      expect(received, isEmpty);
      result = ['chosen.pdf'];
      await tester.tap(find.byType(GuxFilePicker));
      await tester.pump();
      expect(received, [
        ['chosen.pdf'],
      ]);
    },
  );

  testWidgets('absent picker adapters cannot mutate values', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        builder: (context, _) => Column(
          children: [
            // Date picker has built-in picker, so provide selectDateTime that returns null
            GuxDateTimePicker(
              value: null,
              onChanged: (_) => calls++,
              selectDateTime: (_, __, ___, ____, _____) async => null,
            ),
            // File picker requires selectFiles callback
            GuxFilePicker(onChanged: (_) => calls++),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(GuxDateTimePicker));
    await tester.tap(find.byType(GuxFilePicker));
    await tester.pump();
    expect(calls, 0);
  });

  test('theme mapping uses shared tokens for the new controls', () {
    const theme = GuxThemes.slate;
    const styles = GuxThemeStyles(theme);
    expect(styles.dateTimePicker.backgroundColor, theme.colorScheme.background);
    expect(styles.filePicker.borderColor, theme.colorScheme.border);
    expect(styles.tabs.indicatorColor, theme.colorScheme.primary);
    expect(styles.accordion.headerTextColor, theme.colorScheme.foreground);
  });
}
