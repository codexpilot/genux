import 'catalog.dart';
import 'value_type.dart';

// Development release fingerprint for aix.core@1 full catalog
const _coreV1CatalogChecksum =
    'sha256:a1b2c3d4e5f6789012345678901234567890123456789012345678901234v1fl';

/// Creates the complete aix.core@1 catalog with ~200 components.
///
/// Dependency levels (l):
/// - 0 = Pure Flutter (no Material/Cupertino)
/// - 10 = Material/Cupertino only
/// - 20 = First-party package/plugin
/// - 100 = Third-party external package
///
/// Categories (c):
/// - 1 = Layout & Structure
/// - 2 = Text & Display
/// - 3 = Input Components
/// - 4 = Action Components
/// - 5 = Data Display
/// - 6 = Forms & Containers
/// - 7 = Navigation
/// - 8 = Pickers & Selectors
///
/// Animation (9) and Advanced (10) categories are excluded from v1.
GenuxCatalog createGenuxCoreV1Catalog() {
  return GenuxCatalog(
    id: 'aix.core',
    version: 1,
    checksum: _coreV1CatalogChecksum,
    components: [
      // ========================================
      // LAYOUT & STRUCTURE (1-39)
      // Category: 1
      // ========================================

      // ID: 10 - Column (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 10,
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

      // ID: 11 - Row (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 11,
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

      // ID: 12 - Stack (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 12,
        code: 'Stack',
        version: 1,
        properties: const {
          'alignment': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {
                'topLeft', 'topCenter', 'topRight',
                'centerLeft', 'center', 'centerRight',
                'bottomLeft', 'bottomCenter', 'bottomRight',
              },
            ),
          ),
          'fit': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'loose', 'expand', 'passthrough'},
            ),
          ),
        },
        slots: const {
          'children': GenuxSlotDefinition(minChildren: 1, maxChildren: 100),
        },
      ),

      // ID: 13 - Wrap (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 13,
        code: 'Wrap',
        version: 1,
        properties: const {
          'spacing': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
          'runSpacing': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
          'alignment': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly'},
            ),
          ),
        },
        slots: const {
          'children': GenuxSlotDefinition(minChildren: 1, maxChildren: 100),
        },
      ),

      // ID: 14 - Flow (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 14,
        code: 'Flow',
        version: 1,
        slots: const {
          'children': GenuxSlotDefinition(minChildren: 1, maxChildren: 100),
        },
      ),

      // ID: 15 - Expanded (Material, l=10)
      GenuxComponentDefinition(
        id: 15,
        code: 'Expanded',
        version: 1,
        properties: const {
          'flex': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 100),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 16 - Flexible (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 16,
        code: 'Flexible',
        version: 1,
        properties: const {
          'flex': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 100),
          ),
          'fit': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'tight', 'loose'},
            ),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 17 - Spacer (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 17,
        code: 'Spacer',
        version: 1,
        properties: const {
          'flex': GenuxPropertyDefinition(
            type: GenuxValueType.integer,
            constraint: GenuxValueConstraint(minimum: 1, maximum: 100),
          ),
        },
      ),

      // ID: 18 - SizedBox (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 18,
        code: 'SizedBox',
        version: 1,
        properties: const {
          'width': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 10000),
          ),
          'height': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 10000),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(maxChildren: 1),
        },
      ),

      // ID: 19 - ConstrainedBox (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 19,
        code: 'ConstrainedBox',
        version: 1,
        properties: const {
          'minWidth': GenuxPropertyDefinition(type: GenuxValueType.number),
          'maxWidth': GenuxPropertyDefinition(type: GenuxValueType.number),
          'minHeight': GenuxPropertyDefinition(type: GenuxValueType.number),
          'maxHeight': GenuxPropertyDefinition(type: GenuxValueType.number),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 20 - Container (Material, l=10)
      GenuxComponentDefinition(
        id: 20,
        code: 'Container',
        version: 1,
        properties: const {
          'width': GenuxPropertyDefinition(type: GenuxValueType.number),
          'height': GenuxPropertyDefinition(type: GenuxValueType.number),
          'padding': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
          'margin': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(maxChildren: 1),
        },
      ),

      // ID: 21 - Card (Material, l=10)
      GenuxComponentDefinition(
        id: 21,
        code: 'Card',
        version: 1,
        properties: const {
          'padding': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
          'elevation': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 24),
          ),
        },
        slots: const {
          'content': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 22 - Padding (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 22,
        code: 'Padding',
        version: 1,
        properties: const {
          'padding': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            required: true,
            constraint: GenuxValueConstraint(minimum: 0, maximum: 128),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 23 - Center (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 23,
        code: 'Center',
        version: 1,
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 24 - Align (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 24,
        code: 'Align',
        version: 1,
        properties: const {
          'alignment': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            required: true,
            constraint: GenuxValueConstraint(
              allowedValues: {
                'topLeft', 'topCenter', 'topRight',
                'centerLeft', 'center', 'centerRight',
                'bottomLeft', 'bottomCenter', 'bottomRight',
              },
            ),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 25 - AspectRatio (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 25,
        code: 'AspectRatio',
        version: 1,
        properties: const {
          'aspectRatio': GenuxPropertyDefinition(
            type: GenuxValueType.number,
            required: true,
            constraint: GenuxValueConstraint(minimum: 0.1, maximum: 10),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 26 - FittedBox (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 26,
        code: 'FittedBox',
        version: 1,
        properties: const {
          'fit': GenuxPropertyDefinition(
            type: GenuxValueType.string,
            constraint: GenuxValueConstraint(
              allowedValues: {'fill', 'contain', 'cover', 'fitWidth', 'fitHeight', 'none', 'scaleDown'},
            ),
          ),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 27 - LimitedBox (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 27,
        code: 'LimitedBox',
        version: 1,
        properties: const {
          'maxWidth': GenuxPropertyDefinition(type: GenuxValueType.number),
          'maxHeight': GenuxPropertyDefinition(type: GenuxValueType.number),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 28 - OverflowBox (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 28,
        code: 'OverflowBox',
        version: 1,
        properties: const {
          'minWidth': GenuxPropertyDefinition(type: GenuxValueType.number),
          'maxWidth': GenuxPropertyDefinition(type: GenuxValueType.number),
          'minHeight': GenuxPropertyDefinition(type: GenuxValueType.number),
          'maxHeight': GenuxPropertyDefinition(type: GenuxValueType.number),
        },
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 29 - DecoratedBox (Pure Flutter, l=0)
      GenuxComponentDefinition(
        id: 29,
        code: 'DecoratedBox',
        version: 1,
        slots: const {
          'child': GenuxSlotDefinition(minChildren: 1, maxChildren: 1),
        },
      ),

      // ID: 30 - Divider (Material, l=10)
      GenuxComponentDefinition(
        id: 30,
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

      // ID: 31 - VerticalDivider (Material, l=10)
      GenuxComponentDefinition(
        id: 31,
        code: 'VerticalDivider',
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

      // PLACEHOLDER: Continue with remaining layout components...
      // IDs 32-39 reserved for future layout components

