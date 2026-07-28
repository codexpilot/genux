import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  test('ComboBox exposes Flutter-native channel directions', () {
    final comboBox = createGenuxCoreCatalog().component('ComboBox')!;

    expect(comboBox.channels['items']!.direction, GenuxChannelDirection.input);
    expect(comboBox.channels['value']!.direction, GenuxChannelDirection.state);
    expect(comboBox.channels['value']!.acceptsLiteral, isFalse);
    expect(comboBox.events.keys, ['changed']);
    expect(comboBox.channels, isNot(contains('query')));
  });

  test('TextField exposes bounded text editing contracts', () {
    final textField = createGenuxCoreCatalog().component('TextField')!;

    expect(
      textField.properties.keys,
      unorderedEquals(['label', 'hint', 'maxLines']),
    );
    expect(textField.properties['label']!.type, GenuxValueType.string);
    expect(textField.properties['label']!.constraint.maxLength, 256);
    expect(textField.properties['hint']!.constraint.maxLength, 512);
    expect(textField.properties['maxLines']!.type, GenuxValueType.integer);
    expect(textField.properties['maxLines']!.constraint.minimum, 1);
    expect(textField.properties['maxLines']!.constraint.maximum, 20);

    expect(
      textField.channels.keys,
      unorderedEquals(['value', 'enabled', 'readOnly', 'errorText']),
    );
    expect(textField.channels['value']!.type, GenuxValueType.string);
    expect(textField.channels['value']!.direction, GenuxChannelDirection.state);
    expect(textField.channels['value']!.required, isTrue);
    expect(textField.channels['value']!.constraint.maxLength, 16384);
    expect(
      textField.channels['enabled']!.direction,
      GenuxChannelDirection.input,
    );
    expect(textField.channels['enabled']!.type, GenuxValueType.boolean);
    expect(
      textField.channels['readOnly']!.direction,
      GenuxChannelDirection.input,
    );
    expect(textField.channels['readOnly']!.type, GenuxValueType.boolean);
    expect(
      textField.channels['errorText']!.type,
      GenuxValueType.nullableString,
    );
    expect(textField.channels['errorText']!.constraint.maxLength, 1024);

    expect(textField.events.keys, unorderedEquals(['changed', 'submitted']));
    expect(textField.events['changed']!.payload, GenuxValueType.string);
    expect(textField.events['submitted']!.payload, GenuxValueType.string);
  });

  test('Checkbox exposes a required label and boolean state', () {
    final checkbox = createGenuxCoreCatalog().component('Checkbox')!;

    expect(checkbox.properties.keys, ['label']);
    expect(checkbox.properties['label']!.type, GenuxValueType.string);
    expect(checkbox.properties['label']!.required, isTrue);
    expect(checkbox.properties['label']!.constraint.maxLength, 256);
    expect(checkbox.channels.keys, unorderedEquals(['value', 'enabled']));
    expect(checkbox.channels['value']!.type, GenuxValueType.boolean);
    expect(checkbox.channels['value']!.direction, GenuxChannelDirection.state);
    expect(checkbox.channels['value']!.required, isTrue);
    expect(
      checkbox.channels['enabled']!.direction,
      GenuxChannelDirection.input,
    );
    expect(checkbox.events['changed']!.payload, GenuxValueType.boolean);
  });

  test('Form v1 does not advertise deferred update policies', () {
    final form = createGenuxCoreCatalog().component('Form')!;

    expect(form.properties, isEmpty);
  });

  test('Row and Card define bounded layout slots', () {
    final catalog = createGenuxCoreCatalog();
    final row = catalog.component('Row')!;
    final card = catalog.component('Card')!;

    expect(row.properties['gap']!.type, GenuxValueType.number);
    expect(row.properties['gap']!.constraint.minimum, 0);
    expect(row.properties['gap']!.constraint.maximum, 128);
    expect(row.properties['mainAxisSize']!.constraint.allowedValues, {
      'min',
      'max',
    });
    expect(row.properties['crossAxisAlignment']!.constraint.allowedValues, {
      'start',
      'center',
      'end',
    });
    expect(row.slots.keys, ['children']);
    expect(row.slots['children']!.minChildren, 1);
    expect(row.slots['children']!.maxChildren, 100);

    expect(card.properties.keys, ['padding']);
    expect(card.properties['padding']!.type, GenuxValueType.number);
    expect(card.properties['padding']!.constraint.minimum, 0);
    expect(card.properties['padding']!.constraint.maximum, 128);
    expect(card.slots.keys, ['content']);
    expect(card.slots['content']!.minChildren, 1);
    expect(card.slots['content']!.maxChildren, 1);
  });

  test('Divider dimensions are bounded and thickness is strictly positive', () {
    final divider = createGenuxCoreCatalog().component('Divider')!;
    final thickness = divider.properties['thickness']!;

    expect(
      divider.properties.keys,
      unorderedEquals(['thickness', 'indent', 'endIndent']),
    );
    expect(thickness.type, GenuxValueType.number);
    expect(thickness.constraint.violation(0), isNotNull);
    expect(thickness.constraint.violation(0.5), isNull);
    expect(thickness.constraint.maximum, 16);
    for (final name in ['indent', 'endIndent']) {
      expect(divider.properties[name]!.type, GenuxValueType.number);
      expect(divider.properties[name]!.constraint.minimum, 0);
      expect(divider.properties[name]!.constraint.maximum, 512);
    }
  });

  test('ChoiceItem has a stable key and presentation-only label', () {
    final item = GenuxChoiceItem.fromJson({
      'key': 42,
      'label': 'Business',
      'disabled': true,
      'meta': {'color': 'blue'},
    });

    expect(item.key, 42);
    expect(item.label, 'Business');
    expect(item.disabled, isTrue);
    expect(item.toJson()['meta'], {'color': 'blue'});
  });

  test('catalog rejects duplicate component codes', () {
    final component = GenuxComponentDefinition(code: 'Text', version: 1);

    expect(
      () => GenuxCatalog(
        id: 'test',
        version: 1,
        checksum:
            'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        components: [component, component],
      ),
      throwsArgumentError,
    );
  });

  test('component contracts reject member-name collisions', () {
    expect(
      () => GenuxComponentDefinition(
        code: 'Invalid',
        version: 1,
        properties: const {
          'value': GenuxPropertyDefinition(type: GenuxValueType.string),
        },
        channels: const {
          'value': GenuxChannelDefinition(
            type: GenuxValueType.string,
            direction: GenuxChannelDirection.input,
          ),
        },
      ),
      throwsArgumentError,
    );
  });

  test('ChoiceItem rejects non-finite numeric identity', () {
    expect(
      () => GenuxChoiceItem(key: double.nan, label: 'Invalid'),
      throwsArgumentError,
    );
  });

  test('ChoiceItem collections require keys unique under Dart equality', () {
    expect(
      GenuxValueType.choiceItems.accepts([
        {'key': 1, 'label': 'Integer'},
        {'key': 1.0, 'label': 'Equivalent double'},
      ]),
      isFalse,
    );
  });

  test('component contract collections cannot be mutated by their caller', () {
    final allowed = <Object?>{'one'};
    final accepted = <String>{'Text'};
    final component = GenuxComponentDefinition(
      code: 'Immutable',
      version: 1,
      properties: {
        'mode': GenuxPropertyDefinition(
          type: GenuxValueType.string,
          constraint: GenuxValueConstraint(allowedValues: allowed),
        ),
      },
      slots: {'content': GenuxSlotDefinition(acceptedComponents: accepted)},
    );

    allowed.add('two');
    accepted.add('Button');

    expect(component.properties['mode']!.constraint.allowedValues, {'one'});
    expect(component.slots['content']!.acceptedComponents, {'Text'});
    expect(
      () => component.properties['mode']!.constraint.allowedValues!.add('x'),
      throwsUnsupportedError,
    );
  });
}
