import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../catalog/catalog.dart';
import '../state/surface_store.dart';
import 'collection_view_renderer.dart';
import 'component_scope.dart';
import 'flutter_catalog.dart';

GenuxFlutterCatalog createGenuxMaterialCatalog(GenuxCatalog catalog) {
  // Base registrations for aix.core@1 (10 components)
  final baseRegistrations = const [
    GenuxFlutterRegistration(componentCode: 'Column', builder: _buildColumn),
    GenuxFlutterRegistration(componentCode: 'Text', builder: _buildText),
    GenuxFlutterRegistration(
      componentCode: 'ComboBox',
      builder: _buildComboBox,
    ),
    GenuxFlutterRegistration(componentCode: 'Button', builder: _buildButton),
    GenuxFlutterRegistration(componentCode: 'Form', builder: _buildForm),
    GenuxFlutterRegistration(
      componentCode: 'TextField',
      builder: _buildTextField,
    ),
    GenuxFlutterRegistration(
      componentCode: 'Checkbox',
      builder: _buildCheckbox,
    ),
    GenuxFlutterRegistration(componentCode: 'Row', builder: _buildRow),
    GenuxFlutterRegistration(componentCode: 'Card', builder: _buildCard),
    GenuxFlutterRegistration(
      componentCode: 'Divider',
      builder: _buildDivider,
    ),
  ];

  // Additional registrations for aix.core@2
  final v2Registrations = const [
    GenuxFlutterRegistration(
      componentCode: 'CollectionView',
      builder: buildCollectionView,
    ),
    GenuxFlutterRegistration(
      componentCode: 'Expanded',
      builder: buildExpanded,
    ),
  ];

  // Select registrations based on catalog version
  final registrations = catalog.version >= 2
      ? [...baseRegistrations, ...v2Registrations]
      : baseRegistrations;

  return GenuxFlutterCatalog(
    catalog: catalog,
    registrations: registrations,
  );
}

Widget _buildColumn(BuildContext context, GenuxComponentScope scope) {
  final gap = scope.property<num>('gap')?.toDouble() ?? 12;
  final children = _withGap(scope.slot('children'), gap);
  final mainAxisSize = switch (scope.property<String>('mainAxisSize')) {
    'min' => MainAxisSize.min,
    _ => MainAxisSize.max,
  };
  final crossAxisAlignment = switch (scope.property<String>(
    'crossAxisAlignment',
  )) {
    'center' => CrossAxisAlignment.center,
    'end' => CrossAxisAlignment.end,
    'stretch' => CrossAxisAlignment.stretch,
    _ => CrossAxisAlignment.start,
  };
  return Column(
    key: ValueKey('genux:${scope.nodeId}'),
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    children: children,
  );
}

Widget _buildText(BuildContext context, GenuxComponentScope scope) {
  final theme = Theme.of(context).textTheme;
  final style = switch (scope.property<String>('style')) {
    'displaySmall' => theme.displaySmall,
    'headlineMedium' => theme.headlineMedium,
    'headlineSmall' => theme.headlineSmall,
    'titleLarge' => theme.titleLarge,
    'titleMedium' => theme.titleMedium,
    'labelLarge' => theme.labelLarge,
    'bodySmall' => theme.bodySmall,
    _ => theme.bodyLarge,
  };
  return Text(
    scope.requireValue<String>('text'),
    key: ValueKey('genux:${scope.nodeId}'),
    maxLines: scope.property<int>('maxLines'),
    overflow: scope.property<int>('maxLines') == null
        ? null
        : TextOverflow.ellipsis,
    style: style,
  );
}

Widget _buildComboBox(BuildContext context, GenuxComponentScope scope) {
  final choices = scope.choiceItems('items');
  final selected = scope.value('value');
  final enabled = scope.optionalValue<bool>('enabled') ?? true;
  final busy = scope.optionalValue<bool>('busy') ?? false;
  final clearable = scope.property<bool>('clearable') ?? false;
  // A disabled choice cannot be selected by the user, but an existing bound
  // value must remain visible. Hiding it would make rendered state disagree
  // with the surface store.
  final availableSelection = choices.any((item) => item.key == selected)
      ? selected
      : null;

  return DropdownButtonFormField<Object>(
    key: ValueKey(
      'genux:${scope.nodeId}:${availableSelection.runtimeType}:'
      '$availableSelection',
    ),
    initialValue: availableSelection,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: scope.property<String>('placeholder'),
      border: const OutlineInputBorder(),
      suffixIcon: busy
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
    ),
    items: [
      if (clearable)
        const DropdownMenuItem<Object>(
          value: null,
          child: Text('No selection'),
        ),
      for (final choice in choices)
        DropdownMenuItem<Object>(
          value: choice.key,
          enabled: !choice.disabled,
          child: Text(
            choice.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: choice.disabled
                ? TextStyle(color: Theme.of(context).disabledColor)
                : null,
          ),
        ),
    ],
    onChanged: enabled && !busy
        ? (next) {
            if (next == null && !clearable) {
              return;
            }
            final result = scope.write('value', next);
            if (result is GenuxStateCommitted) {
              unawaited(scope.emit('changed', next));
            }
          }
        : null,
  );
}

Widget _buildButton(BuildContext context, GenuxComponentScope scope) {
  final label = scope.requireValue<String>('label');
  final busy = scope.optionalValue<bool>('busy') ?? false;
  final enabled = scope.optionalValue<bool>('enabled') ?? true;
  final onPressed = enabled && !busy
      ? () => unawaited(scope.emit('pressed'))
      : null;
  final child = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (busy) ...[
        const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
      ],
      Flexible(
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ],
  );

  return switch (scope.property<String>('variant')) {
    'secondary' => FilledButton.tonal(
      key: ValueKey('genux:${scope.nodeId}'),
      onPressed: onPressed,
      child: child,
    ),
    'tertiary' => TextButton(
      key: ValueKey('genux:${scope.nodeId}'),
      onPressed: onPressed,
      child: child,
    ),
    'danger' => FilledButton(
      key: ValueKey('genux:${scope.nodeId}'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      onPressed: onPressed,
      child: child,
    ),
    _ => FilledButton(
      key: ValueKey('genux:${scope.nodeId}'),
      onPressed: onPressed,
      child: child,
    ),
  };
}

Widget _buildForm(BuildContext context, GenuxComponentScope scope) {
  final content = scope.slot('content');
  final actions = scope.slot('actions');
  final busy = scope.optionalValue<bool>('busy') ?? false;
  final rawErrors = scope.value('errors');
  final errors = rawErrors is Map
      ? _formErrorLines(rawErrors)
      : const <String>[];
  final children = <Widget>[
    if (busy) ...[
      LinearProgressIndicator(key: ValueKey('genux:${scope.nodeId}:busy')),
      const SizedBox(height: 16),
    ],
    if (errors.isNotEmpty) ...[
      _FormErrorSummary(
        key: ValueKey('genux:${scope.nodeId}:errors'),
        errors: errors,
      ),
      const SizedBox(height: 16),
    ],
    ..._withGap(content, 20),
    if (actions.isNotEmpty) ...[
      const SizedBox(height: 4),
      Wrap(spacing: 12, runSpacing: 12, children: actions),
    ],
  ];
  return CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
        if (!busy) unawaited(scope.emit('submitted'));
      },
      const SingleActivator(LogicalKeyboardKey.enter, meta: true): () {
        if (!busy) unawaited(scope.emit('submitted'));
      },
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (!busy) unawaited(scope.emit('cancelled'));
      },
    },
    child: Form(
      key: ValueKey('genux:${scope.nodeId}'),
      child: _FormBusyGate(
        busy: busy,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: busy ? 0.62 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

final class _FormBusyGate extends StatefulWidget {
  const _FormBusyGate({required this.busy, required this.child});

  final bool busy;
  final Widget child;

  @override
  State<_FormBusyGate> createState() => _FormBusyGateState();
}

final class _FormBusyGateState extends State<_FormBusyGate> {
  late final FocusScopeNode _focusScope;

  @override
  void initState() {
    super.initState();
    _focusScope = FocusScopeNode(debugLabel: 'Genux Form');
  }

  @override
  void didUpdateWidget(covariant _FormBusyGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busy && !oldWidget.busy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusScope.hasFocus) {
          _focusScope.unfocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FocusScope(
    node: _focusScope,
    canRequestFocus: !widget.busy,
    descendantsAreFocusable: !widget.busy,
    descendantsAreTraversable: !widget.busy,
    child: AbsorbPointer(absorbing: widget.busy, child: widget.child),
  );
}

List<String> _formErrorLines(Map<Object?, Object?> errors) {
  final lines = <String>[];
  for (final entry in errors.entries) {
    final value = entry.value;
    if (value == null || value == '' || (value is Iterable && value.isEmpty)) {
      continue;
    }
    final message = value is Iterable ? value.join(', ') : value.toString();
    lines.add('${entry.key}: $message');
  }
  return List.unmodifiable(lines);
}

final class _FormErrorSummary extends StatelessWidget {
  const _FormErrorSummary({required this.errors, super.key});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: 'Form errors',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please review this form',
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final error in errors)
                      Text(
                        error,
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
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

Widget _buildTextField(BuildContext context, GenuxComponentScope scope) {
  return _GenuxTextField(key: ValueKey('genux:${scope.nodeId}'), scope: scope);
}

final class _GenuxTextField extends StatefulWidget {
  const _GenuxTextField({required this.scope, super.key});

  final GenuxComponentScope scope;

  @override
  State<_GenuxTextField> createState() => _GenuxTextFieldState();
}

final class _GenuxTextFieldState extends State<_GenuxTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.scope.requireValue<String>('value'),
    );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _GenuxTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllerFromState();
  }

  void _syncControllerFromState() {
    final text = widget.scope.requireValue<String>('value');
    if (_controller.text == text) {
      return;
    }
    _controller.value = TextEditingValue(
      text: text,
      selection: _selectionFor(text),
    );
  }

  TextSelection _selectionFor(String text) {
    final current = _controller.selection;
    if (!current.isValid) {
      return TextSelection.collapsed(offset: text.length);
    }
    return TextSelection(
      baseOffset: current.baseOffset.clamp(0, text.length),
      extentOffset: current.extentOffset.clamp(0, text.length),
      affinity: current.affinity,
      isDirectional: current.isDirectional,
    );
  }

  void _handleChanged(String value) {
    final result = widget.scope.write('value', value);
    if (result is GenuxStateCommitted) {
      unawaited(widget.scope.emit('changed', value));
      return;
    }
    _syncControllerFromState();
  }

  void _handleSubmitted(String value) {
    unawaited(widget.scope.emit('submitted', value));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.scope.optionalValue<bool>('enabled') ?? true;
    final readOnly = widget.scope.optionalValue<bool>('readOnly') ?? false;
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: widget.scope.property<int>('maxLines') ?? 1,
      decoration: InputDecoration(
        labelText: widget.scope.property<String>('label'),
        hintText: widget.scope.property<String>('hint'),
        errorText: widget.scope.optionalValue<String>('errorText'),
        border: const OutlineInputBorder(),
      ),
      onChanged: enabled && !readOnly ? _handleChanged : null,
      onSubmitted: enabled && !readOnly ? _handleSubmitted : null,
    );
  }
}

Widget _buildCheckbox(BuildContext context, GenuxComponentScope scope) {
  final enabled = scope.optionalValue<bool>('enabled') ?? true;
  return CheckboxListTile(
    key: ValueKey('genux:${scope.nodeId}'),
    value: scope.requireValue<bool>('value'),
    enabled: enabled,
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    title: Text(scope.property<String>('label') ?? ''),
    onChanged: enabled
        ? (value) {
            if (value == null) {
              return;
            }
            final result = scope.write('value', value);
            if (result is GenuxStateCommitted) {
              unawaited(scope.emit('changed', value));
            }
          }
        : null,
  );
}

Widget _buildRow(BuildContext context, GenuxComponentScope scope) {
  final gap = scope.property<num>('gap')?.toDouble() ?? 12;
  final children = _withHorizontalGap(scope.slot('children'), gap);
  final mainAxisSize = switch (scope.property<String>('mainAxisSize')) {
    'min' => MainAxisSize.min,
    _ => MainAxisSize.max,
  };
  final crossAxisAlignment = switch (scope.property<String>(
    'crossAxisAlignment',
  )) {
    'start' => CrossAxisAlignment.start,
    'end' => CrossAxisAlignment.end,
    _ => CrossAxisAlignment.center,
  };
  return Row(
    key: ValueKey('genux:${scope.nodeId}'),
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    children: children,
  );
}

Widget _buildCard(BuildContext context, GenuxComponentScope scope) {
  final padding = scope.property<num>('padding')?.toDouble() ?? 16;
  return Card(
    key: ValueKey('genux:${scope.nodeId}'),
    child: Padding(
      padding: EdgeInsets.all(padding),
      child: scope.slot('content').single,
    ),
  );
}

Widget _buildDivider(BuildContext context, GenuxComponentScope scope) {
  return Divider(
    key: ValueKey('genux:${scope.nodeId}'),
    thickness: scope.property<num>('thickness')?.toDouble(),
    indent: scope.property<num>('indent')?.toDouble(),
    endIndent: scope.property<num>('endIndent')?.toDouble(),
  );
}

List<Widget> _withGap(List<Widget> children, double gap) {
  return [
    for (var index = 0; index < children.length; index += 1) ...[
      if (index > 0) SizedBox(height: gap),
      children[index],
    ],
  ];
}

List<Widget> _withHorizontalGap(List<Widget> children, double gap) {
  return [
    for (var index = 0; index < children.length; index += 1) ...[
      if (index > 0) SizedBox(width: gap),
      children[index],
    ],
  ];
}
