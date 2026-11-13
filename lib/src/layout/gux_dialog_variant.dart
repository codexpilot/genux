import 'package:flutter/widgets.dart';
import '../forms/gux_button.dart';

/// Dialog variant types
enum DialogVariantType {
  alert,
  confirm,
  info,
}

/// Style configuration for dialog variants
class GuxDialogVariantStyle {
  const GuxDialogVariantStyle({
    this.alertColor = const Color(0xFFEF4444),
    this.confirmColor = const Color(0xFF3B82F6),
    this.infoColor = const Color(0xFF10B981),
    this.iconSize = 24.0,
  });

  final Color alertColor;
  final Color confirmColor;
  final Color infoColor;
  final double iconSize;
}

/// A specialized dialog with predefined layouts for common patterns.
///
/// Provides three variants:
/// - alert: Warning/error dialog with destructive action
/// - confirm: Yes/no confirmation dialog
/// - info: Informational dialog with single dismiss action
class GuxDialogVariant extends StatelessWidget {
  const GuxDialogVariant({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.backgroundColor = const Color(0xFF252525),
    this.padding = const EdgeInsets.all(24),
    this.style = const GuxDialogVariantStyle(),
  });

  final DialogVariantType type;
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final GuxDialogVariantStyle style;

  Color get _iconColor {
    switch (type) {
      case DialogVariantType.alert:
        return style.alertColor;
      case DialogVariantType.confirm:
        return style.confirmColor;
      case DialogVariantType.info:
        return style.infoColor;
    }
  }

  IconData get _icon {
    switch (type) {
      case DialogVariantType.alert:
        return const IconData(0xe002, fontFamily: 'MaterialIcons'); // error
      case DialogVariantType.confirm:
        return const IconData(0xe8fd, fontFamily: 'MaterialIcons'); // help
      case DialogVariantType.info:
        return const IconData(0xe88e, fontFamily: 'MaterialIcons'); // info
    }
  }

  String get _defaultConfirmLabel {
    switch (type) {
      case DialogVariantType.alert:
        return 'OK';
      case DialogVariantType.confirm:
        return 'Confirm';
      case DialogVariantType.info:
        return 'OK';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon and title row
              Row(
                children: [
                  Icon(
                    _icon,
                    size: style.iconSize,
                    color: _iconColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (type == DialogVariantType.confirm && onCancel != null) ...[
                    GuxButton(
                      onPressed: onCancel,
                      style: GuxButtonStyle(
                        backgroundColor: const Color(0xFF374151),
                        hoverColor: const Color(0xFF4B5563),
                        pressedColor: const Color(0xFF1F2937),
                        disabledColor: const Color(0xFF6B7280),
                        foregroundColor: const Color(0xFFFFFFFF),
                        disabledForegroundColor: const Color(0xFF9CA3AF),
                      ),
                      child: Text(cancelLabel ?? 'Cancel'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GuxButton(
                    onPressed: onConfirm,
                    style: GuxButtonStyle(
                      backgroundColor: _iconColor,
                      hoverColor: Color.alphaBlend(
                        const Color(0x1AFFFFFF),
                        _iconColor,
                      ),
                      pressedColor: Color.alphaBlend(
                        const Color(0x33000000),
                        _iconColor,
                      ),
                      disabledColor: const Color(0xFF6B7280),
                      foregroundColor: const Color(0xFFFFFFFF),
                      disabledForegroundColor: const Color(0xFF9CA3AF),
                    ),
                    child: Text(confirmLabel ?? _defaultConfirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows an alert dialog with a warning/error message
Future<bool?> showGuxAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String barrierLabel = 'Alert',
}) {
  return showGeneralDialog<bool>(
    context: context,
    pageBuilder: (context, _, __) {
      return GuxDialogVariant(
        type: DialogVariantType.alert,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(context).pop(true),
      );
    },
    barrierDismissible: false,
    barrierLabel: barrierLabel,
    barrierColor: const Color(0x80000000),
    transitionDuration: const Duration(milliseconds: 150),
  );
}

/// Shows a confirmation dialog with confirm/cancel actions
Future<bool?> showGuxConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  String barrierLabel = 'Confirm',
}) {
  return showGeneralDialog<bool>(
    context: context,
    pageBuilder: (context, _, __) {
      return GuxDialogVariant(
        type: DialogVariantType.confirm,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      );
    },
    barrierDismissible: true,
    barrierLabel: barrierLabel,
    barrierColor: const Color(0x80000000),
    transitionDuration: const Duration(milliseconds: 150),
  );
}

/// Shows an info dialog with informational message
Future<bool?> showGuxInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String barrierLabel = 'Info',
}) {
  return showGeneralDialog<bool>(
    context: context,
    pageBuilder: (context, _, __) {
      return GuxDialogVariant(
        type: DialogVariantType.info,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: () => Navigator.of(context).pop(true),
      );
    },
    barrierDismissible: true,
    barrierLabel: barrierLabel,
    barrierColor: const Color(0x80000000),
    transitionDuration: const Duration(milliseconds: 150),
  );
}
