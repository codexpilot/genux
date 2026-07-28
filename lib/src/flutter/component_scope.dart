import 'package:flutter/widgets.dart';

import '../model/choice_item.dart';
import '../model/evaluation_context.dart';
import '../runtime/surface_session.dart';
import '../state/surface_store.dart';

abstract interface class GenuxComponentScope {
  String get nodeId;

  T? property<T>(String name);

  Object? value(String channel);

  T requireValue<T>(String channel);

  T? optionalValue<T>(String channel);

  List<GenuxChoiceItem> choiceItems(String channel);

  GenuxCommitResult write(String channel, Object? value);

  Future<GenuxActionDispatchResult> emit(String event, [Object? payload]);

  List<Widget> slot(String name);

  /// Builds an item template widget for the given slot with evaluation context.
  ///
  /// Used by CollectionView and other repeated-template components to render
  /// each item with its own local context. The instanceKey must be unique and
  /// stable across reordering (typically derived from the item's stable key).
  ///
  /// Returns a widget tree rooted at the first child of the slot, with the
  /// evaluation context available to all descendants for item/event bindings.
  Widget buildItemTemplate(
    String slotName,
    String instanceKey,
    GenuxEvaluationContext context,
  );
}

typedef GenuxComponentBuilder =
    Widget Function(BuildContext context, GenuxComponentScope scope);
