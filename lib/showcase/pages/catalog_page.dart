import 'package:flutter/material.dart';
import 'package:genux/genux_flutter.dart';

import '../showcase_runtime.dart';

final class CatalogPage extends StatelessWidget {
  const CatalogPage({required this.runtime, super.key});

  final ShowcaseRuntime runtime;

  @override
  Widget build(BuildContext context) {
    final catalog = runtime.catalog;
    return SafeArea(
      key: const ValueKey('catalog-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CatalogHeader(catalog: catalog),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 900
                        ? (constraints.maxWidth - 20) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (final component in catalog.components.values)
                          SizedBox(
                            width: cardWidth,
                            child: _ComponentCard(component: component),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.catalog});

  final GenuxCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 20,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RELEASED FLUTTER CATALOG',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${catalog.id}@${catalog.version}',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every card below is derived from the same trusted catalog '
                    'used by the compiler and renderer. CloudX authors against '
                    'this contract; Flutter owns the implementation. The JSON '
                    'Component Lab exercises every public member live.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    catalog.checksum,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _CatalogMetric(
              value: '${catalog.components.length}',
              label: 'trusted renderers',
              icon: Icons.widgets_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

final class _CatalogMetric extends StatelessWidget {
  const _CatalogMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: scheme.onPrimaryContainer),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(label, style: TextStyle(color: scheme.onPrimaryContainer)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.component});

  final GenuxComponentDefinition component;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(component.code)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    component.code,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text('v${component.version}')),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Covered by component.lab',
                  child: Chip(
                    avatar: Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: scheme.primary,
                    ),
                    label: const Text('live'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (component.properties.isNotEmpty)
              _MemberGroup(
                label: 'Properties',
                color: scheme.tertiaryContainer,
                members: [
                  for (final entry in component.properties.entries)
                    _Member(
                      name: entry.key,
                      detail: entry.value.type.displayName,
                      required: entry.value.required,
                    ),
                ],
              ),
            if (component.channels.isNotEmpty)
              _MemberGroup(
                label: 'Channels',
                color: scheme.primaryContainer,
                members: [
                  for (final entry in component.channels.entries)
                    _Member(
                      name: entry.key,
                      detail:
                          '${entry.value.direction.name} · '
                          '${entry.value.type.displayName}',
                      required: entry.value.required,
                    ),
                ],
              ),
            if (component.events.isNotEmpty)
              _MemberGroup(
                label: 'Events',
                color: scheme.secondaryContainer,
                members: [
                  for (final entry in component.events.entries)
                    _Member(
                      name: entry.key,
                      detail: entry.value.payload.displayName,
                    ),
                ],
              ),
            if (component.slots.isNotEmpty)
              _MemberGroup(
                label: 'Slots',
                color: scheme.surfaceContainerHighest,
                members: [
                  for (final entry in component.slots.entries)
                    _Member(
                      name: entry.key,
                      detail:
                          '${entry.value.minChildren}..'
                          '${entry.value.maxChildren ?? 'many'} children',
                      required: entry.value.required,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String code) => switch (code) {
    'Form' => Icons.description_outlined,
    'Text' => Icons.text_fields,
    'TextField' => Icons.input,
    'Checkbox' => Icons.check_box_outlined,
    'ComboBox' => Icons.arrow_drop_down_circle_outlined,
    'Button' => Icons.smart_button_outlined,
    'Column' => Icons.view_agenda_outlined,
    'Row' => Icons.view_week_outlined,
    'Card' => Icons.crop_7_5_outlined,
    'Divider' => Icons.horizontal_rule,
    _ => Icons.widgets_outlined,
  };
}

final class _MemberGroup extends StatelessWidget {
  const _MemberGroup({
    required this.label,
    required this.color,
    required this.members,
  });

  final String label;
  final Color color;
  final List<_Member> members;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final member in members)
              Tooltip(
                message: member.detail,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: member.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (member.required)
                            const TextSpan(text: '  *', style: TextStyle()),
                          TextSpan(
                            text: '  ${member.detail}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

final class _Member {
  const _Member({
    required this.name,
    required this.detail,
    this.required = false,
  });

  final String name;
  final String detail;
  final bool required;
}
