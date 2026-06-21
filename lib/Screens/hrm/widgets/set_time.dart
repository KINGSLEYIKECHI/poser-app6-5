// import 'package:flutter/material.dart';
//
// Future<void> setTime(TextEditingController controller, BuildContext context) async {
//   TimeOfDay initialTime = TimeOfDay.now();
//
//   if (controller.text.isNotEmpty) {
//     final timeParts = controller.text.split(' ');
//     final time = timeParts[0].split(':');
//     final period = timeParts[1];
//
//     int hour = int.parse(time[0]);
//     if (period == 'PM' && hour != 12) hour += 12;
//     if (period == 'AM' && hour == 12) hour = 0;
//
//     initialTime = TimeOfDay(hour: hour, minute: int.parse(time[1]));
//   }
//
//   final TimeOfDay? picked = await showTimePicker(
//     context: context,
//     initialTime: initialTime,
//     builder: (context, child) => MediaQuery(
//       data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//       child: child!,
//     ),
//   );
//
//   if (picked != null) {
//     final hours = picked.hourOfPeriod;
//     final minutes = picked.minute.toString().padLeft(2, '0');
//     final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
//     controller.text = '$hours:$minutes $period';
//   }
// }

import 'package:flutter/material.dart';

Future<void> setTime(TextEditingController controller, BuildContext context) async {
  TimeOfDay initialTime = TimeOfDay.now();

  if (controller.text.isNotEmpty) {
    final timeParts = controller.text.split(' ');
    final time = timeParts[0].split(':');
    final period = timeParts.length > 1 ? timeParts[1] : '';

    int hour = int.parse(time[0]);
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    initialTime = TimeOfDay(hour: hour, minute: int.parse(time[1]));
  }

  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      final theme = Theme.of(context);
      return Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: theme.colorScheme.primary, // active selection color
            onPrimary: Colors.white, // text color on primary (e.g., white text)
            surface: theme.colorScheme.surface, // dialog background
            onSurface: theme.colorScheme.onSurface, // default text color
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: theme.dialogBackgroundColor,
            hourMinuteTextColor: theme.colorScheme.onSurface,
            dialBackgroundColor: theme.colorScheme.surfaceVariant,
            dialHandColor: theme.colorScheme.primary,
          ),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        ),
      );
    },
  );

  if (picked != null) {
    final hours = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final minutes = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    controller.text = '$hours:$minutes $period';
  }
}
