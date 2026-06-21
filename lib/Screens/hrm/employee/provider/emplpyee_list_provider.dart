import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/employee/model/employee_list_model.dart';
import 'package:mobile_pos/Screens/hrm/employee/repo/employee_repo.dart';

final repo = EmployeeRepo();
final employeeListProvider = FutureProvider<EmployeeListModel>((ref) => repo.fetchAllEmployee());
