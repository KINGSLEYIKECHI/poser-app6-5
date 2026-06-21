import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Expense/Model/expense_modle.dart';

import '../../../Provider/transactions_provider.dart';
import '../Repo/expanse_repo.dart';

//---------income for duration--------------------------------

final expenseRepoProvider = Provider<ExpenseRepo>(
  (ref) => ExpenseRepo(),
);

final filteredExpenseProvider = FutureProvider.family.autoDispose<List<Expense>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(expenseRepoProvider);

    return repo.fetchAllIExpense(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);
