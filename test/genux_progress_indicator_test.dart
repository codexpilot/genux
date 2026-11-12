import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  testWidgets('exposes determinate progress and updates its semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var progress = 0.25;
    late StateSetter update;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return GenuxProgressIndicator(
                color: const Color(0xFF3B82F6),
                trackColor: const Color(0xFF333333),
                size: 24,
                value: progress,
                semanticsLabel: 'Uploading',
              );
            },
          ),
        ),
      ),
    );
    final indicator = find.byType(GenuxProgressIndicator);
    expect(tester.getSize(indicator), const Size.square(24));
    expect(
      tester.getSemantics(indicator),
      matchesSemantics(label: 'Uploading', value: '25%'),
    );
    update(() => progress = 0.75);
    await tester.pump();
    expect(
      tester.getSemantics(indicator),
      matchesSemantics(label: 'Uploading', value: '75%'),
    );
    semantics.dispose();
  });

  testWidgets('indeterminate indicator supports reduced motion and disposal', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: GenuxProgressIndicator(
              color: Color(0xFF3B82F6),
              trackColor: Color(0xFF333333),
              semanticsLabel: 'Loading',
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(GenuxProgressIndicator)),
      matchesSemantics(label: 'Loading'),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });
}
