import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genux/genux.dart';

void main() {
  late GenuxCatalog catalog;
  late GenuxDocumentCompiler compiler;
  late Map<String, String> sources;
  late GenuxActionDispatcher dispatcher;
  late GenuxViewCoordinator coordinator;

  setUp(() {
    catalog = createGenuxCoreCatalog();
    compiler = GenuxDocumentCompiler(
      catalog: catalog,
      capabilities: GenuxCapabilityRegistry(const []),
    );
    sources = {
      'view.a': _viewSource(catalog, 'view.a', count: 1),
      'view.b': _viewSource(catalog, 'view.b', count: 2),
    };
    dispatcher = (_) {};
    coordinator = GenuxViewCoordinator(
      compiler: compiler,
      sourceLoader: (target) => sources[target.viewCode]!,
      dispatcher: dispatcher,
    );
  });

  test(
    'open activates one view session and publishes one immutable change',
    () async {
      final changes = <GenuxViewStackChange>[];
      coordinator.subscribe(changes.add);

      final result = await coordinator.open(_target('view.a'));

      expect(result, isA<GenuxViewOpenSuccess>());
      final entry = (result as GenuxViewOpenSuccess).entry;
      expect(result.changed, isTrue);
      expect(entry.viewCode, 'view.a');
      expect(entry.session.document.view.code, 'view.a');
      expect(entry.session.dispatcher, same(dispatcher));
      expect(coordinator.current, same(entry));
      expect(coordinator.version, 1);
      expect(changes, hasLength(1));
      expect(changes.single.kind, GenuxViewStackChangeKind.pushed);
      expect(changes.single.current, same(entry));
      expect(() => coordinator.stack.add(entry), throwsUnsupportedError);
      expect(() => changes.single.stack.clear(), throwsUnsupportedError);
    },
  );

  test(
    'opening the current view is an explicit no-op without reloading',
    () async {
      var loads = 0;
      var notifications = 0;
      coordinator = GenuxViewCoordinator(
        compiler: compiler,
        sourceLoader: (target) {
          loads += 1;
          return sources[target.viewCode]!;
        },
        dispatcher: dispatcher,
      );
      coordinator.subscribe((_) => notifications += 1);
      await coordinator.open(_target('view.a'));
      final original = coordinator.current;

      final result = await coordinator.push(_target('view.a'));

      expect(result, isA<GenuxViewOpenNoop>());
      expect(
        (result as GenuxViewOpenNoop).reason,
        GenuxViewOpenNoopReason.alreadyCurrent,
      );
      expect(result.changed, isFalse);
      expect(coordinator.current, same(original));
      expect(loads, 1);
      expect(notifications, 1);
      expect(coordinator.version, 1);
    },
  );

  test(
    'same active identity rejects conflicting parameters without reloading',
    () async {
      var loads = 0;
      coordinator = GenuxViewCoordinator(
        compiler: compiler,
        sourceLoader: (target) {
          loads += 1;
          return sources[target.viewCode]!;
        },
        dispatcher: dispatcher,
      );
      final originalTarget = GenuxViewTarget(
        viewCode: 'view.a',
        instanceKey: 'customer:42',
        parameters: const {
          'customerId': 42,
          'filters': ['active'],
        },
      );
      await coordinator.open(originalTarget);
      final originalEntry = coordinator.current;

      final sameParameters = await coordinator.open(
        GenuxViewTarget(
          viewCode: 'view.a',
          instanceKey: 'customer:42',
          parameters: const {
            'filters': ['active'],
            'customerId': 42,
          },
        ),
      );
      expect(sameParameters, isA<GenuxViewOpenNoop>());

      final result = await coordinator.open(
        GenuxViewTarget(
          viewCode: 'view.a',
          instanceKey: 'customer:42',
          parameters: const {
            'customerId': 43,
            'filters': ['active'],
          },
        ),
      );

      expect(result, isA<GenuxViewOpenFailure>());
      final failure = result as GenuxViewOpenFailure;
      expect(failure.stage, GenuxViewOpenFailureStage.request);
      expect(failure.error, isA<ArgumentError>());
      expect(coordinator.current, same(originalEntry));
      expect(coordinator.stack, hasLength(1));
      expect(coordinator.version, 1);
      expect(loads, 1);
    },
  );

  test(
    'parameter conflict supersedes an older pending navigation request',
    () async {
      final pendingSource = Completer<String>();
      coordinator = GenuxViewCoordinator(
        compiler: compiler,
        sourceLoader: (target) => target.viewCode == 'view.a'
            ? sources[target.viewCode]!
            : pendingSource.future,
        dispatcher: dispatcher,
      );
      final activeTarget = GenuxViewTarget(
        viewCode: 'view.a',
        instanceKey: 'customer:42',
        parameters: const {'customerId': 42},
      );
      await coordinator.open(activeTarget);
      final activeEntry = coordinator.current;
      final pending = coordinator.open(_target('view.b'));

      final conflict = await coordinator.open(
        GenuxViewTarget(
          viewCode: 'view.a',
          instanceKey: 'customer:42',
          parameters: const {'customerId': 43},
        ),
      );
      pendingSource.complete(sources['view.b']);
      final stale = await pending;

      expect(conflict, isA<GenuxViewOpenFailure>());
      expect(
        (conflict as GenuxViewOpenFailure).stage,
        GenuxViewOpenFailureStage.request,
      );
      expect(stale, isA<GenuxViewOpenNoop>());
      expect(
        (stale as GenuxViewOpenNoop).reason,
        GenuxViewOpenNoopReason.superseded,
      );
      expect(coordinator.current, same(activeEntry));
      expect(coordinator.stack, hasLength(1));
      expect(coordinator.version, 1);
    },
  );

  test(
    'instance key distinguishes sessions and parameters are deeply immutable',
    () async {
      final mutableParameters = <String, Object?>{
        'customerId': 42,
        'filters': <Object?>['active'],
      };
      final firstTarget = GenuxViewTarget(
        viewCode: 'view.a',
        instanceKey: 'customer:42',
        parameters: mutableParameters,
      );
      mutableParameters['customerId'] = 99;
      final filters = firstTarget.parameters['filters']! as List<Object?>;

      final first = await coordinator.open(firstTarget);
      final second = await coordinator.open(
        GenuxViewTarget(
          viewCode: 'view.a',
          instanceKey: 'customer:43',
          parameters: const {'customerId': 43},
        ),
      );

      expect(first, isA<GenuxViewOpenSuccess>());
      expect(second, isA<GenuxViewOpenSuccess>());
      expect(coordinator.stack, hasLength(2));
      expect(coordinator.stack.map((entry) => entry.instanceKey), [
        'customer:42',
        'customer:43',
      ]);
      expect(
        coordinator.stack.first.session,
        isNot(same(coordinator.stack.last.session)),
      );
      expect(firstTarget.parameters['customerId'], 42);
      expect(
        () => firstTarget.parameters['customerId'] = 7,
        throwsUnsupportedError,
      );
      expect(() => filters.add('new'), throwsUnsupportedError);
    },
  );

  test('load and compile failures leave the active stack unchanged', () async {
    coordinator = GenuxViewCoordinator(
      compiler: compiler,
      sourceLoader: (target) {
        final viewCode = target.viewCode;
        if (viewCode == 'view.a') return sources[viewCode]!;
        if (viewCode == 'view.invalid') return '{not json';
        throw StateError('QueryHub unavailable');
      },
      dispatcher: dispatcher,
    );
    await coordinator.open(_target('view.a'));
    final activeEntry = coordinator.current;
    var notifications = 0;
    coordinator.subscribe((_) => notifications += 1);
    final loadFailure = await coordinator.open(_target('view.missing'));

    expect(loadFailure, isA<GenuxViewOpenFailure>());
    expect(
      (loadFailure as GenuxViewOpenFailure).stage,
      GenuxViewOpenFailureStage.load,
    );
    expect(loadFailure.error, isA<StateError>());
    expect(coordinator.current, same(activeEntry));

    final compileFailure = await coordinator.open(_target('view.invalid'));

    expect(compileFailure, isA<GenuxViewOpenFailure>());
    expect(
      (compileFailure as GenuxViewOpenFailure).stage,
      GenuxViewOpenFailureStage.compile,
    );
    expect(compileFailure.diagnostics, isNotEmpty);
    expect(coordinator.current, same(activeEntry));
    expect(coordinator.stack, hasLength(1));
    expect(coordinator.version, 1);
    expect(notifications, 0);
  });

  test(
    'document identity failure does not publish a mismatched view',
    () async {
      sources['view.alias'] = _viewSource(catalog, 'view.actual', count: 3);

      final result = await coordinator.open(_target('view.alias'));

      expect(result, isA<GenuxViewOpenFailure>());
      final failure = result as GenuxViewOpenFailure;
      expect(failure.stage, GenuxViewOpenFailureStage.identity);
      expect(
        failure.diagnostics.map((diagnostic) => diagnostic.code),
        contains('view.codeMismatch'),
      );
      expect(coordinator.stack, isEmpty);
      expect(coordinator.version, 0);
    },
  );

  test('pop reveals the exact prior session with retained state', () async {
    final changes = <GenuxViewStackChange>[];
    coordinator.subscribe(changes.add);
    final first =
        (await coordinator.open(_target('view.a')) as GenuxViewOpenSuccess)
            .entry;
    first.session.store.transact(
      (transaction) => transaction.setPath('/count', 9),
      origin: GenuxTransactionOrigin.user,
    );
    await coordinator.open(_target('view.b'));

    final result = coordinator.pop();

    expect(result, isA<GenuxViewPopped>());
    expect(result.changed, isTrue);
    expect((result as GenuxViewPopped).revealed, same(first));
    expect(coordinator.current, same(first));
    expect(first.session.store.read(GenuxJsonPointer.parse('/count')).value, 9);
    expect(coordinator.version, 3);
    expect(changes.map((change) => change.kind), [
      GenuxViewStackChangeKind.pushed,
      GenuxViewStackChangeKind.pushed,
      GenuxViewStackChangeKind.popped,
    ]);

    final rootPop = coordinator.pop();
    expect(rootPop, isA<GenuxViewPopNoop>());
    expect((rootPop as GenuxViewPopNoop).reason, GenuxViewPopNoopReason.atRoot);
    expect(coordinator.current, same(first));
    expect(changes, hasLength(3));
  });

  test('latest asynchronous open wins and stale work cannot commit', () async {
    final slow = Completer<String>();
    final fast = Completer<String>();
    final changes = <GenuxViewStackChange>[];
    coordinator = GenuxViewCoordinator(
      compiler: compiler,
      sourceLoader: (target) => switch (target.viewCode) {
        'view.a' => slow.future,
        'view.b' => fast.future,
        _ => throw StateError('Unknown view'),
      },
      dispatcher: dispatcher,
    );
    coordinator.subscribe(changes.add);

    final slowResult = coordinator.open(_target('view.a'));
    final fastResult = coordinator.open(_target('view.b'));
    fast.complete(sources['view.b']);
    expect(await fastResult, isA<GenuxViewOpenSuccess>());
    slow.complete(sources['view.a']);
    final stale = await slowResult;

    expect(stale, isA<GenuxViewOpenNoop>());
    expect(
      (stale as GenuxViewOpenNoop).reason,
      GenuxViewOpenNoopReason.superseded,
    );
    expect(coordinator.stack.map((entry) => entry.viewCode), ['view.b']);
    expect(changes, hasLength(1));
  });

  test('pop intent supersedes a pending open even at the root', () async {
    await coordinator.open(_target('view.a'));
    final pendingSource = Completer<String>();
    coordinator = GenuxViewCoordinator(
      compiler: compiler,
      sourceLoader: (target) {
        final viewCode = target.viewCode;
        if (viewCode == 'view.a') return sources[viewCode]!;
        return pendingSource.future;
      },
      dispatcher: dispatcher,
    );
    await coordinator.open(_target('view.a'));
    final root = coordinator.current;
    final pending = coordinator.open(_target('view.b'));

    expect(coordinator.pop(), isA<GenuxViewPopNoop>());
    pendingSource.complete(sources['view.b']);
    final result = await pending;

    expect(result, isA<GenuxViewOpenNoop>());
    expect(
      (result as GenuxViewOpenNoop).reason,
      GenuxViewOpenNoopReason.superseded,
    );
    expect(coordinator.current, same(root));
    expect(coordinator.stack, hasLength(1));
  });

  test(
    'subscriber failures are isolated and do not stop later listeners',
    () async {
      final listenerErrors = <Object>[];
      var laterNotifications = 0;
      runZonedGuarded(() {
        coordinator.subscribe((_) => throw StateError('listener failed'));
        coordinator.subscribe((_) => laterNotifications += 1);
      }, (error, _) => listenerErrors.add(error));

      final result = await coordinator.open(_target('view.a'));

      expect(result, isA<GenuxViewOpenSuccess>());
      expect(laterNotifications, 1);
      expect(listenerErrors, hasLength(1));
      expect(listenerErrors.single, isA<StateError>());
    },
  );
}

GenuxViewTarget _target(String viewCode, {String? instanceKey}) =>
    GenuxViewTarget(
      viewCode: viewCode,
      instanceKey: instanceKey ?? '$viewCode:default',
    );

String _viewSource(
  GenuxCatalog catalog,
  String viewCode, {
  required int count,
  String kind = 'view',
}) {
  return jsonEncode({
    'schema': 'aix.genux/1.0',
    'view': {'id': viewCode, 'code': viewCode, 'revision': 1, 'kind': kind},
    'catalog': {
      'id': catalog.id,
      'version': catalog.version,
      'checksum': catalog.checksum,
    },
    'root': 'root',
    'state': {'count': count},
    'actions': <String, Object?>{},
    'nodes': [
      {
        'id': 'root',
        'component': 'Text',
        'version': 1,
        'props': {'text': viewCode},
      },
    ],
  });
}
