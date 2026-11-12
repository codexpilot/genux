# Genux Example App

Simple example demonstrating JSON-driven UI with Genux components.

## Running the Example

```bash
cd example
flutter run -d macos  # or chrome, linux, windows
```

## What's Demonstrated

This example shows how to create Genux components from JSON:

### 1. GuxButton from JSON
```dart
final json = {
  'style': {
    'backgroundColor': '#3B82F6',
    'foregroundColor': '#FFFFFF',
  },
  'child': {'type': 'Text', 'data': 'Click Me'},
  'onPressed': 'handleClick',
};

GuxButton.fromJson(json, actions: {
  'handleClick': () { /* handle click */ },
});
```

### 2. GuxSummaryLines from JSON
```dart
final json = {
  'primary': 'John Doe',
  'secondary': 'Software Engineer',
  'tertiary': 'San Francisco, CA',
  'primaryStyle': {
    'fontSize': 16.0,
    'fontWeight': '600',
    'color': '#FFFFFF',
  },
};

GuxSummaryLines.fromJson(json);
```

### 3. GuxProgressIndicator from JSON
```dart
final json = {
  'value': 0.65,
  'style': {
    'color': '#3B82F6',
    'trackColor': '#333333',
  },
};

GuxProgressIndicator.fromJson(json);
```

## Key Concepts

- **JSON Serialization**: All 11 Genux components support `fromJson()`/`toJson()`
- **Action Binding**: String keys in JSON map to VoidCallback functions at runtime
- **Type Safety**: Graceful defaults prevent errors from malformed JSON
- **Framework Independent**: Built on WidgetsApp only, no Material/Cupertino

## Additional Examples

See the `../examples/` directory for more JSON examples:
- `dashboard.json` - Complete workspace layout

## Documentation

For complete API documentation, see:
- [Component JSON API](../docs/) - JSON schemas for all components
- [Main README](../README.md) - Project overview and architecture
