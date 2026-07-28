import 'catalog.dart';
import 'value_type.dart';

// Development release fingerprint. The catalog exporter will replace this with
// a SHA-256 of the canonical manifest before the first compatibility release.
const _coreCatalogChecksum =
    'sha256:df13b4276c7e3f607524c4bc7e8b82d0fda561d610ac73013341794fa2e5de9d';

GenuxCatalog createGenuxCoreCatalog() {
  return GenuxCatalog(
    id: 'aix.core',
    version: 1,
    checksum: _coreCatalogChecksum,
    components: [
      GenuxComponentDefinition(
        code: 'Column',
        version: 1,
        properties: const {
          'gap': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
          'mainAxisSize': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(allowedValues: {'min', 'max'}),
          ),
          'crossAxisAlignment': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'start', 'center', 'end', 'stretch'},
            ),
          ),
        },
        slots: const {
          'children': GenuxSlotDefinition(minChildren: 1, maxChildren: 1000),
        },
      ),
      GenuxComponentDefinition(
        code: 'Text',
        version: 1,
        properties: const {
          'style': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(maxLength: 63),
          ),
          'maxLines': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 100),
          ),
        },
        channels: const {
          'text': GenuxChannelDefinition(
            type: GenuxValueType.string,
            direction: GenuxChannelDirection.input,
            required: true,
            constraint: GenuxValueConstraint(maxLength: 16384),
          ),
        },
      ),
      GenuxComponentDefinition(
        code: 'TextField',
        version: 1,
        properties: const {
          'label': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(maxLength: 256),
          ),
          'hint': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(maxLength: 512),
          ),
          'maxLines': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 20),
          ),
        },
        channels: const {
          'value': GenuxChannelDefinition(
            type: GenuxValueType.string,
            direction: GenuxChannelDirection.state,
            required: true,
            constraint: GenuxValueConstraint(maxLength: 16384),
          ),
          'enabled': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
          'readOnly': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
          'errorText': GenuxChannelDefinition(
            type: GenuxValueType.nullableString,
            direction: GenuxChannelDirection.input,
            constraint: GenuxValueConstraint(maxLength: 1024),
          ),
        },
        events: const {
          'changed': GenuxEventDefinition(payload: GenuxValueType.string),
          'submitted': GenuxEventDefinition(payload: GenuxValueType.string),
        },
      ),
      GenuxComponentDefinition(
        code: 'Checkbox',
        version: 1,
        properties: const {
          'label': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            required: true,
            constraint: GenuxValueConstraint(maxLength: 256),
          ),
        },
        channels: const {
          'value': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.state,
            required: true,
          ),
          'enabled': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
        },
        events: const {
          'changed': GenuxEventDefinition(payload: GenuxValueType.boolean),
        },
      ),
      GenuxComponentDefinition(
        code: 'ComboBox',
        version: 1,
        properties: const {
          'clearable': GenuxPropertyDefinition(type: GenuxValueType.boolean),
          'placeholder': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(maxLength: 256),
          ),
        },
        channels: const {
          'items': GenuxChannelDefinition(
            type: GenuxValueType.choiceItems,
            direction: GenuxChannelDirection.input,
            required: true,
            constraint: GenuxValueConstraint(maxItems: 10000),
          ),
          'value': GenuxChannelDefinition(
            type: GenuxValueType.nullableJsonScalar,
            direction: GenuxChannelDirection.state,
            required: true,
          ),
          'busy': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
          'enabled': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
        },
        events: const {
          'changed': GenuxEventDefinition(
            payload: GenuxValueType.nullableJsonScalar,
          ),
        },
      ),
      GenuxComponentDefinition(
        code: 'Button',
        version: 1,
        properties: const {
          'variant': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'primary', 'secondary', 'tertiary', 'danger'},
            ),
          ),
        },
        channels: const {
          'label': GenuxChannelDefinition(
            type: GenuxValueType.string,
            direction: GenuxChannelDirection.input,
            required: true,
            constraint: GenuxValueConstraint(maxLength: 256),
          ),
          'enabled': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
          'busy': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
        },
        events: const {'pressed': GenuxEventDefinition()},
      ),
      GenuxComponentDefinition(
        code: 'Form',
        version: 1,
        channels: const {
          'busy': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
          'errors': GenuxChannelDefinition(
            type: GenuxValueType.nullableObject,
            direction: GenuxChannelDirection.input,
          ),
        },
        events: const {
          'submitted': GenuxEventDefinition(),
          'cancelled': GenuxEventDefinition(),
        },
        slots: const {
          'content': GenuxSlotDefinition(minChildren: 1, maxChildren: 100),
          'actions': GenuxSlotDefinition(maxChildren: 10),
        },
      ),
      GenuxComponentDefinition(
        code: 'Row',
        version: 1,
        properties: const {
          'gap': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
          'mainAxisSize': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(allowedValues: {'min', 'max'}),
          ),
          'crossAxisAlignment': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'start', 'center', 'end'},
            ),
          ),
        },
        slots: const {
          'children': GenuxSlotDefinition(minChildren: 1, maxChildren: 100),
        },
      ),
      GenuxComponentDefinition(
        code: 'Card',
        version: 1,
        properties: const {
          'padding': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
        },
        slots: const {
          'content': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),
      GenuxComponentDefinition(
        code: 'Divider',
        version: 1,
        properties: const {
          'thickness': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0.5, maximum: 16),
          ),
          'indent': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 512),
          ),
          'endIndent': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 512),
          ),
        },
      ),
    ],
  );
}
