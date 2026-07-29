import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/workspace_page_v3.dart';
import 'showcase_runtime.dart';

final class GenuxShowcaseApp extends StatefulWidget {
  const GenuxShowcaseApp({this.fixtureSource, super.key});

  final String? fixtureSource;

  @override
  State<GenuxShowcaseApp> createState() => _GenuxShowcaseAppState();
}

final class _GenuxShowcaseAppState extends State<GenuxShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late final ShowcaseRuntime _runtime;
  bool _isLoadingTheme = true;

  @override
  void initState() {
    super.initState();
    _runtime = ShowcaseRuntime.standard();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      _themeMode = _parseThemeMode(themeModeString);
      _isLoadingTheme = false;
    });
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  void _cycleThemeMode() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
    _saveThemePreference(_themeMode);
  }

  String _getThemeModeLabel() {
    return switch (_themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  IconData _getThemeModeIcon() {
    return switch (_themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTheme) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Genux Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: WorkspacePageV3(
        runtime: _runtime,
        initialSource: widget.fixtureSource,
        themeMode: _themeMode,
        onThemeModeChanged: _cycleThemeMode,
        themeModeLabel: _getThemeModeLabel(),
        themeModeIcon: _getThemeModeIcon(),
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
    );
  }
}
