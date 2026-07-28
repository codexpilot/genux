import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  late GenuxStateStore store;

  setUp(() {
    store = GenuxStateStore({
      'draft': {'customerType': 2, 'name': 'Mya'},
      'ui': {'busy': false},
    });
  });

  test('commits multiple writes as one version and one notification', () {
    final changes = <GenuxStateChange>[];
    store.subscribe([GenuxJsonPointer.parse('')], changes.add);

    final result = store.transact((transaction) {
      transaction.setPath('/draft/customerType', 1);
      transaction.setPath('/ui/busy', true);
      return null;
    }, origin: GenuxTransactionOrigin.user);

    expect(result, isA<GenuxStateCommitted>());
    expect(store.version, 1);
    expect(changes, hasLength(1));
    expect(store.read(GenuxJsonPointer.parse('/draft/customerType')).value, 1);
    expect(store.dirtyPaths, {'/draft/customerType', '/ui/busy'});
  });

  test('later overlapping writes win and commit atomically', () {
    final result = store.transact((transaction) {
      transaction.setPath('/draft', {
        'customerType': 1,
        'name': 'Parent write',
        'details': {'city': 'Yangon'},
      });
      transaction.setPath('/draft/name', 'Descendant write');
      transaction.setPath('/draft/details/city', 'Mandalay');
      return null;
    }, origin: GenuxTransactionOrigin.user);

    expect(result, isA<GenuxStateCommitted>());
    expect(store.version, 1);
    expect(store.state['draft'], {
      'customerType': 1,
      'name': 'Descendant write',
      'details': {'city': 'Mandalay'},
    });
    expect(store.dirtyPaths, {'/draft', '/draft/name', '/draft/details/city'});
  });

  test('a later ancestor write replaces earlier descendant writes', () {
    final result = store.transact((transaction) {
      transaction.setPath('/draft/name', 'Discarded');
      transaction.setPath('/draft', {
        'customerType': 3,
        'name': 'Final parent',
      });
      return null;
    });

    expect(result, isA<GenuxStateCommitted>());
    expect(store.state['draft'], {'customerType': 3, 'name': 'Final parent'});
  });

  test('invalid overlapping writes reject without partial state changes', () {
    final before = store.state;

    final result = store.transact((transaction) {
      transaction.setPath('/draft', 'not a collection');
      transaction.setPath('/draft/name', 'Cannot be applied');
      return null;
    });

    expect(result, isA<GenuxStateRejected>());
    expect(
      (result as GenuxStateRejected).reason,
      GenuxRejectionReason.invalidWrite,
    );
    expect(store.state, same(before));
    expect(store.version, 0);
  });

  test('rolls back the whole transaction when one write is invalid', () {
    final result = store.transact((transaction) {
      transaction.setPath('/draft/customerType', 1);
      transaction.setPath('/draft/invalid', DateTime(2026));
      return null;
    });

    expect(result, isA<GenuxStateRejected>());
    expect(store.version, 0);
    expect(store.read(GenuxJsonPointer.parse('/draft/customerType')).value, 2);
    expect(
      store.read(GenuxJsonPointer.parse('/draft/invalid')).exists,
      isFalse,
    );
  });

  test('no-op and stale-version transactions do not notify', () {
    var notifications = 0;
    store.subscribe(const [], (_) => notifications += 1);

    final noop = store.transact(
      (transaction) => transaction.setPath('/draft/customerType', 2),
    );
    final stale = store.transact(
      (transaction) => transaction.setPath('/draft/customerType', 1),
      expectedVersion: 3,
    );

    expect(noop, isA<GenuxStateNoop>());
    expect(stale, isA<GenuxStateRejected>());
    expect(store.version, 0);
    expect(notifications, 0);
  });

  test('remote writes reject dirty intersections until acknowledged', () {
    store.transact(
      (transaction) => transaction.setPath('/draft/customerType', 1),
      origin: GenuxTransactionOrigin.user,
    );

    final rejected = store.transact(
      (transaction) =>
          transaction.setPath('/draft', {'customerType': 3, 'name': 'Mya'}),
      origin: GenuxTransactionOrigin.remote,
    );
    expect(rejected, isA<GenuxStateRejected>());
    expect(
      (rejected as GenuxStateRejected).reason,
      GenuxRejectionReason.dirtyConflict,
    );

    store.acknowledge([GenuxJsonPointer.parse('/draft')]);
    final committed = store.transact(
      (transaction) => transaction.setPath('/draft/customerType', 3),
      origin: GenuxTransactionOrigin.remote,
    );
    expect(committed, isA<GenuxStateCommitted>());
    expect(store.dirtyPaths, isEmpty);
  });

  test('path subscriptions match ancestors but not unrelated state', () {
    var draftNotifications = 0;
    store.subscribe([
      GenuxJsonPointer.parse('/draft'),
    ], (_) => draftNotifications += 1);

    store.transact((transaction) => transaction.setPath('/ui/busy', true));
    store.transact(
      (transaction) => transaction.setPath('/draft/customerType', 1),
    );

    expect(draftNotifications, 1);
  });

  test('listener errors are isolated and later listeners still run', () {
    final listenerErrors = <Object>[];
    var laterNotifications = 0;
    late GenuxCommitResult result;

    runZonedGuarded(() {
      store.subscribe(const [], (_) => throw StateError('listener failed'));
      store.subscribe(const [], (_) => laterNotifications += 1);

      result = store.transact(
        (transaction) => transaction.setPath('/ui/busy', true),
      );
    }, (error, _) => listenerErrors.add(error));

    expect(result, isA<GenuxStateCommitted>());
    expect(store.version, 1);
    expect(store.state['ui'], {'busy': true});
    expect(laterNotifications, 1);
    expect(listenerErrors, hasLength(1));
    expect(listenerErrors.single, isA<StateError>());
  });

  test('exposed state is deeply immutable', () {
    final draft = store.state['draft']! as Map<String, Object?>;

    expect(() => draft['name'] = 'Changed', throwsUnsupportedError);
  });
}
