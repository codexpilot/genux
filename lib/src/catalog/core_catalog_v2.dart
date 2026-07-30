import 'catalog.dart';
import 'core_catalog.dart';
import 'value_type.dart';

// Development release fingerprint for aix.core@2. The catalog exporter will
// replace this with a SHA-256 of the canonical manifest before the first
// compatibility release.
const _coreV2CatalogChecksum =
    'sha256:a1b2c3d4e5f6789012345678901234567890123456789012345678901234abcd';

/// Creates the aix.core@2 catalog with CollectionView and Expanded components.
///
/// This release extends aix.core@1 (10 components) with:
/// - CollectionView: repeated item template with list/grid layouts
/// - Expanded: bounded layout primitive for flex children
///
/// Total: 12 components, all with Material renderers registered.
GenuxCatalog createGenuxCoreV2Catalog() {
  final v1 = createGenuxCoreCatalog();

  return GenuxCatalog(
    id: 'aix.core',
    version: 2,
    checksum: _coreV2CatalogChecksum,
    components: [
      ...v1.components.values,
      GenuxComponentDefinition(
        id: 11,
        code: 'CollectionView',
        version: 1,
        properties: const {
          'itemKey': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            required: true,
            constraint: GenuxValueConstraint(maxLength: 256),
          ),
          'layout': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            required: true,
            constraint: GenuxValueConstraint(
              allowedValues: {'list', 'grid'},
            ),
          ),
          'itemHeight': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 20, maximum: 1000),
          ),
          'columns': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 12),
          ),
          'aspectRatio': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0.1, maximum: 10),
          ),
          'spacing': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 64),
          ),
          'padding': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 64),
          ),
        },
        channels: const {
          'items': GenuxChannelDefinition(
            type: GenuxValueType(
              GenuxValueKind.list,
              itemType: GenuxValueType.object,
            ),
            direction: GenuxChannelDirection.input,
            required: true,
            constraint: GenuxValueConstraint(maxItems: 10000),
          ),
          'loading': GenuxChannelDefinition(
            type: GenuxValueType.boolean,
            direction: GenuxChannelDirection.input,
          ),
          'emptyMessage': GenuxChannelDefinition(
            type: GenuxValueType.string,
            direction: GenuxChannelDirection.input,
            constraint: GenuxValueConstraint(maxLength: 256),
          ),
        },
        events: const {
          'itemInvoked': GenuxEventDefinition(
            payload: GenuxValueType.object,
          ),
        },
        slots: const {
          'itemTemplate': GenuxSlotDefinition(
            minChildren: 1,
            maxChildren: 1,
            introducesContext: GenuxContextKind.item,
          ),
        },
      ),
      GenuxComponentDefinition(
        id: 12,
        code: 'Expanded',
        version: 1,
        properties: const {
          'flex': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 100),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(
            minChildren: 1,
            maxChildren: 1,
          ),
        },
      ),
    ],
  );
}
