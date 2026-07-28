import 'package:flutter/material.dart';

import '../compiler/document_compiler.dart';
import '../model/choice_item.dart';
import '../model/evaluation_context.dart';
import '../runtime/surface_session.dart';
import '../state/surface_store.dart';
import 'component_scope.dart';
import 'flutter_catalog.dart';

typedef GenuxRenderErrorHandler =
    void Function(String nodeId, Object error, StackTrace stackTrace);

final class GenuxSurfaceHost extends StatelessWidget {
  const GenuxSurfaceHost({
    required this.session,
    required this.catalog,
    this.onRenderError,
    super.key,
  });

  final GenuxSurfaceSession session;
  final GenuxFlutterCatalog catalog;
  final GenuxRenderErrorHandler? onRenderError;

  @override
  Widget build(BuildContext context) {
    // Catalog must match ID and document version must not exceed catalog version
    if (session.document.catalog.id != catalog.catalog.id ||
        session.document.catalog.version > catalog.catalog.version) {
      return const _SurfaceError(
        message: 'The active surface and Flutter catalog do not match.',
      );
    }
    // Only check checksum if versions match exactly
    if (session.document.catalog.version == catalog.catalog.version &&
        session.document.catalog.checksum != catalog.catalog.checksum) {
      return const _SurfaceError(
        message: 'The active surface and Flutter catalog do not match.',
      );
    }
    return _GenuxNodeHost(
      key: ValueKey(session.document.rootId),
      node: session.document.root,
      session: session,
      catalog: catalog,
      onRenderError: onRenderError,
    );
  }
}

final class _GenuxNodeHost extends StatefulWidget {
  const _GenuxNodeHost({
    required this.node,
    required this.session,
    required this.catalog,
    this.context = GenuxEvaluationContext.empty,
    this.onRenderError,
    super.key,
  });

  final GenuxCompiledNode node;
  final GenuxSurfaceSession session;
  final GenuxFlutterCatalog catalog;
  final GenuxEvaluationContext context;
  final GenuxRenderErrorHandler? onRenderError;

  @override
  State<_GenuxNodeHost> createState() => _GenuxNodeHostState();
}

final class _GenuxNodeHostState extends State<_GenuxNodeHost> {
  GenuxStateSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _GenuxNodeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.session, widget.session) ||
        !identical(oldWidget.node, widget.node)) {
      _subscription?.cancel();
      _subscription = null;
      _subscribe();
    }
  }

  void _subscribe() {
    if (widget.node.bindings.isEmpty) {
      return;
    }
    final paths = widget.node.bindings.values.map((binding) => binding.pointer);
    _subscription = widget.session.store.subscribe(paths, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final builder = widget.catalog.builderFor(widget.node.component);
      return builder(
        context,
        _ComponentScope(
          node: widget.node,
          session: widget.session,
          catalog: widget.catalog,
          evaluationContext: widget.context,
          onRenderError: widget.onRenderError,
        ),
      );
    } catch (error, stackTrace) {
      widget.onRenderError?.call(widget.node.id, error, stackTrace);
      return _SurfaceError(
        message: 'Unable to render ${widget.node.component.code}.',
      );
    }
  }
}

final class _ComponentScope implements GenuxComponentScope {
  const _ComponentScope({
    required this.node,
    required this.session,
    required this.catalog,
    required this.evaluationContext,
    required this.onRenderError,
  });

  final GenuxCompiledNode node;
  final GenuxSurfaceSession session;
  final GenuxFlutterCatalog catalog;
  final GenuxEvaluationContext evaluationContext;
  final GenuxRenderErrorHandler? onRenderError;

  @override
  String get nodeId => node.id;

  @override
  T? property<T>(String name) {
    final value = node.properties[name];
    if (value == null) {
      return null;
    }
    if (value is! T) {
      throw StateError('Property $name is not a $T.');
    }
    return value as T;
  }

  @override
  Object? value(String channel) {
    if (node.literalInputs.containsKey(channel)) {
      return node.literalInputs[channel];
    }
    final binding = node.bindings[channel];
    if (binding == null) {
      return null;
    }
    return binding.read(session.store.state, evaluationContext);
  }

  @override
  T requireValue<T>(String channel) {
    final current = value(channel);
    if (current is! T) {
      throw StateError('Channel $channel is not a $T.');
    }
    return current;
  }

  @override
  T? optionalValue<T>(String channel) {
    final current = value(channel);
    if (current == null) {
      return null;
    }
    if (current is! T) {
      throw StateError('Channel $channel is not a $T.');
    }
    return current as T;
  }

  @override
  List<GenuxChoiceItem> choiceItems(String channel) {
    final current = requireValue<List<Object?>>(channel);
    return List<GenuxChoiceItem>.unmodifiable(
      current.map((item) {
        if (item is! Map) {
          throw StateError('Choice channel $channel contains a non-object.');
        }
        return GenuxChoiceItem.fromJson({
          for (final entry in item.entries) entry.key! as String: entry.value,
        });
      }),
    );
  }

  @override
  GenuxCommitResult write(String channel, Object? value) {
    final binding = node.bindings[channel];
    if (binding == null || !binding.isWritable) {
      return GenuxStateRejected(
        reason: GenuxRejectionReason.invalidWrite,
        message: 'Channel $channel is not writable.',
      );
    }
    if (!binding.definition.type.accepts(value)) {
      return GenuxStateRejected(
        reason: GenuxRejectionReason.invalidWrite,
        message:
            'Channel $channel requires '
            '${binding.definition.type.displayName}.',
      );
    }
    final constraint = binding.definition.constraint.violation(value);
    if (constraint != null) {
      return GenuxStateRejected(
        reason: GenuxRejectionReason.invalidWrite,
        message: constraint,
      );
    }
    return session.store.transact(
      (transaction) => transaction.set(binding.pointer, value),
      origin: GenuxTransactionOrigin.user,
    );
  }

  @override
  Future<GenuxActionDispatchResult> emit(String event, [Object? payload]) =>
      session.emit(
        nodeId: node.id,
        event: event,
        payload: payload,
        context: evaluationContext,
      );

  @override
  List<Widget> slot(String name) {
    final slot = node.slots[name];
    if (slot == null) {
      return const [];
    }
    return [
      for (final childId in slot.childIds)
        _GenuxNodeHost(
          key: ValueKey(childId),
          node: session.document.nodes[childId]!,
          session: session,
          catalog: catalog,
          context: evaluationContext,
          onRenderError: onRenderError,
        ),
    ];
  }

  @override
  Widget buildItemTemplate(
    String slotName,
    String instanceKey,
    GenuxEvaluationContext context,
  ) {
    final slot = node.slots[slotName];
    if (slot == null || slot.childIds.isEmpty) {
      throw StateError('Slot $slotName is not defined or is empty.');
    }

    final templateNodeId = slot.childIds.first;
    final templateNode = session.document.nodes[templateNodeId];
    if (templateNode == null) {
      throw StateError('Template node $templateNodeId not found.');
    }

    return _GenuxNodeHost(
      key: ValueKey('$templateNodeId:$instanceKey'),
      node: templateNode,
      session: session,
      catalog: catalog,
      context: context,
      onRenderError: onRenderError,
    );
  }
}

final class _SurfaceError extends StatelessWidget {
  const _SurfaceError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    ),
  );
}
