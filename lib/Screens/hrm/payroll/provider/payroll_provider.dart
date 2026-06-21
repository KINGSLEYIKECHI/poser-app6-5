// File: payroll_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/payroll/repo/payroll_repo.dart';

import '../Model/payroll_lsit_model.dart';

final repo = PayrollRepo();
final payrollListProvider = FutureProvider<PayrollListModel>((ref) => repo.fetchAllPayrolls());
