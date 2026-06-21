import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/department/model/department_list_model.dart';
import 'package:mobile_pos/Screens/hrm/department/repo/department_repo.dart';
import 'package:mobile_pos/Screens/hrm/shift/Model/shift_list_model.dart';
import 'package:mobile_pos/Screens/hrm/shift/repo/shift_repo.dart';

ShiftRepo repo = ShiftRepo();
final shiftListProvider = FutureProvider<ShiftListModel>((ref) => repo.fetchAllShifts());
