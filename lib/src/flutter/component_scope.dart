import 'package:flutter/widgets.dart';

import '../model/choice_item.dart';
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
}

typedef GenuxComponentBuilder =
    Widget Function(BuildContext context, GenuxComponentScope scope);
