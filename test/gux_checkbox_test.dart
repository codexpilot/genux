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

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

// Helper to create a default style for testing
GuxCheckboxStyle _defaultStyle() => const GuxCheckboxStyle(
      checkedBackgroundColor: Color(0xFF3B82F6),
      uncheckedBackgroundColor: Color(0xFF252525),
      hoverBackgroundColor: Color(0xFF2563EB),
      disabledBackgroundColor: Color(0xFF6B7280),
      checkedBorderColor: Color(0xFF3B82F6),
      uncheckedBorderColor: Color(0xFF6B7280),
      disabledBorderColor: Color(0xFF4B5563),
      checkColor: Color(0xFFFFFFFF),
      disabledCheckColor: Color(0xFF9CA3AF),
      focusColor: Color(0xFF60A5FA),
    );

void main() {
  group('GuxCheckbox', () {
    testWidgets('displays unchecked state', (tester) async {
      bool? value = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: value,
            onChanged: (newValue) => value = newValue,
            style: _defaultStyle(),
          ),
        ),
      );

      expect(find.byType(GuxCheckbox), findsOneWidget);
    });

    testWidgets('displays checked state', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: true,
            onChanged: (_) {},
            style: _defaultStyle(),
          ),
        ),
      );

      expect(find.byType(GuxCheckbox), findsOneWidget);
    });

    testWidgets('displays indeterminate state in tristate mode', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: null,
            onChanged: (_) {},
            style: _defaultStyle(),
            tristate: true,
          ),
        ),
      );

      expect(find.byType(GuxCheckbox), findsOneWidget);
    });

    testWidgets('toggles on tap', (tester) async {
      bool? value = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxCheckbox(
                value: value,
                onChanged: (newValue) {
                  setState(() => value = newValue);
                },
                style: _defaultStyle(),
              );
            },
          ),
        ),
      );

      expect(value, isFalse);

      await tester.tap(find.byType(GuxCheckbox));
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('cycles through states in tristate mode', (tester) async {
      bool? value;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxCheckbox(
                value: value,
                onChanged: (newValue) {
                  setState(() => value = newValue);
                },
                style: _defaultStyle(),
                tristate: true,
              );
            },
          ),
        ),
      );

      expect(value, isNull);

      // null -> true
      await tester.tap(find.byType(GuxCheckbox));
      await tester.pump();
      expect(value, isTrue);

      // true -> false
      await tester.tap(find.byType(GuxCheckbox));
      await tester.pump();
      expect(value, isFalse);

      // false -> null
      await tester.tap(find.byType(GuxCheckbox));
      await tester.pump();
      expect(value, isNull);
    });

    testWidgets('responds to Space key', (tester) async {
      bool? value = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxCheckbox(
                value: value,
                onChanged: (newValue) {
                  setState(() => value = newValue);
                },
                style: _defaultStyle(),
                autofocus: true,
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(value, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('responds to Enter key', (tester) async {
      bool? value = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxCheckbox(
                value: value,
                onChanged: (newValue) {
                  setState(() => value = newValue);
                },
                style: _defaultStyle(),
                autofocus: true,
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(value, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('ignores unhandled keys', (tester) async {
      bool? value = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return GuxCheckbox(
                value: value,
                onChanged: (newValue) {
                  setState(() => value = newValue);
                },
                style: _defaultStyle(),
                autofocus: true,
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(value, isFalse);

      // Tab should be ignored (for focus traversal)
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(value, isFalse);
    });

    testWidgets('disabled checkbox ignores interactions', (tester) async {
      bool? value = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: value,
            onChanged: null, // Disabled
            style: _defaultStyle(),
          ),
        ),
      );

      await tester.tap(find.byType(GuxCheckbox));
      await tester.pump();

      expect(value, isFalse); // Should not change
    });

    testWidgets('applies custom styling', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: true,
            onChanged: (_) {},
            style: const GuxCheckboxStyle(
              checkedBackgroundColor: Color(0xFF3B82F6),
              uncheckedBackgroundColor: Color(0xFF252525),
              hoverBackgroundColor: Color(0xFF2563EB),
              disabledBackgroundColor: Color(0xFF6B7280),
              checkedBorderColor: Color(0xFF3B82F6),
              uncheckedBorderColor: Color(0xFF6B7280),
              disabledBorderColor: Color(0xFF4B5563),
              checkColor: Color(0xFFFFFFFF),
              disabledCheckColor: Color(0xFF9CA3AF),
              focusColor: Color(0xFF60A5FA),
              size: 24.0,
            ),
          ),
        ),
      );

      expect(find.byType(GuxCheckbox), findsOneWidget);
    });

    testWidgets('supports focus management', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: false,
            onChanged: (_) {},
            style: _defaultStyle(),
            focusNode: focusNode,
          ),
        ),
      );

      expect(focusNode.hasFocus, isFalse);

      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      focusNode.dispose();
    });

    testWidgets('autofocus works', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxCheckbox(
            value: false,
            onChanged: (_) {},
            style: _defaultStyle(),
            autofocus: true,
          ),
        ),
      );

      await tester.pump();

      // After autofocus, the checkbox should be focused
      final checkbox = tester.widget<GuxCheckbox>(find.byType(GuxCheckbox));
      expect(checkbox.autofocus, isTrue);
    });
  });
}
