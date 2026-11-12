import 'package:genux/genux.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows three styled lines in order with configurable spacing', (
    tester,
  ) async {
    const primaryStyle = TextStyle(fontSize: 18, color: Color(0xFF123456));
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: GuxSummaryLines(
            primary: 'First',
            secondary: 'Second',
            tertiary: 'Third',
            primaryStyle: primaryStyle,
            spacing: 9,
          ),
        ),
      ),
    );

    final first = find.text('First');
    final second = find.text('Second');
    final third = find.text('Third');
    expect(tester.widget<Text>(first).style, primaryStyle);
    expect(tester.getTopLeft(second).dy - tester.getBottomLeft(first).dy, 9);
    expect(tester.getTopLeft(third).dy - tester.getBottomLeft(second).dy, 9);
  });

  testWidgets('truncates visually while preserving full accessible text', (
    tester,
  ) async {
    const longText = 'A long description that is much wider than its container';
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 80,
            child: GuxSummaryLines(
              primary: longText,
              secondary: 'Second',
              tertiary: 'Third',
            ),
          ),
        ),
      ),
    );

    final line = tester.widget<Text>(find.text(longText));
    expect(line.maxLines, 1);
    expect(line.softWrap, false);
    expect(line.overflow, TextOverflow.ellipsis);
    expect(find.bySemanticsLabel(longText), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
