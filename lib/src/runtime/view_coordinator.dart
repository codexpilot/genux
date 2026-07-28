import 'dart:async';

import '../compiler/document_compiler.dart';
import '../model/document.dart';
import '../validation/document_validator.dart';
import 'surface_session.dart';

typedef GenuxViewSourceLoader =
    FutureOr<String> Function(GenuxViewTarget target);

final class GenuxViewTarget {
  GenuxViewTarget({
    required this.viewCode,
    required this.instanceKey,
    Map<String, Object?> parameters = const {},
  }) : parameters = _freezeParameters(parameters) {
    if (viewCode.isEmpty || instanceKey.isEmpty) {
      throw ArgumentError(
        'View code and instance key must both be stable, non-empty strings.',
      );
    }
  }

  final String viewCode;
  final String instanceKey;
  final Map<String, Object?> parameters;

  bool hasSameIdentity(GenuxViewTarget other) =>
      viewCode == other.viewCode && instanceKey == other.instanceKey;
}

final class GenuxViewStackEntry {
  const GenuxViewStackEntry._({required this.target, required this.session});

  final GenuxViewTarget target;
  final GenuxSurfaceSession session;

  String get viewCode => target.viewCode;
  String get instanceKey => target.instanceKey;
}

enum GenuxViewStackChangeKind { pushed, popped }

final class GenuxViewStackChange {
  GenuxViewStackChange({
    required this.kind,
    required this.version,
    required Iterable<GenuxViewStackEntry> stack,
  }) : stack = List.unmodifiable(stack);

  final GenuxViewStackChangeKind kind;
  final int version;
  final List<GenuxViewStackEntry> stack;

  GenuxViewStackEntry? get current => stack.isEmpty ? null : stack.last;
}

typedef GenuxViewStackListener = void Function(GenuxViewStackChange change);

final class GenuxViewStackSubscription {
  GenuxViewStackSubscription._(this._cancel);

  void Function()? _cancel;

  void cancel() {
    _cancel?.call();
    _cancel = null;
  }
}

sealed class GenuxViewOpenResult {
  const GenuxViewOpenResult();

  bool get changed => this is GenuxViewOpenSuccess;
}

final class GenuxViewOpenSuccess extends GenuxViewOpenResult {
  const GenuxViewOpenSuccess(this.entry);

  final GenuxViewStackEntry entry;
}

enum GenuxViewOpenNoopReason { alreadyCurrent, superseded }

final class GenuxViewOpenNoop extends GenuxViewOpenResult {
  const GenuxViewOpenNoop({
    required this.target,
    required this.reason,
    required this.current,
  });

  final GenuxViewTarget target;
  final GenuxViewOpenNoopReason reason;
  final GenuxViewStackEntry? current;

  String get viewCode => target.viewCode;
}

enum GenuxViewOpenFailureStage { request, load, compile, identity }

final class GenuxViewOpenFailure extends GenuxViewOpenResult {
  GenuxViewOpenFailure({
    required this.target,
    required this.stage,
    Iterable<GenuxDiagnostic> diagnostics = const [],
    this.error,
    this.stackTrace,
  }) : diagnostics = List.unmodifiable(diagnostics),
       assert(diagnostics.isNotEmpty || error != null);

  final GenuxViewTarget target;
  final GenuxViewOpenFailureStage stage;
  final List<GenuxDiagnostic> diagnostics;
  final Object? error;
  final StackTrace? stackTrace;

  String get viewCode => target.viewCode;
}

sealed class GenuxViewPopResult {
  const GenuxViewPopResult();

  bool get changed => this is GenuxViewPopped;
}

final class GenuxViewPopped extends GenuxViewPopResult {
  const GenuxViewPopped({required this.removed, required this.revealed});

  final GenuxViewStackEntry removed;
  final GenuxViewStackEntry revealed;
}

enum GenuxViewPopNoopReason { empty, atRoot }

final class GenuxViewPopNoop extends GenuxViewPopResult {
  const GenuxViewPopNoop({required this.reason, required this.current});

  final GenuxViewPopNoopReason reason;
  final GenuxViewStackEntry? current;
}

/// Coordinates independently compiled Genux views without owning app actions.
///
/// Each successful [open] creates a new session and pushes it onto the stack.
/// Pending opens use latest-request-wins semantics: a later [open] or [pop]
/// prevents an older asynchronous load from committing. The coordinator does
/// not interpret `view.open`, `view.back`, or any other capability; the shared
/// trusted [dispatcher] decides when to call these navigation methods.
final class GenuxViewCoordinator {
  GenuxViewCoordinator({
    required this.compiler,
    required this.sourceLoader,
    required this.dispatcher,
  });

  final GenuxDocumentCompiler compiler;
  final GenuxViewSourceLoader sourceLoader;
  final GenuxActionDispatcher dispatcher;

  final List<GenuxViewStackEntry> _stack = [];
  final Map<int, _ViewSubscriptionEntry> _subscriptions = {};
  int _version = 0;
  int _nextSubscriptionId = 0;
  int _latestNavigationRequest = 0;

  List<GenuxViewStackEntry> get stack => List.unmodifiable(_stack);
  GenuxViewStackEntry? get current => _stack.isEmpty ? null : _stack.last;
  int get version => _version;
  bool get canPop => _stack.length > 1;

  GenuxViewStackSubscription subscribe(GenuxViewStackListener listener) {
    final id = _nextSubscriptionId++;
    // This is the same isolation model used by synchronous Dart streams:
    // preserve the subscriber's zone and route its failures to that zone's
    // uncaught-error handler without interrupting the notification fan-out.
    final guardedListener = Zone.current.bindUnaryCallbackGuarded(listener);
    _subscriptions[id] = _ViewSubscriptionEntry(guardedListener);
    return GenuxViewStackSubscription._(() => _subscriptions.remove(id));
  }

  /// Loads, compiles, activates, and pushes one full view document.
  ///
  /// Reopening the current view is an explicit no-op. The same view code may
  /// appear elsewhere in the stack; opening it from another current view
  /// creates a distinct session.
  Future<GenuxViewOpenResult> open(GenuxViewTarget target) async {
    final request = ++_latestNavigationRequest;
    final active = current;
    if (active?.target.hasSameIdentity(target) ?? false) {
      if (!_jsonEquals(active!.target.parameters, target.parameters)) {
        return GenuxViewOpenFailure(
          target: target,
          stage: GenuxViewOpenFailureStage.request,
          error: ArgumentError(
            'View identity ${target.viewCode}/${target.instanceKey} is '
            'already active with different parameters.',
          ),
        );
      }
      return GenuxViewOpenNoop(
        target: target,
        reason: GenuxViewOpenNoopReason.alreadyCurrent,
        current: active,
      );
    }

    late final String source;
    try {
      source = await Future<String>.sync(() => sourceLoader(target));
    } catch (error, stackTrace) {
      if (request != _latestNavigationRequest) {
        return _superseded(target);
      }
      return GenuxViewOpenFailure(
        target: target,
        stage: GenuxViewOpenFailureStage.load,
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (request != _latestNavigationRequest) {
      return _superseded(target);
    }

    late final GenuxCompileResult compileResult;
    try {
      compileResult = compiler.compileJson(source);
    } catch (error, stackTrace) {
      return GenuxViewOpenFailure(
        target: target,
        stage: GenuxViewOpenFailureStage.compile,
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (compileResult case GenuxCompileFailure(:final diagnostics)) {
      return GenuxViewOpenFailure(
        target: target,
        stage: GenuxViewOpenFailureStage.compile,
        diagnostics: diagnostics,
      );
    }

    final document = (compileResult as GenuxCompileSuccess).document;
    final identityDiagnostics = _identityDiagnostics(target.viewCode, document);
    if (identityDiagnostics.isNotEmpty) {
      return GenuxViewOpenFailure(
        target: target,
        stage: GenuxViewOpenFailureStage.identity,
        diagnostics: identityDiagnostics,
      );
    }

    // Compilation is synchronous today, but keep the commit guard adjacent to
    // the mutation so future asynchronous compiler work cannot publish stale
    // sessions accidentally.
    if (request != _latestNavigationRequest) {
      return _superseded(target);
    }

    final entry = GenuxViewStackEntry._(
      target: target,
      session: GenuxSurfaceSession.activate(document, dispatcher: dispatcher),
    );
    _stack.add(entry);
    _publish(GenuxViewStackChangeKind.pushed);
    return GenuxViewOpenSuccess(entry);
  }

  Future<GenuxViewOpenResult> push(GenuxViewTarget target) => open(target);

  /// Pops only when a prior view exists; root dismissal belongs to the app.
  GenuxViewPopResult pop() {
    // Back navigation also supersedes any pending open, even when already at
    // the root, so an obsolete load cannot appear after the user's back intent.
    _latestNavigationRequest += 1;
    final active = current;
    if (active == null) {
      return const GenuxViewPopNoop(
        reason: GenuxViewPopNoopReason.empty,
        current: null,
      );
    }
    if (_stack.length == 1) {
      return GenuxViewPopNoop(
        reason: GenuxViewPopNoopReason.atRoot,
        current: active,
      );
    }

    final removed = _stack.removeLast();
    final revealed = _stack.last;
    _publish(GenuxViewStackChangeKind.popped);
    return GenuxViewPopped(removed: removed, revealed: revealed);
  }

  GenuxViewOpenNoop _superseded(GenuxViewTarget target) => GenuxViewOpenNoop(
    target: target,
    reason: GenuxViewOpenNoopReason.superseded,
    current: current,
  );

  void _publish(GenuxViewStackChangeKind kind) {
    _version += 1;
    final change = GenuxViewStackChange(
      kind: kind,
      version: _version,
      stack: _stack,
    );
    final subscriptions = List<_ViewSubscriptionEntry>.of(
      _subscriptions.values,
    );
    for (final subscription in subscriptions) {
      subscription.listener(change);
    }
  }
}

final class _ViewSubscriptionEntry {
  const _ViewSubscriptionEntry(this.listener);

  final GenuxViewStackListener listener;
}

List<GenuxDiagnostic> _identityDiagnostics(
  String requestedCode,
  GenuxCompiledDocument document,
) {
  final diagnostics = <GenuxDiagnostic>[];
  if (document.view.code != requestedCode) {
    diagnostics.add(
      GenuxDiagnostic(
        code: 'view.codeMismatch',
        message:
            'Requested view $requestedCode but the document contains '
            '${document.view.code}.',
        location: '/view/code',
      ),
    );
  }
  if (document.view.kind != GenuxViewKind.view) {
    diagnostics.add(
      GenuxDiagnostic(
        code: 'view.kindNotNavigable',
        message: 'Only full view documents can be pushed onto the view stack.',
        location: '/view/kind',
      ),
    );
  }
  return diagnostics;
}

Map<String, Object?> _freezeParameters(Map<String, Object?> parameters) {
  if (!_isJsonValue(parameters)) {
    throw ArgumentError.value(
      parameters,
      'parameters',
      'View target parameters must contain only finite JSON values.',
    );
  }
  return Map<String, Object?>.unmodifiable({
    for (final entry in parameters.entries) entry.key: _freezeJson(entry.value),
  });
}

Object? _freezeJson(Object? value) {
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_freezeJson));
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key! as String: _freezeJson(entry.value),
    });
  }
  return value;
}

bool _isJsonValue(Object? value, [int depth = 0]) {
  if (depth > 128) return false;
  if (value == null || value is bool || value is int || value is String) {
    return true;
  }
  if (value is double) return value.isFinite;
  if (value is List) {
    return value.every((item) => _isJsonValue(item, depth + 1));
  }
  if (value is Map) {
    return value.entries.every(
      (entry) => entry.key is String && _isJsonValue(entry.value, depth + 1),
    );
  }
  return false;
}

bool _jsonEquals(Object? first, Object? second) {
  if (identical(first, second) || first == second) {
    return true;
  }
  if (first is List && second is List && first.length == second.length) {
    for (var index = 0; index < first.length; index += 1) {
      if (!_jsonEquals(first[index], second[index])) {
        return false;
      }
    }
    return true;
  }
  if (first is Map && second is Map && first.length == second.length) {
    for (final entry in first.entries) {
      if (!second.containsKey(entry.key) ||
          !_jsonEquals(entry.value, second[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return false;
}
