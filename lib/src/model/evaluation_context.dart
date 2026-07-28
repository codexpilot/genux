/// Evaluation context for template rendering.
///
/// Provides immutable read-only local values available during one render
/// instance. This is separate from persistent transactional state and never
/// merged into the state store.
final class GenuxEvaluationContext {
  const GenuxEvaluationContext({
    this.itemKey,
    this.itemIndex,
    this.itemData,
    this.eventPayload,
  });

  /// Stable item identity extracted from the item object.
  final Object? itemKey;

  /// Current array position of the item.
  final int? itemIndex;

  /// The complete item object from the items array.
  final Map<String, Object?>? itemData;

  /// Event payload for action argument resolution.
  final Object? eventPayload;

  /// Empty context with no local values.
  static const empty = GenuxEvaluationContext();

  /// Whether this context has item data available.
  bool get hasItemContext => itemData != null;

  /// Whether this context has event payload available.
  bool get hasEventContext => eventPayload != null;

  /// Converts item context to a map structure for pointer resolution.
  ///
  /// Returns a map with:
  /// - `/key` → item stable key
  /// - `/index` → item index
  /// - `/data` → item object
  Map<String, Object?> toItemMap() {
    if (!hasItemContext) {
      throw StateError('Item context is not available.');
    }
    return {
      'key': itemKey,
      'index': itemIndex,
      'data': itemData,
    };
  }

  /// Converts event context to a map structure for pointer resolution.
  ///
  /// Returns a map with:
  /// - `/data` → event payload
  Map<String, Object?> toEventMap() {
    if (!hasEventContext) {
      throw StateError('Event context is not available.');
    }
    return {
      'data': eventPayload,
    };
  }
}

/// Source of a binding value.
enum GenuxBindingSource {
  /// Persistent surface state accessed via the state store.
  state,

  /// Item-template local data from the item context.
  item,

  /// Event payload available during action argument resolution.
  event,
}
