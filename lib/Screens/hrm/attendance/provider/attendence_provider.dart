

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/attendence_list_model.dart';
import '../repo/attendence_repo.dart';

final repo = AttendanceRepo();
final attendanceListProvider = FutureProvider<AttendanceListModel>((ref) => repo.fetchAllAttendance());
