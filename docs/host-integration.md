# Host integration: pickers and theme

Genux does not access files or open a platform picker by itself. A host supplies
`GuxFilePicker.selectFiles`, an asynchronous callback receiving the build
context, `allowMultiple`, and `acceptedExtensions`. It must open an appropriate
platform picker and return selected host-defined identifiers, or `null` when
cancelled. The host owns permissions, validation, platform differences,
security and any file access; returned strings are not guaranteed to be paths.
An empty result is an explicit empty selection. If multiple selection is disabled,
returning multiple items throws a `StateError`. Without an adapter or `onChanged`,
the trigger is disabled. An adapter exception propagates to Flutter's error
handling; the host should handle its platform errors.

`GuxDateTimePicker.selectDateTime` receives the current value, picker mode, and
inclusive minimum and maximum instants. The host must open a calendar, time
selector, or other appropriate UI and return the chosen `DateTime`, or `null`
on cancellation. The trigger is disabled without the adapter; there is currently
no built-in calendar. A result outside the bounds is ignored. Invalid bound
ordering raises `ArgumentError` when activated. Dates represented by epoch
milliseconds are returned as epoch milliseconds when the current value is an
integer; a null or `DateTime` value yields a `DateTime`. Values and bounds are
compared as instants; the host owns timezone and date-only policy. Supply
localized placeholders and an optional icon widget.

Both pickers are controlled: the host updates `value` after `onChanged`. A
selection that completes after the widget is disposed or disabled is ignored.
Existing applications must provide adapters when migrating from the previous
placeholder implementation, which fired callbacks without a selection.

`GuxTheme` is data, not an inherited widget theme. `GuxThemeStyles(theme)`
provides a shared explicit mapping for date/time pickers, file pickers, tabs,
and accordions; pass its corresponding style to each widget. Other component
styles still require host mapping. Existing widget defaults remain unchanged.
Hosts can replace an individual style when a local override is needed.

Genux's experimental static presentation format has no data bindings, actions,
authorization, or offline synchronization. It is not a Dataset runtime
renderer. Those capabilities must be provided and tested by the host or by a
separately specified integration; no compatibility or security guarantee is
implied by the component or catalog APIs.
