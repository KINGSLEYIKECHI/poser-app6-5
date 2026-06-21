import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/due_collection_model.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/guest_due_model.dart';

import '../../../Provider/transactions_provider.dart';
import '../Model/due_collection_invoice_model.dart';
import '../Repo/due_repo.dart';

//------------dues-------------------------------------
final dueRepo = Provider<DueRepo>((ref) => DueRepo());

final dueCollectionListProvider = FutureProvider.autoDispose<List<DueCollection>>((ref) {
  final repo = ref.read(dueRepo);
  return repo.fetchDueCollectionList();
});

final filteredDueProvider = FutureProvider.family.autoDispose<List<DueCollection>, FilterModel>(
  (ref, filter) {
    final repo = ref.read(dueRepo);
    return repo.fetchDueCollectionList(
      type: filter.duration,
      fromDate: filter.fromDate,
      toDate: filter.toDate,
    );
  },
);

DueRepo repo = DueRepo();
final dueInvoiceListProvider =
    FutureProvider.autoDispose.family<DueCollectionInvoice, int>((ref, id) => repo.fetchDueInvoiceList(id: id));

final guestDueListProvider = FutureProvider.autoDispose<List<GuestDueModel>>((ref) {
  final repo = ref.read(dueRepo);
  return repo.fetchGuestDueList();
});
