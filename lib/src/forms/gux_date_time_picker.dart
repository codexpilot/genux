import 'package:flutter/services.dart';
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

/// Opens a host-provided date/time selector. Return null when cancelled.
typedef GuxDateTimeSelection = Future<DateTime?> Function(
  BuildContext context,
  DateTime? value,
  DateTimePickerMode mode,
  DateTime? minDate,
  DateTime? maxDate,
);

/// A date and time picker component.
///
/// Opens a built-in calendar and time selector in a [Navigator] by default.
/// Supply [selectDateTime] to use a host-specific selector instead. A value is
/// reported only after confirmation and within the inclusive instant bounds.
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
    this.selectDateTime,
    this.icon,
    this.labels = const GuxDateTimePickerLabels(),
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

  /// Host picker. Null results cancel without changing the value.
  final GuxDateTimeSelection? selectDateTime;

  /// Optional host-supplied decorative icon.
  final Widget? icon;

  /// Text used by the built-in picker, supplied by the host for localization.
  final GuxDateTimePickerLabels labels;

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
        final date =
            '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
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
        : (dateTime == null
              ? widget.style.disabledColor
              : widget.style.textColor);

    return MouseRegion(
      onEnter: _isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: _isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: FocusableActionDetector(
        enabled: _isEnabled,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _showPicker();
              return null;
            },
          ),
        },
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
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  if (widget.icon != null) widget.icon!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseBound(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    throw ArgumentError.value(
      value,
      'bound',
      'Expected DateTime or epoch milliseconds',
    );
  }

  bool _picking = false;
  Future<void> _showPicker() async {
    if (!_isEnabled || _picking) return;
    final minInput = widget.minDate;
    final maxInput = widget.maxDate;
    final min = _parseBound(minInput);
    final max = _parseBound(maxInput);
    if (min != null && max != null && min.isAfter(max)) {
      throw ArgumentError('minDate must not be after maxDate');
    }
    final selector = widget.selectDateTime;
    final currentValue = widget.value;
    setState(() => _picking = true);
    try {
      final selected = selector != null
          ? await selector(context, _dateTimeValue, widget.mode, min, max)
          : await _showBuiltInPicker(
              context,
              _dateTimeValue,
              widget.mode,
              min,
              max,
              widget.style,
              widget.labels,
              widget.use24HourFormat,
            );
      if (!mounted ||
          !_isEnabled ||
          widget.value != currentValue ||
          widget.selectDateTime != selector ||
          widget.minDate != minInput ||
          widget.maxDate != maxInput ||
          selected == null ||
          (min != null && selected.isBefore(min)) ||
          (max != null && selected.isAfter(max))) {
        return;
      }
      widget.onChanged!(
        currentValue is int ? selected.millisecondsSinceEpoch : selected,
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }
}

/// Mode for date/time picker
enum DateTimePickerMode { date, time, dateTime }

/// Localizable text used by the built-in date/time selector.
class GuxDateTimePickerLabels {
  const GuxDateTimePickerLabels({
    this.title = 'Choose date and time',
    this.cancel = 'Cancel',
    this.confirm = 'Confirm',
    this.previousMonth = 'Previous month',
    this.nextMonth = 'Next month',
    this.hour = 'Hour',
    this.minute = 'Minute',
    this.increaseHour = 'Increase hour',
    this.decreaseHour = 'Decrease hour',
    this.increaseMinute = 'Increase minute',
    this.decreaseMinute = 'Decrease minute',
    this.weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.firstWeekday = DateTime.monday,
  }) : assert(firstWeekday >= 1 && firstWeekday <= 7);

  final String title;
  final String cancel;
  final String confirm;
  final String previousMonth;
  final String nextMonth;
  final String hour;
  final String minute;
  final String increaseHour;
  final String decreaseHour;
  final String increaseMinute;
  final String decreaseMinute;

  /// Weekday labels in Monday-to-Sunday order.
  final List<String> weekdays;

  /// First day of week using [DateTime.monday] through [DateTime.sunday].
  final int firstWeekday;
}

Future<DateTime?> _showBuiltInPicker(
  BuildContext context,
  DateTime? value,
  DateTimePickerMode mode,
  DateTime? min,
  DateTime? max,
  GuxDateTimePickerStyle style,
  GuxDateTimePickerLabels labels,
  bool use24HourFormat,
) {
  if (labels.weekdays.length != 7) {
    throw ArgumentError('weekday labels must contain seven entries');
  }
  return showGeneralDialog<DateTime>(
    context: context,
    barrierLabel: labels.cancel,
    barrierDismissible: true,
    barrierColor: const Color(0x80000000),
    pageBuilder: (context, animation, secondaryAnimation) => _DateTimeDialog(
      value: value,
      mode: mode,
      min: min,
      max: max,
      style: style,
      labels: labels,
      use24HourFormat: use24HourFormat,
    ),
  );
}

class _DateTimeDialog extends StatefulWidget {
  const _DateTimeDialog({
    required this.value,
    required this.mode,
    required this.min,
    required this.max,
    required this.style,
    required this.labels,
    required this.use24HourFormat,
  });
  final DateTime? value;
  final DateTimePickerMode mode;
  final DateTime? min;
  final DateTime? max;
  final GuxDateTimePickerStyle style;
  final GuxDateTimePickerLabels labels;
  final bool use24HourFormat;
  @override
  State<_DateTimeDialog> createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<_DateTimeDialog> {
  late DateTime _selected;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _selected = _clamp(widget.value ?? DateTime.now());
    _month = _make(_selected.year, _selected.month, 1);
  }

  DateTime _clamp(DateTime value) {
    if (widget.min != null && value.isBefore(widget.min!)) return widget.min!;
    if (widget.max != null && value.isAfter(widget.max!)) return widget.max!;
    return value;
  }

  DateTime _make(int year, int month, int day, [int hour = 0, int minute = 0]) {
    return _selected.isUtc
        ? DateTime.utc(year, month, day, hour, minute)
        : DateTime(year, month, day, hour, minute);
  }

  bool _dayEnabled(DateTime day) {
    final end = _make(
      day.year,
      day.month,
      day.day + 1,
    ).subtract(const Duration(microseconds: 1));
    return (widget.min == null || !end.isBefore(widget.min!)) &&
        (widget.max == null || !day.isAfter(widget.max!));
  }

  void _chooseDay(DateTime day) {
    final value = _make(
      day.year,
      day.month,
      day.day,
      _selected.hour,
      _selected.minute,
    );
    setState(() => _selected = _clamp(value));
  }

  void _changeMonth(int delta) {
    setState(() => _month = _make(_month.year, _month.month + delta, 1));
  }

  bool _monthEnabled(int delta) {
    final month = _make(_month.year, _month.month + delta, 1);
    final end = _make(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(microseconds: 1));
    return (widget.min == null || !end.isBefore(widget.min!)) &&
        (widget.max == null || !month.isAfter(widget.max!));
  }

  void _changeTime(Duration delta) {
    setState(() => _selected = _clamp(_selected.add(delta)));
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final labels = widget.labels;
    final first = _make(_month.year, _month.month, 1);
    final offset = (first.weekday - labels.firstWeekday + 7) % 7;
    final count = _make(_month.year, _month.month + 1, 0).day;
    final hour = widget.use24HourFormat
        ? _selected.hour
        : (_selected.hour % 12 == 0 ? 12 : _selected.hour % 12);
    final period = widget.use24HourFormat
        ? ''
        : (_selected.hour >= 12 ? ' PM' : ' AM');
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).pop();
              return null;
            },
          ),
        },
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: labels.title,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 600,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    border: Border.all(
                      color: style.borderColor,
                      width: style.borderWidth,
                    ),
                    borderRadius: BorderRadius.circular(style.borderRadius),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(color: style.textColor, fontSize: 14),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(labels.title),
                            if (widget.mode != DateTimePickerMode.time) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _PickerButton(
                                    label: labels.previousMonth,
                                    text: '‹',
                                    style: style,
                                    onPressed: _monthEnabled(-1)
                                        ? () => _changeMonth(-1)
                                        : null,
                                  ),
                                  Text(
                                    '${_month.year}-${_month.month.toString().padLeft(2, '0')}',
                                  ),
                                  _PickerButton(
                                    label: labels.nextMonth,
                                    text: '›',
                                    style: style,
                                    onPressed: _monthEnabled(1)
                                        ? () => _changeMonth(1)
                                        : null,
                                  ),
                                ],
                              ),
                              Row(
                                children: List.generate(
                                  7,
                                  (index) => Expanded(
                                    child: Center(
                                      child: Text(
                                        labels.weekdays[(labels.firstWeekday -
                                                1 +
                                                index) %
                                            7],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      childAspectRatio: 1.1,
                                    ),
                                itemCount: offset + count,
                                itemBuilder: (context, index) {
                                  if (index < offset)
                                    return const SizedBox.shrink();
                                  final day = _make(
                                    _month.year,
                                    _month.month,
                                    index - offset + 1,
                                  );
                                  final selected =
                                      day.year == _selected.year &&
                                      day.month == _selected.month &&
                                      day.day == _selected.day;
                                  final label =
                                      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                                  return _PickerButton(
                                    label: label,
                                    text: '${day.day}',
                                    style: style,
                                    selected: selected,
                                    onPressed: _dayEnabled(day)
                                        ? () => _chooseDay(day)
                                        : null,
                                  );
                                },
                              ),
                            ],
                            if (widget.mode != DateTimePickerMode.date) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _PickerButton(
                                    label: labels.decreaseHour,
                                    text: '−',
                                    style: style,
                                    onPressed: () =>
                                        _changeTime(const Duration(hours: -1)),
                                  ),
                                  Semantics(
                                    label: labels.hour,
                                    value: '$hour$period',
                                    child: Text(
                                      hour.toString().padLeft(2, '0'),
                                    ),
                                  ),
                                  _PickerButton(
                                    label: labels.increaseHour,
                                    text: '+',
                                    style: style,
                                    onPressed: () =>
                                        _changeTime(const Duration(hours: 1)),
                                  ),
                                  const Text(':'),
                                  _PickerButton(
                                    label: labels.decreaseMinute,
                                    text: '−',
                                    style: style,
                                    onPressed: () => _changeTime(
                                      const Duration(minutes: -1),
                                    ),
                                  ),
                                  Semantics(
                                    label: labels.minute,
                                    value: '${_selected.minute}',
                                    child: Text(
                                      _selected.minute.toString().padLeft(
                                        2,
                                        '0',
                                      ),
                                    ),
                                  ),
                                  _PickerButton(
                                    label: labels.increaseMinute,
                                    text: '+',
                                    style: style,
                                    onPressed: () =>
                                        _changeTime(const Duration(minutes: 1)),
                                  ),
                                  if (period.isNotEmpty) Text(period),
                                ],
                              ),
                            ],
                            Wrap(
                              alignment: WrapAlignment.end,
                              children: [
                                _PickerButton(
                                  label: labels.cancel,
                                  text: labels.cancel,
                                  style: style,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                _PickerButton(
                                  label: labels.confirm,
                                  text: labels.confirm,
                                  style: style,
                                  onPressed: () =>
                                      Navigator.of(context).pop(_selected),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerButton extends StatefulWidget {
  const _PickerButton({
    required this.label,
    required this.text,
    required this.style,
    required this.onPressed,
    this.selected = false,
  });
  final String label;
  final String text;
  final GuxDateTimePickerStyle style;
  final VoidCallback? onPressed;
  final bool selected;
  @override
  State<_PickerButton> createState() => _PickerButtonState();
}

class _PickerButtonState extends State<_PickerButton> {
  final _focus = FocusNode();
  bool _highlight = false;
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: _focus,
      enabled: widget.onPressed != null,
      onShowFocusHighlight: (value) => setState(() => _highlight = value),
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        selected: widget.selected,
        label: widget.label,
        onTap: widget.onPressed,
        excludeSemantics: true,
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: widget.onPressed == null
              ? null
              : () {
                  _focus.requestFocus();
                  widget.onPressed!();
                },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected ? widget.style.selectedColor : null,
              border: _highlight
                  ? Border.all(color: widget.style.selectedColor, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.onPressed == null
                    ? widget.style.disabledColor
                    : widget.selected
                    ? widget.style.selectedTextColor
                    : widget.style.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
