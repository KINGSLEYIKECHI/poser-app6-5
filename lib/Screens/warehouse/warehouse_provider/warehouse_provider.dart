import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/transfer/repo/transfer_repo.dart';
import 'package:mobile_pos/Screens/warehouse/model/warehouse_by_branch_model.dart';
import 'package:mobile_pos/Screens/transfer/model/transfar_list_model.dart';

import '../warehouse_model/warehouse_list_model.dart';
import '../warehouse_repo/warehouse_repo.dart';

WarehouseRepo repo = WarehouseRepo();

// fetch warehouse list
final fetchWarehouseListProvider = FutureProvider<WarehouseListModel>((ref) {
  return repo.fetchWareHouseList();
});

// fetch transfer list
final fetchTransferListProvider = FutureProvider.autoDispose<TransferListModel>((ref) async {
  return TransferRepo().fetchTransferList();
});

final warehouseByBranchProvider = FutureProvider.family<List<WarehouseByBranchData>, String>((ref, branchId) async {
  return WarehouseRepo().fetchWarehouseByBranch(branchId);
});
