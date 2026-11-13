import 'package:flutter/widgets.dart';

/// Style configuration for GuxFilePicker
class GuxFilePickerStyle {
  const GuxFilePickerStyle({
    this.backgroundColor = const Color(0xFF292929),
    this.textColor = const Color(0xFFE5E7EB),
    this.disabledColor = const Color(0xFF6B7280),
    this.borderColor = const Color(0xFF404040),
    this.hoverColor = const Color(0xFF333333),
    this.borderRadius = 4.0,
    this.borderWidth = 1.0,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color disabledColor;
  final Color borderColor;
  final Color hoverColor;
  final double borderRadius;
  final double borderWidth;
}

/// A file picker component for selecting files.
///
/// This is a trigger widget that represents file selection UI.
/// The actual file picking must be implemented by the host application
/// using platform-specific file picker APIs (e.g., file_picker package).
class GuxFilePicker extends StatefulWidget {
  const GuxFilePicker({
    super.key,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.placeholder = 'Choose file',
    this.allowMultiple = false,
    this.acceptedExtensions,
    this.style = const GuxFilePickerStyle(),
  });

  final ValueChanged<List<String>?>? onChanged;
  final List<String>? value;
  final bool enabled;
  final String placeholder;
  final bool allowMultiple;
  final List<String>? acceptedExtensions;
  final GuxFilePickerStyle style;

  @override
  State<GuxFilePicker> createState() => _GuxFilePickerState();
}

class _GuxFilePickerState extends State<GuxFilePicker> {
  bool _isHovered = false;

  bool get _isEnabled => widget.enabled && widget.onChanged != null;

  String _formatValue() {
    if (widget.value == null || widget.value!.isEmpty) {
      return widget.placeholder;
    }

    if (widget.value!.length == 1) {
      // Show just the filename, not the full path
      final path = widget.value!.first;
      final lastSlash = path.lastIndexOf('/');
      return lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
    }

    return '${widget.value!.length} files selected';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = !_isEnabled
        ? widget.style.disabledColor
        : (widget.value == null || widget.value!.isEmpty
            ? widget.style.disabledColor
            : widget.style.textColor);

    return MouseRegion(
      onEnter: _isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: _isEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _isEnabled ? _showFilePicker : null,
        child: Semantics(
          button: true,
          enabled: _isEnabled,
          label: widget.placeholder,
          value: _formatValue(),
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
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                Icon(
                  const IconData(0xe226, fontFamily: 'MaterialIcons'), // upload_file
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

  void _showFilePicker() {
    // This is a placeholder - actual file picking must be implemented
    // by the host application using platform-specific APIs.
    // The host would call widget.onChanged with the selected file paths.
    widget.onChanged?.call([]);
  }
}
