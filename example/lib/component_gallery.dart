import 'package:flutter/widgets.dart';
import 'dart:convert';

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  String _selectedCategory = 'Layout';

  final Map<String, List<ComponentExample>> _categories = {
    'Layout': [
      ComponentExample(
        name: 'GuxApp',
        description: 'Root application widget with theme configuration',
        jsonConfig: {
          'title': 'My App',
          'color': '#3B82F6',
          'textStyle': {
            'color': '#FFFFFF',
            'fontSize': 14,
          },
        },
      ),
      ComponentExample(
        name: 'GuxWorkspaceScaffold',
        description: 'Application scaffold with navigation and content areas',
        jsonConfig: {
          'title': 'Workspace',
          'navigationItems': [
            {'label': 'Home', 'icon': 'home'},
            {'label': 'Settings', 'icon': 'settings'},
          ],
        },
      ),
      ComponentExample(
        name: 'GuxCard',
        description: 'Container with elevation and border',
        jsonConfig: {
          'style': {
            'backgroundColor': '#252525',
            'borderColor': '#333333',
            'borderRadius': 8.0,
            'elevation': 2.0,
            'padding': 16.0,
          },
        },
      ),
      ComponentExample(
        name: 'GuxSheet',
        description: 'Elevated surface for grouping content',
        jsonConfig: {
          'style': {
            'backgroundColor': '#1E1E1E',
            'borderRadius': 12.0,
            'padding': 24.0,
          },
        },
      ),
    ],
    'Input': [
      ComponentExample(
        name: 'GuxButton',
        description: 'Interactive button with states',
        jsonConfig: {
          'style': {
            'backgroundColor': '#3B82F6',
            'hoverColor': '#2563EB',
            'pressedColor': '#1D4ED8',
            'foregroundColor': '#FFFFFF',
          },
          'child': {'type': 'Text', 'data': 'Click Me'},
        },
      ),
      ComponentExample(
        name: 'GuxCheckbox',
        description: 'Boolean selection control',
        jsonConfig: {
          'value': true,
          'style': {
            'activeColor': '#3B82F6',
            'checkColor': '#FFFFFF',
          },
        },
      ),
      ComponentExample(
        name: 'GuxToggle',
        description: 'Binary switch control',
        jsonConfig: {
          'value': true,
          'style': {
            'activeColor': '#3B82F6',
            'inactiveColor': '#555555',
          },
        },
      ),
      ComponentExample(
        name: 'GuxTextInput',
        description: 'Single-line text entry',
        jsonConfig: {
          'placeholder': 'Enter text...',
          'style': {
            'backgroundColor': '#252525',
            'borderColor': '#333333',
            'textColor': '#FFFFFF',
          },
        },
      ),
      ComponentExample(
        name: 'GuxTextField',
        description: 'Multi-line text entry',
        jsonConfig: {
          'placeholder': 'Enter multiple lines...',
          'maxLines': 5,
          'style': {
            'backgroundColor': '#252525',
            'borderColor': '#333333',
          },
        },
      ),
      ComponentExample(
        name: 'GuxDropdown',
        description: 'Selection from list of options',
        jsonConfig: {
          'items': [
            {'value': '1', 'label': 'Option 1'},
            {'value': '2', 'label': 'Option 2'},
            {'value': '3', 'label': 'Option 3'},
          ],
          'selectedValue': '1',
        },
      ),
      ComponentExample(
        name: 'GuxSwitch',
        description: 'Toggle switch control',
        jsonConfig: {
          'value': false,
          'style': {
            'activeColor': '#10B981',
            'inactiveColor': '#6B7280',
          },
        },
      ),
      ComponentExample(
        name: 'GuxRadio',
        description: 'Single selection from group',
        jsonConfig: {
          'value': 'option1',
          'groupValue': 'option1',
          'style': {
            'activeColor': '#3B82F6',
          },
        },
      ),
      ComponentExample(
        name: 'GuxSlider',
        description: 'Numeric value selector',
        jsonConfig: {
          'value': 0.5,
          'min': 0.0,
          'max': 1.0,
          'style': {
            'activeColor': '#3B82F6',
            'inactiveColor': '#555555',
          },
        },
      ),
    ],
    'Navigation': [
      ComponentExample(
        name: 'GuxNavigation',
        description: 'Navigation menu with items',
        jsonConfig: {
          'items': [
            {'label': 'Dashboard', 'icon': 'dashboard'},
            {'label': 'Projects', 'icon': 'folder'},
            {'label': 'Settings', 'icon': 'settings'},
          ],
          'selectedIndex': 0,
        },
      ),
      ComponentExample(
        name: 'GuxTabs',
        description: 'Tabbed navigation interface',
        jsonConfig: {
          'tabs': [
            {'label': 'Tab 1'},
            {'label': 'Tab 2'},
            {'label': 'Tab 3'},
          ],
          'selectedIndex': 0,
        },
      ),
      ComponentExample(
        name: 'GuxAccordion',
        description: 'Collapsible content sections',
        jsonConfig: {
          'items': [
            {'title': 'Section 1', 'expanded': true},
            {'title': 'Section 2', 'expanded': false},
          ],
        },
      ),
    ],
    'Feedback': [
      ComponentExample(
        name: 'GuxDialog',
        description: 'Modal dialog overlay',
        jsonConfig: {
          'title': 'Confirm Action',
          'content': 'Are you sure you want to proceed?',
          'actions': [
            {'label': 'Cancel', 'action': 'cancel'},
            {'label': 'Confirm', 'action': 'confirm'},
          ],
        },
      ),
      ComponentExample(
        name: 'GuxToast',
        description: 'Temporary notification message',
        jsonConfig: {
          'message': 'Operation completed successfully',
          'type': 'success',
          'duration': 3000,
        },
      ),
      ComponentExample(
        name: 'GuxAlert',
        description: 'Inline alert message',
        jsonConfig: {
          'message': 'Important information',
          'type': 'info',
          'style': {
            'backgroundColor': '#1E3A8A',
            'textColor': '#FFFFFF',
          },
        },
      ),
      ComponentExample(
        name: 'GuxBadge',
        description: 'Status indicator badge',
        jsonConfig: {
          'text': '5',
          'style': {
            'backgroundColor': '#EF4444',
            'textColor': '#FFFFFF',
          },
        },
      ),
      ComponentExample(
        name: 'GuxProgressIndicator',
        description: 'Progress visualization',
        jsonConfig: {
          'value': 0.65,
          'style': {
            'color': '#3B82F6',
            'trackColor': '#333333',
          },
        },
      ),
      ComponentExample(
        name: 'GuxAvatar',
        description: 'User profile image or initials',
        jsonConfig: {
          'initials': 'JD',
          'style': {
            'backgroundColor': '#3B82F6',
            'textColor': '#FFFFFF',
            'size': 48.0,
          },
        },
      ),
    ],
    'Utilities': [
      ComponentExample(
        name: 'GuxSeparator',
        description: 'Visual divider between content',
        jsonConfig: {
          'style': {
            'color': '#333333',
            'thickness': 1.0,
            'indent': 0.0,
          },
        },
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final categoryExamples = _categories[_selectedCategory] ?? [];

    return Container(
      color: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          // Category navigation
          Container(
            width: 200,
            color: const Color(0xFF252525),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Components',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _categories.keys.map((category) {
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0x00000000),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFFCCCCCC),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Component count
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_getTotalComponentCount()} components',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Component examples
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: categoryExamples.length,
              itemBuilder: (context, index) {
                final example = categoryExamples[index];
                return _ComponentCard(example: example);
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalComponentCount() {
    return _categories.values.fold(0, (sum, list) => sum + list.length);
  }
}

class ComponentExample {
  final String name;
  final String description;
  final Map<String, dynamic> jsonConfig;

  ComponentExample({
    required this.name,
    required this.description,
    required this.jsonConfig,
  });
}

class _ComponentCard extends StatelessWidget {
  final ComponentExample example;

  const _ComponentCard({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Component name and description
          Text(
            example.name,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            example.description,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Component preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: _buildComponentPreview(),
            ),
          ),

          const SizedBox(height: 24),

          // JSON configuration
          const Text(
            'JSON Configuration:',
            style: TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _formatJson(example.jsonConfig),
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentPreview() {
    // Return simple visual representation
    // In a real implementation, this would render the actual component
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        '${example.name} Preview',
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}
