import 'package:flutter/widgets.dart';

import 'genux_workspace_scaffold.dart';
import 'presentation_document.dart';
import 'summary_lines.dart';

/// Renders an already validated experimental Genux presentation document.
///
/// The embedding application supplies text direction and inherited text styles.
/// Documents contain no callbacks or data bindings. Give the view bounded
/// constraints when it fills a workspace.
class GenuxPresentationView extends StatelessWidget {
  const GenuxPresentationView({super.key, required this.document});

  final GenuxPresentationDocument document;

  @override
  Widget build(BuildContext context) => _render(document.root);
}

Widget _render(GenuxNode node) => switch (node) {
  GenuxTextNode() => _scrollingContent(Text(node.text)),
  GenuxSummaryLinesNode() => _scrollingContent(
    GenuxSummaryLines(
      primary: node.primary,
      secondary: node.secondary,
      tertiary: node.tertiary,
      spacing: node.spacing,
    ),
  ),
  GenuxColumnNode() => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < node.children.length; i++) ...[
          if (i > 0) SizedBox(height: node.spacing),
          _render(node.children[i]),
        ],
      ],
    ),
  ),
  GenuxWorkspaceNode() => LayoutBuilder(
    builder: (context, constraints) => SizedBox(
      // A workspace can appear in a scrolling column, where height is
      // unbounded. Supply a finite fallback so the slot layout remains safe.
      width: constraints.hasBoundedWidth ? constraints.maxWidth : 640,
      height: constraints.hasBoundedHeight ? constraints.maxHeight : 320,
      child: GenuxWorkspaceScaffold(
        body: _render(node.body),
        topBar: node.topBar == null ? null : _render(node.topBar!),
        bottomBar: node.bottomBar == null ? null : _render(node.bottomBar!),
        sideBar: node.sideBar == null ? null : _render(node.sideBar!),
        topBarHeight: node.topBarHeight,
        bottomBarHeight: node.bottomBarHeight,
        sideBarWidth: node.sideBarWidth,
      ),
    ),
  ),
};

// A slot can be smaller than its content, including at large text scales.
// Scrolling gives text a finite width and an unconstrained natural height;
// clipping keeps its paint within the slot without altering shared widgets.
Widget _scrollingContent(Widget child) =>
    ClipRect(child: SingleChildScrollView(child: child));
