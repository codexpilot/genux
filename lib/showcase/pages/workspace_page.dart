import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genux/genux_flutter.dart';

import '../showcase_runtime.dart';

final class WorkspacePage extends StatefulWidget {
  const WorkspacePage({
    required this.runtime,
    this.initialSource,
    this.sourceLoader,
    this.initialViewCode = ShowcaseRuntime.initialViewCode,
    this.initialInstanceKey,
    super.key,
  });

  final ShowcaseRuntime runtime;
  final String? initialSource;
  final GenuxViewSourceLoader? sourceLoader;
  final String initialViewCode;
  final String? initialInstanceKey;

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

final class _WorkspacePageState extends State<WorkspacePage> {
  final List<GenuxActionInvocation> _actions = [];
  final Map<String, String> _sources = {};
  late final GenuxViewCoordinator _views;
  GenuxViewStackSubscription? _viewSubscription;
  GenuxStateSubscription? _stateSubscription;
  List<GenuxDiagnostic> _diagnostics = const [];
  String? _loadError;
  String? _notice;
  bool _navigationBusy = true;
  int _latestUiNavigationRequest = 0;

  GenuxViewStackEntry? get _currentEntry => _views.current;
  GenuxSurfaceSession? get _session => _currentEntry?.session;
  String? get _source =>
      _currentEntry == null ? null : _sources[_currentEntry!.viewCode];

  @override
  void initState() {
    super.initState();
    _views = GenuxViewCoordinator(
      compiler: widget.runtime.compiler,
      sourceLoader: _loadViewSource,
      dispatcher: _dispatch,
    );
    _viewSubscription = _views.subscribe(_onViewStackChanged);
    unawaited(_openInitialView());
  }

  Future<String> _loadViewSource(GenuxViewTarget target) async {
    final injectedSource = widget.initialSource;
    if (target.viewCode == widget.initialViewCode && injectedSource != null) {
      _sources[target.viewCode] = injectedSource;
      return injectedSource;
    }
    final injectedLoader = widget.sourceLoader;
    if (injectedLoader != null) {
      final source = await Future<String>.sync(() => injectedLoader(target));
      _sources[target.viewCode] = source;
      return source;
    }
    final asset = ShowcaseRuntime.fixtureAssets[target.viewCode];
    if (asset == null) {
      throw StateError('View ${target.viewCode} is not allowlisted.');
    }
    final source = await rootBundle.loadString(asset);
    _sources[target.viewCode] = source;
    return source;
  }

  Future<void> _openInitialView() async {
    await _openView(
      GenuxViewTarget(
        viewCode: widget.initialViewCode,
        instanceKey:
            widget.initialInstanceKey ??
            (widget.initialViewCode == ShowcaseRuntime.initialViewCode
                ? 'customer:1001'
                : '${widget.initialViewCode}:root'),
      ),
      initial: true,
    );
  }

  Future<void> _openView(GenuxViewTarget target, {bool initial = false}) async {
    final request = ++_latestUiNavigationRequest;
    if (!initial && mounted) {
      setState(() => _navigationBusy = true);
    }
    final result = await _views.open(target);
    if (!mounted || request != _latestUiNavigationRequest) {
      return;
    }
    _handleOpenResult(result, initial: initial);
  }

  void _popView() {
    _latestUiNavigationRequest += 1;
    _handlePopResult(_views.pop());
  }

  void _onViewStackChanged(GenuxViewStackChange change) {
    _stateSubscription?.cancel();
    final current = change.current;
    if (current != null) {
      _stateSubscription = current.session.store.subscribe(const [], (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _diagnostics = const [];
      _loadError = null;
      _navigationBusy = false;
      _notice = switch (change.kind) {
        GenuxViewStackChangeKind.pushed =>
          '${current!.viewCode} activated · stack depth ${change.stack.length}.',
        GenuxViewStackChangeKind.popped =>
          '${current!.viewCode} restored with state '
              'v${current.session.store.version}.',
      };
    });
  }

  void _handleOpenResult(GenuxViewOpenResult result, {bool initial = false}) {
    if (!mounted) {
      return;
    }
    switch (result) {
      case GenuxViewOpenSuccess():
        if (initial) {
          setState(() {
            _navigationBusy = false;
            _notice = 'Published MultiView workspace activated.';
            _actions.clear();
          });
        }
        return;
      case GenuxViewOpenNoop(:final reason):
        setState(() {
          _navigationBusy = false;
          _notice = reason == GenuxViewOpenNoopReason.superseded
              ? 'A newer navigation intent superseded this request.'
              : '${result.viewCode} is already the current View.';
        });
        return;
      case GenuxViewOpenFailure(:final diagnostics, :final error, :final stage):
        setState(() {
          _navigationBusy = false;
          _diagnostics = diagnostics;
          _loadError = _session == null
              ? diagnostics.isEmpty
                    ? error.toString()
                    : 'The published View failed runtime validation.'
              : null;
          _notice = 'View open failed at ${stage.name}; current View retained.';
        });
        return;
    }
  }

  Future<void> _dispatch(GenuxActionInvocation invocation) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _actions.insert(0, invocation);
      _notice = '${invocation.action.capability} dispatched locally.';
    });

    switch (invocation.action.capability) {
      case 'view.open':
        if (!identical(invocation.session, _session)) {
          setState(() => _notice = 'Stale View navigation was ignored.');
          return;
        }
        final viewCode = invocation.arguments['viewCode'];
        if (viewCode is! String ||
            !ShowcaseRuntime.fixtureAssets.containsKey(viewCode)) {
          setState(() => _notice = 'Requested View is not allowlisted.');
          return;
        }
        await _openView(
          GenuxViewTarget(
            viewCode: viewCode,
            instanceKey: '$viewCode:showcase',
          ),
        );
        return;
      case 'view.back':
        if (!identical(invocation.session, _session)) {
          setState(() => _notice = 'Stale View back action was ignored.');
          return;
        }
        _popView();
        return;
      case 'customer.save':
        final session = invocation.session;
        session.store.transact(
          (transaction) => transaction.setPath('/ui/saving', true),
          origin: GenuxTransactionOrigin.system,
        );
        await Future<void>.delayed(const Duration(milliseconds: 550));
        if (!mounted) {
          return;
        }
        session.store.acknowledge([GenuxJsonPointer.parse('/draft')]);
        session.store.transact(
          (transaction) => transaction.setPath('/ui/saving', false),
          origin: GenuxTransactionOrigin.system,
        );
        if (identical(session, _session)) {
          setState(() {
            _notice = 'Local showcase handler accepted customer.save.';
          });
        }
        return;
      default:
        return;
    }
  }

  void _handlePopResult(GenuxViewPopResult result) {
    if (!mounted || result is GenuxViewPopped) {
      return;
    }
    final noop = result as GenuxViewPopNoop;
    setState(() {
      _navigationBusy = false;
      _notice = noop.reason == GenuxViewPopNoopReason.atRoot
          ? '${_currentEntry?.viewCode ?? 'The current View'} is the root View.'
          : 'There is no active View to close.';
    });
  }

  void _testSafeRejection() {
    final source = _source;
    if (source == null) {
      return;
    }
    final invalid = source.replaceFirst(
      RegExp(r'"component"\s*:\s*"[^"]+"'),
      '"component": "UnknownBox"',
    );
    final result = widget.runtime.compiler.compileJson(invalid);
    if (result case GenuxCompileFailure(:final diagnostics)) {
      setState(() {
        _diagnostics = diagnostics;
        _notice = 'UnknownBox rejected. The active View was not replaced.';
      });
    }
  }

  @override
  void dispose() {
    _viewSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('workspace-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  session: _session,
                  stack: _views.stack,
                  navigationBusy: _navigationBusy,
                  onBack: _views.canPop ? _popView : null,
                  onTestRejection: _source == null ? null : _testSafeRejection,
                ),
                if (_views.stack.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _ViewStackBar(stack: _views.stack),
                ],
                const SizedBox(height: 20),
                if (_diagnostics.isNotEmpty) ...[
                  _DiagnosticBanner(
                    diagnostics: _diagnostics,
                    onDismiss: () => setState(() => _diagnostics = const []),
                  ),
                  const SizedBox(height: 20),
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final preview = _PreviewCard(
                      session: _session,
                      runtime: widget.runtime,
                      loadError: _loadError,
                      notice: _notice,
                      navigationBusy: _navigationBusy,
                    );
                    final inspector = _InspectorCard(
                      session: _session,
                      source: _source,
                      actions: _actions,
                    );
                    if (constraints.maxWidth < 1040) {
                      return Column(
                        children: [
                          preview,
                          const SizedBox(height: 20),
                          inspector,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: preview),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: inspector),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _Header extends StatelessWidget {
  const _Header({
    required this.session,
    required this.stack,
    required this.navigationBusy,
    required this.onBack,
    required this.onTestRejection,
  });

  final GenuxSurfaceSession? session;
  final List<GenuxViewStackEntry> stack;
  final bool navigationBusy;
  final VoidCallback? onBack;
  final VoidCallback? onTestRejection;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE GENUX WORKSPACE',
                style: textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Multiple Views. One trusted native runtime.',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Each screen is an independently compiled aix.genux/1.0 '
                'document. Semantic actions open or pop allowlisted Views '
                'while earlier sessions keep their exact local state.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (session != null) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      icon: Icons.layers_outlined,
                      label:
                          '${stack.length} View${stack.length == 1 ? '' : 's'}',
                    ),
                    _StatusPill(
                      icon: Icons.tag,
                      label: session!.document.view.code,
                    ),
                    _StatusPill(
                      icon: Icons.verified_outlined,
                      label: 'revision ${session!.document.view.revision}',
                    ),
                    _StatusPill(
                      icon: Icons.sync,
                      label: 'state v${session!.store.version}',
                    ),
                    _StatusPill(
                      icon: Icons.edit_note,
                      label: '${session!.store.dirtyPaths.length} dirty',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('safe-rejection-button'),
              onPressed: onTestRejection,
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Test safe rejection'),
            ),
            FilledButton.tonalIcon(
              key: const ValueKey('native-view-back-button'),
              onPressed: navigationBusy ? null : onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ],
        ),
      ],
    );
  }
}

final class _ViewStackBar extends StatelessWidget {
  const _ViewStackBar({required this.stack});

  final List<GenuxViewStackEntry> stack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Active Genux View stack',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Icon(Icons.account_tree_outlined, size: 18),
              for (var index = 0; index < stack.length; index += 1) ...[
                if (index > 0)
                  Icon(Icons.chevron_right, size: 18, color: scheme.outline),
                Chip(
                  avatar: Icon(
                    index == stack.length - 1
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                  ),
                  label: Text(
                    '${stack[index].viewCode} · '
                    'r${stack[index].session.document.view.revision}',
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.session,
    required this.runtime,
    required this.loadError,
    required this.notice,
    required this.navigationBusy,
  });

  final GenuxSurfaceSession? session;
  final ShowcaseRuntime runtime;
  final String? loadError;
  final String? notice;
  final bool navigationBusy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewCode = session?.document.view.code;
    final namePath = viewCode == 'customer.summary'
        ? '/summary/name'
        : '/draft/name';
    final customerName = switch (session?.store
        .read(GenuxJsonPointer.parse(namePath))
        .value) {
      final String name when name.trim().isNotEmpty => name.trim(),
      _ => 'Customer',
    };
    final previewTitle = switch (viewCode) {
      'component.lab' => 'Component Lab · complete catalog',
      'customer.summary' => '$customerName · Summary View',
      'customer.edit' => '$customerName · Customer editor',
      final String code => code,
      _ => 'Loading Genux View',
    };
    final previewSubtitle = viewCode == 'component.lab'
        ? '${runtime.catalog.components.length} trusted renderers / '
              '${runtime.catalogMemberCount} catalog members / live JSON state'
        : 'Native shell / preserved dynamic View session';
    final avatarLabel = viewCode == 'component.lab'
        ? '${runtime.catalog.components.length}'
        : customerName.substring(0, 1).toUpperCase();
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: scheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: Text(avatarLabel),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewTitle,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            previewSubtitle,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const _StatusPill(
                      icon: Icons.cloud_done_outlined,
                      label: 'published',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: switch ((session, loadError)) {
                (_, final String error) => Text('Unable to load demo: $error'),
                (null, _) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                (final active?, _) => GenuxSurfaceHost(
                  key: const ValueKey('showcase-surface-host'),
                  session: active,
                  catalog: runtime.flutterCatalog,
                ),
              },
            ),
            if (navigationBusy) const LinearProgressIndicator(minHeight: 3),
            if (notice != null)
              ColoredBox(
                color: scheme.secondaryContainer.withValues(alpha: 0.55),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.terminal,
                        size: 18,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          notice!,
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _InspectorCard extends StatelessWidget {
  const _InspectorCard({
    required this.session,
    required this.source,
    required this.actions,
  });

  final GenuxSurfaceSession? session;
  final String? source;
  final List<GenuxActionInvocation> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 500,
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'State'),
                  Tab(text: 'Actions'),
                  Tab(text: 'Source'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _CodePane(
                      text: session == null
                          ? 'Waiting for activation…'
                          : const JsonEncoder.withIndent(
                              '  ',
                            ).convert(session!.store.state),
                    ),
                    actions.isEmpty
                        ? const _EmptyInspector(
                            icon: Icons.bolt_outlined,
                            message:
                                'Interact with a View to see typed intents.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: actions.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final action = actions[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action.action.capability,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${action.session.document.view.code} · '
                                    'node ${action.sourceNodeId} · state '
                                    'v${action.stateVersion}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    const JsonEncoder.withIndent(
                                      '  ',
                                    ).convert(action.arguments),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    _CodePane(text: source ?? 'Loading source…'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _CodePane extends StatelessWidget {
  const _CodePane({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: SelectableText(
      text,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        height: 1.45,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

final class _EmptyInspector extends StatelessWidget {
  const _EmptyInspector({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

final class _DiagnosticBanner extends StatelessWidget {
  const _DiagnosticBanner({required this.diagnostics, required this.onDismiss});

  final List<GenuxDiagnostic> diagnostics;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.gpp_bad_outlined, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Candidate snapshot rejected safely',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final diagnostic in diagnostics.take(3))
                    Text(
                      '${diagnostic.code} · ${diagnostic.location}',
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Dismiss diagnostics',
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
