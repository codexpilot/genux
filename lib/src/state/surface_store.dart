import 'dart:async';

import '../model/json_pointer.dart';

enum GenuxTransactionOrigin { user, remote, system }

enum GenuxDirtyConflictPolicy { reject, overwrite }

enum GenuxRejectionReason {
  staleVersion,
  dirtyConflict,
  invalidWrite,
  asyncTransaction,
  nestedTransaction,
}

sealed class GenuxCommitResult {
  const GenuxCommitResult();

  bool get committed => this is GenuxStateCommitted;
}

final class GenuxStateCommitted extends GenuxCommitResult {
  const GenuxStateCommitted(this.change);

  final GenuxStateChange change;
}

final class GenuxStateNoop extends GenuxCommitResult {
  const GenuxStateNoop();
}

final class GenuxStateRejected extends GenuxCommitResult {
  const GenuxStateRejected({required this.reason, required this.message});

  final GenuxRejectionReason reason;
  final String message;
}

final class GenuxStateChange {
  GenuxStateChange({
    required this.before,
    required this.after,
    required this.version,
    required this.origin,
    required Iterable<GenuxJsonPointer> changedPaths,
  }) : changedPaths = List.unmodifiable(changedPaths);

  final Map<String, Object?> before;
  final Map<String, Object?> after;
  final int version;
  final GenuxTransactionOrigin origin;
  final List<GenuxJsonPointer> changedPaths;
}

typedef GenuxStateListener = void Function(GenuxStateChange change);

final class GenuxStateSubscription {
  GenuxStateSubscription._(this._cancel);

  void Function()? _cancel;

  void cancel() {
    _cancel?.call();
    _cancel = null;
  }
}

final class GenuxStateTransaction {
  GenuxStateTransaction._();

  final List<_StateWrite> _writes = [];
  String? _error;
  bool _active = true;

  void set(GenuxJsonPointer pointer, Object? value) {
    _ensureActive();
    if (pointer.segments.isEmpty) {
      _error ??= 'The surface state root cannot be replaced.';
      return;
    }
    if (!_isJsonValue(value)) {
      _error ??= 'State writes must contain only finite JSON values.';
      return;
    }
    _writes.add(_StateWrite(pointer, _freezeJson(value)));
  }

  void setPath(String path, Object? value) {
    _ensureActive();
    try {
      set(GenuxJsonPointer.parse(path), value);
    } on FormatException catch (exception) {
      _error ??= exception.message.toString();
    }
  }

  void _ensureActive() {
    if (!_active) {
      throw StateError('The state transaction is no longer active.');
    }
  }

  void _close() {
    _active = false;
  }
}

final class GenuxStateStore {
  GenuxStateStore(Map<String, Object?> initialState)
    : _state = _freezeObject(initialState);

  Map<String, Object?> _state;
  int _version = 0;
  bool _transactionOpen = false;
  int _nextSubscriptionId = 0;
  final Map<int, _StateSubscriptionEntry> _subscriptions = {};
  final Map<String, GenuxJsonPointer> _dirtyPaths = {};

  Map<String, Object?> get state => _state;
  int get version => _version;
  Set<String> get dirtyPaths => Set.unmodifiable(_dirtyPaths.keys);

  GenuxPointerValue read(GenuxJsonPointer pointer) => pointer.read(_state);

  GenuxStateSubscription subscribe(
    Iterable<GenuxJsonPointer> paths,
    GenuxStateListener listener,
  ) {
    final id = _nextSubscriptionId++;
    final watched = List<GenuxJsonPointer>.unmodifiable(paths);
    // Match Dart stream semantics: listeners run in the zone in which they
    // subscribed, and a listener failure is routed to that zone's uncaught
    // error handler. The guarded callback keeps the failure from escaping a
    // committed transaction or preventing the remaining listeners from
    // receiving the same change.
    final guardedListener = Zone.current.bindUnaryCallbackGuarded(listener);
    _subscriptions[id] = _StateSubscriptionEntry(watched, guardedListener);
    return GenuxStateSubscription._(() => _subscriptions.remove(id));
  }

  GenuxCommitResult transact(
    Object? Function(GenuxStateTransaction transaction) body, {
    GenuxTransactionOrigin origin = GenuxTransactionOrigin.system,
    int? expectedVersion,
    GenuxDirtyConflictPolicy dirtyConflict = GenuxDirtyConflictPolicy.reject,
  }) {
    if (_transactionOpen) {
      return const GenuxStateRejected(
        reason: GenuxRejectionReason.nestedTransaction,
        message: 'Nested state transactions are not supported.',
      );
    }
    if (expectedVersion != null && expectedVersion != _version) {
      return GenuxStateRejected(
        reason: GenuxRejectionReason.staleVersion,
        message:
            'Expected state version $expectedVersion, current is $_version.',
      );
    }

    final transaction = GenuxStateTransaction._();
    _transactionOpen = true;
    Object? callbackResult;
    try {
      callbackResult = body(transaction);
    } finally {
      transaction._close();
      _transactionOpen = false;
    }

    if (callbackResult is Future) {
      return const GenuxStateRejected(
        reason: GenuxRejectionReason.asyncTransaction,
        message: 'State transaction callbacks must be synchronous.',
      );
    }
    if (transaction._error != null) {
      return GenuxStateRejected(
        reason: GenuxRejectionReason.invalidWrite,
        message: transaction._error!,
      );
    }
    if (transaction._writes.isEmpty) {
      return const GenuxStateNoop();
    }

    final draft = _mutableObject(_state);
    final changed = <String, GenuxJsonPointer>{};
    try {
      // Writes are applied in call order. Each write observes the result of
      // earlier writes, so the later write deterministically wins for equal or
      // overlapping paths. Transaction values are frozen when captured; make
      // a mutable copy here so a later descendant write can safely traverse a
      // collection installed by an earlier write.
      for (final write in transaction._writes) {
        final current = write.pointer.read(draft);
        if (current.exists && _jsonEquals(current.value, write.value)) {
          continue;
        }
        _setAtPointer(draft, write.pointer, _mutableJson(write.value));
        changed[write.pointer.source] = write.pointer;
      }
    } on StateError catch (exception) {
      return GenuxStateRejected(
        reason: GenuxRejectionReason.invalidWrite,
        message: exception.message.toString(),
      );
    }

    if (changed.isEmpty || _jsonEquals(_state, draft)) {
      return const GenuxStateNoop();
    }

    if (origin == GenuxTransactionOrigin.remote) {
      final conflicts = <String>[];
      for (final changedPath in changed.values) {
        for (final dirtyPath in _dirtyPaths.values) {
          if (_pathsIntersect(changedPath, dirtyPath)) {
            conflicts.add(dirtyPath.source);
          }
        }
      }
      if (conflicts.isNotEmpty &&
          dirtyConflict == GenuxDirtyConflictPolicy.reject) {
        return GenuxStateRejected(
          reason: GenuxRejectionReason.dirtyConflict,
          message:
              'Remote update conflicts with dirty paths: '
              '${conflicts.toSet().join(', ')}.',
        );
      }
      if (dirtyConflict == GenuxDirtyConflictPolicy.overwrite) {
        _dirtyPaths.removeWhere(
          (_, dirtyPath) => changed.values.any(
            (changedPath) => _pathsIntersect(changedPath, dirtyPath),
          ),
        );
      }
    }

    final before = _state;
    final after = _freezeObject(draft);
    _state = after;
    _version += 1;
    if (origin == GenuxTransactionOrigin.user) {
      _dirtyPaths.addAll(changed);
    }

    final change = GenuxStateChange(
      before: before,
      after: after,
      version: _version,
      origin: origin,
      changedPaths: changed.values,
    );
    _notify(change);
    return GenuxStateCommitted(change);
  }

  void acknowledge(Iterable<GenuxJsonPointer> paths) {
    final acknowledged = List<GenuxJsonPointer>.of(paths);
    _dirtyPaths.removeWhere(
      (_, dirtyPath) =>
          acknowledged.any((path) => _pathsIntersect(path, dirtyPath)),
    );
  }

  void _notify(GenuxStateChange change) {
    final subscriptions = List<_StateSubscriptionEntry>.of(
      _subscriptions.values,
    );
    for (final subscription in subscriptions) {
      final affected =
          subscription.paths.isEmpty ||
          subscription.paths.any(
            (watched) => change.changedPaths.any(
              (changed) => _pathsIntersect(watched, changed),
            ),
          );
      if (affected) {
        subscription.listener(change);
      }
    }
  }
}

final class _StateWrite {
  const _StateWrite(this.pointer, this.value);

  final GenuxJsonPointer pointer;
  final Object? value;
}

final class _StateSubscriptionEntry {
  const _StateSubscriptionEntry(this.paths, this.listener);

  final List<GenuxJsonPointer> paths;
  final GenuxStateListener listener;
}

bool _pathsIntersect(GenuxJsonPointer first, GenuxJsonPointer second) {
  final shorter = first.segments.length <= second.segments.length
      ? first.segments
      : second.segments;
  final longer = identical(shorter, first.segments)
      ? second.segments
      : first.segments;
  for (var index = 0; index < shorter.length; index += 1) {
    if (shorter[index] != longer[index]) {
      return false;
    }
  }
  return true;
}

void _setAtPointer(
  Map<String, Object?> root,
  GenuxJsonPointer pointer,
  Object? value,
) {
  Object? current = root;
  for (var index = 0; index < pointer.segments.length - 1; index += 1) {
    final segment = pointer.segments[index];
    if (current is Map<String, Object?>) {
      final next = current[segment];
      if (next == null && !current.containsKey(segment)) {
        final created = <String, Object?>{};
        current[segment] = created;
        current = created;
      } else {
        current = next;
      }
      continue;
    }
    if (current is List<Object?>) {
      final itemIndex = _arrayIndex(segment, current.length);
      current = current[itemIndex];
      continue;
    }
    throw StateError(
      'Cannot traverse ${pointer.source}; $segment is not a collection.',
    );
  }

  final leaf = pointer.segments.last;
  if (current is Map<String, Object?>) {
    current[leaf] = value;
    return;
  }
  if (current is List<Object?>) {
    current[_arrayIndex(leaf, current.length)] = value;
    return;
  }
  throw StateError(
    'Cannot write ${pointer.source}; its parent is not a collection.',
  );
}

int _arrayIndex(String segment, int length) {
  if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(segment)) {
    throw StateError('Array index "$segment" is not canonical.');
  }
  final index = int.tryParse(segment);
  if (index == null || index < 0 || index >= length) {
    throw StateError('Array index "$segment" is out of range.');
  }
  return index;
}

Map<String, Object?> _freezeObject(Map<String, Object?> value) {
  if (!_isJsonValue(value)) {
    throw ArgumentError.value(value, 'value', 'Must be JSON-compatible.');
  }
  return Map<String, Object?>.unmodifiable({
    for (final entry in value.entries)
      entry.key: _freezeJsonUnchecked(entry.value),
  });
}

Object? _freezeJson(Object? value) {
  if (!_isJsonValue(value)) {
    throw ArgumentError.value(value, 'value', 'Must be JSON-compatible.');
  }
  return _freezeJsonUnchecked(value);
}

Object? _freezeJsonUnchecked(Object? value) {
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_freezeJsonUnchecked));
  }
  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key! as String: _freezeJsonUnchecked(entry.value),
    });
  }
  return value;
}

Map<String, Object?> _mutableObject(Map<String, Object?> value) => {
  for (final entry in value.entries) entry.key: _mutableJson(entry.value),
};

Object? _mutableJson(Object? value) {
  if (value is List) {
    return <Object?>[for (final item in value) _mutableJson(item)];
  }
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key! as String: _mutableJson(entry.value),
    };
  }
  return value;
}

bool _isJsonValue(Object? value, [int depth = 0]) {
  if (depth > 128) {
    return false;
  }
  if (value == null || value is bool || value is int || value is String) {
    return true;
  }
  if (value is double) {
    return value.isFinite;
  }
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
