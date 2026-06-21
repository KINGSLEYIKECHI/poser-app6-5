import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/branch/provider/branch_list_provider.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_cart_data_model.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_details_model.dart'; // Import Details Model
import 'package:mobile_pos/Screens/transfer/repo/transfer_repo.dart';
import 'package:mobile_pos/Screens/transfer/transfer_product_list_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/Screens/transfer/provider/transfer_provider.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_repo/warehouse_repo.dart';
import 'package:mobile_pos/Screens/warehouse/model/warehouse_by_branch_model.dart';
import 'package:mobile_pos/currency.dart';

class AddNewTransferScreen extends ConsumerStatefulWidget {
  final TransferData? editTransferData; // [NEW] Optional Data for Edit Mode

  const AddNewTransferScreen({super.key, this.editTransferData});

  @override
  ConsumerState<AddNewTransferScreen> createState() => _AddNewTransferScreenState();
}

class _AddNewTransferScreenState extends ConsumerState<AddNewTransferScreen> {
  // Controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController shippingController = TextEditingController();

  // Selection States
  String? selectedFromBranch;
  String? selectedToBranch;

  // Warehouse Selection States
  String? selectedFromWarehouse;
  String? selectedToWarehouse;

  // Warehouse Lists
  List<WarehouseByBranchData> fromWarehouseList = [];
  List<WarehouseByBranchData> toWarehouseList = [];

  String selectedStatus = 'Pending';
  final List<String> statusList = ['Pending', 'Cancelled', 'Completed'];

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.editTransferData != null;

    if (isEditMode) {
      _initializeEditMode();
    } else {
      dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Future.delayed(Duration.zero, () {
        ref.read(transferCartProvider.notifier).clearCart();
        // Delay _loadAllWarehouses logic until build phase gets user active branch
      });
    }
  }

  // --- LOGIC: Initialize Edit Mode ---
  void _initializeEditMode() {
    final data = widget.editTransferData!;

    dateController.text = data.transferDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    noteController.text = data.note ?? '';
    shippingController.text = data.shippingCharge?.toString() ?? '0';

    String? apiStatus = data.status;
    if (apiStatus != null) {
      selectedStatus = statusList.firstWhere(
        (s) => s.toLowerCase() == apiStatus.toLowerCase(),
        orElse: () => 'Pending',
      );
    }

    selectedFromBranch = data.fromBranch?.id?.toString();
    selectedToBranch = data.toBranch?.id?.toString();
    selectedFromWarehouse = data.fromWarehouse?.id?.toString();
    selectedToWarehouse = data.toWarehouse?.id?.toString();

    if (selectedFromBranch != null) {
      _loadFromWarehousesByBranch(selectedFromBranch!);
    } else {
      _loadAllWarehouses();
    }

    if (selectedToBranch != null) {
      _loadToWarehousesByBranch(selectedToBranch!);
    } else {
      _loadAllWarehousesForTo();
    }

    Future.delayed(Duration.zero, () {
      ref.read(transferCartProvider.notifier).clearCart();

      if (data.transferProducts != null) {
        for (var p in data.transferProducts!) {
          TransferCartItem item = TransferCartItem(
            productId: p.product?.id.toString() ?? '0',
            productName: p.product?.productName ?? 'Unknown',
            productCode: '',
            quantity: p.quantity ?? 0,
            purchasePrice: p.unitPrice ?? 0,
            stockId: p.stockId ?? 0,
            currentStock: 0,
            serialNumber: p.serialNumbers,
          );
          ref.read(transferCartProvider.notifier).addItem(item);
        }
      }
    });
  }

  // --- LOGIC: Load All Warehouses ---
  Future<void> _loadAllWarehouses() async {
    final model = await WarehouseRepo().fetchWareHouseList();
    if (model.data != null) {
      final mappedList = model.data!.map((e) => WarehouseByBranchData(id: e.id?.toInt(), name: e.name)).toList();
      if (mounted) {
        setState(() {
          fromWarehouseList = mappedList;
          // Only initialize toWarehouseList if it's currently empty
          if (toWarehouseList.isEmpty) toWarehouseList = mappedList;
        });
      }
    }
  }

  Future<void> _loadAllWarehousesForTo() async {
    final model = await WarehouseRepo().fetchWareHouseList();
    if (model.data != null) {
      final mappedList = model.data!.map((e) => WarehouseByBranchData(id: e.id?.toInt(), name: e.name)).toList();
      if (mounted) {
        setState(() {
          toWarehouseList = mappedList;
        });
      }
    }
  }

  // --- LOGIC: Load Warehouses By Branch ---
  Future<void> _loadFromWarehousesByBranch(String branchId) async {
    final list = await WarehouseRepo().fetchWarehouseByBranch(branchId);
    if (mounted) {
      setState(() {
        fromWarehouseList = list;
        if (selectedFromWarehouse != null && !list.any((e) => e.id.toString() == selectedFromWarehouse)) {
          selectedFromWarehouse = null;
        }
      });
    }
  }

  Future<void> _loadToWarehousesByBranch(String branchId) async {
    final list = await WarehouseRepo().fetchWarehouseByBranch(branchId);
    if (mounted) {
      setState(() {
        toWarehouseList = list;
        if (selectedToWarehouse != null && !list.any((e) => e.id.toString() == selectedToWarehouse)) {
          selectedToWarehouse = null;
        }
      });
    }
  }

  double getSubTotal(List<TransferCartItem> cart) {
    return cart.fold(0, (sum, item) => sum + (item.purchasePrice * item.quantity));
  }

  double getTotal(List<TransferCartItem> cart) {
    double subTotal = getSubTotal(cart);
    double shipping = double.tryParse(shippingController.text) ?? 0;
    return subTotal + shipping;
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final cartList = ref.watch(transferCartProvider);
    final businessInfoAsync = ref.watch(businessInfoProvider);
    final branchListAsync = ref.watch(branchListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text(isEditMode ? _lang.editTransfer : _lang.addNewTransfer, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: businessInfoAsync.when(
        data: (businessInfo) {
          final hasMultiBranch = businessInfo.data?.addons?.multiBranchAddon ?? false;
          final hasWarehouse = businessInfo.data?.addons?.warehouseAddon ?? false;
          final userActiveBranchId = businessInfo.data?.user?.activeBranchId?.toString();

          final String? effectiveFromBranch = selectedFromBranch ?? userActiveBranchId;

          // Load default warehouses initially based on branch context
          if (!isEditMode && fromWarehouseList.isEmpty && toWarehouseList.isEmpty) {
            Future.delayed(Duration.zero, () {
              if (effectiveFromBranch != null) {
                _loadFromWarehousesByBranch(effectiveFromBranch);
                _loadToWarehousesByBranch(effectiveFromBranch);
              } else {
                _loadAllWarehouses();
              }
            });
          }

          // ** LOGIC: Determine if "To Warehouse" should be disabled **
          bool isToWarehouseDisabled = false;
          if (userActiveBranchId != null && selectedToBranch != null && selectedToBranch != userActiveBranchId) {
            // User is in a branch, and selected a DIFFERENT branch -> Cannot select warehouse
            isToWarehouseDisabled = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(dateController.text),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2050),
                    );
                    if (picked != null) {
                      setState(() {
                        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                  child: _buildReadOnlyField(_lang.date, dateController.text, Icons.calendar_today_outlined),
                ),
                const SizedBox(height: 16),

                // --- FROM & TO BRANCH SECTION ---
                if (hasMultiBranch) ...[
                  branchListAsync.when(
                    data: (data) {
                      if (data.data == null || data.data!.isEmpty) return const SizedBox.shrink();

                      return Column(
                        children: [
                          _buildDropdown(
                            label: _lang.fromBranch,
                            value: effectiveFromBranch,
                            items: data.data!
                                .map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.name ?? '')))
                                .toList(),
                            onChanged: (val) {
                              if (userActiveBranchId != null && userActiveBranchId != val) {
                                EasyLoading.showInfo("You can only transfer from your active branch");
                                return;
                              }
                              setState(() {
                                if (selectedFromBranch != val) {
                                  ref.read(transferCartProvider.notifier).clearCart();
                                  selectedFromBranch = val;
                                  if (hasWarehouse && val != null) {
                                    _loadFromWarehousesByBranch(val);
                                  }
                                }
                              });
                            },
                            onClear: (userActiveBranchId == null && selectedFromBranch != null)
                                ? () {
                                    setState(() {
                                      selectedFromBranch = null;
                                      ref.read(transferCartProvider.notifier).clearCart();
                                      if (hasWarehouse) {
                                        selectedFromWarehouse = null;
                                        _loadAllWarehouses();
                                      }
                                    });
                                  }
                                : null,
                            disabled: userActiveBranchId != null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: _lang.toBranch,
                            value: selectedToBranch,
                            items: data.data!
                                .map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.name ?? '')))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedToBranch = val;
                                if (hasWarehouse) {
                                  selectedToWarehouse = null; // Always reset when branch changes

                                  if (userActiveBranchId != null && val != null && val != userActiveBranchId) {
                                    // Rule: User in a branch transferring to ANOTHER branch. Disable warehouse.
                                    toWarehouseList = [];
                                  } else if (val != null) {
                                    _loadToWarehousesByBranch(val);
                                  } else {
                                    // Branch cleared
                                    if (userActiveBranchId != null) {
                                      _loadToWarehousesByBranch(userActiveBranchId);
                                    } else {
                                      _loadAllWarehousesForTo();
                                    }
                                  }
                                }
                              });
                            },
                            onClear: selectedToBranch != null
                                ? () {
                                    setState(() {
                                      selectedToBranch = null;
                                      if (hasWarehouse) {
                                        selectedToWarehouse = null;
                                        if (userActiveBranchId != null) {
                                          _loadToWarehousesByBranch(userActiveBranchId);
                                        } else {
                                          _loadAllWarehousesForTo();
                                        }
                                      }
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    error: (e, s) => Text('Error loading branches: $e'),
                    loading: () => const LinearProgressIndicator(),
                  ),
                ],

                // --- WAREHOUSE SECTION ---
                if (hasWarehouse) ...[
                  _buildDropdown(
                    label: effectiveFromBranch != null ? _lang.fromWarehouseOptional : _lang.fromWarehouse,
                    value: selectedFromWarehouse,
                    items: fromWarehouseList
                        .map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.name ?? '')))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        if (selectedFromWarehouse != val) {
                          ref.read(transferCartProvider.notifier).clearCart();
                          selectedFromWarehouse = val;
                        }
                      });
                    },
                    onClear: selectedFromWarehouse != null
                        ? () {
                            setState(() {
                              selectedFromWarehouse = null;
                              ref.read(transferCartProvider.notifier).clearCart();
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // "To Warehouse" Dropdown
                  _buildDropdown(
                    label: isToWarehouseDisabled
                        ? "Warehouse selection disabled for other branches"
                        : (selectedToBranch != null ? _lang.toWarehouseOptional : _lang.toWarehouse),
                    value: selectedToWarehouse,
                    items: toWarehouseList
                        .map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.name ?? '')))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedToWarehouse = val;
                      });
                    },
                    onClear: selectedToWarehouse != null ? () => setState(() => selectedToWarehouse = null) : null,
                    disabled: isToWarehouseDisabled, // Pass disabled state
                  ),
                  const SizedBox(height: 16),
                ],

                // Status Dropdown
                _buildDropdown(
                  label: _lang.status,
                  value: selectedStatus,
                  items: [
                    DropdownMenuItem<String>(value: 'Pending', child: Text(_lang.pending)),
                    DropdownMenuItem<String>(value: 'Cancelled', child: Text(_lang.cancelled)),
                    DropdownMenuItem<String>(value: 'Completed', child: Text(_lang.completed)),
                  ],
                  onChanged: (val) => setState(() => selectedStatus = val!),
                ),

                const SizedBox(height: 20),

                // Items Section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(_lang.itemAdded, style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(_lang.quantity, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 0),
                      if (cartList.isEmpty)
                        Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(_lang.noItemAdded, style: TextStyle(color: Colors.grey)))
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartList.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, index) {
                            final item = cartList[index];
                            return _buildItemRow(item, index, ref);
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              // Validation
                              bool isSourceSelected = false;
                              if (hasWarehouse && selectedFromWarehouse != null) {
                                isSourceSelected = true;
                              } else if (hasMultiBranch && effectiveFromBranch != null) {
                                isSourceSelected = true;
                              } else if (!hasMultiBranch && !hasWarehouse) {
                                isSourceSelected = true;
                              }

                              if (!isSourceSelected) {
                                EasyLoading.showError("Please select From Branch OR From Warehouse");
                                return;
                              }

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransferProductList(
                                    fromBranchId: effectiveFromBranch,
                                    fromWarehouseId: selectedFromWarehouse,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(backgroundColor: const Color(0xffFFF1F1)),
                            child: Text(_lang.addItems, style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Calculations formatted to 2 decimal places
                _buildSummaryRow(_lang.subTotal, '$currency${getSubTotal(cartList).toStringAsFixed(2)}'),
                _buildSummaryRow(_lang.discount, '$currency 0.00'),
                _buildSummaryRow(_lang.tax, '$currency 0.00'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_lang.shippingCharge),
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: TextField(
                        controller: shippingController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '$currency 0.00',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    )
                  ],
                ),
                const Divider(height: 30),
                _buildSummaryRow(_lang.totalAmount, '$currency${getTotal(cartList).toStringAsFixed(2)}', isTotal: true),
                const SizedBox(height: 20),

                Align(alignment: Alignment.centerLeft, child: Text(_lang.transferNote)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: _lang.typeNote,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // --- SUBMISSION VALIDATION ---
                      bool isFromValid = false;
                      bool isToValid = false;

                      if (selectedFromWarehouse != null) {
                        isFromValid = true;
                      } else if (effectiveFromBranch != null) {
                        isFromValid = true;
                      }

                      if (selectedToWarehouse != null) {
                        isToValid = true;
                      } else if (selectedToBranch != null) {
                        isToValid = true;
                      } else if (userActiveBranchId != null && selectedToWarehouse == null) {
                        // User trying to do warehouse to warehouse, but didn't select To Warehouse or To Branch
                        // Let logic catch below
                      }

                      if (!isFromValid) {
                        EasyLoading.showError('Select From Source (Branch or Warehouse)');
                        return;
                      }
                      if (!isToValid && userActiveBranchId == null) {
                        EasyLoading.showError('Select To Destination (Branch or Warehouse)');
                        return;
                      } else if (!isToValid && userActiveBranchId != null) {
                        // Fallback for branch user if they didn't explicitly select "To Branch" but did "To Warehouse"
                        if (selectedToWarehouse == null) {
                          EasyLoading.showError('Select To Destination (Branch or Warehouse)');
                          return;
                        }
                      }

                      if (cartList.isEmpty) {
                        EasyLoading.showError('Add at least one item');
                        return;
                      }

                      // Determine Final To Branch ID
                      String? finalToBranchId = selectedToBranch;

                      TransferRepo repo = TransferRepo();
                      bool success;

                      if (isEditMode) {
                        success = await repo.updateTransfer(
                          id: widget.editTransferData!.id.toString(),
                          date: dateController.text,
                          fromWarehouseId: selectedFromWarehouse,
                          toWarehouseId: selectedToWarehouse,
                          fromBranchId: effectiveFromBranch,
                          toBranchId: finalToBranchId,
                          status: selectedStatus,
                          shippingCharge: shippingController.text.isEmpty ? '0' : shippingController.text,
                          note: noteController.text,
                          items: cartList,
                          context: context,
                          ref: ref,
                        );
                      } else {
                        success = await repo.createTransfer(
                          date: dateController.text,
                          fromWarehouseId: selectedFromWarehouse,
                          toWarehouseId: selectedToWarehouse,
                          fromBranchId: effectiveFromBranch ?? (businessInfo.data?.user?.activeBranchId?.toString()),
                          toBranchId: finalToBranchId,
                          status: selectedStatus,
                          shippingCharge: shippingController.text.isEmpty ? '0' : shippingController.text,
                          note: noteController.text,
                          items: cartList,
                          context: context,
                          ref: ref,
                        );
                      }

                      if (success) {
                        if (mounted) Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text(isEditMode ? 'Transfer Updated Successfully' : 'Transfer Created Successfully')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffC52127),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isEditMode ? _lang.updateTransfer : _lang.save,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    VoidCallback? onClear,
    bool disabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: disabled ? Colors.grey.shade400 : Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: disabled ? Colors.grey.shade100 : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: Text(disabled ? "Not Applicable" : label),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    onChanged: disabled ? null : onChanged,
                    items: items,
                  ),
                ),
              ),
              if (value != null && onClear != null && !disabled)
                InkWell(
                  onTap: onClear,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.close, color: Colors.grey, size: 18),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: Colors.black)),
              Icon(icon, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(TransferCartItem item, int index, WidgetRef ref) {
    bool hasSerials = item.serialNumber != null && item.serialNumber!.isNotEmpty;

    return ListTile(
      title: Text(item.productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item price formatted to exactly 2 decimal places
          Text("${l.S.of(context).price}: $currency${item.purchasePrice.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (hasSerials)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "${l.S.of(context).serial}: ${item.serialNumber!.join(', ')}",
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: hasSerials ? Colors.grey.shade300 : Colors.grey),
            onPressed: hasSerials
                ? () {
                    EasyLoading.showInfo("Cannot change quantity manually for serial items.");
                  }
                : () => ref.read(transferCartProvider.notifier).decrementItem(index),
          ),
          Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.add_circle, color: hasSerials ? Colors.grey.shade300 : Colors.red),
            onPressed: hasSerials
                ? () {
                    EasyLoading.showInfo("Cannot change quantity manually for serial items.");
                  }
                : () => ref.read(transferCartProvider.notifier).incrementItem(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
            onPressed: () => ref.read(transferCartProvider.notifier).removeItem(index),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
          Text(value,
              style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}
