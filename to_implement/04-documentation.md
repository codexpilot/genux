# 04 — Documentation plan

## Goals and ownership

Make the README a reliable starting point, provide a discoverable reference for each supported API, and distinguish implemented behavior from proposals and historical reports. Documentation changes accompany code changes; the author of a component or behavior change updates its examples, status and limitations in the same review.

## Immediate corrections

- [ ] Replace obsolete `Genux*` symbols in [README](../README.md) and examples with current `Gux*` names. Check every snippet against the public package entry point, including the static presentation example.
- [ ] Describe actual SDK constraints and runtime dependencies from `pubspec.yaml`; retain the precise UI-independence boundary without claiming Flutter is the only dependency. Explain Git dependency pinning and upgrade behavior.
- [ ] Correct [routing examples](../docs/routing-and-navigation.md), including required `GuxButtonStyle`, and explain `GuxApp` route behavior and any changes made under the routing milestone. Avoid Material-only icons in purported framework-independent examples or explicitly explain host ownership.
- [ ] Fix [example app documentation](../example/README.md): use a supported child shape or register a factory, put progress colors at the expected level, correct component counts and malformed-input claims, and link to real documentation. Verify examples against the app actually shipped.
- [ ] Clarify that the static preview is experimental and separate from component JSON. Describe the catalog as schema declarations, and do not describe an A2UI adapter as complete without protocol evidence. Label old migration/phase reports with baseline date and historical status; retain them as history rather than current reference.

## New and revised guides

- [ ] **Getting started:** supported Flutter/Dart versions; install from a pinned Git revision; a minimal runnable `GuxApp` and styled control; required host setup, theme, navigation and run commands. Include troubleshooting for dependency and SDK constraints.
- [ ] **Component catalog and API reference:** every exported component, style and helper, purpose, constructor examples, variations, callbacks, accessibility and keyboard behavior, supported platforms, limitations and links to gallery/tests. Maintain the status matrix described in [03-components.md](03-components.md); clearly separate implemented, partial and planned features.
- [ ] **Theming and composition:** tokens, theme presets, host overrides, light/dark and high-contrast behavior, text scaling, RTL and custom styling, with representative examples.
- [ ] **Navigation and overlays:** app setup, home and named-route fallback, unknown routes, route transitions, responsive scaffolds, overlay lifecycle, focus and dismissal. Align examples with the final implementation, including any migration notes.
- [ ] **JSON and A2UI:** document both existing JSON paths separately, schemas and limits, accepted types and errors, color format, registry setup, action binding and partial serialization. Explain untrusted-input boundaries and version compatibility. Give the catalog and any adapter their own status and supported-protocol matrix; show an end-to-end example only after it is tested.
- [ ] **Accessibility and platform behavior:** control semantics, keyboard interactions, focus, localization, reduced motion, text scaling, touch and screen-reader testing, plus explicit platform limitations. Include a checklist for contributors and users.
- [ ] **Contributor and release guide:** target file structure, naming, public vs internal API, test commands and schema dependencies, component definition of done, compatibility/deprecation policy, release notes and dependency independence checks.
- [ ] **Migration/status:** update the ContextStudio plan against its dated baseline and record what is verified, what still depends on host integration and what remains incomplete. Document any `Genux*` to `Gux*` or deep-import migration as appropriate to the supported API.

## Examples and verification

- [ ] Make the example app a browsable gallery for the components actually implemented, showing key states, interaction and accessibility information; keep the JSON demo clearly marked by format. Use real supported APIs and avoid prohibited UI libraries.
- [ ] Turn representative onboarding and integration snippets into runnable sample files or tests analyzed in CI. Include at least the minimal app, routing, common form controls, static preview and registered JSON renderer. Avoid duplicated snippets where one source can be referenced.
- [ ] Add CI checks for broken local documentation links and the maintained snippet examples. Keep the existing Flutter analyzer, test, independence and schema validation checks. Verify the README setup on a clean checkout and smoke-test the documented app on representative targets.
- [ ] Review all public claims and the component status matrix at each release. Date external reference comparisons and record outstanding limitations rather than making blanket accessibility, JSON round-trip or shadcn/A2UI parity claims.

## Done

A new user can install Genux, run a complete example, find the status and API of a component, and understand the supported JSON and protocol boundaries without consulting source code. Examples and links are verified in CI, and historical planning documents cannot be mistaken for current product status.
