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

## Component Design Principles

### 1. Host-Provided Styling
Components never have built-in colors or styles. All visual properties come from the host through style parameters.

```dart
// ✅ CORRECT
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
Always include proper semantics and support for:
- Screen readers
- Keyboard navigation
- Reduce motion preferences
- High contrast modes

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
