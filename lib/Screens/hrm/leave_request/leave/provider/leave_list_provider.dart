// File: leave_request_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/leave_list_model.dart';
import '../repo/leave_repo.dart';

final repo = LeaveRepo();
// This provider will fetch the list of all leave requests
final leaveRequestListProvider = FutureProvider<LeaveListModel>((ref) => repo.fetchAllLeaveRequests());
