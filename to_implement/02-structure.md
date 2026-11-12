# 02 — Dart structure and migration

## Target layout

Organize by responsibility and component, not by arbitrary file size. The following is a target, not a requirement to split every widget into multiple files:

```text
lib/
  genux.dart                       # stable public entry point
  src/
    foundation/                    # themes, tokens, shared interaction/overlay primitives
    components/
      button/                      # widget, style, private helpers as needed
      dropdown/                    # widget, menu/positioning helpers, codec as appropriate
      text_field/                  # widget, selection/menu helpers
      ...
    navigation/                    # app, page routes, navigation and scaffolds
    presentation/                  # bounded static document and view
    json/                          # component JSON contracts, registry and codecs
    a2ui/                          # catalog and any future protocol adapter
 test/
  components/<component>/          # behavior, semantics and serialization tests
  navigation/
  presentation/
  json/
  a2ui/
  integration/                    # public entry point and representative journeys
```

Keep styles next to their component unless they are shared. Extract focus, keyboard, overlays, colors and theme utilities only after identifying genuinely shared behavior; avoid a broad base class or duplicated utility libraries. Large current candidates include the dropdown, text field and catalog. Split the catalog by component family and separate schemas from any runtime adapter.

## Compatibility and sequence

- [ ] Inventory every symbol exported by `lib/genux.dart`, including extensions and types re-exported through theme files; capture a public-import consumer smoke test before moving files. Preserve public names, constructors, extensions and barrel exports during a move.
- [ ] Inventory current `package:genux/src/...` imports in tests and known consumers. `src` is conventionally internal, but consumers may still rely on it: migrate tests to the public barrel when practical and decide whether to provide temporary export shims. Document the support period and breaking-change policy before removing any shim.
- [ ] Move one cohesive domain at a time, update internal imports and mirror tests, then run analysis, targeted tests, the full suite and UI-independence checks. Keep file moves separate from behavior changes where practical so diffs remain reviewable.
- [ ] Dart underscore declarations are library-private. When splitting a widget, preserve access by keeping private collaborators in the same library or introducing a deliberate internal interface; use `part` only when justified. Do not accidentally expose internals to make a split compile.
- [ ] Keep the static presentation parser/view, component renderer and A2UI schema/adapter distinct. Avoid cycles between widgets and JSON; preserve the dropdown JSON extension and all currently public types. Do not introduce dependencies on app-specific code or forbidden UI frameworks.
- [ ] Remove tracked OS metadata such as `lib/.DS_Store` in an appropriate cleanup change and prevent recurrence through ignore rules.

## Done

Public-import consumer tests, all existing and newly relevant tests, analysis, and independence checks pass after each slice. A maintainer can locate a component, its style, tests and codec without searching the flat `lib/src` directory; any deep-import migration is documented.
