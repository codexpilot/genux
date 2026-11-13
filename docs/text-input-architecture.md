# Text Input Architecture

Genux implements a clean, composable hierarchy for text input components.

## Component Hierarchy

```
GuxTextInput (primitive)
    ↓
GuxTextField (adds labels/errors)
    ↓
GuxComboBox (adds dropdown selection)
```

### GuxTextInput - The Primitive Base

**Purpose**: Low-level editable text input with full EditableText functionality.

**Features**:
- EditableText integration with cursor and selection
- Focus management and keyboard handling
- Text selection menu (cut, copy, paste, select all)
- Custom styling via `GuxTextInputStyle`
- Obscure text support (password fields)
- Input formatters and validation
- Multi-line support

**When to use**: When you need a basic text input without labels or error messages. Most applications should use `GuxTextField` instead.

**Example**:
```dart
final controller = TextEditingController();

GuxTextInput(
  controller: controller,
  semanticsLabel: 'Email',
  style: GuxTextInputStyle(
    textStyle: TextStyle(fontSize: 14),
    backgroundColor: Color(0xFF252525),
    borderColor: Color(0xFF484848),
    focusedBorderColor: Color(0xFF3B82F6),
    cursorColor: Color(0xFF3B82F6),
    // ... other styling
  ),
  placeholder: 'Enter email',
  onChanged: (value) => print('Changed: $value'),
)
```

### GuxTextField - Labeled Text Input

**Purpose**: Wraps `GuxTextInput` and adds label, error message, and validation display.

**Features**:
- All features of `GuxTextInput`
- Optional label text above input
- Error message display below input
- Configurable spacing
- Separate styles for normal and error states

**When to use**: For most text input needs in forms and user interfaces.

**Example**:
```dart
final controller = TextEditingController();

GuxTextField(
  controller: controller,
  style: GuxTextFieldStyle(
    inputStyle: normalInputStyle,
    errorInputStyle: errorInputStyle,
    labelStyle: TextStyle(fontSize: 14),
    errorTextStyle: TextStyle(fontSize: 12, color: Colors.red),
    labelSpacing: 4.0,
    errorSpacing: 4.0,
  ),
  labelText: 'Email Address',
  placeholder: 'you@example.com',
  errorMessage: _emailError,
  onChanged: (value) => _validateEmail(value),
)
```

### GuxComboBox - Selection with Dropdown

**Purpose**: Extends the text field concept with a dropdown menu for selection.

**Features**:
- All features of text field hierarchy
- Dropdown menu with keyboard navigation
- Loading and error states
- Disabled/enabled options
- Optional subtitles for options
- Custom equality comparison

**When to use**: When users need to select from a predefined list of options.

**Example**:
```dart
GuxComboBox<String>(
  options: [
    GuxComboBoxOption(value: 'us', label: 'United States'),
    GuxComboBoxOption(value: 'ca', label: 'Canada'),
    GuxComboBoxOption(value: 'mx', label: 'Mexico'),
  ],
  value: selectedCountry,
  onChanged: (value) => setState(() => selectedCountry = value),
  placeholder: 'Select country',
)
```

## Design Principles

### 1. Single Responsibility
Each component has one clear purpose:
- **GuxTextInput**: Editable text primitive
- **GuxTextField**: Labeled input with validation display
- **GuxComboBox**: Selection from predefined options

### 2. Composition Over Inheritance
Components build on each other through composition:
- `GuxTextField` wraps `GuxTextInput`
- `GuxComboBox` can be refactored to extend `GuxTextField`

### 3. Explicit Styling
All styling is explicit through style classes:
- `GuxTextInputStyle` - primitive styling
- `GuxTextFieldStyle` - contains `inputStyle`, `errorInputStyle`, label styles
- `GuxComboBoxStyle` - complete dropdown styling

### 4. Host-Owned State
The host application owns:
- Text controllers
- Focus nodes
- Validation logic
- State management

Components are controlled - they don't manage their own state.

## Migration Guide

### From Old GuxTextField (primitive)
Old `GuxTextField` is now `GuxTextInput`:

```dart
// Old
GuxTextField(
  controller: controller,
  style: GuxTextFieldStyle(...),
  semanticsLabel: 'Email',
)

// New
GuxTextInput(
  controller: controller,
  style: GuxTextInputStyle(...),
  semanticsLabel: 'Email',
)
```

### From Old GuxTextInput (labeled)
Old `GuxTextInput` is now `GuxTextField`:

```dart
// Old
GuxTextInput(
  controller: controller,
  style: GuxTextInputStyle(
    fieldStyle: ...,
    labelStyle: ...,
  ),
  labelText: 'Email',
)

// New
GuxTextField(
  controller: controller,
  style: GuxTextFieldStyle(
    inputStyle: ...,
    errorInputStyle: ...,
    labelStyle: ...,
  ),
  labelText: 'Email',
)
```

### From Old GuxDropdown
Old `GuxDropdown` is now `GuxComboBox`:

```dart
// Old
GuxDropdown<String>(
  options: [...],
  value: selected,
  onChanged: (v) => ...,
)

// New - identical API
GuxComboBox<String>(
  options: [...],
  value: selected,
  onChanged: (v) => ...,
)
```

## JSON Support

All components support JSON serialization for dynamic UI:

```dart
// GuxTextInput from JSON
final input = GuxTextInput.fromJson(
  {'semanticsLabel': 'Email', 'placeholder': 'Enter email'},
  controller: controller,
);

// GuxTextField from JSON
final field = GuxTextField.fromJson(
  {'labelText': 'Email', 'placeholder': 'you@example.com'},
  controller: controller,
  actions: {'onChanged': handleChange},
);

// GuxComboBox from JSON
final combo = GuxComboBox.fromJson(
  {
    'options': [
      {'value': 'us', 'label': 'United States'},
      {'value': 'ca', 'label': 'Canada'},
    ],
    'placeholder': 'Select country',
  },
  actions: {'onChanged': handleChange},
);
```

## Testing

Each component has comprehensive test coverage:

- **test/gux_text_input_test.dart** - Primitive text input tests
- **test/gux_text_field_test.dart** - Labeled field tests  
- **test/json/gux_text_input_json_test.dart** - JSON serialization
- **test/json/gux_text_field_json_test.dart** - JSON serialization
- **test/json/gux_text_selection_menu_json_test.dart** - Selection menu tests
- **test/gux_combo_box_test.dart** - ComboBox tests
- **test/json/gux_combo_box_json_test.dart** - ComboBox JSON tests

All 488 tests pass.
