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

import 'package:a2ui_core/a2ui_core.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// A2UI catalog registration for all Genux components.
///
/// This catalog makes Genux widgets available to A2UI agents for
/// dynamic UI generation. Each component is registered with its JSON schema
/// and can be instantiated from JSON at runtime.
///
/// Example usage:
/// ```dart
/// import 'package:a2ui_core/a2ui_core.dart';
/// import 'package:genux/genux.dart';
///
/// final catalog = GuxCatalog.v1_0();
/// // Use catalog with A2UI renderer
/// ```
abstract final class GuxCatalog {
  /// The catalog ID for Genux v1.0
  static const String v1_0Id = 'https://aix.dev/genux/v1/catalog.json';

  /// Creates the v1.0 Genux catalog for A2UI.
  ///
  /// This catalog includes all 23 Genux components with their JSON schemas
  /// and is compatible with A2UI protocol v1.0.
  static CatalogApi v1_0() {
    return Catalog(
      id: v1_0Id,
      components: [
        _guxAppComponent(),
        _guxButtonComponent(),
        _guxCheckboxComponent(),
        _guxDialogComponent(),
        _guxDropdownComponent(),
        _guxNavigationComponent(),
        _guxProgressIndicatorComponent(),
        _guxTextFieldComponent(),
        _guxTextInputComponent(),
        _guxToggleComponent(),
        _guxWorkspaceScaffoldComponent(),
        _guxCardComponent(),
        _guxBadgeComponent(),
        _guxAvatarComponent(),
        _guxAccordionComponent(),
        _guxTabsComponent(),
        _guxSheetComponent(),
        _guxToastComponent(),
        _guxAlertComponent(),
        _guxSeparatorComponent(),
        _guxSwitchComponent(),
        _guxRadioComponent(),
        _guxSliderComponent(),
      ],
      title: 'Genux Widget Catalog',
      description: 'A2UI-compatible Flutter widgets for AIX applications',
      protocolVersion: A2uiProtocolVersion.v1_0,
    );
  }

  // Component definitions

  static ComponentApi _guxAppComponent() {
    return ComponentApi(
      name: 'GuxApp',
      schema: Schema.object(
        properties: {
          'title': Schema.string(
            description: 'Application title',
          ),
          'color': Schema.string(
            description: 'Primary color (hex format #RRGGBB)',
          ),
          'home': Schema.object(
            description: 'Home widget component',
          ),
        },
        required: ['title', 'color', 'home'],
        description: 'Application root widget wrapping WidgetsApp',
      ),
    );
  }

  static ComponentApi _guxButtonComponent() {
    return ComponentApi(
      name: 'GuxButton',
      schema: Schema.object(
        properties: {
          'style': Schema.object(
            description: 'Button visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'foregroundColor': Schema.string(
                description: 'Text/icon color (hex format)',
              ),
              'borderRadius': Schema.number(
                description: 'Corner radius in pixels',
              ),
              'padding': Schema.object(
                properties: {
                  'horizontal': Schema.number(),
                  'vertical': Schema.number(),
                },
              ),
            },
          ),
          'child': Schema.object(
            description: 'Button content widget',
          ),
          'onPressed': Schema.string(
            description: 'Action handler reference',
          ),
        },
        required: ['style', 'child'],
        description: 'Accessible button with customizable styling',
      ),
    );
  }

  static ComponentApi _guxCheckboxComponent() {
    return ComponentApi(
      name: 'GuxCheckbox',
      schema: Schema.object(
        properties: {
          'value': Schema.boolean(
            description: 'Checked state',
          ),
          'onChanged': Schema.string(
            description: 'Action handler reference',
          ),
          'tristate': Schema.boolean(
            description: 'Whether to allow null (indeterminate) state',
          ),
        },
        required: ['value'],
        description: 'Checkbox control with optional tristate support',
      ),
    );
  }

  static ComponentApi _guxDialogComponent() {
    return ComponentApi(
      name: 'GuxDialog',
      schema: Schema.object(
        properties: {
          'title': Schema.string(
            description: 'Dialog title text',
          ),
          'content': Schema.object(
            description: 'Dialog body widget',
          ),
          'actions': Schema.object(
            description: 'Dialog action buttons',
            properties: {
              'type': Schema.string(),
              'items': Schema.object(),
            },
          ),
          'style': Schema.object(
            description: 'Dialog visual styling',
          ),
        },
        required: ['title', 'content'],
        description: 'Modal dialog with title, content, and actions',
      ),
    );
  }

  static ComponentApi _guxDropdownComponent() {
    return ComponentApi(
      name: 'GuxDropdown',
      schema: Schema.object(
        properties: {
          'options': Schema.object(
            description: 'Dropdown options',
            properties: {
              'type': Schema.string(),
              'items': Schema.object(
                properties: {
                  'value': Schema.string(),
                  'label': Schema.string(),
                },
                required: ['value', 'label'],
              ),
            },
          ),
          'value': Schema.string(
            description: 'Currently selected value',
          ),
          'onChanged': Schema.string(
            description: 'Action handler reference',
          ),
          'style': Schema.object(
            description: 'Dropdown visual styling',
          ),
        },
        required: ['options'],
        description: 'Dropdown selector with customizable options',
      ),
    );
  }

  static ComponentApi _guxNavigationComponent() {
    return ComponentApi(
      name: 'GuxNavigation',
      schema: Schema.object(
        properties: {
          'items': Schema.object(
            description: 'Navigation items',
            properties: {
              'type': Schema.string(),
              'items': Schema.object(
                properties: {
                  'label': Schema.string(),
                  'icon': Schema.string(),
                  'onTap': Schema.string(),
                },
                required: ['label'],
              ),
            },
          ),
          'selectedIndex': Schema.integer(
            description: 'Currently selected item index',
          ),
          'style': Schema.object(
            description: 'Navigation rail visual styling',
          ),
        },
        required: ['items'],
        description: 'Navigation rail for app navigation',
      ),
    );
  }

  static ComponentApi _guxProgressIndicatorComponent() {
    return ComponentApi(
      name: 'GuxProgressIndicator',
      schema: Schema.object(
        properties: {
          'value': Schema.number(
            description: 'Progress value (0.0 to 1.0, null for indeterminate)',
          ),
          'style': Schema.object(
            description: 'Progress indicator styling',
            properties: {
              'color': Schema.string(),
              'backgroundColor': Schema.string(),
              'strokeWidth': Schema.number(),
            },
          ),
        },
        description: 'Linear or circular progress indicator',
      ),
    );
  }

  static ComponentApi _guxTextFieldComponent() {
    return ComponentApi(
      name: 'GuxTextField',
      schema: Schema.object(
        properties: {
          'label': Schema.string(
            description: 'Field label',
          ),
          'value': Schema.string(
            description: 'Current text value',
          ),
          'placeholder': Schema.string(
            description: 'Placeholder text',
          ),
          'maxLines': Schema.integer(
            description: 'Maximum number of lines',
          ),
          'onChanged': Schema.string(
            description: 'Action handler reference',
          ),
        },
        description: 'Multi-line text input field',
      ),
    );
  }

  static ComponentApi _guxTextInputComponent() {
    return ComponentApi(
      name: 'GuxTextInput',
      schema: Schema.object(
        properties: {
          'label': Schema.string(
            description: 'Input label',
          ),
          'value': Schema.string(
            description: 'Current text value',
          ),
          'placeholder': Schema.string(
            description: 'Placeholder text',
          ),
          'errorMessage': Schema.string(
            description: 'Validation error message',
          ),
          'obscureText': Schema.boolean(
            description: 'Whether to hide text (for passwords)',
          ),
          'onChanged': Schema.string(
            description: 'Action handler reference',
          ),
        },
        description: 'Single-line text input with validation support',
      ),
    );
  }

  static ComponentApi _guxToggleComponent() {
    return ComponentApi(
      name: 'GuxToggle',
      schema: Schema.object(
        properties: {
          'value': Schema.boolean(
            description: 'Toggle state (on/off)',
          ),
          'onChanged': Schema.string(
            description: 'Action handler reference',
          ),
        },
        required: ['value'],
        description: 'Toggle switch control',
      ),
    );
  }

  static ComponentApi _guxWorkspaceScaffoldComponent() {
    return ComponentApi(
      name: 'GuxWorkspaceScaffold',
      schema: Schema.object(
        properties: {
          'navigation': Schema.object(
            description: 'Navigation rail widget',
          ),
          'body': Schema.object(
            description: 'Main content area widget',
          ),
          'style': Schema.object(
            description: 'Scaffold visual styling',
          ),
        },
        required: ['body'],
        description: 'Workspace layout with optional navigation rail',
      ),
    );
  }

  static ComponentApi _guxCardComponent() {
    return ComponentApi(
      name: 'GuxCard',
      schema: Schema.object(
        properties: {
          'style': Schema.object(
            description: 'Card visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'borderColor': Schema.string(
                description: 'Border color (hex format)',
              ),
              'borderWidth': Schema.number(
                description: 'Border width in pixels',
              ),
              'borderRadius': Schema.number(
                description: 'Corner radius in pixels',
              ),
              'padding': Schema.object(
                properties: {
                  'left': Schema.number(),
                  'top': Schema.number(),
                  'right': Schema.number(),
                  'bottom': Schema.number(),
                },
              ),
              'elevation': Schema.number(
                description: 'Shadow elevation',
              ),
              'shadowColor': Schema.string(
                description: 'Shadow color (hex format)',
              ),
            },
          ),
          'child': Schema.object(
            description: 'Child widget to display inside the card',
          ),
        },
        required: ['style', 'child'],
        description: 'Card container with border, padding, and optional shadow',
      ),
    );
  }

  static ComponentApi _guxBadgeComponent() {
    return ComponentApi(
      name: 'GuxBadge',
      schema: Schema.object(
        properties: {
          'label': Schema.string(
            description: 'Text label to display',
          ),
          'style': Schema.object(
            description: 'Badge visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'textColor': Schema.string(
                description: 'Text color (hex format)',
              ),
              'borderColor': Schema.string(
                description: 'Border color (hex format)',
              ),
              'borderWidth': Schema.number(
                description: 'Border width in pixels',
              ),
              'borderRadius': Schema.number(
                description: 'Corner radius in pixels',
              ),
              'padding': Schema.object(
                properties: {
                  'horizontal': Schema.number(),
                  'vertical': Schema.number(),
                },
              ),
              'fontSize': Schema.number(),
              'fontWeight': Schema.string(),
            },
          ),
        },
        required: ['label', 'style'],
        description: 'Small badge label for displaying status, count, or category',
      ),
    );
  }

  static ComponentApi _guxAvatarComponent() {
    return ComponentApi(
      name: 'GuxAvatar',
      schema: Schema.object(
        properties: {
          'initials': Schema.string(
            description: 'User initials to display',
          ),
          'imageUrl': Schema.string(
            description: 'Optional image URL',
          ),
          'style': Schema.object(
            description: 'Avatar visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'textColor': Schema.string(
                description: 'Text color for initials (hex format)',
              ),
              'borderColor': Schema.string(
                description: 'Border color (hex format)',
              ),
              'borderWidth': Schema.number(
                description: 'Border width in pixels',
              ),
              'size': Schema.number(
                description: 'Avatar size (width and height)',
              ),
              'fontSize': Schema.number(),
              'fontWeight': Schema.string(),
            },
          ),
        },
        required: ['style'],
        description: 'Circular avatar displaying initials or an image',
      ),
    );
  }

  static ComponentApi _guxAccordionComponent() {
    return ComponentApi(
      name: 'GuxAccordion',
      schema: Schema.object(
        properties: {
          'title': Schema.string(
            description: 'Title text displayed in the header',
          ),
          'content': Schema.object(
            description: 'Content widget shown when expanded',
          ),
          'initiallyExpanded': Schema.boolean(
            description: 'Whether the accordion starts expanded',
          ),
          'style': Schema.object(
            description: 'Accordion visual styling',
            properties: {
              'backgroundColor': Schema.string(),
              'expandedBackgroundColor': Schema.string(),
              'borderColor': Schema.string(),
              'borderWidth': Schema.number(),
              'borderRadius': Schema.number(),
              'headerPadding': Schema.object(),
              'contentPadding': Schema.object(),
              'headerTextColor': Schema.string(),
              'headerFontSize': Schema.number(),
              'contentTextColor': Schema.string(),
              'iconColor': Schema.string(),
            },
          ),
        },
        required: ['title', 'content', 'style'],
        description: 'Collapsible content section with expand/collapse functionality',
      ),
    );
  }

  static ComponentApi _guxTabsComponent() {
    return ComponentApi(
      name: 'GuxTabs',
      schema: Schema.object(
        properties: {
          'tabs': Schema.object(
            description: 'List of tab definitions',
            properties: {
              'type': Schema.string(),
              'items': Schema.object(
                properties: {
                  'id': Schema.string(),
                  'label': Schema.string(),
                  'icon': Schema.string(),
                },
                required: ['id', 'label'],
              ),
            },
          ),
          'initialTabId': Schema.string(
            description: 'Initially selected tab ID',
          ),
          'style': Schema.object(
            description: 'Tabs visual styling',
            properties: {
              'backgroundColor': Schema.string(),
              'activeTabColor': Schema.string(),
              'inactiveTabColor': Schema.string(),
              'activeTextColor': Schema.string(),
              'inactiveTextColor': Schema.string(),
              'borderRadius': Schema.number(),
              'tabBarHeight': Schema.number(),
            },
          ),
          'children': Schema.object(
            description: 'Content widgets for each tab',
          ),
        },
        required: ['tabs', 'style', 'children'],
        description: 'Tabbed interface for switching between panels',
      ),
    );
  }

  static ComponentApi _guxSheetComponent() {
    return ComponentApi(
      name: 'GuxSheet',
      schema: Schema.object(
        properties: {
          'style': Schema.object(
            description: 'Sheet visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'borderColor': Schema.string(
                description: 'Border color (hex format)',
              ),
              'borderWidth': Schema.number(
                description: 'Border width in pixels',
              ),
              'borderRadius': Schema.number(
                description: 'Corner radius for top corners',
              ),
              'padding': Schema.object(),
              'elevation': Schema.number(
                description: 'Shadow elevation',
              ),
              'shadowColor': Schema.string(),
              'maxHeightFraction': Schema.number(
                description: 'Maximum height as fraction of screen',
              ),
            },
          ),
          'child': Schema.object(
            description: 'Child widget to display inside the sheet',
          ),
        },
        required: ['style', 'child'],
        description: 'Modal bottom sheet that slides up from the bottom',
      ),
    );
  }

  static ComponentApi _guxToastComponent() {
    return ComponentApi(
      name: 'GuxToast',
      schema: Schema.object(
        properties: {
          'message': Schema.string(
            description: 'Message text to display',
          ),
          'style': Schema.object(
            description: 'Toast visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'textColor': Schema.string(
                description: 'Text color (hex format)',
              ),
              'borderColor': Schema.string(),
              'borderWidth': Schema.number(),
              'borderRadius': Schema.number(),
              'padding': Schema.object(),
              'fontSize': Schema.number(),
              'fontWeight': Schema.string(),
              'elevation': Schema.number(),
              'shadowColor': Schema.string(),
            },
          ),
        },
        required: ['message', 'style'],
        description: 'Temporary notification message displayed as a toast',
      ),
    );
  }

  static ComponentApi _guxAlertComponent() {
    return ComponentApi(
      name: 'GuxAlert',
      schema: Schema.object(
        properties: {
          'message': Schema.string(
            description: 'The message text to display',
          ),
          'title': Schema.string(
            description: 'Optional title text',
          ),
          'style': Schema.object(
            description: 'Alert visual styling',
            properties: {
              'backgroundColor': Schema.string(
                description: 'Background color (hex format)',
              ),
              'textColor': Schema.string(
                description: 'Text color (hex format)',
              ),
              'borderColor': Schema.string(),
              'borderWidth': Schema.number(),
              'borderRadius': Schema.number(),
              'padding': Schema.object(),
              'fontSize': Schema.number(),
              'fontWeight': Schema.string(),
              'iconColor': Schema.string(),
              'iconSize': Schema.number(),
            },
          ),
        },
        required: ['message', 'style'],
        description: 'Prominent message box for displaying important information',
      ),
    );
  }

  static ComponentApi _guxSeparatorComponent() {
    return ComponentApi(
      name: 'GuxSeparator',
      schema: Schema.object(
        properties: {
          'style': Schema.object(
            description: 'Separator visual styling',
            properties: {
              'color': Schema.string(
                description: 'Color of the separator line (hex format)',
              ),
              'thickness': Schema.number(
                description: 'Thickness in pixels',
              ),
              'spacing': Schema.number(
                description: 'Spacing around the separator',
              ),
              'orientation': Schema.string(
                description: 'horizontal or vertical',
              ),
            },
          ),
        },
        required: ['style'],
        description: 'Visual divider between sections',
      ),
    );
  }

  static ComponentApi _guxSwitchComponent() {
    return ComponentApi(
      name: 'GuxSwitch',
      schema: Schema.object(
        properties: {
          'value': Schema.boolean(
            description: 'Current state of the switch',
          ),
          'style': Schema.object(
            description: 'Switch visual styling',
            properties: {
              'offColor': Schema.string(
                description: 'Background color when off (hex format)',
              ),
              'onColor': Schema.string(
                description: 'Background color when on (hex format)',
              ),
              'thumbColor': Schema.string(
                description: 'Thumb color (hex format)',
              ),
              'borderColor': Schema.string(),
              'borderWidth': Schema.number(),
              'borderRadius': Schema.number(),
              'width': Schema.number(),
              'height': Schema.number(),
              'thumbSize': Schema.number(),
              'thumbPadding': Schema.number(),
            },
          ),
          'action': Schema.string(
            description: 'Action handler reference',
          ),
        },
        required: ['value', 'style'],
        description: 'Toggle switch for on/off state',
      ),
    );
  }

  static ComponentApi _guxRadioComponent() {
    return ComponentApi(
      name: 'GuxRadio',
      schema: Schema.object(
        properties: {
          'value': Schema.string(
            description: 'The value represented by this radio button',
          ),
          'groupValue': Schema.string(
            description: 'The currently selected value for the radio group',
          ),
          'style': Schema.object(
            description: 'Radio button visual styling',
            properties: {
              'borderColor': Schema.string(
                description: 'Border color when unchecked (hex format)',
              ),
              'checkedColor': Schema.string(
                description: 'Background color when checked (hex format)',
              ),
              'dotColor': Schema.string(
                description: 'Inner dot color when checked (hex format)',
              ),
              'borderWidth': Schema.number(),
              'size': Schema.number(
                description: 'Size of the radio button',
              ),
              'dotSize': Schema.number(),
            },
          ),
        },
        required: ['value', 'groupValue', 'style'],
        description: 'Radio button for selecting one option from a group',
      ),
    );
  }

  static ComponentApi _guxSliderComponent() {
    return ComponentApi(
      name: 'GuxSlider',
      schema: Schema.object(
        properties: {
          'value': Schema.number(
            description: 'Current value of the slider',
          ),
          'min': Schema.number(
            description: 'Minimum value',
          ),
          'max': Schema.number(
            description: 'Maximum value',
          ),
          'style': Schema.object(
            description: 'Slider visual styling',
            properties: {
              'trackColor': Schema.string(
                description: 'Track color (hex format)',
              ),
              'activeTrackColor': Schema.string(
                description: 'Active track color (hex format)',
              ),
              'thumbColor': Schema.string(
                description: 'Thumb color (hex format)',
              ),
              'trackHeight': Schema.number(),
              'thumbSize': Schema.number(),
              'borderRadius': Schema.number(),
            },
          ),
        },
        required: ['value', 'style'],
        description: 'Slider for selecting a value from a range',
      ),
    );
  }
}
