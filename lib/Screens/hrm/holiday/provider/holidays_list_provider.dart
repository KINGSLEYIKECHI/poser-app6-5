import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/department/model/department_list_model.dart';
import 'package:mobile_pos/Screens/hrm/department/repo/department_repo.dart';
import 'package:mobile_pos/Screens/hrm/holiday/model/holiday_list_model.dart';
import 'package:mobile_pos/Screens/hrm/holiday/repo/holiday_repo.dart';

final repo = HolidayRepo();
final holidayListProvider = FutureProvider<HolidayListModel>((ref) => repo.fetchAllHolidays());
