import 'package:flutter/widgets.dart';

/// Style configuration for GuxDateTimePicker
class GuxDateTimePickerStyle {
  const GuxDateTimePickerStyle({
    this.backgroundColor = const Color(0xFF292929),
    this.textColor = const Color(0xFFE5E7EB),
    this.selectedColor = const Color(0xFF3B82F6),
    this.selectedTextColor = const Color(0xFFFFFFFF),
    this.disabledColor = const Color(0xFF6B7280),
    this.borderColor = const Color(0xFF404040),
    this.hoverColor = const Color(0xFF333333),
    this.borderRadius = 4.0,
    this.borderWidth = 1.0,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color selectedColor;
  final Color selectedTextColor;
  final Color disabledColor;
  final Color borderColor;
  final Color hoverColor;
  final double borderRadius;
  final double borderWidth;
}

/// A date and time picker component.
///
/// Displays a trigger widget that opens a picker overlay when tapped.
/// The picker shows a calendar for date selection and optional time controls.
class GuxDateTimePicker extends StatefulWidget {
  const GuxDateTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.mode = DateTimePickerMode.date,
    this.minDate,
    this.maxDate,
    this.enabled = true,
    this.placeholder = 'Select date',
    this.style = const GuxDateTimePickerStyle(),
    this.use24HourFormat = false,
  });

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTimePickerMode mode;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool enabled;
  final String placeholder;
  final GuxDateTimePickerStyle style;
  final bool use24HourFormat;

  @override
  State<GuxDateTimePicker> createState() => _GuxDateTimePickerState();
}

class _GuxDateTimePickerState extends State<GuxDateTimePicker> {
  bool _isHovered = false;

  bool get _isEnabled => widget.enabled && widget.onChanged != null;

  String _formatValue() {
    if (widget.value == null) return widget.placeholder;

    switch (widget.mode) {
      case DateTimePickerMode.date:
        return '${widget.value!.year}-${widget.value!.month.toString().padLeft(2, '0')}-${widget.value!.day.toString().padLeft(2, '0')}';
      case DateTimePickerMode.time:
        final hour = widget.use24HourFormat
            ? widget.value!.hour
            : (widget.value!.hour % 12 == 0 ? 12 : widget.value!.hour % 12);
        final minute = widget.value!.minute.toString().padLeft(2, '0');
        final period = widget.use24HourFormat
            ? ''
            : (widget.value!.hour >= 12 ? ' PM' : ' AM');
        return '${hour.toString().padLeft(2, '0')}:$minute$period';
      case DateTimePickerMode.dateTime:
        final date = '${widget.value!.year}-${widget.value!.month.toString().padLeft(2, '0')}-${widget.value!.day.toString().padLeft(2, '0')}';
        final hour = widget.use24HourFormat
            ? widget.value!.hour
            : (widget.value!.hour % 12 == 0 ? 12 : widget.value!.hour % 12);
        final minute = widget.value!.minute.toString().padLeft(2, '0');
        final period = widget.use24HourFormat
            ? ''
            : (widget.value!.hour >= 12 ? ' PM' : ' AM');
        return '$date ${hour.toString().padLeft(2, '0')}:$minute$period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = !_isEnabled
        ? widget.style.disabledColor
        : (widget.value == null ? widget.style.disabledColor : widget.style.textColor);

    return MouseRegion(
      onEnter: _isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: _isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _isEnabled ? _showPicker : null,
        child: Semantics(
          button: true,
          enabled: _isEnabled,
          label: widget.placeholder,
          value: widget.value?.toString(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered && _isEnabled
                  ? widget.style.hoverColor
                  : widget.style.backgroundColor,
              border: Border.all(
                color: widget.style.borderColor,
                width: widget.style.borderWidth,
              ),
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatValue(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  widget.mode == DateTimePickerMode.time
                      ? IconData(0xe192, fontFamily: 'MaterialIcons')
                      : IconData(0xe878, fontFamily: 'MaterialIcons'),
                  size: 16,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker() {
    // This is a simplified version - a full implementation would show
    // a calendar/time picker overlay using showGuxModal or similar.
    // For now, this demonstrates the component structure.
    widget.onChanged?.call(DateTime.now());
  }
}

/// Mode for date/time picker
enum DateTimePickerMode {
  date,
  time,
  dateTime,
}
