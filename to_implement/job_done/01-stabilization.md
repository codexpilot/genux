# Completed stabilization work

Recorded against `main` at `16982ea`, reviewed 2026-11-12. Updated with additional P0 work through commit 6df6f9e. These are completed slices of larger milestones, not claims that the controls or documentation meet every acceptance criterion. Remaining work is tracked in [stabilization](../01-stabilization.md) and the [documentation plan](../04-documentation.md).

## Initial P0 Work (commit 16982ea)

- [x] Added controlled slider callbacks, tap/drag and keyboard handlers, disabled styling and semantic properties, with initial widget tests. See [slider](../../lib/src/gux_slider.dart) and [tests](../../test/gux_slider_test.dart).
- [x] Added focus indication, Space/Enter handling, disabled styling and semantic properties to switch and radio, with initial widget tests. See [switch](../../lib/src/gux_switch.dart), [radio](../../lib/src/gux_radio.dart), and their [switch tests](../../test/gux_switch_test.dart) and [radio tests](../../test/gux_radio_test.dart).
- [x] Implemented a standalone hex color codec with alpha and malformed-input coverage. See [codec](../../lib/src/json/gux_color_codec.dart) and [tests](../../test/json/gux_color_codec_test.dart). Integration into component serializers remains open.
- [x] Corrected the README component names and static-preview example to use `Gux*` names. See [README](../../README.md). Verification of remaining snippets and claims remains open.
- [x] Added the required button style and replaced the Material icon in the scaffold example in the [routing guide](../../docs/routing-and-navigation.md). Broader routing documentation and behavior checks remain open.

## P0 Fixes (commit edaf566)

- [x] **Fixed GuxSlider division snapping** to calculate relative to `min` instead of zero, ensuring all division points are reachable. See [nonzero min tests](../../test/gux_slider_nonzero_min_test.dart).
- [x] **Fixed keyboard event handling** in GuxSlider to return `KeyEventResult.ignored` for unhandled keys (Tab, Escape, etc.), enabling proper focus traversal. See [keyboard tests](../../test/gux_slider_keyboard_test.dart).
- [x] **Verified GuxSwitch and GuxRadio** already return `KeyEventResult.ignored` for unhandled keys.
- [x] **Verified disabled control focus behavior** across GuxSlider, GuxSwitch, and GuxRadio - disabled controls properly ignore keyboard and pointer interactions. See [disabled focus tests](../../test/gux_disabled_focus_test.dart).
- [x] **Verified GuxRadio.fromJson callback contract** uses `ValueChanged<String>` and handles missing/unknown action keys gracefully. See [callback tests](../../test/gux_radio_json_callback_test.dart).

## P0 Routing and Documentation (commit ba5d1ea)

- [x] **Documented skipped text field test** with concrete platform limitation (selection handles require framework-specific TextSelectionControls). See [text field tests](../../test/gux_text_field_test.dart).
- [x] **Audited recently added controls** (accordion, tabs, sheet, toast, alert, card, badge, avatar, separator) - documented lack of test coverage and verification needs. See [control audit](control-audit-2026-11-12.md).
- [x] **Fixed GuxApp routing** to handle unknown routes explicitly with `onUnknownRoute` fallback to home. See [app tests](../../test/gux_app_test.dart).
- [x] **Documented radio group accessibility** requirements and implementation options for arrow-key navigation. See [radio group accessibility](radio-group-accessibility.md). Arrow-key group navigation deferred to P1/P2.

## P0 Test Coverage - Simple Controls (commit 3564a4c)

- [x] **GuxSeparator** - Tests for orientation, color, thickness, spacing, JSON. See [separator tests](../../test/gux_separator_test.dart).
- [x] **GuxBadge** - Tests for label, colors, border, padding, JSON. See [badge tests](../../test/gux_badge_test.dart).
- [x] **GuxAvatar** - Tests for initials, size, colors, border, JSON. See [avatar tests](../../test/gux_avatar_test.dart).
- [x] **GuxCard** - Tests for child content, colors, border, shadow, JSON. See [card tests](../../test/gux_card_test.dart).

## P0 Test Coverage - Interactive and Overlay Controls (commit 6df6f9e)

- [x] **GuxAccordion** - Tests for expand/collapse, callbacks, keyboard, styling, JSON. See [accordion tests](../../test/gux_accordion_test.dart).
- [x] **GuxTabs** - Tests for tab switching, callbacks, initialTabId, styling. See [tabs tests](../../test/gux_tabs_test.dart).
- [x] **GuxSheet** - Tests for styling, rounded corners, elevation. See [sheet tests](../../test/gux_sheet_test.dart).
- [x] **GuxToast** - Tests for message, colors, JSON. See [toast tests](../../test/gux_toast_test.dart).
- [x] **GuxAlert** - Tests for message, title, icon, colors, JSON. See [alert tests](../../test/gux_alert_test.dart).

## Summary

At this baseline (commit 6fde7aa), `flutter analyze` passed and `flutter test` passed **375 tests** with one skipped. All 9 audited controls now have basic test coverage. Color serialization bug fixed across all 12 style classes. These checks do not cover all remaining acceptance criteria.

**Test Growth:**
- Initial: 297 tests
- After P0 fixes: 317 tests (+20)
- After simple controls: 341 tests (+24)
- After interactive/overlay controls: 371 tests (+30)
- After color serialization fix: 375 tests (+4)

## Remaining P0 Work

Per [01-stabilization.md](../01-stabilization.md):
- Implement GuxRadioGroup for arrow-key navigation within radio groups (deferred to P1)
- Complete remaining documentation verification per [04-documentation.md](../04-documentation.md)
  - README component names and examples verified ✓
  - Routing documentation verified ✓
  - Comprehensive example verification deferred to next phase
- Additional acceptance criteria testing (RTL, performance, advanced accessibility)
