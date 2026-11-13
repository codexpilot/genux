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
///
/// Accepts values as either DateTime objects or epoch milliseconds (int).
/// Returns values in the same format as provided via onChanged callback.
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

  /// The current value as either DateTime or int (epoch milliseconds)
  final dynamic value;

  /// Callback that receives either DateTime or int based on input type
  final ValueChanged<dynamic>? onChanged;

  final DateTimePickerMode mode;

  /// Min/max dates accept either DateTime or int (epoch milliseconds)
  final dynamic minDate;
  final dynamic maxDate;

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

  /// Convert value to DateTime for internal use
  DateTime? get _dateTimeValue {
    if (widget.value == null) return null;
    if (widget.value is DateTime) return widget.value as DateTime;
    if (widget.value is int) {
      return DateTime.fromMillisecondsSinceEpoch(widget.value as int);
    }
    return null;
  }

  String _formatValue() {
    final dateTime = _dateTimeValue;
    if (dateTime == null) return widget.placeholder;

    switch (widget.mode) {
      case DateTimePickerMode.date:
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      case DateTimePickerMode.time:
        final hour = widget.use24HourFormat
            ? dateTime.hour
            : (dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12);
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = widget.use24HourFormat
            ? ''
            : (dateTime.hour >= 12 ? ' PM' : ' AM');
        return '${hour.toString().padLeft(2, '0')}:$minute$period';
      case DateTimePickerMode.dateTime:
        final date = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
        final hour = widget.use24HourFormat
            ? dateTime.hour
            : (dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12);
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = widget.use24HourFormat
            ? ''
            : (dateTime.hour >= 12 ? ' PM' : ' AM');
        return '$date ${hour.toString().padLeft(2, '0')}:$minute$period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = _dateTimeValue;
    final textColor = !_isEnabled
        ? widget.style.disabledColor
        : (dateTime == null ? widget.style.disabledColor : widget.style.textColor);

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
          value: dateTime?.toString(),
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
    final now = DateTime.now();

    // Return value in same format as input
    if (widget.value is int) {
      widget.onChanged?.call(now.millisecondsSinceEpoch);
    } else {
      widget.onChanged?.call(now);
    }
  }
}

/// Mode for date/time picker
enum DateTimePickerMode {
  date,
  time,
  dateTime,
}
