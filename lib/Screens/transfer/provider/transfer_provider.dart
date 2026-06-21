import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_cart_data_model.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_details_model.dart';
import 'package:mobile_pos/Screens/transfer/repo/transfer_repo.dart';

class TransferCartNotifier extends StateNotifier<List<TransferCartItem>> {
  TransferCartNotifier() : super([]);

  void addItem(TransferCartItem item) {
    // Check both productId and stockId (previously only productId was checked)
    final index = state.indexWhere((element) => element.productId == item.productId && element.stockId == item.stockId);

    // If both product and batch (stockId) match, increase quantity
    if (index != -1) {
      if (state[index].quantity + item.quantity <= state[index].currentStock) {
        // Logic to merge serials
        List<String>? updatedSerials;
        // Casting List<dynamic> to String for safety
        if (item.serialNumber != null) {
          updatedSerials = [
            ...(state[index].serialNumber?.map((e) => e.toString()) ?? []),
            ...item.serialNumber!.map((e) => e.toString())
          ];
        }

        state = [
          ...state.sublist(0, index),
          state[index].copyWith(
              quantity: state[index].quantity + item.quantity,
              serialNumber: updatedSerials ?? state[index].serialNumber),
          ...state.sublist(index + 1),
        ];
      }
    }
    // If batch is different (stockId doesn't match), add as a new item to the list
    else {
      state = [...state, item];
    }
  }

  void incrementItem(int index) {
    if (state[index].quantity < state[index].currentStock) {
      state = [
        ...state.sublist(0, index),
        state[index].copyWith(quantity: state[index].quantity + 1),
        ...state.sublist(index + 1),
      ];
    }
  }

  void decrementItem(int index) {
    if (state[index].quantity > 1) {
      List<String>? updatedSerials;
      if (state[index].serialNumber != null && state[index].serialNumber!.isNotEmpty) {
        updatedSerials = List.from(state[index].serialNumber!);
        updatedSerials.removeLast();
      }

      state = [
        ...state.sublist(0, index),
        state[index].copyWith(quantity: state[index].quantity - 1, serialNumber: updatedSerials),
        ...state.sublist(index + 1),
      ];
    } else {
      removeItem(index);
    }
  }

  void removeItem(int index) {
    state = List.from(state)..removeAt(index);
  }

  void clearCart() {
    state = [];
  }
}

final transferCartProvider = StateNotifierProvider<TransferCartNotifier, List<TransferCartItem>>((ref) {
  return TransferCartNotifier();
});

final transferDetailsProvider = FutureProvider.family.autoDispose<TransferDetailsModel, String>((ref, id) async {
  return TransferRepo().fetchTransferDetails(id);
});
