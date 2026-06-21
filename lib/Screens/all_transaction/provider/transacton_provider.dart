import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/transaction_model.dart';
import '../repo/transaction_repo.dart';

final transactionRepoProvider = Provider<TransactionRepo>((ref) {
  return TransactionRepo();
});

// final filteredTransactionProvider = FutureProvider.family<TransactionModel, TransactionFilteredModel>(
//   (ref, filter) async {
//     final repo = ref.read(transactionRepoProvider);
//
//     return repo.fetchTransactionList(
//       duration: filter.duration,
//       fromDate: filter.fromDate,
//       toDate: filter.toDate,
//       platform: filter.transactionType == 'all_transaction' ? null : filter.transactionType,
//       partyId: filter.party == 'all_parties' ? null : int.tryParse(filter.party!),
//     );
//   },
// );

class TransactionFilteredModel {
  final String duration;
  final String? fromDate;
  final String? toDate;
  final String? transactionType;
  final String? party;

  const TransactionFilteredModel({
    required this.duration,
    this.fromDate,
    this.toDate,
    this.transactionType,
    this.party,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFilteredModel &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          fromDate == other.fromDate &&
          toDate == other.toDate &&
          transactionType == other.transactionType &&
          party == other.party;

  @override
  int get hashCode =>
      duration.hashCode ^ fromDate.hashCode ^ toDate.hashCode ^ transactionType.hashCode ^ party.hashCode;
}

final filteredTransactionProvider = FutureProvider.autoDispose.family<TransactionModel, TransactionFilteredModel>(
  (ref, filter) async {
    final repo = ref.read(transactionRepoProvider);

    // Convert party string to int if it's not "all_parties"
    int? partyId;
    if (filter.party != null && filter.party!.isNotEmpty && filter.party != 'all_parties') {
      partyId = int.tryParse(filter.party!);
    }

    return repo.fetchTransactionList(
      duration: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
      platform: filter.transactionType,
      partyId: partyId,
    );
  },
);
