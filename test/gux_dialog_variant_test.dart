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
  group('GuxDialogVariant', () {
    testWidgets('displays alert dialog', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialogVariant(
            type: DialogVariantType.alert,
            title: 'Error',
            message: 'Something went wrong',
            onConfirm: () {},
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('displays confirm dialog', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialogVariant(
            type: DialogVariantType.confirm,
            title: 'Confirm Action',
            message: 'Are you sure?',
            onConfirm: () {},
            onCancel: () {},
          ),
        ),
      );

      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays info dialog', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialogVariant(
            type: DialogVariantType.info,
            title: 'Information',
            message: 'Here is some info',
            onConfirm: () {},
          ),
        ),
      );

      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Here is some info'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('applies custom button labels', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialogVariant(
            type: DialogVariantType.confirm,
            title: 'Delete',
            message: 'Delete this item?',
            confirmLabel: 'Delete',
            cancelLabel: 'Keep',
            onConfirm: () {},
            onCancel: () {},
          ),
        ),
      );

      expect(find.text('Delete'), findsNWidgets(2)); // Title + button
      expect(find.text('Keep'), findsOneWidget);
    });

    testWidgets('calls onConfirm when confirm button tapped', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialogVariant(
            type: DialogVariantType.alert,
            title: 'Alert',
            message: 'Message',
            onConfirm: () {
              confirmed = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(confirmed, isTrue);
    });

    testWidgets('calls onCancel when cancel button tapped', (tester) async {
      bool cancelled = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GuxDialogVariant(
            type: DialogVariantType.confirm,
            title: 'Confirm',
            message: 'Message',
            onConfirm: () {},
            onCancel: () {
              cancelled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
    });
  });
}
