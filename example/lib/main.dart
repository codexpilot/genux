import 'package:flutter/widgets.dart';
import 'package:genux/genux.dart';
import 'component_gallery.dart';

void main() {
  runApp(const GenuxExampleApp());
}

class GenuxExampleApp extends StatelessWidget {
  const GenuxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GuxApp(
      title: 'Genux Component Gallery',
      color: Color(0xFF3B82F6),
      textStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 14,
      ),
      home: ComponentGallery(),
    );
  }
}

class ExampleHome extends StatelessWidget {
  const ExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Genux JSON Example',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            _JsonButtonExample(),
            const SizedBox(height: 24),
            const _JsonSummaryExample(),
            const SizedBox(height: 24),
            const _JsonProgressExample(),
          ],
        ),
      ),
    );
  }
}

class _JsonButtonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example: Create button from JSON
    final json = {
      'style': {
        'backgroundColor': '#3B82F6',
        'hoverColor': '#2563EB',
        'pressedColor': '#1D4ED8',
        'disabledColor': '#9CA3AF',
        'foregroundColor': '#FFFFFF',
        'disabledForegroundColor': '#D1D5DB',
      },
      'child': {
        'type': 'Text',
        'data': 'Click Me',
      },
      'onPressed': 'handleClick',
    };

    return Column(
      children: [
        const Text(
          'GuxButton from JSON:',
          style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
        ),
        const SizedBox(height: 8),
        GuxButton.fromJson(
          json,
          actions: {
            'handleClick': () {
              // Handle button click
            },
          },
        ),
      ],
    );
  }
}

class _JsonSummaryExample extends StatelessWidget {
  const _JsonSummaryExample();

  @override
  Widget build(BuildContext context) {
    // Example: Create summary from JSON
    final json = {
      'primary': 'John Doe',
      'secondary': 'Software Engineer',
      'tertiary': 'San Francisco, CA',
      'primaryStyle': {
        'fontSize': 16.0,
        'fontWeight': '600',
        'color': '#FFFFFF',
      },
      'secondaryStyle': {
        'fontSize': 14.0,
        'color': '#CCCCCC',
      },
      'tertiaryStyle': {
        'fontSize': 12.0,
        'color': '#888888',
      },
      'spacing': 4.0,
    };

    return Column(
      children: [
        const Text(
          'GuxSummaryLines from JSON:',
          style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: GuxSummaryLines.fromJson(json),
        ),
      ],
    );
  }
}

class _JsonProgressExample extends StatelessWidget {
  const _JsonProgressExample();

  @override
  Widget build(BuildContext context) {
    // Example: Create progress indicator from JSON
    final json = {
      'value': 0.65,
      'style': {
        'color': '#3B82F6',
        'trackColor': '#333333',
      },
    };

    return Column(
      children: [
        const Text(
          'GuxProgressIndicator from JSON:',
          style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: GuxProgressIndicator.fromJson(json),
        ),
      ],
    );
  }
}
