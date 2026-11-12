# Routing and Navigation

Genux provides framework-independent routing and navigation components that work without Material, Cupertino, or Fluent dependencies.

## GuxPageRoute

A framework-independent page route for navigation transitions.

### Basic Usage

```dart
Navigator.of(context).push(
  GuxPageRoute(
    builder: (context) => DetailsScreen(),
  ),
);
```

### Transition Types

```dart
// Fade transition (default)
Navigator.of(context).push(
  GuxPageRoute(
    builder: (context) => DetailsScreen(),
    transitionType: GuxTransitionType.fade,
  ),
);

// Slide transition
Navigator.of(context).push(
  GuxPageRoute(
    builder: (context) => DetailsScreen(),
    transitionType: GuxTransitionType.slide,
  ),
);

// No transition
Navigator.of(context).push(
  GuxPageRoute(
    builder: (context) => DetailsScreen(),
    transitionType: GuxTransitionType.none,
  ),
);
```

### With Route Settings

```dart
Navigator.of(context).push(
  GuxPageRoute(
    builder: (context) => DetailsScreen(),
    settings: RouteSettings(name: '/details'),
  ),
);
```

## GuxScaffold

A simple screen layout structure without Material dependencies.

### Basic Usage

```dart
GuxScaffold(
  appBar: GuxAppBar(
    title: Text('My Screen'),
  ),
  body: Center(
    child: Text('Content here'),
  ),
)
```

### With Actions

```dart
GuxScaffold(
  appBar: GuxAppBar(
    title: Text('My Screen'),
    actions: [
      GuxButton(
        style: GuxButtonStyle(
          backgroundColor: Color(0xFF3B82F6),
          hoverColor: Color(0xFF2563EB),
          pressedColor: Color(0xFF1D4ED8),
          disabledColor: Color(0xFF9CA3AF),
          foregroundColor: Color(0xFFFFFFFF),
          disabledForegroundColor: Color(0xFFD1D5DB),
        ),
        onPressed: () => print('Action'),
        child: Text('Settings'),
      ),
    ],
  ),
  body: MyContent(),
)
```

### With Bottom Bar

```dart
GuxScaffold(
  appBar: GuxAppBar(title: Text('My Screen')),
  body: MyContent(),
  bottomBar: Container(
    height: 50,
    child: Text('Footer'),
  ),
)
```

### Custom Colors

```dart
GuxScaffold(
  backgroundColor: Color(0xFF000000),
  appBar: GuxAppBar(
    backgroundColor: Color(0xFF1A1A1A),
    foregroundColor: Color(0xFFFFFFFF),
    title: Text('Dark Theme'),
  ),
  body: MyContent(),
)
```

## Migration from Material

### MaterialPageRoute → GuxPageRoute

**Before:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => DetailsScreen(),
  ),
);
```

**After:**
```dart
Navigator.of(context).push(
  GuxPageRoute(
    builder: (context) => DetailsScreen(),
  ),
);
```

### Scaffold + AppBar → GuxScaffold + GuxAppBar

**Before:**
```dart
Scaffold(
  appBar: AppBar(
    title: Text('My Screen'),
  ),
  body: MyContent(),
)
```

**After:**
```dart
GuxScaffold(
  appBar: GuxAppBar(
    title: Text('My Screen'),
  ),
  body: MyContent(),
)
```

## When to Use

- **GuxScaffold**: Use for simple login, setup, or settings screens that need basic app bar + body layout
- **GuxWorkspaceScaffold**: Use for complex application workspaces with sidebars and multiple regions
- **GuxPageRoute**: Use for all navigation transitions instead of MaterialPageRoute or CupertinoPageRoute

## Implementation Notes

Both components use only `package:flutter/widgets.dart` and maintain complete framework independence. They provide essential navigation and layout functionality without coupling to any design system.
