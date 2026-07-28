import 'package:genux/genux_flutter.dart';

final class ShowcaseRuntime {
  ShowcaseRuntime._({
    required this.catalog,
    required this.capabilities,
    required this.flutterCatalog,
  });

  factory ShowcaseRuntime.standard() {
    // Use aix.core@2 catalog with CollectionView and Expanded
    final catalog = createGenuxCoreV2Catalog();
    final capabilities = GenuxCapabilityRegistry([
      GenuxCapabilityDefinition(
        code: 'view.open',
        arguments: const {
          'viewCode': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(code: 'view.back'),
      GenuxCapabilityDefinition(
        code: 'demo.event',
        arguments: const {
          'control': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
          'event': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
          'value': GenuxArgumentDefinition(
            type: GenuxValueType.nullableJsonScalar,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'customer.type.changed',
        arguments: const {
          'value': GenuxArgumentDefinition(
            type: GenuxValueType.nullableJsonScalar,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'customer.save',
        arguments: const {
          'customer': GenuxArgumentDefinition(
            type: GenuxValueType.object,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'customer.select',
        arguments: const {
          'customerId': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
          'customerName': GenuxArgumentDefinition(
            type: GenuxValueType.string,
            required: true,
          ),
        },
      ),
      GenuxCapabilityDefinition(
        code: 'debug.log',
        arguments: const {
          'message': GenuxArgumentDefinition(
            type: GenuxValueType.string,
          ),
          'itemKey': GenuxArgumentDefinition(
            type: GenuxValueType.any,
          ),
          'itemIndex': GenuxArgumentDefinition(
            type: GenuxValueType.integer,
          ),
        },
      ),
    ]);
    return ShowcaseRuntime._(
      catalog: catalog,
      capabilities: capabilities,
      flutterCatalog: createGenuxMaterialCatalog(catalog),
    );
  }

  static const initialViewCode = 'customer.edit';
  static const fixtureAssets = <String, String>{
    'customer.edit': 'assets/views/customer-edit.genux.json',
    'customer.summary': 'assets/views/customer-summary.genux.json',
    'customer.list': 'assets/views/customer-list.genux.json',
    'component.lab': 'assets/views/component-lab.genux.json',
  };

  static String get fixtureAsset => fixtureAssets[initialViewCode]!;

  final GenuxCatalog catalog;
  final GenuxCapabilityRegistry capabilities;
  final GenuxFlutterCatalog flutterCatalog;

  int get catalogMemberCount => catalog.components.values.fold(
    0,
    (count, component) =>
        count +
        component.properties.length +
        component.channels.length +
        component.events.length +
        component.slots.length,
  );

  GenuxDocumentCompiler get compiler =>
      GenuxDocumentCompiler(catalog: catalog, capabilities: capabilities);
}
