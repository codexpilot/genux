# Control Audit - 2026-11-12

Audit of recently added controls per P0 stabilization requirements. This documents the current state, not acceptance criteria compliance.

## Controls Audited

The following controls were checked for: test coverage, keyboard navigation, focus management, accessibility semantics, responsive layout, and lifecycle handling.

### GuxAccordion
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Has fromJson/toJson. Needs basic widget tests covering expand/collapse, keyboard (Space/Enter), focus indication, and accessibility semantics.

### GuxTabs
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Tab navigation typically requires arrow key support for switching between tabs and proper ARIA semantics.

### GuxSheet
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Sheet/modal components typically need Escape key handling, focus trapping, and proper dismiss behavior.

### GuxToast
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Toast notifications need accessibility announcements (assertive/polite), auto-dismiss timing, and optional dismiss buttons.

### GuxAlert
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Alert components typically need proper ARIA role (alert/alertdialog) and focus management for action buttons.

### GuxCard
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Cards are typically static layout components. If interactive (clickable), need keyboard activation and focus.

### GuxBadge
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Badges are typically decorative. If conveying status, need proper accessibility labels.

### GuxAvatar
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Avatars are typically decorative images. Need proper alt text/semantics if conveying user identity.

### GuxSeparator
- **Status**: Implementation exists
- **Test Coverage**: None
- **Keyboard Support**: Not verified (no tests)
- **Focus Management**: Not verified (no tests)
- **Accessibility**: Not verified (no tests)
- **Responsive Layout**: Not verified (no tests)
- **Notes**: Separators are static layout elements. Should have proper ARIA role (separator) for screen readers.

## Summary

**Current State:**
- 9 controls implemented without test coverage
- Keyboard navigation, focus management, and accessibility not verified for any audited control
- All controls have JSON serialization but no round-trip tests

**Recommendations:**
1. Prioritize interactive controls (Accordion, Tabs, Sheet, Alert, Toast) for immediate test coverage
2. Verify keyboard behavior matches patterns established in Slider/Switch/Radio (KeyEventResult.ignored for unhandled keys)
3. Add accessibility semantics appropriate to each control type
4. Document any platform-specific limitations (like TextField's context menu)
5. Test JSON round-trips for all controls
6. Add basic widget tests before claiming components are "complete"

**Component Matrix Status:**
The component matrix mentioned in the stabilization plan should mark these controls as "Partial - Implementation only, no test coverage" until verified.

## Next Steps

Per handover priorities:
1. Start with P0 stabilization of core controls (Slider, Switch, Radio) - COMPLETE
2. Complete P1 work: JSON contract consistency, color codec integration, registry ownership
3. Add test coverage for audited controls as part of basic component catalog work (05-basic-components.md)
4. Verify routing behavior for GuxApp/GuxScaffold
5. Complete accessibility testing for switch/radio groups with arrow-key navigation

This audit satisfies the P0 requirement to "record actual status in the component matrix; fix failures rather than extrapolating from class names."
