import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/add%20product/modle/create_product_model.dart';
import 'package:mobile_pos/Screens/Products/add%20product/serial_code_section.dart';
import 'package:mobile_pos/Screens/Products/product_setting/model/get_product_setting_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/warehouse_list_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../../constant.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../vat_&_tax/model/vat_model.dart';
import '../../warehouse/warehouse_provider/warehouse_provider.dart';

// Helper class to hold controllers for each batch
class SingleStockControllers {
  TextEditingController batchController;
  TextEditingController stockController;
  TextEditingController purchaseExController;
  TextEditingController purchaseIncController;
  TextEditingController profitController;
  TextEditingController saleController;
  TextEditingController wholesaleController;
  TextEditingController dealerController;
  TextEditingController mfgDateController;
  TextEditingController expDateController;
  String? warehouseId;
  List<String> serials;
  bool isExpanded;

  SingleStockControllers({
    required this.batchController,
    required this.stockController,
    required this.purchaseExController,
    required this.purchaseIncController,
    required this.profitController,
    required this.saleController,
    required this.wholesaleController,
    required this.dealerController,
    required this.mfgDateController,
    required this.expDateController,
    this.warehouseId,
    required this.serials,
    this.isExpanded = true,
  });

  void dispose() {
    batchController.dispose();
    stockController.dispose();
    purchaseExController.dispose();
    purchaseIncController.dispose();
    profitController.dispose();
    saleController.dispose();
    wholesaleController.dispose();
    dealerController.dispose();
    mfgDateController.dispose();
    expDateController.dispose();
  }
}

class SingleProductForm extends ConsumerStatefulWidget {
  const SingleProductForm({
    super.key,
    required this.snapShot,
    required this.initialStocks,
    required this.tax,
    required this.taxType,
    required this.productCode,
    this.defaultWarehouse,
    required this.isSerialEnabled,
    required this.onStocksUpdated,
  });

  final GetProductSettingModel snapShot;
  final List<StockDataModel> initialStocks;
  final VatModel? tax;
  final String taxType;
  final String productCode;
  final WarehouseData? defaultWarehouse;
  final bool isSerialEnabled;
  final Function(List<StockDataModel>) onStocksUpdated;

  @override
  ConsumerState<SingleProductForm> createState() => _SingleProductFormState();
}

class _SingleProductFormState extends ConsumerState<SingleProductForm> {
  List<SingleStockControllers> controllersList = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (int i = 0; i < widget.initialStocks.length; i++) {
      var stock = widget.initialStocks[i];
      bool expanded = i == 0;
      controllersList.add(_createController(stock, isExpanded: expanded));
    }
    if (controllersList.isEmpty) {
      _addBatch();
    }
  }

  SingleStockControllers _createController(StockDataModel stock, {bool isExpanded = true}) {
    return SingleStockControllers(
      batchController: TextEditingController(text: stock.batchNo ?? ''),
      stockController: TextEditingController(text: stock.productStock ?? '0'),
      purchaseExController: TextEditingController(text: stock.exclusivePrice ?? ''),
      purchaseIncController: TextEditingController(text: stock.inclusivePrice ?? ''),
      profitController: TextEditingController(text: stock.profitPercent ?? ''),
      saleController: TextEditingController(text: stock.productSalePrice ?? ''),
      wholesaleController: TextEditingController(text: stock.productWholeSalePrice ?? ''),
      dealerController: TextEditingController(text: stock.productDealerPrice ?? ''),
      mfgDateController: TextEditingController(text: stock.mfgDate ?? ''),
      expDateController: TextEditingController(text: stock.expireDate ?? ''),
      serials: stock.serialNumbers != null ? List.from(stock.serialNumbers!) : [],
      warehouseId: stock.warehouseId ?? widget.defaultWarehouse?.id?.toString(),
      isExpanded: isExpanded,
    );
  }

  @override
  void didUpdateWidget(covariant SingleProductForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tax != widget.tax || oldWidget.taxType != widget.taxType) {
      for (int i = 0; i < controllersList.length; i++) {
        _calculatePrices(i, 'purchase_ex', sync: false);
      }
      _syncToParent();
    }

    if (oldWidget.productCode != widget.productCode) {
      if (controllersList.isNotEmpty) {
        if (controllersList[0].batchController.text.isEmpty ||
            controllersList[0].batchController.text.startsWith(oldWidget.productCode)) {
          controllersList[0].batchController.text = widget.productCode.isNotEmpty ? "${widget.productCode}-1" : "";
          _syncToParent();
        }
      }
    }
  }

  @override
  void dispose() {
    for (var c in controllersList) {
      c.dispose();
    }
    super.dispose();
  }

  void _addBatch() {
    final newBatchNo = widget.productCode.isNotEmpty ? "${widget.productCode}-${controllersList.length + 1}" : "";
    setState(() {
      controllersList.add(_createController(StockDataModel(batchNo: newBatchNo), isExpanded: true));
    });
    _syncToParent();
  }

  void _removeBatch(int index) {
    if (controllersList.length > 1) {
      setState(() {
        controllersList[index].dispose();
        controllersList.removeAt(index);
      });
      _syncToParent();
    } else {
      EasyLoading.showError("At least one batch is required.");
    }
  }

  void _calculatePrices(int index, String from, {bool sync = true}) {
    num taxRate = widget.tax?.rate ?? 0;
    var c = controllersList[index];

    num purchaseExc = 0;
    num purchaseInc = 0;
    num profitMargin = num.tryParse(c.profitController.text) ?? 0;
    num salePrice = 0;

    if (from == 'purchase_inc') {
      if (taxRate != 0) {
        purchaseExc = (num.tryParse(c.purchaseIncController.text) ?? 0) / (1 + taxRate / 100);
      } else {
        purchaseExc = num.tryParse(c.purchaseIncController.text) ?? 0;
      }
      c.purchaseExController.text = purchaseExc.toStringAsFixed(2);
    } else {
      purchaseExc = num.tryParse(c.purchaseExController.text) ?? 0;
      purchaseInc = purchaseExc + (purchaseExc * taxRate / 100);
      c.purchaseIncController.text = purchaseInc.toStringAsFixed(2);
    }

    purchaseInc = num.tryParse(c.purchaseIncController.text) ?? 0;

    if (from == 'mrp') {
      salePrice = num.tryParse(c.saleController.text) ?? 0;
      num basePrice = widget.taxType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc;

      if (basePrice > 0) {
        profitMargin = ((salePrice - basePrice) / basePrice) * 100;
        c.profitController.text = profitMargin.toStringAsFixed(2);
      } else {
        c.profitController.text = '0.00';
      }
    } else {
      num basePrice = widget.taxType.toLowerCase() == 'exclusive' ? purchaseExc : purchaseInc;

      if (basePrice > 0) {
        salePrice = basePrice + (basePrice * profitMargin / 100);
        c.saleController.text = salePrice.toStringAsFixed(2);
      } else {
        c.saleController.text = '0.00';
      }
    }

    if (sync) {
      _syncToParent();
    }
  }

  void _syncToParent() {
    List<StockDataModel> updatedStocks = [];
    for (int i = 0; i < controllersList.length; i++) {
      var c = controllersList[i];
      updatedStocks.add(StockDataModel(
        stockId: widget.initialStocks.length > i ? widget.initialStocks[i].stockId : null,
        batchNo: c.batchController.text,
        productStock: c.stockController.text,
        exclusivePrice: c.purchaseExController.text,
        inclusivePrice: c.purchaseIncController.text,
        profitPercent: c.profitController.text,
        productSalePrice: c.saleController.text,
        productWholeSalePrice: c.wholesaleController.text,
        productDealerPrice: c.dealerController.text,
        mfgDate: c.mfgDateController.text.isNotEmpty ? c.mfgDateController.text : null,
        expireDate: c.expDateController.text.isNotEmpty ? c.expDateController.text : null,
        serialNumbers: c.serials,
        warehouseId: c.warehouseId,
      ));
    }
    widget.onStocksUpdated(updatedStocks);
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService(ref);
    final businessInfoAsyncValue = ref.watch(businessInfoProvider);
    final modules = widget.snapShot.data?.modules;
    final _lang = lang.S.of(context);

    return Column(
      children: [
        ...List.generate(controllersList.length, (index) {
          final c = controllersList[index];

          return Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: ObjectKey(c),
                initiallyExpanded: c.isExpanded,
                onExpansionChanged: (expanded) {
                  c.isExpanded = expanded;
                },
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: c.batchController,
                        builder: (context, value, child) {
                          String batchTitle = value.text.trim();
                          if (batchTitle.isEmpty) {
                            batchTitle = "${_lang.batch} ${index + 1}";
                          }
                          return Text(
                            batchTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTitleColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    if (controllersList.length > 1)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeBatch(index),
                      ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///-------------Batch No & Warehouse----------------------------------
                        if (modules?.showBatchNo == '1' || modules?.showWarehouse == '1') ...[
                          Row(
                            children: [
                              if (modules?.showBatchNo == '1')
                                Expanded(
                                  child: TextFormField(
                                    controller: c.batchController,
                                    onChanged: (val) {
                                      _syncToParent();
                                    },
                                    decoration: InputDecoration(
                                      labelText: _lang.batchNo,
                                      hintText: _lang.enterBatchNo,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              if (modules?.showBatchNo == '1' && modules?.showWarehouse == '1')
                                const SizedBox(width: 14),

                              // FIX: Wrap with Consumer and check both Addon + Module to prevent API trigger
                              if (modules?.showWarehouse == '1' &&
                                  businessInfoAsyncValue.value?.data?.addons?.warehouseAddon == true)
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      return ref.watch(fetchWarehouseListProvider).when(
                                            data: (dataList) {
                                              return DropdownButtonFormField<String>(
                                                hint: Text(_lang.selectWarehouse),
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  labelText: _lang.warehouse,
                                                  border: const OutlineInputBorder(),
                                                ),
                                                value: c.warehouseId,
                                                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                items: dataList.data
                                                    ?.map(
                                                      (rack) => DropdownMenuItem<String>(
                                                        value: rack.id.toString(),
                                                        child: Text(rack.name ?? '',
                                                            style: const TextStyle(fontWeight: FontWeight.normal)),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (val) {
                                                  setState(() {
                                                    c.warehouseId = val;
                                                  });
                                                  _syncToParent();
                                                },
                                              );
                                            },
                                            error: (e, st) => const Text('Error'),
                                            loading: () => const Center(child: CircularProgressIndicator()),
                                          );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        ///-------------Stock (With Serial Logic)--------------------------------------
                        if (modules?.showProductStock == '1') ...[
                          (widget.isSerialEnabled &&
                                  modules?.showSerial == '1' &&
                                  businessInfoAsyncValue.value?.data?.addons?.serialCodeAddon == true)
                              ? TextFormField(
                                  controller: c.stockController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: _lang.stock,
                                    hintText: "0",
                                    border: const OutlineInputBorder(),
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        showSerialModal(
                                          context: context,
                                          initialSerials: c.serials,
                                          oldSerials: [],
                                          onSave: (updatedList) {
                                            setState(() {
                                              c.serials = updatedList;
                                              c.stockController.text = updatedList.length.toString();
                                            });
                                            _syncToParent();
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        height: 48,
                                        width: 44,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                                          color: const Color(0xffD8D8D8).withOpacity(0.3),
                                        ),
                                        child: const Icon(Icons.playlist_add, color: kMainColor, size: 26),
                                      ),
                                    ),
                                  ),
                                )
                              : TextFormField(
                                  controller: c.stockController,
                                  onChanged: (val) => _syncToParent(),
                                  readOnly: widget.isSerialEnabled,
                                  onTap: widget.isSerialEnabled
                                      ? () {
                                          EasyLoading.showError(_lang.enableSerialAddonToModifyStockForSerialNumbers);
                                        }
                                      : null,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: _lang.stock,
                                    hintText: _lang.enterStock,
                                    border: const OutlineInputBorder(),
                                    filled: widget.isSerialEnabled,
                                    fillColor: widget.isSerialEnabled ? Colors.grey.shade200 : null,
                                  ),
                                ),
                          const SizedBox(height: 24),
                        ],

                        ///_________Purchase Price (Exclusive & Inclusive)____________________
                        if ((modules?.showExclusivePrice == '1' || modules?.showInclusivePrice == '1') &&
                            permissionService.hasPermission(Permit.productsPriceView.value)) ...[
                          Row(
                            children: [
                              if (modules?.showExclusivePrice == '1')
                                Expanded(
                                  child: TextFormField(
                                    controller: c.purchaseExController,
                                    onChanged: (value) => _calculatePrices(index, 'purchase_ex'),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: _lang.purchaseEx,
                                      hintText: _lang.enterPurchasePrice,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              if (modules?.showExclusivePrice == '1' && modules?.showInclusivePrice == '1')
                                const SizedBox(width: 14),
                              if (modules?.showInclusivePrice == '1')
                                Expanded(
                                  child: TextFormField(
                                    controller: c.purchaseIncController,
                                    onChanged: (value) => _calculatePrices(index, 'purchase_inc'),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: _lang.purchaseIn,
                                      hintText: _lang.enterSaltingPrice,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        ///_________Profit Margin & MRP_____________________
                        if (modules?.showProfitPercent == '1' || modules?.showProductSalePrice == '1') ...[
                          Row(
                            children: [
                              if (modules?.showProfitPercent == '1' &&
                                  permissionService.hasPermission(Permit.productsPriceView.value))
                                Expanded(
                                  child: TextFormField(
                                    controller: c.profitController,
                                    onChanged: (value) => _calculatePrices(index, 'profit_margin'),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: _lang.profitMargin,
                                      hintText: _lang.enterPurchasePrice,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              if (modules?.showProfitPercent == '1' &&
                                  modules?.showProductSalePrice == '1' &&
                                  permissionService.hasPermission(Permit.productsPriceView.value))
                                const SizedBox(width: 14),
                              if (modules?.showProductSalePrice == '1')
                                Expanded(
                                  child: TextFormField(
                                    controller: c.saleController,
                                    onChanged: (value) => _calculatePrices(index, 'mrp'),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: _lang.mrp,
                                      hintText: _lang.enterSaltingPrice,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        ///_______Wholesale & Dealer Price_________________
                        if (modules?.showProductWholesalePrice == '1' || modules?.showProductDealerPrice == '1') ...[
                          Row(
                            children: [
                              if (modules?.showProductWholesalePrice == '1')
                                Expanded(
                                  child: TextFormField(
                                    controller: c.wholesaleController,
                                    onChanged: (val) => _syncToParent(),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: _lang.wholeSalePrice,
                                      hintText: _lang.enterWholesalePrice,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              if (modules?.showProductWholesalePrice == '1' && modules?.showProductDealerPrice == '1')
                                const SizedBox(width: 14),
                              if (modules?.showProductDealerPrice == '1')
                                Expanded(
                                  child: TextFormField(
                                    controller: c.dealerController,
                                    onChanged: (val) => _syncToParent(),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: _lang.dealerPrice,
                                      hintText: _lang.enterDealerPrice,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        ///_______Dates_________________
                        if ((modules?.showMfgDate == '1') || (modules?.showExpireDate == '1')) ...[
                          Row(
                            children: [
                              if (modules?.showMfgDate == '1')
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: c.mfgDateController,
                                    decoration: InputDecoration(
                                      labelText: _lang.manuDate,
                                      hintText: _lang.selectDate,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        onPressed: () async {
                                          final DateTime? picked = await showDatePicker(
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2015, 8),
                                            lastDate: DateTime(2101),
                                            context: context,
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              c.mfgDateController.text =
                                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                            });
                                            _syncToParent();
                                          }
                                        },
                                        icon: const Icon(IconlyLight.calendar, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              if (modules?.showMfgDate == '1' && modules?.showExpireDate == '1')
                                const SizedBox(width: 14),
                              if (modules?.showExpireDate == '1')
                                Expanded(
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: c.expDateController,
                                    decoration: InputDecoration(
                                      labelText: _lang.expDate,
                                      hintText: _lang.selectDate,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        onPressed: () async {
                                          final DateTime? picked = await showDatePicker(
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2015, 8),
                                            lastDate: DateTime(2101),
                                            context: context,
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              c.expDateController.text =
                                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                            });
                                            _syncToParent();
                                          }
                                        },
                                        icon: const Icon(IconlyLight.calendar, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Add Batch Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _addBatch,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Add Another Batch"),
            style: TextButton.styleFrom(
              foregroundColor: kMainColor,
            ),
          ),
        ),
      ],
    );
  }
}
