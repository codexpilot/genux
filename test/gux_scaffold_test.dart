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
  group('GuxScaffold', () {
    testWidgets('renders body content', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            body: Text('Test Body'),
          ),
        ),
      );

      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('renders with appBar', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            appBar: GuxAppBar(
              title: Text('Test Title'),
            ),
            body: Text('Test Body'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('renders with bottomBar', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            body: Text('Test Body'),
            bottomBar: Text('Bottom Content'),
          ),
        ),
      );

      expect(find.text('Test Body'), findsOneWidget);
      expect(find.text('Bottom Content'), findsOneWidget);
    });

    testWidgets('renders with all components', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            appBar: GuxAppBar(
              title: Text('App Bar'),
            ),
            body: Text('Body'),
            bottomBar: Text('Bottom Bar'),
          ),
        ),
      );

      expect(find.text('App Bar'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Bottom Bar'), findsOneWidget);
    });

    testWidgets('applies default background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            body: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Test'),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.color, const Color(0xFF1E1E1E));
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            body: Text('Test'),
            backgroundColor: Color(0xFF123456),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Test'),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.color, const Color(0xFF123456));
    });

    testWidgets('body is wrapped in Expanded', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            body: Text('Test'),
          ),
        ),
      );

      expect(
        find.ancestor(
          of: find.text('Test'),
          matching: find.byType(Expanded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses Column layout', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxScaffold(
            appBar: GuxAppBar(title: Text('Title')),
            body: Text('Body'),
            bottomBar: Text('Bottom'),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, 3);
    });
  });

  group('GuxAppBar', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Test Title'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            leading: Text('Back'),
            title: Text('Title'),
          ),
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
            actions: [
              Text('Action 1'),
              Text('Action 2'),
            ],
          ),
        ),
      );

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });

    testWidgets('renders all components together', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            leading: Text('Leading'),
            title: Text('Title'),
            actions: [
              Text('Action'),
            ],
          ),
        ),
      );

      expect(find.text('Leading'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('applies default height', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minHeight, 56.0);
    });

    testWidgets('applies custom height', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
            height: 72.0,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minHeight, 72.0);
    });

    testWidgets('applies default background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF2D2D2D));
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
            backgroundColor: Color(0xFF112233),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF112233));
    });

    testWidgets('applies default foreground color to title text', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
          ),
        ),
      );

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.ancestor(
          of: find.text('Title'),
          matching: find.byType(DefaultTextStyle),
        ),
      );

      expect(defaultTextStyle.style.color, const Color(0xFFFFFFFF));
    });

    testWidgets('applies custom foreground color', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
            foregroundColor: Color(0xFF00FF00),
          ),
        ),
      );

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.ancestor(
          of: find.text('Title'),
          matching: find.byType(DefaultTextStyle),
        ),
      );

      expect(defaultTextStyle.style.color, const Color(0xFF00FF00));
    });

    testWidgets('title text has correct font properties', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
          ),
        ),
      );

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        find.ancestor(
          of: find.text('Title'),
          matching: find.byType(DefaultTextStyle),
        ),
      );

      expect(defaultTextStyle.style.fontSize, 20);
      expect(defaultTextStyle.style.fontWeight, FontWeight.w600);
    });

    testWidgets('has bottom border', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            title: Text('Title'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.bottom.width, 1);
    });

    testWidgets('renders without optional widgets', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(),
        ),
      );

      expect(find.byType(GuxAppBar), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('uses Row layout', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GuxAppBar(
            leading: Text('Leading'),
            title: Text('Title'),
            actions: [Text('Action')],
          ),
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });
  });
}
