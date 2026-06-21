import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Provider/transactions_provider.dart';
import '../Model/income_modle.dart';
import '../Repo/income_repo.dart';

final incomeRepoProvider = Provider<IncomeRepo>(
  (ref) => IncomeRepo(),
);

final filteredIncomeProvider = FutureProvider.family.autoDispose<List<Income>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(incomeRepoProvider);

    return repo.fetchAllIncome(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);
