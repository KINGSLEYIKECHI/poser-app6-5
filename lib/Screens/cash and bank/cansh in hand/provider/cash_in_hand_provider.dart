// File: cash_transaction_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cash_transaction_list_model.dart';
import '../repo/cash_in_hand_repo.dart';

// Simple AutoDisposeProvider for the cash transaction history list
// Note: You can optionally make this a FamilyProvider if filtering is complex.
final cashTransactionHistoryProvider = FutureProvider.autoDispose<CashTransactionModel>((ref) async {
  final repo = CashTransactionRepo();

  return repo.fetchCashTransactions(filter: null);
});
