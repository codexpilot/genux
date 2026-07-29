import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genux/genux_flutter.dart';

import '../showcase_runtime.dart';

/// Two-tab workspace: JSON editor tab and runtime view tab (like DartPad).
final class WorkspacePageV3 extends StatefulWidget {
  const WorkspacePageV3({
    required this.runtime,
    this.initialSource,
    this.sourceLoader,
    this.initialViewCode = ShowcaseRuntime.initialViewCode,
    this.initialInstanceKey,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.themeModeLabel,
    this.themeModeIcon,
    super.key,
  });

  final ShowcaseRuntime runtime;
  final String? initialSource;
  final GenuxViewSourceLoader? sourceLoader;
  final String initialViewCode;
  final String? initialInstanceKey;
  final ThemeMode themeMode;
  final VoidCallback? onThemeModeChanged;
  final String? themeModeLabel;
  final IconData? themeModeIcon;

  @override
  State<WorkspacePageV3> createState() => _WorkspacePageV3State();
}

final class _WorkspacePageV3State extends State<WorkspacePageV3>
    with SingleTickerProviderStateMixin {
  late final GenuxViewCoordinator _views;
  late final TabController _tabController;
  GenuxViewStackSubscription? _viewSubscription;
  final Map<String, String> _sources = {};
  GenuxSurfaceSession? _session;
  GenuxViewStackEntry? _currentEntry;
  String? _loadError;
  bool _navigationBusy = false;
  String? _notice;
  int _latestUiNavigationRequest = 0;
  final _jsonController = TextEditingController();
  bool _autoApply = true;
  String? _compileError;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _views = GenuxViewCoordinator(
      compiler: widget.runtime.compiler,
      sourceLoader: _loadViewSource,
      dispatcher: _handleAction,
    );
    _viewSubscription = _views.subscribe(_onViewStackChanged);
    _openInitialView();
  }

  @override
  void dispose() {
    _viewSubscription?.cancel();
    _tabController.dispose();
    _jsonController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onViewStackChanged(GenuxViewStackChange change) {
    if (!mounted) return;

    setState(() {
      _currentEntry = _views.current;
      _session = _currentEntry?.session;
      if (_currentEntry != null) {
        final source = _sources[_currentEntry!.viewCode];
        if (source != null) {
          _jsonController.text = _formatJson(source);
        }
      }
    });
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
        instanceKey: widget.initialInstanceKey ??
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
    setState(() {
      _navigationBusy = false;
      _loadError = result is GenuxViewOpenFailure ? result.error.toString() : null;
    });
  }

  void _popView() {
    final result = _views.pop();
    _handlePopResult(result);
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

  Future<void> _handleAction(GenuxActionInvocation invocation) async {
    switch (invocation.action.capability) {
      case 'view.open':
        final viewCode = invocation.arguments['viewCode'];
        if (viewCode is! String) {
          return;
        }
        await _openView(
          GenuxViewTarget(
            viewCode: viewCode,
            instanceKey: '$viewCode:root',
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
            _notice = 'Accepted customer.save';
          });
        }
        return;
      default:
        return;
    }
  }

  String _formatJson(String source) {
    try {
      final json = jsonDecode(source);
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (_) {
      return source;
    }
  }

  void _applyJsonChanges() {
    if (_currentEntry == null) return;

    try {
      // Validate JSON
      jsonDecode(_jsonController.text);

      // Update source cache
      _sources[_currentEntry!.viewCode] = _jsonController.text;

      // Trigger reload by reopening the current view
      final target = _currentEntry!.target;
      _openView(target);

      setState(() {
        _compileError = null;
        _notice = 'Recompiling...';
      });
    } catch (e) {
      setState(() {
        _compileError = 'JSON Parse Error: $e';
      });
    }
  }

  void _onJsonChanged(String value) {
    if (!_autoApply) return;

    // Debounce auto-apply
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_autoApply && mounted) {
        _applyJsonChanges();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final session = _session;
    final loadError = _loadError;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.code, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            const Text('Genux Showcase'),
            if (_currentEntry != null) ...[
              const SizedBox(width: 16),
              const Text('·'),
              const SizedBox(width: 8),
              Text(
                _currentEntry!.viewCode,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (widget.onThemeModeChanged != null)
            IconButton(
              icon: Icon(widget.themeModeIcon ?? Icons.brightness_auto),
              tooltip: 'Theme: ${widget.themeModeLabel ?? "System"}',
              onPressed: widget.onThemeModeChanged,
            ),
          if (_views.canPop)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: _popView,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.code),
              text: 'JSON Source',
            ),
            Tab(
              icon: Icon(Icons.play_arrow),
              text: 'Runtime View',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: JSON Editor
          _buildJsonEditorTab(scheme),

          // Tab 2: Runtime View
          _buildRuntimeViewTab(scheme, session, loadError),
        ],
      ),
    );
  }

  Widget _buildJsonEditorTab(ColorScheme scheme) {
    return Column(
      children: [
        // Editor toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            border: Border(
              bottom: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Edit JSON and switch to Runtime View to see results',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Auto',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _autoApply,
                    onChanged: (value) {
                      setState(() => _autoApply = value);
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {
                  _applyJsonChanges();
                  // Switch to runtime view to see result
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Apply & View'),
              ),
            ],
          ),
        ),

        // JSON Editor
        Expanded(
          child: TextField(
            controller: _jsonController,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: _onJsonChanged,
          ),
        ),

        // Error display
        if (_compileError != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: scheme.errorContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 20,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _compileError!,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() => _compileError = null);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRuntimeViewTab(
    ColorScheme scheme,
    GenuxSurfaceSession? session,
    String? loadError,
  ) {
    return Column(
      children: [
        // Runtime toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            border: Border(
              bottom: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Live preview of compiled view',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (session != null)
                Text(
                  'State v${session.store.version}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),

        // Runtime content
        Expanded(
          child: switch ((session, loadError)) {
            (_, final String error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: scheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load view',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            (null, _) => const Center(
                child: CircularProgressIndicator(),
              ),
            (final active?, _) => () {
                // A8: Detect CollectionView and apply bounded viewport
                final hasCollectionView = active.document.nodes.values.any(
                  (node) => node.component.code == 'CollectionView',
                );

                final host = GenuxSurfaceHost(
                  key: const ValueKey('showcase-surface-host'),
                  session: active,
                  catalog: widget.runtime.flutterCatalog,
                );

                // Wrap in bounded viewport if CollectionView detected
                return hasCollectionView
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: host,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: host,
                        ),
                      );
              }(),
          },
        ),

        // Navigation busy indicator
        if (_navigationBusy) const LinearProgressIndicator(minHeight: 3),

        // Notice bar
        if (_notice != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: scheme.secondaryContainer.withValues(alpha: 0.55),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: scheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _notice!,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() => _notice = null);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
