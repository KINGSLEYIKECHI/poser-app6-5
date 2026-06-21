import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/transfer/add_new_transfer_screen.dart';
import 'package:mobile_pos/Screens/transfer/transfer_list_tab_screen.dart';
import 'package:mobile_pos/Screens/warehouse/add_and_edit_warehouse_screen.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/warehouse_list_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_repo/warehouse_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';

import '../../widgets/empty_warehouse_widget/empty_warehouse.dart';

class WarehouseListScreen extends ConsumerStatefulWidget {
  const WarehouseListScreen({super.key});

  @override
  ConsumerState<WarehouseListScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with length 2 (Warehouse & Transfer)
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to update the Floating Action Button
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Refresh functionality for both tabs
  Future<void> _onRefresh() async {
    if (_tabController.index == 0) {
      return ref.refresh(fetchWarehouseListProvider);
    } else {
      return ref.refresh(fetchTransferListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warehouseAsync = ref.watch(fetchWarehouseListProvider);
    final _lang = l.S.of(context);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(_lang.warehouse),
        centerTitle: true,
        bottom: _buildTabBar(theme),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Warehouse List
          _buildWarehouseTab(context: context, ref: ref, warehouseAsync: warehouseAsync, theme: theme),
          // Tab 2: Transfer List
          buildTransferTab(context: context, ref: ref),
        ],
      ),
      floatingActionButton: _buildFAB(theme),
    );
  }

  // Optimized TabBar with Controller
  PreferredSizeWidget _buildTabBar(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(45),
      child: Column(
        children: [
          const Divider(height: 2, color: kBackgroundColor),
          Theme(
            data: theme.copyWith(
              tabBarTheme: const TabBarThemeData(dividerColor: kBackgroundColor),
            ),
            child: TabBar(
              controller: _tabController,
              labelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              labelColor: Colors.red,
              unselectedLabelColor: kPeraColor,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: l.S.of(context).warehouseList),
                Tab(text: l.S.of(context).transferList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Warehouse Tab Builder
  Widget _buildWarehouseTab({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<WarehouseListModel> warehouseAsync,
    required ThemeData theme,
  }) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(fetchWarehouseListProvider),
      child: warehouseAsync.when(
        data: (snapshot) {
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: emptyWidget(theme, context),
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 2),
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                onTap: () => _handleItemDetails(item),
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "$currency${item.totalValue ?? '0'}",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.phone ?? 'n/a',
                      style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                    ),
                    Text(
                      l.S.of(context).stockValue,
                      style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (e, stack) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _handleItemDetails(WarehouseData item) {
    showEditDeletePopUp(
      context: context,
      item: {
        l.S.of(context).name: item.name ?? 'n/a',
        l.S.of(context).phone: item.phone ?? 'n/a',
        l.S.of(context).email: item.email ?? 'n/a',
        l.S.of(context).address: item.address ?? 'n/a',
        l.S.of(context).stockQty: item.totalQuantity?.toString() ?? '0',
        l.S.of(context).stockValue: "$currency${item.totalValue ?? '0'}",
      },
      editData: item,
      ref: ref,
    );
  }

  // Dynamic Floating Action Button
  Widget _buildFAB(ThemeData theme) {
    final bool isWarehouseTab = _tabController.index == 0;

    return Container(
      height: 48,
      width: 190,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC52127).withOpacity(0.2),
            offset: const Offset(0, 11),
            blurRadius: 14,
          ),
        ],
      ),
      child: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: kMainColor,
        onPressed: () {
          if (isWarehouseTab) {
            // Navigate to Add Warehouse Screen
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewWarehouse()));
          } else {
            // Navigate to Add Transfer Screen
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNewTransferScreen()));
          }
        },
        child: Text(
          isWarehouseTab ? '+ ${l.S.of(context).addWarehouse}' : '+ ${l.S.of(context).addTransfer}',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

// Dialog Logic for Warehouse Edit/Delete
Future<void> showEditDeletePopUp({
  required BuildContext context,
  required Map<String, String> item,
  WarehouseData? editData,
  required WidgetRef ref,
}) async {
  final theme = Theme.of(context);
  return await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (dialogContext) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.S.of(context).viewDetails,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                      IconButton(onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  ...item.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                            Expanded(flex: 4, child: Text(': ${e.value}')),
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            bool confirmDelete =
                                await showDeleteConfirmationDialog(context: context, itemName: 'warehouse');
                            if (confirmDelete) {
                              if (!context.mounted) return;

                              WarehouseRepo repo = WarehouseRepo();
                              bool success = await repo.deleteWarehouse(
                                id: editData?.id.toString() ?? '',
                                context: context,
                                ref: ref,
                              );

                              if (success && context.mounted) {
                                ref.refresh(fetchWarehouseListProvider);
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Deleted Successfully')));
                              }
                            }
                          },
                          child: Text(l.S.of(context).delete),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            if (!context.mounted) return;
                            Navigator.push(
                                context, MaterialPageRoute(builder: (_) => AddNewWarehouse(editData: editData)));
                          },
                          child: Text(l.S.of(context).edit),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
