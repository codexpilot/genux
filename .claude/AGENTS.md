# Genux Development Guidelines

## Framework Independence

**STRICT RULES - Never violate:**

### ❌ FORBIDDEN Imports
- `package:flutter/material.dart` - NO Material Design framework
- `package:flutter/cupertino.dart` - NO Cupertino (iOS) framework
- Any Material or Cupertino UI components

### ✅ ALLOWED Imports
- `package:flutter/widgets.dart` - Core Flutter primitives only
- `package:flutter/services.dart` - Platform services
- `package:flutter/painting.dart` - Custom painting
- `package:flutter/rendering.dart` - Low-level rendering

### Framework-Free Alternatives

Instead of framework-dependent APIs, use:

```dart
// ❌ WRONG - Material dependency
MediaQuery.of(context).size
MediaQuery.of(context).viewInsets
Theme.of(context).textTheme

// ✅ CORRECT - Framework-free
View.of(context).physicalSize
View.of(context).viewInsets
View.of(context).devicePixelRatio
View.of(context).platformDispatcher.accessibilityFeatures
```

```dart
// ❌ WRONG - Material widget
Material(
  elevation: 8,
  child: child,
)

// ✅ CORRECT - Custom implementation
DecoratedBox(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: child,
)
    ],
  ),
  child: child,
)
```

```dart
// ❌ WRONG - Material colors
Colors.blue
Colors.transparent

// ✅ CORRECT - Explicit colors
Color(0xFF0078D4)
Color(0x00000000)
```

### Before Committing

Always verify framework independence:
```bash
# These should return 0 results
grep -r "import.*material\.dart" lib/src --include="*.dart"
grep -r "import.*cupertino\.dart" lib/src --include="*.dart"
grep -r "MediaQuery\." lib/src --include="*.dart"
grep -r "Theme\.of" lib/src --include="*.dart"
grep -r "Colors\." lib/src --include="*.dart"
```

## Version Numbering

**STRICT RULE for semantic versioning:**

### Format: MAJOR.MINOR.PATCH (e.g., 1.2.3)

- **MAJOR (first digit)** - Breaking changes
  - Changes that break existing code
  - Removed parameters or methods
  - Changed behavior that requires code updates
  
- **MINOR (second digit)** - New classes or components ONLY
  - ✅ Added new GuxSomething component
  - ✅ Added new class exported in genux.dart
  - ❌ Added parameters to existing component
  - ❌ Enhanced existing functionality
  - ❌ Bug fixes

- **PATCH (third digit)** - Everything else backward-compatible
  - ✅ Bug fixes
  - ✅ Added optional parameters to existing components
  - ✅ Performance improvements
  - ✅ Documentation updates
  - ✅ Framework independence fixes
  - ✅ Internal refactoring

### Examples

```
0.1.0 → 0.1.1  Added optional parameters to GuxComboBox
0.1.1 → 0.1.2  Fixed framework dependencies
0.1.2 → 0.2.0  Added new GuxDatePicker component
0.2.0 → 1.0.0  Stable API, ready for production
1.0.0 → 1.0.1  Bug fixes and enhancements
1.0.1 → 1.1.0  Added new GuxTimePicker component
1.1.0 → 2.0.0  Removed deprecated methods (breaking)
```

### When in Doubt

**ALWAYS ASK** the user what version number to use. Version numbering is a product decision, not just technical.

## Pickers and Platform Integration

### Date/Time Picker

**GuxDateTimePicker has a built-in picker** (`_showBuiltInPicker`) that displays a custom calendar/time dialog.

- **Default behavior**: Opens a framework-free calendar dialog
- **Host override**: Optional `selectDateTime` callback allows host to provide platform picker
- **Min/Max enforcement**: Built-in picker enforces `minDate` and `maxDate` constraints
- **NOT a placeholder**: Fully functional out of the box

```dart
// ✅ Works with built-in picker
GuxDateTimePicker(
  value: selectedDate,
  onChanged: (value) => setState(() => selectedDate = value),
  mode: DateTimePickerMode.date,
  minDate: DateTime(2020, 1, 1),
  maxDate: DateTime(2030, 12, 31),
  style: const GuxDateTimePickerStyle(),
)

// ✅ Host can override with platform picker
GuxDateTimePicker(
  value: selectedDate,
  onChanged: (value) => setState(() => selectedDate = value),
  selectDateTime: (context, value, mode, min, max) async {
    // Host provides platform-specific picker
    return await showPlatformDatePicker(...);
  },
  style: const GuxDateTimePickerStyle(),
)
```

### File Picker

**GuxFilePicker REQUIRES host implementation** - it is a UI wrapper, not a file picker.

- **No built-in picker**: Genux cannot access platform file dialogs
- **Required parameter**: `selectFiles` callback must be provided by host
- **Host responsibility**: Opening file picker, handling permissions, returning file data

```dart
// ✅ Host must provide selectFiles callback
GuxFilePicker(
  value: selectedFiles,
  onChanged: (files) => setState(() => selectedFiles = files),
  selectFiles: (context, allowMultiple, acceptedExtensions) async {
    // Host implementation required
    // Use file_picker package, platform channels, or web file input
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: acceptedExtensions,
    );
    return result?.files.map((f) => GuxFileInfo(...)).toList();
  },
  allowMultiple: true,
  acceptedExtensions: ['pdf', 'docx'],
  style: const GuxFilePickerStyle(),
)
```

### Host Integration Requirements

When using Genux in ContextStudio or Dataset:

1. **File picker**: Must provide `selectFiles` callback
2. **Date picker**: Can use built-in or override with `selectDateTime`
3. **Permissions**: Host handles file access permissions
4. **Platform specifics**: Host handles web vs native differences

## Icons and Fonts

### Material Symbols Font

Genux includes Material Symbols Outlined font for host use:

- **Location**: `assets/fonts/material_symbols/MaterialSymbolsOutlined.ttf`
- **Registered**: In pubspec.yaml under `flutter.fonts`
- **Family name**: `MaterialSymbols`
- **Usage**: Host-provided, not built into components

### Icon Strategy

**Components DO NOT have built-in icons**. All icons are host-provided through optional `icon` parameter.

```dart
// ❌ WRONG - No built-in icons
GuxDateTimePicker(
  // No icon appears automatically
)

// ✅ CORRECT - Host provides icon widget
GuxDateTimePicker(
  icon: Text(
    String.fromCharCode(0xe935), // calendar_today
    style: TextStyle(
      fontFamily: 'MaterialSymbols',
      fontSize: 20,
      color: Color(0xFFFFFFFF),
    ),
  ),
  // ... other parameters
)

// ✅ CORRECT - Or use any custom icon
GuxDateTimePicker(
  icon: Image.asset('assets/icons/calendar.png', width: 20, height: 20),
  // ... other parameters
)
```

### Icon Guidelines

1. **Never bundle icons** - Host provides all icons
2. **Material Symbols available** - Font is packaged for host convenience
3. **Icon parameter is Widget** - Host can use text, image, or custom widget
4. **No icon dependencies** - Components work without icons
5. **Host consistency** - Host ensures consistent icon usage across app

### Using Material Symbols (Host Code)

Create a helper for Material Symbols icons:

```dart
// In host application (ContextStudio/Dataset)
class GuxIcons {
  static Widget calendar({Color? color, double size = 20}) {
    return Text(
      String.fromCharCode(0xe935),
      style: TextStyle(
        fontFamily: 'MaterialSymbols',
        fontSize: size,
        color: color,
      ),
    );
  }
  
  static Widget folder({Color? color, double size = 20}) {
    return Text(
      String.fromCharCode(0xe2c7),
      style: TextStyle(
        fontFamily: 'MaterialSymbols',
        fontSize: size,
        color: color,
      ),
    );
  }
}

// Usage
GuxDateTimePicker(
  icon: GuxIcons.calendar(color: Color(0xFFFFFFFF)),
  // ...
)
```

### Before Committing Icon Changes

Verify no hardcoded icon dependencies:

```bash
# Should return 0 results
grep -r "Icons\." lib/src --include="*.dart"
grep -r "IconData" lib/src --include="*.dart" | grep -v "// "
grep -r "0xe[0-9a-f]" lib/src --include="*.dart"  # Icon codepoints
```

## Component Design Principles

### 1. Host-Provided Styling (Explicit, Not Inherited)

**IMPORTANT: Components DO NOT auto-consume GuxTheme from context.**

All visual properties must be explicitly passed through style parameters. This is intentional design, not a missing feature.

#### Why Explicit Styling?

1. **Predictable behavior** - No hidden context dependencies
2. **Host control** - ContextStudio/Dataset implement their own theme systems
3. **No surprises** - What you pass is what you get
4. **Framework independence** - No InheritedWidget magic
5. **Testability** - Components work in isolation

#### GuxTheme Purpose

`GuxTheme` and `GuxThemeStyles` are **convenience helpers for hosts**, not runtime theme providers:

```dart
// ✅ CORRECT - Host explicitly maps theme to component styles
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const theme = GuxThemes.slate;
    const styles = GuxThemeStyles(theme);
    
    return GuxButton(
      style: styles.button,  // Explicit mapping
      onPressed: () {},
      child: Text('Click'),
    );
  }
}

// ❌ WRONG - Expecting auto-consumption
GuxButton(
  // Does NOT automatically use GuxTheme.of(context)
  onPressed: () {},
  child: Text('Click'),
)
```

#### Host Theme Integration

Hosts should create their own theme system that maps to Genux styles:

```dart
// In ContextStudio/Dataset
class AppTheme {
  final GuxTheme genuxTheme;
  final GuxThemeStyles genuxStyles;
  
  AppTheme(this.genuxTheme) : genuxStyles = GuxThemeStyles(genuxTheme);
  
  // Provide via InheritedWidget or Riverpod/Provider
  static AppTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppThemeProvider>()!.theme;
  }
}

// Usage in Dataset renderer
GuxButton(
  style: AppTheme.of(context).genuxStyles.button,
  // ...
)
```

### 2. Framework-Free Implementation
class GuxButton extends StatelessWidget {
  const GuxButton({
    required this.style,  // Host provides all styling
    required this.child,
    this.onPressed,
  });
  
  final GuxButtonStyle style;
  final Widget child;
  final VoidCallback? onPressed;
}
```

### 2. Framework-Free Implementation
Use only Flutter primitives - never Material or Cupertino widgets.

```dart
// ✅ Use these
Container, Column, Row, Stack, Positioned
DecoratedBox, BoxDecoration, BoxShadow
GestureDetector, MouseRegion
Text, DefaultTextStyle
CustomPaint, CustomPainter
```

### 3. Composability
Components should be small, focused, and composable.

### 4. Accessibility

All interactive components must support full keyboard navigation and screen readers.

#### Required Accessibility Features

**Keyboard Support:**
- Use `FocusableActionDetector` for keyboard shortcuts
- Support both Space and Enter keys for activation
- Handle arrow keys for navigation (tabs, lists, menus)
- Provide visible focus indicators

**Semantics:**
- Use `Semantics` widget with appropriate properties
- `button: true` for clickable elements
- `selected: true/false` for tabs and list items
- `expanded: true/false` for accordions and dropdowns
- `label` and `hint` for screen reader context
- `onTap` callbacks for TalkBack/VoiceOver

**Example - Accessible Button:**
```dart
FocusableActionDetector(
  onShowFocusHighlight: (focused) => setState(() => _focused = focused),
  shortcuts: const {
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  },
  actions: {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onPressed?.call();
        return null;
      },
    ),
  },
  child: Semantics(
    button: true,
    enabled: widget.enabled,
    label: widget.accessibilityLabel,
    onTap: widget.onPressed,
    child: GestureDetector(
      excludeFromSemantics: true,  // Avoid duplicate semantics
      onTap: widget.onPressed,
      child: // ... visual widget
    ),
  ),
)
```

**Example - Accessible Tab:**
```dart
FocusableActionDetector(
  onShowFocusHighlight: (focused) => setState(() => _focused = focused),
  shortcuts: const {
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  },
  actions: {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        _selectTab(tab.id);
        return null;
      },
    ),
  },
  child: Semantics(
    button: true,
    selected: isActive,
    label: tab.label,
    onTap: () => _selectTab(tab.id),
    child: // ... tab visual
  ),
)
```

**Example - Accessible Accordion:**
```dart
FocusableActionDetector(
  focusNode: _focusNode,
  onShowFocusHighlight: (focused) => setState(() => _focused = focused),
  shortcuts: const {
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
  },
  actions: {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        _toggleExpansion();
        return null;
      },
    ),
  },
  child: Semantics(
    button: true,
    expanded: _isExpanded,
    label: widget.title,
    onTap: _toggleExpansion,
    child: // ... accordion header visual
  ),
)
```

#### Accessibility Testing Requirements

Every interactive component must have tests for:

1. **Mouse/Touch interaction** - `await tester.tap(find.byType(Widget))`
2. **Keyboard-only activation** - Focus then send key without tapping first
3. **Screen reader semantics** - Verify Semantics properties
4. **Focus management** - Tab order, focus indicators

**Example - Complete Accessibility Test:**
```dart
testWidgets('supports keyboard-only activation', (tester) async {
  var activated = false;
  
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: GuxButton(
        onPressed: () => activated = true,
        child: Text('Click Me'),
        style: const GuxButtonStyle(),
      ),
    ),
  );
  
  // Focus without tapping (keyboard-only navigation)
  final buttonFinder = find.byType(GuxButton);
  await tester.sendKeyEvent(LogicalKeyboardKey.tab); // Focus
  await tester.pump();
  
  // Activate with Space key
  await tester.sendKeyEvent(LogicalKeyboardKey.space);
  await tester.pump();
  
  expect(activated, isTrue);
  
  // Reset and test Enter key
  activated = false;
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pump();
  
  expect(activated, isTrue);
});

testWidgets('has proper screen reader semantics', (tester) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: GuxButton(
        onPressed: () {},
        child: Text('Submit'),
        style: const GuxButtonStyle(),
      ),
    ),
  );
  
  final semantics = tester.getSemantics(find.byType(GuxButton));
  expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
  expect(semantics.hasAction(SemanticsAction.tap), isTrue);
  expect(semantics.label, contains('Submit'));
});
```

#### Accessibility Checklist

Before committing a new interactive component:

- [ ] `FocusableActionDetector` with Space + Enter shortcuts
- [ ] `Semantics` widget with appropriate properties
- [ ] Visible focus indicator (change color/border when focused)
- [ ] `excludeFromSemantics: true` on `GestureDetector`
- [ ] Tests for mouse, keyboard, and screen reader
- [ ] Works with VoiceOver (iOS) and TalkBack (Android)
- [ ] Reduce motion support (no required animations)
- [ ] High contrast mode support (sufficient color contrast)

### 5. Testing
Every component must have tests covering:
- Basic rendering
- User interaction
- Edge cases
- Style application

## Git Commit Messages

Follow conventional commits format:

```
feat(component): add new feature
fix(component): fix bug description
refactor(component): refactor without behavior change
chore: bump version to X.Y.Z
docs(component): update documentation
test(component): add or update tests
```

Always end commits with:
```
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

## Code Review Checklist

Before committing:
- [ ] No Material/Cupertino imports
- [ ] No MediaQuery.of or Theme.of usage
- [ ] All colors are explicit Color(0xAARRGGBB)
- [ ] All styling comes from style parameters
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] Version number follows rules (ask if unsure)
- [ ] Commit message follows format
