import 'dart:async';

import '../compiler/document_compiler.dart';
import '../model/evaluation_context.dart';
import '../state/surface_store.dart';

final class GenuxActionInvocation {
  GenuxActionInvocation({
    required this.session,
    required this.action,
    required this.sourceNodeId,
    required this.event,
    required this.payload,
    required Map<String, Object?> arguments,
    required this.stateVersion,
  }) : arguments = Map.unmodifiable(arguments);

  final GenuxSurfaceSession session;
  final GenuxCompiledAction action;
  final String sourceNodeId;
  final String event;
  final Object? payload;
  final Map<String, Object?> arguments;
  final int stateVersion;
}

typedef GenuxActionDispatcher =
    FutureOr<void> Function(GenuxActionInvocation invocation);

sealed class GenuxActionDispatchResult {
  const GenuxActionDispatchResult();

  bool get dispatched => this is GenuxActionDispatched;
}

final class GenuxActionDispatched extends GenuxActionDispatchResult {
  const GenuxActionDispatched(this.invocation);

  final GenuxActionInvocation invocation;
}

final class GenuxActionNotBound extends GenuxActionDispatchResult {
  const GenuxActionNotBound({required this.nodeId, required this.event});

  final String nodeId;
  final String event;
}

final class GenuxActionDispatchFailed extends GenuxActionDispatchResult {
  const GenuxActionDispatchFailed({
    required this.nodeId,
    required this.event,
    required this.error,
    required this.stackTrace,
    this.action,
  });

  final String nodeId;
  final String event;
  final GenuxCompiledAction? action;
  final Object error;
  final StackTrace stackTrace;
}

final class GenuxSurfaceSession {
  GenuxSurfaceSession._({
    required this.document,
    required this.store,
    required this.dispatcher,
  });

  factory GenuxSurfaceSession.activate(
    GenuxCompiledDocument document, {
    required GenuxActionDispatcher dispatcher,
  }) {
    return GenuxSurfaceSession._(
      document: document,
      store: GenuxStateStore(document.state),
      dispatcher: dispatcher,
    );
  }

  final GenuxCompiledDocument document;
  final GenuxStateStore store;
  final GenuxActionDispatcher dispatcher;

  Future<GenuxActionDispatchResult> emit({
    required String nodeId,
    required String event,
    Object? payload,
    GenuxEvaluationContext context = GenuxEvaluationContext.empty,
  }) async {
    final node = document.nodes[nodeId];
    if (node == null) {
      return GenuxActionDispatchFailed(
        nodeId: nodeId,
        event: event,
        error: StateError('Node $nodeId is not part of the active surface.'),
        stackTrace: StackTrace.current,
      );
    }
    final compiledEvent = node.events[event];
    if (compiledEvent == null) {
      return GenuxActionNotBound(nodeId: nodeId, event: event);
    }
    try {
      if (!compiledEvent.definition.payload.accepts(payload)) {
        throw StateError(
          'Event $event payload must be '
          '${compiledEvent.definition.payload.displayName}.',
        );
      }

      final augmentedContext = GenuxEvaluationContext(
        itemKey: context.itemKey,
        itemIndex: context.itemIndex,
        itemData: context.itemData,
        eventPayload: payload,
      );
      final arguments = compiledEvent.action.resolveArgs(store.state, augmentedContext);
      for (final definition
          in compiledEvent.action.definition.arguments.entries) {
        final exists = arguments.containsKey(definition.key);
        if (definition.value.required && !exists) {
          throw StateError(
            'Capability ${compiledEvent.action.capability} requires '
            '${definition.key}.',
          );
        }
        if (exists &&
            !definition.value.type.accepts(arguments[definition.key])) {
          throw StateError(
            'Capability argument ${definition.key} must be '
            '${definition.value.type.displayName}.',
          );
        }
      }

      final invocation = GenuxActionInvocation(
        session: this,
        action: compiledEvent.action,
        sourceNodeId: nodeId,
        event: event,
        payload: payload,
        arguments: arguments,
        stateVersion: store.version,
      );
      await Future<void>.sync(() => dispatcher(invocation));
      return GenuxActionDispatched(invocation);
    } catch (error, stackTrace) {
      return GenuxActionDispatchFailed(
        nodeId: nodeId,
        event: event,
        action: compiledEvent.action,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
