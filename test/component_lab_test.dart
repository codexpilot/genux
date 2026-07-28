import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux_flutter.dart';
import 'package:genux/showcase/showcase_runtime.dart';

void main() {
  late ShowcaseRuntime runtime;
  late Map<String, Object?> document;
  late List<Map<String, Object?>> nodes;

  setUpAll(() {
    runtime = ShowcaseRuntime.standard();
    final source = File(
      'assets/views/component-lab.genux.json',
    ).readAsStringSync();
    document = jsonDecode(source) as Map<String, Object?>;
    nodes = (document['nodes']! as List<Object?>).cast<Map<String, Object?>>();
  });

  test('Component Lab is a strictly compilable full View', () {
    final result = runtime.compiler.compileObject(document);

    expect(result, isA<GenuxCompileSuccess>());
    final compiled = (result as GenuxCompileSuccess).document;
    expect(compiled.view.code, 'component.lab');
    expect(compiled.view.kind, GenuxViewKind.view);
    expect(compiled.nodes, hasLength(43));
  });

  test('Component Lab covers every released catalog member', () {
    final usedComponents = nodes
        .map((node) => node['component'])
        .whereType<String>()
        .toSet();
    expect(usedComponents, runtime.catalog.components.keys.toSet());

    for (final component in runtime.catalog.components.values) {
      final examples = nodes.where(
        (node) => node['component'] == component.code,
      );
      final props = _memberNames(examples, 'props');
      final bindings = _memberNames(examples, 'bind');
      final events = _memberNames(examples, 'events');
      final slots = _memberNames(examples, 'slots');

      expect(
        props,
        containsAll(component.properties.keys),
        reason: '${component.code} is missing a property example.',
      );
      expect(
        {...props, ...bindings},
        containsAll(component.channels.keys),
        reason: '${component.code} is missing a channel example.',
      );
      expect(
        events,
        containsAll(component.events.keys),
        reason: '${component.code} is missing an event example.',
      );
      expect(
        slots,
        containsAll(component.slots.keys),
        reason: '${component.code} is missing a slot example.',
      );
    }
  });

  test('Component Lab renders every Button variant', () {
    final variants = nodes
        .where((node) => node['component'] == 'Button')
        .map((node) => node['props'])
        .whereType<Map<String, Object?>>()
        .map((props) => props['variant'])
        .whereType<String>()
        .toSet();

    expect(variants, {'primary', 'secondary', 'tertiary', 'danger'});
  });
}

Set<String> _memberNames(Iterable<Map<String, Object?>> nodes, String section) {
  final names = <String>{};
  for (final node in nodes) {
    final values = node[section];
    if (values is Map) {
      names.addAll(values.keys.whereType<String>());
    }
  }
  return names;
}
