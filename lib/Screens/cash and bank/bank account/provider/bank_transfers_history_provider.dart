// File: bank_transaction_history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/bank_transfer_history_model.dart';
import '../repo/bank_transfer_history_repo.dart';

final repo = BankTransactionHistoryRepo();

// Provider that takes bankId as a parameter (Family Provider)
final bankTransactionHistoryProvider = FutureProvider.autoDispose.family<TransactionHistoryListModel, num>((ref, bankId) {
  // Pass the bankId to the repository
  return repo.fetchHistory(bankId: bankId);
});
