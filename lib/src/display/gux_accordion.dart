// Copyright 2025 AIX Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';

import '../utility/gux_color_codec.dart';

/// Visual styling for [GuxAccordion].
class GuxAccordionStyle {
  /// Background color of the accordion.
  final Color backgroundColor;

  /// Background color when expanded.
  final Color expandedBackgroundColor;

  /// Border color (if borderWidth > 0).
  final Color? borderColor;

  /// Border width in pixels.
  final double borderWidth;

  /// Corner radius in pixels.
  final double borderRadius;

  /// Padding inside the header.
  final EdgeInsets headerPadding;

  /// Padding inside the content area.
  final EdgeInsets contentPadding;

  /// Header text color.
  final Color headerTextColor;

  /// Header font size.
  final double headerFontSize;

  /// Header font weight.
  final FontWeight headerFontWeight;

  /// Content text color.
  final Color contentTextColor;

  /// Content font size.
  final double contentFontSize;

  /// Icon color.
  final Color iconColor;

  /// Icon size.
  final double iconSize;

  /// Spacing between header and content.
  final double spacing;

  const GuxAccordionStyle({
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.expandedBackgroundColor = const Color(0xFFF9FAFB),
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 8.0,
    this.headerPadding = const EdgeInsets.all(16.0),
    this.contentPadding = const EdgeInsets.all(16.0),
    this.headerTextColor = const Color(0xFF1F2937),
    this.headerFontSize = 16.0,
    this.headerFontWeight = FontWeight.w600,
    this.contentTextColor = const Color(0xFF4B5563),
    this.contentFontSize = 14.0,
    this.iconColor = const Color(0xFF6B7280),
    this.iconSize = 20.0,
    this.spacing = 0.0,
  });

  /// Creates an accordion style from JSON.
  factory GuxAccordionStyle.fromJson(Map<String, dynamic> json) {
    return GuxAccordionStyle(
      backgroundColor: json['backgroundColor'] != null
          ? GuxColorCodec.parse(json['backgroundColor'] as String)
          : const Color(0xFFFFFFFF),
      expandedBackgroundColor: json['expandedBackgroundColor'] != null
          ? GuxColorCodec.parse(json['expandedBackgroundColor'] as String)
          : const Color(0xFFF9FAFB),
      borderColor: json['borderColor'] != null
          ? GuxColorCodec.parse(json['borderColor'] as String)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      headerPadding: json['headerPadding'] != null
          ? _parsePadding(json['headerPadding'] as Map<String, dynamic>)
          : const EdgeInsets.all(16.0),
      contentPadding: json['contentPadding'] != null
          ? _parsePadding(json['contentPadding'] as Map<String, dynamic>)
          : const EdgeInsets.all(16.0),
      headerTextColor: json['headerTextColor'] != null
          ? GuxColorCodec.parse(json['headerTextColor'] as String)
          : const Color(0xFF1F2937),
      headerFontSize: (json['headerFontSize'] as num?)?.toDouble() ?? 16.0,
      headerFontWeight:
          _parseFontWeight(json['headerFontWeight'] as String?),
      contentTextColor: json['contentTextColor'] != null
          ? GuxColorCodec.parse(json['contentTextColor'] as String)
          : const Color(0xFF4B5563),
      contentFontSize: (json['contentFontSize'] as num?)?.toDouble() ?? 14.0,
      iconColor: json['iconColor'] != null
          ? GuxColorCodec.parse(json['iconColor'] as String)
          : const Color(0xFF6B7280),
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 20.0,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this style to JSON.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': GuxColorCodec.toHex(backgroundColor),
      'expandedBackgroundColor': GuxColorCodec.toHex(expandedBackgroundColor),
      if (borderColor != null) 'borderColor': GuxColorCodec.toHex(borderColor!),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'headerPadding': {
        'left': headerPadding.left,
        'top': headerPadding.top,
        'right': headerPadding.right,
        'bottom': headerPadding.bottom,
      },
      'contentPadding': {
        'left': contentPadding.left,
        'top': contentPadding.top,
        'right': contentPadding.right,
        'bottom': contentPadding.bottom,
      },
      'headerTextColor': GuxColorCodec.toHex(headerTextColor),
      'headerFontSize': headerFontSize,
      'headerFontWeight': _fontWeightToString(headerFontWeight),
      'contentTextColor': GuxColorCodec.toHex(contentTextColor),
      'contentFontSize': contentFontSize,
      'iconColor': GuxColorCodec.toHex(iconColor),
      'iconSize': iconSize,
      'spacing': spacing,
    };
  }



  static EdgeInsets _parsePadding(Map<String, dynamic> json) {
    if (json.containsKey('all')) {
      return EdgeInsets.all((json['all'] as num).toDouble());
    }
    return EdgeInsets.only(
      left: (json['left'] as num?)?.toDouble() ?? 0,
      top: (json['top'] as num?)?.toDouble() ?? 0,
      right: (json['right'] as num?)?.toDouble() ?? 0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 0,
    );
  }

  static FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case 'normal':
        return FontWeight.normal;
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w600;
    }
  }

  static String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.normal) return 'normal';
    if (weight == FontWeight.bold) return 'bold';
    return 'w${weight.value}';
  }
}

/// A collapsible content section with expand/collapse functionality.
///
/// Inspired by shadcn/ui Accordion component. Provides an interactive
/// way to show and hide content sections, commonly used in FAQs,
/// settings panels, or navigation menus.
///
/// Example:
/// ```dart
/// GuxAccordion(
///   title: 'Section Title',
///   content: Text('Collapsible content goes here'),
///   style: GuxAccordionStyle(
///     backgroundColor: Color(0xFFFFFFFF),
///     borderRadius: 8.0,
///   ),
///   initiallyExpanded: false,
/// )
/// ```
class GuxAccordion extends StatefulWidget {
  /// Title text displayed in the header.
  final String title;

  /// Content widget shown when expanded.
  final Widget content;

  /// Visual styling for the accordion.
  final GuxAccordionStyle style;

  /// Whether the accordion starts expanded.
  final bool initiallyExpanded;

  /// Optional callback when expanded state changes.
  final ValueChanged<bool>? onExpansionChanged;

  const GuxAccordion({
    super.key,
    required this.title,
    required this.content,
    required this.style,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  /// Creates an accordion from JSON.
  ///
  /// Example:
  /// ```dart
  /// GuxAccordion.fromJson({
  ///   'title': 'Section Title',
  ///   'content': {'type': 'Text', 'data': 'Content'},
  ///   'style': {
  ///     'backgroundColor': '#FFFFFF',
  ///     'borderRadius': 8.0,
  ///   },
  ///   'initiallyExpanded': false,
  /// })
  /// ```
  factory GuxAccordion.fromJson(
    Map<String, dynamic> json, {
    Map<String, VoidCallback>? actions,
  }) {
    final styleJson = json['style'] as Map<String, dynamic>?;
    final contentJson = json['content'];

    return GuxAccordion(
      title: json['title'] as String? ?? '',
      content: contentJson != null && contentJson is Map<String, dynamic>
          ? _buildChildFromJson(contentJson)
          : const SizedBox.shrink(),
      style: styleJson != null
          ? GuxAccordionStyle.fromJson(styleJson)
          : const GuxAccordionStyle(),
      initiallyExpanded: json['initiallyExpanded'] as bool? ?? false,
    );
  }

  static Widget _buildChildFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'Text') {
      return Text(json['data'] as String? ?? '');
    }
    // Add more widget types as needed
    return const SizedBox.shrink();
  }

  /// Converts this accordion to JSON.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': {
        'type': 'Widget',
      },
      'style': style.toJson(),
      'initiallyExpanded': initiallyExpanded,
    };
  }

  @override
  State<GuxAccordion> createState() => _GuxAccordionState();
}

class _GuxAccordionState extends State<GuxAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;

    return Container(
      decoration: BoxDecoration(
        color: _isExpanded
            ? style.expandedBackgroundColor
            : style.backgroundColor,
        border: style.borderWidth > 0 && style.borderColor != null
            ? Border.all(
                color: style.borderColor!,
                width: style.borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: style.headerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: style.headerTextColor,
                        fontSize: style.headerFontSize,
                        fontWeight: style.headerFontWeight,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  _buildIcon(style),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            if (style.spacing > 0)
              SizedBox(height: style.spacing),
            Container(
              padding: style.contentPadding,
              child: widget.content,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(GuxAccordionStyle style) {
    return AnimatedRotation(
      turns: _isExpanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: CustomPaint(
        size: Size(style.iconSize, style.iconSize),
        painter: _ChevronDownPainter(color: style.iconColor),
      ),
    );
  }
}

/// Custom painter for chevron down icon.
class _ChevronDownPainter extends CustomPainter {
  final Color color;

  _ChevronDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.35);
    path.lineTo(size.width * 0.5, size.height * 0.65);
    path.lineTo(size.width * 0.75, size.height * 0.35);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronDownPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
