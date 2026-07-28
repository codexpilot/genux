import 'package:flutter/material.dart';

import '../showcase_runtime.dart';

final class RuntimePage extends StatelessWidget {
  const RuntimePage({required this.runtime, super.key});

  final ShowcaseRuntime runtime;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('runtime-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(runtime: runtime),
                const SizedBox(height: 24),
                Text(
                  'One deterministic path to pixels',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                const _Pipeline(),
                const SizedBox(height: 28),
                Text(
                  'Activation gates',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                const _SafetyGrid(),
                const SizedBox(height: 28),
                const _OwnershipCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _Hero extends StatelessWidget {
  const _Hero({required this.runtime});

  final ShowcaseRuntime runtime;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(28),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 28,
        runSpacing: 22,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RUNTIME & SAFETY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Dynamic UI, compiled confidence.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Raw JSON is an input—not the runtime. Genux resolves and '
                  'validates every component, path, event, slot, and capability '
                  'before a Flutter builder sees the surface.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ContractLine(label: 'Wire', value: 'aix.genux/1.0'),
                  _ContractLine(
                    label: 'Catalog',
                    value: '${runtime.catalog.id}@${runtime.catalog.version}',
                  ),
                  _ContractLine(
                    label: 'Renderers',
                    value: '${runtime.catalog.components.length} trusted',
                  ),
                  _ContractLine(
                    label: 'Live lab',
                    value:
                        '${runtime.catalog.components.length}/'
                        '${runtime.catalog.components.length} · '
                        '${runtime.catalogMemberCount}/'
                        '${runtime.catalogMemberCount} members',
                  ),
                  _ContractLine(
                    label: 'Capabilities',
                    value: '${runtime.capabilities.definitions.length} typed',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ContractLine extends StatelessWidget {
  const _ContractLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

final class _Pipeline extends StatelessWidget {
  const _Pipeline();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _PipelineStep(
        number: '01',
        title: 'CloudX authors',
        detail: 'Normalized View, node, binding, and action rows.',
        icon: Icons.account_tree_outlined,
      ),
      _PipelineStep(
        number: '02',
        title: 'Publisher compiles',
        detail: 'Pins catalog and partials, validates, hashes, publishes.',
        icon: Icons.fact_check_outlined,
      ),
      _PipelineStep(
        number: '03',
        title: 'QueryHub delivers',
        detail: 'Authenticated structure plus authorized runtime state.',
        icon: Icons.hub_outlined,
      ),
      _PipelineStep(
        number: '04',
        title: 'Genux activates',
        detail: 'Strict decode into immutable Flutter render handles.',
        icon: Icons.flutter_dash,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1000
            ? (constraints.maxWidth - 48) / 4
            : constraints.maxWidth >= 620
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final step in steps)
              SizedBox(
                width: width,
                child: _PipelineStepCard(step: step),
              ),
          ],
        );
      },
    );
  }
}

final class _PipelineStepCard extends StatelessWidget {
  const _PipelineStepCard({required this.step});

  final _PipelineStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(step.icon, color: scheme.primary),
                Text(
                  step.number,
                  style: TextStyle(
                    color: scheme.outline,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              step.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(step.detail, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

final class _SafetyGrid extends StatelessWidget {
  const _SafetyGrid();

  @override
  Widget build(BuildContext context) {
    const gates = [
      ('Strict syntax', 'Unknown fields and malformed JSON are rejected.'),
      (
        'Catalog compatibility',
        'Exact release version and fingerprint must match.',
      ),
      ('Typed channels', 'Inputs and writable state have catalog-owned types.'),
      ('Graph safety', 'One root, one parent, bounded depth, no cycles.'),
      ('Typed capabilities', 'Name and argument schema are default-deny.'),
      ('Atomic activation', 'Failure retains the last-known-good surface.'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 32) / 3
            : constraints.maxWidth >= 600
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final gate in gates)
              SizedBox(
                width: width,
                child: _GateCard(title: gate.$1, detail: gate.$2),
              ),
          ],
        );
      },
    );
  }
}

final class _GateCard extends StatelessWidget {
  const _GateCard({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

final class _OwnershipCard extends StatelessWidget {
  const _OwnershipCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stable ownership boundaries',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _OwnerChip(
                  color: scheme.primaryContainer,
                  owner: 'CloudX',
                  responsibility: 'author · preview · publish · rollback',
                ),
                _OwnerChip(
                  color: scheme.secondaryContainer,
                  owner: 'Aix',
                  responsibility: 'auth · MetaX · QueryX · business authority',
                ),
                _OwnerChip(
                  color: scheme.tertiaryContainer,
                  owner: 'Genux',
                  responsibility: 'compile · state · render · safe dispatch',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Future GenUI/A2UI output enters through the same compiler and '
              'policy gates. It can select or propose Views; it cannot inject '
              'Dart, bypass publication, or become the authorization boundary.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

final class _OwnerChip extends StatelessWidget {
  const _OwnerChip({
    required this.color,
    required this.owner,
    required this.responsibility,
  });

  final Color color;
  final String owner;
  final String responsibility;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$owner  ',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            TextSpan(text: responsibility),
          ],
        ),
      ),
    ),
  );
}

final class _PipelineStep {
  const _PipelineStep({
    required this.number,
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String number;
  final String title;
  final String detail;
  final IconData icon;
}
