// File: leave_type_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/leave_type_list_model.dart';
import '../repo/leave_type_repo.dart';

final repo = LeaveTypeRepo();
final leaveTypeListProvider = FutureProvider<LeaveTypeListModel>((ref) => repo.fetchAllLeaveTypes());
