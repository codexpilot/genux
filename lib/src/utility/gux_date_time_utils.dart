import 'package:flutter/widgets.dart';

/// Utility functions for date/time value conversion
class GuxDateTimeUtils {
  /// Convert a dynamic value (DateTime or int epoch ms) to DateTime
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Convert a dynamic value (DateTime or int epoch ms) to epoch milliseconds
  static int? toEpochMs(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    return null;
  }

  /// Convert DateTime to epoch milliseconds
  static int dateTimeToEpochMs(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// Convert epoch milliseconds to DateTime
  static DateTime epochMsToDateTime(int epochMs) {
    return DateTime.fromMillisecondsSinceEpoch(epochMs);
  }

  /// Check if a value is in epoch milliseconds format
  static bool isEpochMs(dynamic value) {
    return value is int;
  }

  /// Check if a value is in DateTime format
  static bool isDateTime(dynamic value) {
    return value is DateTime;
  }
}
