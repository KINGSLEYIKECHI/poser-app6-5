import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/party%20ledger/repo/party_ledger_repo.dart';
import 'model/party_leder_filer_param.dart';
import 'model/party_ledger_model.dart';

// State Class
class LedgerState {
  final List<PartyLedgerModel> transactions;
  final bool isLoading;
  final bool isLoadMoreRunning;
  final int page;
  final bool hasMoreData;
  final String currentFilter;

  LedgerState({
    this.transactions = const [],
    this.isLoading = true,
    this.isLoadMoreRunning = false,
    this.page = 1,
    this.hasMoreData = true,
    this.currentFilter = 'All',
  });

  LedgerState copyWith({
    List<PartyLedgerModel>? transactions,
    bool? isLoading,
    bool? isLoadMoreRunning,
    int? page,
    bool? hasMoreData,
    String? currentFilter,
  }) {
    return LedgerState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadMoreRunning: isLoadMoreRunning ?? this.isLoadMoreRunning,
      page: page ?? this.page,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

// Notifier
// class PartyLedgerNotifier extends StateNotifier<LedgerState> {
//   final PartyLedgerRepo _repository = PartyLedgerRepo();
//   final String partyId;
//
//   PartyLedgerNotifier(this.partyId) : super(LedgerState()) {
//     loadInitialData();
//   }
//
//   // 1. Load Initial Data (Page 1)
//   Future<void> loadInitialData() async {
//     try {
//       state = state.copyWith(isLoading: true);
//       final response = await _repository.getPartyLedger(partyId: partyId, page: 1, duration: state.currentFilter // Pass the filter
//           );
//
//       state = state.copyWith(
//         transactions: response.data,
//         isLoading: false,
//         page: 1,
//         hasMoreData: response.currentPage < response.lastPage,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, hasMoreData: false);
//       print("Error loading ledger: $e");
//     }
//   }
//
//   // 2. Load More (Infinite Scroll)
//   Future<void> loadMore() async {
//     if (state.isLoadMoreRunning || !state.hasMoreData) return;
//
//     state = state.copyWith(isLoadMoreRunning: true);
//
//     try {
//       final nextPage = state.page + 1;
//       final response = await _repository.getPartyLedger(partyId: partyId, page: nextPage, duration: state.currentFilter // Keep using current filter
//           );
//
//       state = state.copyWith(
//         transactions: [...state.transactions, ...response.data],
//         page: nextPage,
//         isLoadMoreRunning: false,
//         hasMoreData: response.currentPage < response.lastPage,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoadMoreRunning: false);
//     }
//   }
//
//   // 3. Update Filter (Resets data)
//   void updateFilter(String newFilter) {
//     if (state.currentFilter == newFilter) return;
//
//     // Reset state but keep the new filter
//     state = LedgerState(currentFilter: newFilter, isLoading: true);
//     loadInitialData(); // Reload with new filter
//   }
// }

class PartyLedgerNotifier extends StateNotifier<LedgerState> {
  final PartyLedgerRepo _repository = PartyLedgerRepo();
  final String partyId;

  PartyLedgerNotifier({
    required this.partyId,
    required String initialFilter,
  }) : super(LedgerState(currentFilter: initialFilter)) {
    loadInitialData();
  }

  // Load initial page (page 1)
  Future<void> loadInitialData() async {
    try {
      state = state.copyWith(isLoading: true, page: 0, hasMoreData: true);
      final response = await _repository.getPartyLedger(
        partyId: partyId,
        page: 1,
        duration: state.currentFilter,
      );

      state = state.copyWith(
        transactions: response.data,
        isLoading: false,
        page: 1,
        hasMoreData: response.currentPage < response.lastPage,
      );
    } catch (e, st) {
      print('Error loading ledger: $e\n$st');
      state = state.copyWith(isLoading: false, hasMoreData: false);
    }
  }

  // Load more for pagination
  Future<void> loadMore() async {
    if (state.isLoadMoreRunning || !state.hasMoreData) return;

    state = state.copyWith(isLoadMoreRunning: true);

    try {
      final nextPage = state.page + 1;
      final response = await _repository.getPartyLedger(
        partyId: partyId,
        page: nextPage,
        duration: state.currentFilter,
      );

      state = state.copyWith(
        transactions: [...state.transactions, ...response.data],
        page: nextPage,
        isLoadMoreRunning: false,
        hasMoreData: response.currentPage < response.lastPage,
      );
    } catch (e) {
      print('Error loading more ledger: $e');
      state = state.copyWith(isLoadMoreRunning: false);
    }
  }

  // Update filter (resets data and reloads)
  void updateFilter(String newFilter) {
    if (state.currentFilter == newFilter) return;

    state = LedgerState(
      currentFilter: newFilter,
      isLoading: true,
      transactions: [],
      page: 0,
      hasMoreData: true,
      isLoadMoreRunning: false,
    );

    loadInitialData();
  }
}

final partyLedgerProvider =
    StateNotifierProvider.family.autoDispose<PartyLedgerNotifier, LedgerState, PartyLedgerFilterParam>(
  (ref, input) => PartyLedgerNotifier(
    partyId: input.partyId,
    initialFilter: input.duration ?? '',
  ),
);

// final partyLedgerProvider = StateNotifierProvider.family.autoDispose<PartyLedgerNotifier, LedgerState, String>(
//   (ref, partyId) => PartyLedgerNotifier(partyId),
// );
