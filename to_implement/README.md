# Genux implementation plan

Status: proposed; no implementation tasks in this directory are complete. Baseline: `main` at `bf0f9a0`, reviewed 2026-11-12. Recheck the code and the upstream catalog before starting each milestone. This plan translates shadcn/ui concepts to Flutter; identical names do not establish visual, behavioral, or accessibility parity.

## Goal and boundaries

Deliver a dependable, maintainable Flutter widget library inspired by [shadcn/ui](https://ui.shadcn.com/docs/components), with an honest component catalog, usable documentation, and a clearly scoped JSON story. Retain Genux's prohibition on production Material, Cupertino, Fluent and their prohibited transitive UI libraries. Use `flutter/widgets.dart`, host-provided styling, and Flutter-native accessibility and platform conventions. Keep ContextStudio's migration requirements in view without coupling core widgets to application code.

The current baseline passes `flutter analyze`, 247 Flutter tests (one skipped), the UI-independence check and its eight Python tests. Schema validation was not run in the review environment because `jsonschema` was missing. Passing tests do not establish parity or accessibility for the newer components.

## Work streams and execution order

1. **Stabilize and clarify:** fix broken documentation and examples immediately; add regression tests, then repair control, routing, serialization and renderer defects. See [01-stabilization.md](01-stabilization.md).
2. **Reorganize incrementally:** introduce the target Dart structure without changing public behavior or `package:genux/genux.dart` imports. Shared infrastructure can be extracted alongside each repair, after tests are in place. See [02-structure.md](02-structure.md).
3. **Build the component catalog:** audit existing components, implement shared interaction primitives, then deliver the component waves in dependency order. See [03-components.md](03-components.md).
4. **Ship documentation continuously:** repair onboarding first; publish component and integration guides alongside each release rather than after all component work. See [04-documentation.md](04-documentation.md).
5. **Protocol integration:** define and test JSON contracts before considering a separate A2UI adapter; a catalog alone is not protocol support. This can proceed in parallel with later component waves only after the JSON contract is agreed. See [01-stabilization.md](01-stabilization.md).

Each milestone should land in small, reviewable changes, with tests and documentation in the same change. Do not advertise a component as complete merely because a class exists. Resolve any API-breaking choice with an explicit migration and versioning decision before implementation.

## Release gates

- `flutter pub get`, `flutter analyze`, `flutter test`, the UI-independence unit tests and dependency/source check, and presentation schema validation pass as configured in CI. Record any environment limitation and skipped test with an owner and issue.
- Public-import compatibility and representative app smoke tests pass. No new prohibited UI dependencies or imports are introduced.
- Every shipped component meets the shared interaction, accessibility, styling, responsive and documentation criteria in [03-components.md](03-components.md); relevant platform manual checks supplement automated tests.
- JSON formats, unsupported cases and protocol status are accurately documented and tested. No A2UI compatibility claim until the adapter's protocol acceptance gate passes.
- README examples and the documented example app run against the release; release notes state API changes and remaining limitations.
