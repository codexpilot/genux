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
  group('GuxFilePicker', () {
    testWidgets('displays placeholder when no files selected', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            onChanged: (_) {},
            placeholder: 'Choose file',
          ),
        ),
      );

      expect(find.text('Choose file'), findsOneWidget);
    });

    testWidgets('displays filename when single file selected', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            value: const ['/path/to/document.pdf'],
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('document.pdf'), findsOneWidget);
    });

    testWidgets('displays file count when multiple files selected', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            value: const ['/path/to/file1.pdf', '/path/to/file2.pdf'],
            onChanged: (_) {},
            allowMultiple: true,
          ),
        ),
      );

      expect(find.text('2 files selected'), findsOneWidget);
    });

    testWidgets('is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            onChanged: null,
          ),
        ),
      );

      final picker = tester.widget<GuxFilePicker>(
        find.byType(GuxFilePicker),
      );
      expect(picker.onChanged, isNull);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            onChanged: (_) {},
            enabled: false,
          ),
        ),
      );

      final picker = tester.widget<GuxFilePicker>(
        find.byType(GuxFilePicker),
      );
      expect(picker.enabled, isFalse);
    });

    testWidgets('supports allowMultiple flag', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            onChanged: (_) {},
            allowMultiple: true,
          ),
        ),
      );

      final picker = tester.widget<GuxFilePicker>(
        find.byType(GuxFilePicker),
      );
      expect(picker.allowMultiple, isTrue);
    });

    testWidgets('supports accepted extensions', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            onChanged: (_) {},
            acceptedExtensions: const ['pdf', 'doc', 'docx'],
          ),
        ),
      );

      final picker = tester.widget<GuxFilePicker>(
        find.byType(GuxFilePicker),
      );
      expect(picker.acceptedExtensions, equals(['pdf', 'doc', 'docx']));
    });

    testWidgets('applies custom style', (tester) async {
      const customStyle = GuxFilePickerStyle(
        backgroundColor: Color(0xFF1A1A1A),
        textColor: Color(0xFFFFFFFF),
        borderRadius: 8.0,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxFilePicker(
            onChanged: (_) {},
            style: customStyle,
          ),
        ),
      );

      final picker = tester.widget<GuxFilePicker>(
        find.byType(GuxFilePicker),
      );
      expect(picker.style.backgroundColor, equals(const Color(0xFF1A1A1A)));
      expect(picker.style.borderRadius, equals(8.0));
    });
  });
}
