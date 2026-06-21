Map<String, String> getPdfDateRangeForSelectedTime(
  String selectedTime, {
  DateTime? fromDate,
  DateTime? toDate,
}) {
  DateTime now = DateTime.now();
  DateTime start;
  DateTime end;

  switch (selectedTime.toLowerCase()) {
    case 'today':
      start = DateTime(now.year, now.month, now.day);
      end = start;
      break;
    case 'yesterday':
      start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      end = start;
      break;
    case 'last_seven_days':
      end = now;
      start = now.subtract(const Duration(days: 6));
      break;
    case 'last_thirty_days':
      end = now;
      start = now.subtract(const Duration(days: 29));
      break;
    case 'current_month':
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0);
      break;
    case 'last_month':
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      start = lastMonth;
      end = DateTime(lastMonth.year, lastMonth.month + 1, 0);
      break;
    case 'current_year':
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31);
      break;
    case 'custom_date':
      start = fromDate ?? now;
      end = toDate ?? now;
      break;
    default:
      start = now;
      end = now;
  }

  final fromStr = "${start.day.toString().padLeft(2, '0')}-"
      "${start.month.toString().padLeft(2, '0')}-"
      "${start.year}";
  final toStr = "${end.day.toString().padLeft(2, '0')}-"
      "${end.month.toString().padLeft(2, '0')}-"
      "${end.year}";

  return {'from': fromStr, 'to': toStr};
}
