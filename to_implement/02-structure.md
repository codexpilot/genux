# 02 — Dart structure and migration

This is a target and migration plan, not a description of today's flat `lib/src` tree. Organize by responsibility and component; do not create empty folders or split a small widget simply to match the diagram. New component families and their priority are tracked in [05-basic-components.md](05-basic-components.md).

## Target layout

```text
lib/
  genux.dart                              # stable public package entry point
  src/
    foundation/
      theme/                              # theme, color schemes, tokens
      interaction/                        # shared focus, keyboard, selection helpers
      overlay/                            # reusable positioning and lifecycle helpers
    components/
      button/
        gux_button.dart                   # public widget implementation
        gux_button_style.dart             # only if a separate file is useful
      dropdown/
        gux_dropdown.dart                 # public widget and option API
        dropdown_overlay.dart             # internal helper only when justified
      text_field/
        gux_text_field.dart
      data_grid/                          # example planned family; add when built
        gux_data_grid.dart
        data_grid_controller.dart
      ...
    navigation/                           # app, page routes, navigation, scaffolds
    presentation/                         # bounded static document and view
    json/                                 # JSON registry, shared codecs and contracts
    a2ui/                                 # catalog; any adapter stays separately scoped

test/
  components/
    button/                               # widget, interaction, semantics tests
    dropdown/
    text_field/
    ...
  navigation/
  presentation/
  json/                                   # registry, codec and JSON contract tests
  a2ui/
  integration/                            # public-import and representative journeys
```

Directories in the example are created when their first implementation or test is moved or added. `data_grid` is illustrative; its eventual API is determined by the component plan. Existing file locations remain valid during the migration, and test folders need not be moved until the corresponding slice is ready.

## Ownership and dependency rules

- A component family owns its widget, controller or selection model, style, semantics and component-specific helpers. Name public Dart types `Gux...`; name files in `snake_case`. Keep a small family in one file; split files only when this improves comprehension or testability. Helpers with no supported public API stay internal.
- `lib/genux.dart` remains the supported consumer import and explicitly exports the existing public symbols, including extensions and types re-exported by theme files. Add new supported APIs deliberately; do not export every file or private implementation helper through a broad barrel. Document any other supported entry point before adding it.
- Foundation owns only behavior shared by multiple components, such as theme tokens and verified focus or overlay helpers. Components may depend on foundation and Flutter widgets; foundation must not import a particular component or application. Extract shared code when there are concrete users, not in anticipation of every possible widget.
- Component JSON uses the contracts and shared codecs in `json/`; the registry and renderer are integration layers. Keep widget construction and JSON adapters free of circular imports. Existing public `fromJson`, `toJson`, extension methods and registry behavior remain supported while moving them; a move alone must not change serialization or action binding.
- `presentation/` owns the bounded static document parser and view. `a2ui/` owns catalog declarations and any separately specified future protocol adapter. Neither is evidence of the other being a working protocol integration. Keep application-specific ERP, POS, commerce, CRM, clinical and FHIR workflows outside core components; introduce optional packages only after specifying their APIs and dependencies.
- Keep production dependencies within Genux's existing UI-independence boundary: use Flutter widgets and host-provided styling, and do not import Flutter Material or Cupertino widgets or prohibited third-party UI libraries. Check dependency and source graphs with the existing independence tool. Additional dependencies require an explicit review of footprint, licensing and supported platforms.
- Dart underscore declarations are library-private. When splitting a widget, preserve access by keeping private collaborators in the same library or introducing a deliberate internal interface; use `part` only when justified. Do not expose implementation details merely to make a split compile.

## Compatibility and incremental sequence

1. [ ] Inventory every symbol exported by `lib/genux.dart`, including extensions and transitive theme exports. Add a consumer smoke test that imports only `package:genux/genux.dart` and exercises representative public APIs before moving files.
2. [ ] Inventory `package:genux/src/...` imports in tests and known consumers. Although `src` is conventionally internal, decide and document a migration and support period before removing an existing deep path. Where shims are needed, make the old file re-export the canonical new library rather than copying classes, so type identity remains intact.
3. [ ] Move a small, cohesive and already-tested component family first. Update the public barrel, internal imports and tests, add old-path shims where promised, and verify public and supported deep imports. Keep file moves separate from behavior changes where practical; do not use a move to rename constructors, alter defaults or change widget behavior.
4. [ ] Move remaining families and shared code incrementally, guided by the [component inventory](05-basic-components.md). Migrate navigation, static presentation, JSON and catalog separately; preserve registration, extensions and API contracts. Keep private collaborators together or introduce a deliberate interface.
5. [ ] For every slice, run `flutter analyze`, targeted tests, the full Flutter suite and UI-independence checks. Include public-import and relevant serialization tests; record failures and any skipped checks. Verify schema validation when touching the static presentation contract. Check for dependency cycles and accidental duplicate public symbols.
6. [ ] Remove tracked OS metadata such as `lib/.DS_Store` in an appropriate cleanup change and prevent recurrence through ignore rules. Remove a compatibility shim only after its documented support period and a deliberate breaking-change decision.

## Done

A maintainer can locate a family, its public API, styles, helpers and tests without searching the flat source tree. Each migrated slice passes its targeted and full checks, public-import consumer tests and independence checks; documented supported deep imports work for their support period. Any breaking change has an explicit migration and versioning decision.
