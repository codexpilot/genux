# Worker handover — Genux

**Intended worker:** Opus 5.5 (or the worker assigned by the project owner).

**Recorded:** 2026-11-12, against repository `main` at `16982ea`. This document is a starting snapshot, not a substitute for inspecting the current branch, worktree and instructions. The owner’s current request takes precedence if it differs from this handover.

## Objective

Build Genux into a dependable, application-independent Flutter UI library for business and clinical applications. Stabilize and complete existing controls before building the planned shared component families. Deliver work in small, reviewable slices, with tests and documentation; the catalog is a roadmap, not a request to implement all 51 families in one change.

The intended consumers include ERP, POS, e-commerce, CRM and EMR/EHR applications. Generic UI belongs in Genux core; business workflows and integrations remain separately scoped. FHIR is an interoperability standard and requires its own integration decisions; a widget catalog does not establish FHIR compliance or clinical safety.

## First steps and reading order

1. Inspect `git status --short --branch`, current commits and applicable repository instructions. Preserve existing uncommitted work; the planning files were uncommitted when this handover was written. Do not reset, overwrite or assume ownership of changes you did not make.
2. Read [the plan index](README.md), then [stabilization and correctness](01-stabilization.md) and [the basic component catalog](05-basic-components.md). The latter contains the prioritized 51-family inventory and minimum acceptance criteria.
3. Read [structure and migration](02-structure.md) before moving code, [the broader component roadmap](03-components.md) for reference-catalog coverage, and [the documentation plan](04-documentation.md) when working on user-facing claims or examples.
4. Check [completed work](job_done/01-stabilization.md) and the current code/tests before choosing a task. Completed slices are not evidence that a whole family or milestone meets its acceptance criteria.
5. Select the slice actually requested by the owner. If no narrower task was specified, start with the P0 stabilization defects below rather than a large restructuring or speculative components. Confirm findings against the current code first, as this snapshot may become stale.

## Current status and priorities

- The catalog classifies **21 of 51 families as existing/partial and 30 as new**; these are planning categories, not a count of finished components. `lib/genux.dart` is the supported public entry point.
- The latest reviewed commit added initial slider, switch and radio behavior and tests, a standalone color codec, and some documentation corrections. It did not complete all their acceptance criteria; details and source links are in [job_done](job_done/01-stabilization.md).
- Start with the P0 control work in [01-stabilization.md](01-stabilization.md): slider snapping with nonzero minima, unhandled keys and Tab traversal, range/division edge cases and RTL; disabled-control focus; and the `GuxRadio.fromJson` callback compatibility break. Add focused failing regression tests before changing confirmed behavior.
- Then continue the other P0 items: audit newer controls, routing, the skipped touch-selection test, and documentation truth. Do not silently remove the skipped test or label unfinished work complete.
- The shared color codec exists but is not integrated into component serializers. Its integration and format/compatibility decisions are tracked under P1 JSON work; preserve alpha and test representative serialization paths, not just the codec in isolation.
- After stabilization, build the basic catalog in its delivery order: shared form/data/overlay foundations and a real host-owned workflow first; broader and domain-specific patterns follow demonstrated needs.

## Architecture and compatibility guardrails

- Use `flutter/widgets.dart` and host-owned styling. Production code must not import Flutter Material or Cupertino widget libraries, `fluent_ui`, `material_ui`, `cupertino_ui`, or prohibited transitive UI libraries. Use the repository's independence checks rather than assuming a dependency is safe.
- Preserve public imports, names and existing behavior unless a migration/versioning decision is made. In particular, check both old and proposed action-binding behavior before changing JSON APIs. Move one cohesive area at a time, with public-import tests and type-preserving re-export shims for any supported deep imports.
- Keep static presentation JSON, component JSON/renderer and the A2UI catalog distinct. Do not claim a working A2UI adapter or FHIR support without a separately specified and verified integration. Keep domain logic, FHIR mapping, payments, device access and clinical decisions out of generic widget primitives.
- Design controlled state, focus and semantics, keyboard/touch, localization/RTL, text scaling, responsive layout and async/error states as appropriate. Test safety-sensitive clinical compositions with clinicians and preserve patient/encounter context, status and provenance.
- Follow the detailed directory ownership, dependency and migration plan in [02-structure.md](02-structure.md). Do not create empty scaffolding or duplicate shared abstractions without a concrete use.

## Verification

From the repository root, the CI-equivalent checks are:

```sh
flutter pub get
flutter analyze
flutter test
python3 -m unittest discover -s tool -p 'test_ui_independence.py'
python3 tool/check_ui_independence.py
python3 tool/validate_presentation_schema.py
```

The final schema command requires `jsonschema==4.23.0` in the chosen Python environment; see [.github/workflows/quality.yml](../.github/workflows/quality.yml). Run relevant targeted tests while developing, then the required full checks for the slice. Record skipped or blocked checks and their cause; do not claim an unrun check passed. At the recorded baseline, `flutter analyze` and `flutter test` passed with 297 tests and one skipped; independence and schema checks were not rerun for that review. SDK constraints and runtime dependencies are in [pubspec.yaml](../pubspec.yaml).

## When handing work back

Report the user-visible behavior changed, relevant files, tests and exact results, and any remaining limitations. Update the active plan and [job_done](job_done/01-stabilization.md) only for verified completed slices; keep unmet criteria active and preserve historical context. Do not mark the entire catalog complete merely because widget classes exist. Follow the owner's instructions for commits, push or deployment.
