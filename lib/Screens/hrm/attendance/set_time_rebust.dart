// File: mobile_pos/Screens/hrm/widgets/set_time_robust.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RobustTimePicker {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // Force 12-hour format for consistency
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format time in a consistent way (English format)
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // Store in consistent English format
      final formattedTime = DateFormat('hh:mm a', 'en_US').format(dateTime);
      controller.text = formattedTime;
    }
  }

  // Helper method to parse time from any format
  static DateTime? parseTime(String timeString) {
    if (timeString.isEmpty) return null;

    timeString = timeString.trim();

    // Try different formats
    final List<DateFormat> formats = [
      DateFormat.jm(), // Current locale
      DateFormat('hh:mm a', 'en_US'),
      DateFormat('h:mm a', 'en_US'),
      DateFormat('HH:mm'),
      DateFormat('H:mm'),
    ];

    for (final format in formats) {
      try {
        return format.parse(timeString);
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  // Helper method to format time for display
  static String formatForDisplay(String timeString) {
    final dateTime = parseTime(timeString);
    if (dateTime != null) {
      return DateFormat('hh:mm a', 'en_US').format(dateTime);
    }
    return timeString;
  }
}
