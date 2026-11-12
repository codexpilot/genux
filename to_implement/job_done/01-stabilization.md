# Completed stabilization work

Recorded against `main` at `16982ea`, reviewed 2026-11-12. These are completed slices of larger milestones, not claims that the controls or documentation meet every acceptance criterion. Remaining work is tracked in [stabilization](../01-stabilization.md) and the [documentation plan](../04-documentation.md).

- [x] Added controlled slider callbacks, tap/drag and keyboard handlers, disabled styling and semantic properties, with initial widget tests. See [slider](../../lib/src/gux_slider.dart) and [tests](../../test/gux_slider_test.dart).
- [x] Added focus indication, Space/Enter handling, disabled styling and semantic properties to switch and radio, with initial widget tests. See [switch](../../lib/src/gux_switch.dart), [radio](../../lib/src/gux_radio.dart), and their [switch tests](../../test/gux_switch_test.dart) and [radio tests](../../test/gux_radio_test.dart).
- [x] Implemented a standalone hex color codec with alpha and malformed-input coverage. See [codec](../../lib/src/json/gux_color_codec.dart) and [tests](../../test/json/gux_color_codec_test.dart). Integration into component serializers remains open.
- [x] Corrected the README component names and static-preview example to use `Gux*` names. See [README](../../README.md). Verification of remaining snippets and claims remains open.
- [x] Added the required button style and replaced the Material icon in the scaffold example in the [routing guide](../../docs/routing-and-navigation.md). Broader routing documentation and behavior checks remain open.
- [x] **Fixed GuxSlider division snapping** to calculate relative to `min` instead of zero, ensuring all division points are reachable. See [nonzero min tests](../../test/gux_slider_nonzero_min_test.dart).
- [x] **Fixed keyboard event handling** in GuxSlider to return `KeyEventResult.ignored` for unhandled keys (Tab, Escape, etc.), enabling proper focus traversal. See [keyboard tests](../../test/gux_slider_keyboard_test.dart).
- [x] **Verified GuxSwitch and GuxRadio** already return `KeyEventResult.ignored` for unhandled keys.
- [x] **Verified disabled control focus behavior** across GuxSlider, GuxSwitch, and GuxRadio - disabled controls properly ignore keyboard and pointer interactions. See [disabled focus tests](../../test/gux_disabled_focus_test.dart).
- [x] **Verified GuxRadio.fromJson callback contract** uses `ValueChanged<String>` and handles missing/unknown action keys gracefully. See [callback tests](../../test/gux_radio_json_callback_test.dart).

At this baseline, `flutter analyze` passed and `flutter test` passed 312 tests. These checks do not cover all remaining acceptance criteria.
