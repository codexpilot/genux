import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../genux_flutter.dart';

/// Material implementation of CollectionView component.
///
/// Supports list and grid layouts with virtualized rendering, stable item
/// identity, accessibility, and bounded viewport behavior.
Widget buildCollectionView(BuildContext context, GenuxComponentScope scope) {
  final itemKey = scope.property<String>('itemKey');
  if (itemKey == null || itemKey.isEmpty) {
    return const _CollectionViewError(
      message: 'CollectionView requires itemKey property.',
    );
  }

  final layout = scope.property<String>('layout') ?? 'list';
  final items = scope.optionalValue<List<Object?>>('items') ?? [];
  final loading = scope.optionalValue<bool>('loading') ?? false;
  final emptyMessage = scope.property<String>('emptyMessage') ??
      scope.optionalValue<String>('emptyMessage') ??
      'No items';

  if (loading) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: 'Loading',
        child: const CircularProgressIndicator(),
      ),
    );
  }

  if (items.isEmpty) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: emptyMessage,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }

  // Preflight: validate items and extract keys
  final validatedItems = <_ValidatedItem>[];
  final seenKeys = <String>{};

  for (var index = 0; index < items.length; index++) {
    final item = items[index];

    if (item is! Map) {
      return _CollectionViewError(
        message: 'Item at index $index is not an object.',
      );
    }

    // Extract item data with type-safe key conversion
    final itemData = <String, Object?>{};
    for (final entry in item.entries) {
      final key = entry.key;
      if (key is! String) {
        return _CollectionViewError(
          message: 'Item at index $index has non-string key: $key',
        );
      }
      itemData[key] = entry.value;
    }

    final keyValue = itemData[itemKey];
    if (keyValue == null) {
      return _CollectionViewError(
        message: 'Item at index $index missing required key field "$itemKey".',
      );
    }

    // Preserve key type but convert to string for widget keys
    if (keyValue is! String && keyValue is! num && keyValue is! bool) {
      return _CollectionViewError(
        message: 'Item key must be string, number, or boolean, got ${keyValue.runtimeType}.',
      );
    }

    final keyString = keyValue.toString();
    if (seenKeys.contains(keyString)) {
      return _CollectionViewError(
        message: 'Duplicate item key: $keyString',
      );
    }
    seenKeys.add(keyString);

    validatedItems.add(_ValidatedItem(
      index: index,
      key: keyValue,
      keyString: keyString,
      data: itemData,
    ));
  }

  return switch (layout) {
    'list' => _CollectionListView(
        items: validatedItems,
        scope: scope,
      ),
    'grid' => _CollectionGridView(
        items: validatedItems,
        scope: scope,
      ),
    _ => _CollectionViewError(message: 'Unknown layout: $layout'),
  };
}

/// Validated item with stable identity.
final class _ValidatedItem {
  const _ValidatedItem({
    required this.index,
    required this.key,
    required this.keyString,
    required this.data,
  });

  final int index;
  final Object key; // Preserves original type
  final String keyString; // For widget keys
  final Map<String, Object?> data;
}

class _CollectionListView extends StatelessWidget {
  const _CollectionListView({
    required this.items,
    required this.scope,
  });

  final List<_ValidatedItem> items;
  final GenuxComponentScope scope;

  @override
  Widget build(BuildContext context) {
    final itemHeight = scope.property<num>('itemHeight')?.toDouble() ?? 72.0;
    final padding = scope.property<num>('padding')?.toDouble() ?? 0.0;

    return Semantics(
      label: 'List with ${items.length} items',
      child: ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: items.length,
        itemExtent: itemHeight,
        itemBuilder: (context, index) {
          return _buildItem(context, items[index]);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, _ValidatedItem item) {
    final evaluationContext = GenuxEvaluationContext(
      itemKey: item.key,
      itemIndex: item.index,
      itemData: item.data,
    );

    return Semantics(
      button: true,
      enabled: true,
      label: 'Item ${item.index + 1} of ${items.length}',
      child: InkWell(
        key: ValueKey(item.keyString),
        onTap: () => _handleItemInvoked(item),
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space)) {
              _handleItemInvoked(item);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: scope.buildItemTemplate(
            'itemTemplate',
            item.keyString,
            evaluationContext,
          ),
        ),
      ),
    );
  }

  Future<void> _handleItemInvoked(_ValidatedItem item) async {
    final payload = {
      'key': item.key,
      'index': item.index,
      'data': item.data,
    };
    await scope.emit('itemInvoked', payload);
  }
}

class _CollectionGridView extends StatelessWidget {
  const _CollectionGridView({
    required this.items,
    required this.scope,
  });

  final List<_ValidatedItem> items;
  final GenuxComponentScope scope;

  @override
  Widget build(BuildContext context) {
    final columns = scope.property<int>('columns') ?? 2;
    final aspectRatio = scope.property<num>('aspectRatio')?.toDouble() ?? 1.0;
    final spacing = scope.property<num>('spacing')?.toDouble() ?? 8.0;
    final padding = scope.property<num>('padding')?.toDouble() ?? 0.0;

    return Semantics(
      label: 'Grid with ${items.length} items, $columns columns',
      child: GridView.builder(
        padding: EdgeInsets.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItem(context, items[index]);
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, _ValidatedItem item) {
    final evaluationContext = GenuxEvaluationContext(
      itemKey: item.key,
      itemIndex: item.index,
      itemData: item.data,
    );

    return Semantics(
      button: true,
      enabled: true,
      label: 'Item ${item.index + 1} of ${items.length}',
      child: InkWell(
        key: ValueKey(item.keyString),
        onTap: () => _handleItemInvoked(item),
        child: Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space)) {
              _handleItemInvoked(item);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: scope.buildItemTemplate(
            'itemTemplate',
            item.keyString,
            evaluationContext,
          ),
        ),
      ),
    );
  }

  Future<void> _handleItemInvoked(_ValidatedItem item) async {
    final payload = {
      'key': item.key,
      'index': item.index,
      'data': item.data,
    };
    await scope.emit('itemInvoked', payload);
  }
}

/// Material implementation of Expanded component.
///
/// Wraps a single child in Flutter's Expanded widget to fill available space
/// in a flex layout (Row or Column).
Widget buildExpanded(BuildContext context, GenuxComponentScope scope) {
  final flex = scope.property<int>('flex') ?? 1;
  final children = scope.slot('child');

  if (children.isEmpty) {
    return const SizedBox.shrink();
  }

  return Expanded(
    flex: flex,
    child: children.first,
  );
}

class _CollectionViewError extends StatelessWidget {
  const _CollectionViewError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        label: 'Error: $message',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
