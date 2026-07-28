import 'package:flutter/material.dart';

import 'pages/catalog_page.dart';
import 'pages/runtime_page.dart';
import 'pages/workspace_page.dart';
import 'showcase_runtime.dart';

final class GenuxShowcaseApp extends StatefulWidget {
  const GenuxShowcaseApp({this.fixtureSource, super.key});

  final String? fixtureSource;

  @override
  State<GenuxShowcaseApp> createState() => _GenuxShowcaseAppState();
}

final class _GenuxShowcaseAppState extends State<GenuxShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genux Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: _ShowcaseShell(
        fixtureSource: widget.fixtureSource,
        themeMode: _themeMode,
        onThemeModeChanged: (value) => setState(() => _themeMode = value),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B5BD6),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF7F7FC)
          : const Color(0xFF101014),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
      ),
    );
  }
}

final class _ShowcaseShell extends StatefulWidget {
  const _ShowcaseShell({
    required this.fixtureSource,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final String? fixtureSource;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<_ShowcaseShell> createState() => _ShowcaseShellState();
}

final class _ShowcaseShellState extends State<_ShowcaseShell> {
  late final ShowcaseRuntime _runtime;
  late final List<Widget> _pages;
  int _selectedIndex = 0;

  static const _destinations = [
    _Destination(
      label: 'Customer workspace',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _Destination(
      label: 'Component catalog',
      icon: Icons.widgets_outlined,
      selectedIcon: Icons.widgets,
    ),
    _Destination(
      label: 'Runtime & safety',
      icon: Icons.security_outlined,
      selectedIcon: Icons.security,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _runtime = ShowcaseRuntime.standard();
    _pages = [
      WorkspacePage(runtime: _runtime, initialSource: widget.fixtureSource),
      CatalogPage(runtime: _runtime),
      RuntimePage(runtime: _runtime),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.auto_awesome_mosaic, color: scheme.onPrimary),
            ),
            const SizedBox(width: 12),
            if (compact)
              const Text('GENUX', style: TextStyle(fontWeight: FontWeight.w800))
            else
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GENUX', style: TextStyle(fontWeight: FontWeight.w800)),
                  Text(
                    'Aix runtime frontend',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          if (!compact)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      'aix.genux/1.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'Use light theme'
                : 'Use dark theme',
            onPressed: () => widget.onThemeModeChanged(
              widget.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            ),
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final page = IndexedStack(index: _selectedIndex, children: _pages);
          if (!wide) {
            return page;
          }
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (value) =>
                    setState(() => _selectedIndex = value),
                extended: constraints.maxWidth >= 1180,
                labelType: constraints.maxWidth >= 1180
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                destinations: [
                  for (final destination in _destinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              VerticalDivider(width: 1, color: scheme.outlineVariant),
              Expanded(child: page),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 900
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) =>
                  setState(() => _selectedIndex = value),
              destinations: [
                for (final destination in _destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label.replaceFirst('Customer ', ''),
                  ),
              ],
            )
          : null,
    );
  }
}

final class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
