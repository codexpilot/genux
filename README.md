# Genux

Genux is a Flutter package for reusable, application-independent
UI primitives. Its runtime dependency is the Flutter SDK; the current widgets
use Flutter's low-level widgets rather than a UI component library.

Genux must not import or depend on `fluent_ui`, `material_ui`, or
`cupertino_ui`, including through another package. Its production code must not
import Flutter's `material.dart` or `cupertino.dart` widget libraries. The
Flutter SDK itself remains a dependency; its internal dependencies can include
`material_color_utilities`, which is not a Material widget library. Any future
integration with another UI framework belongs in a separate optional adapter,
not in Genux core.

The package exports:

- `GenuxSummaryLines`: three single-line text values with configurable styles
  and spacing. Long text is visually ellipsized.
- `GenuxWorkspaceScaffold`: a bounded workspace layout with a body and optional
  top, bottom, and leading side regions. The caller supplies the region sizes
  and may provide the background color and text style.
- `GenuxButton`: a host-styled button with pointer, keyboard, focus, and disabled
  states. `GenuxButtonStyle` supplies its colors, dimensions, and text style.
- `GenuxProgressIndicator`: a compact determinate or indeterminate indicator
  with host-supplied colors and optional accessibility labels.
- `GenuxNavigation`: a configurable vertical navigation rail with caller-owned
  selection, icons, labels, and callbacks.
- `GenuxDropdown`: a controlled selection field with keyboard navigation,
  status states, and an anchored menu. The menu closes on viewport or local
  text-direction or scaling changes and uses fresh bounds when reopened.
- `GenuxTextField`: an early low-level text input with host-owned text, labels,
  styling and validation. Keyboard selection works, but platform selection
  handles, a context menu, and accessibility copy/cut/paste actions are not yet
  implemented; it is not a drop-in replacement for a full-featured text field.
- `GenuxDialog` and `showGenuxDialog`: a host-styled dialog surface and route.
  Supply a localized barrier label, and constrain or shrink-wrap any scrollable
  child placed inside dialog content.

These primitives are an initial migration foundation, not yet a complete
replacement for ContextStudio's UI. See the [component inventory and plan](docs/contextstudio-migration.md)
and the [JSON and A2UI design notes](docs/json-and-a2ui-readiness.md).

To use Genux from another Flutter application, add a Git dependency to its
`pubspec.yaml`:

```yaml
dependencies:
  genux:
    git:
      url: https://github.com/codexpilot/genux.git
      ref: main
```

Run `flutter pub get` to resolve the dependency. Application lockfiles record
the resolved commit; run `flutter pub upgrade genux` to pick up newer changes
on the chosen ref and review and commit the updated lockfile with the app.

## Experimental static JSON preview

Genux can parse and render a small, **internal experimental** presentation
format. Version 1 is for static previews and carries no compatibility guarantee;
it is not A2UI-compatible or a runtime binding artifact. It supports `text`,
`column`, `summaryLines`, and `workspace` nodes. There are no data bindings,
actions, arbitrary widget constructors, or external resource access. See the
[version 1 schema](schema/genux-presentation-v1.schema.json) and
[dashboard example](examples/dashboard.json).

Parse JSON text with `GenuxPresentationDocument.parse`, then give the validated
document to `GenuxPresentationView`. The embedding app supplies text direction
and inherited text style; give the preview bounded constraints:

```dart
import 'package:flutter/widgets.dart';
import 'package:genux/genux.dart';

Widget preview(String jsonText) {
  final document = GenuxPresentationDocument.parse(jsonText);
  return Directionality(
    textDirection: TextDirection.ltr,
    child: DefaultTextStyle(
      style: const TextStyle(fontSize: 14),
      child: SizedBox(
        width: 640,
        height: 320,
        child: GenuxPresentationView(document: document),
      ),
    ),
  );
}
```

The parser rejects invalid JSON, unsupported versions or node types, unknown
fields, and invalid values with `GenuxFormatException`, which includes a JSON
path. Both input and normalized serialization must fit within 262,144 UTF-8
bytes. Other limits include 32 node levels, 512 nodes, 100 children per column,
and 4,096 Unicode code points per text value. Spacing must be between 0 and
200, and workspace region sizes between 0 and 1,000. The parser enforces
aggregate limits in addition to the JSON Schema.

## A2UI and GenUI evaluation

The original [`genui` package](https://pub.dev/packages/genui) is discontinued.
The newer [`a2ui_core`](https://pub.dev/packages/a2ui_core) handles A2UI protocol
state and messages, while [`a2ui_flutter`](https://pub.dev/packages/a2ui_flutter)
renders surfaces. The Flutter adapter's basic catalog uses Material widgets.
A custom catalog built on Genux is a candidate for future evaluation; it is not
implemented or verified here, and the Genux static preview is not an A2UI
implementation.

From the Genux repository root, resolve and check the package with:

```sh
flutter pub get
flutter analyze
flutter test
```

After resolving dependencies, check the Genux runtime dependency graph and
library sources for the prohibited UI libraries:

```sh
python3 tool/check_ui_independence.py
```

To check the presentation schema and fixtures, use a Python environment with
`jsonschema==4.23.0` installed, then run from the Genux repository root:

```sh
python3 -m pip install jsonschema==4.23.0
python3 tool/validate_presentation_schema.py
```
