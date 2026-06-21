import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/department/model/department_list_model.dart';
import 'package:mobile_pos/Screens/hrm/department/repo/department_repo.dart';

DepartmentRepo repo = DepartmentRepo();
final departmentListProvider = FutureProvider<DepartmentListModel>((ref) => repo.fetchAllDepartments());
