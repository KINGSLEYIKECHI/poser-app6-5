import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

// Adjust imports to match your project structure
import '../../Provider/profile_provider.dart';
import '../../generated/l10n.dart' as lang;
import '../../Provider/add_to_cart_purchase.dart';
import '../../Provider/product_provider.dart';
import '../../constant.dart';
import '../Products/Model/product_model.dart';
import '../Products/Repo/product_repo.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../Products/add product/modle/create_product_model.dart';
import '../warehouse/warehouse_provider/warehouse_provider.dart';
import 'Repo/purchase_repo.dart';
import '../Products/add product/serial_code_section.dart';

Future<void> addProductInPurchaseCartButtomSheet({
  required BuildContext context,
  required CartProductModelPurchase product,
  required WidgetRef ref,
  required bool fromUpdate,
  required int index,
  required bool fromStock,
  required List<Stock> stocks,
  num? selectedWarehouseId,
  num? stockId,
}) {
  final theme = Theme.of(context);
  final permissionService = PermissionService(ref);
  final _formKey = GlobalKey<FormState>();
  final decimalFormatter = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];

  // --- State Variables ---
  List<dynamic> serialList = product.serialNumber ?? [];
  num? currentWarehouseId = selectedWarehouseId ?? product.warehouseId;
  Stock? selectedStock;

  // --- Controllers ---
  // সিরিয়াল প্রোডাক্ট হলে ডিফল্ট কোয়ান্টিটি হবে সিরিয়াল লিস্টের লেংথ (শুরুতে ০), অন্যথায় রেগুলার কোয়ান্টিটি
  final stockCtrl = TextEditingController(
    text: product.isSerialEnabled ? serialList.length.toString() : product.quantities.toString(),
  );

  final salePriceCtrl = TextEditingController(text: '${product.productSalePrice ?? 0}');
  final purchaseIncCtrl = TextEditingController(text: '${product.productPurchasePrice ?? 0}');
  final profitMarginCtrl = TextEditingController(text: '${product.profitPercent ?? 0}');
  final wholeSaleCtrl = TextEditingController(text: '${product.productWholeSalePrice ?? 0}');
  final dealerPriceCtrl = TextEditingController(text: '${product.productDealerPrice ?? 0}');
  final batchCtrl = TextEditingController(text: product.batchNumber ?? '');
  final mfgDateCtrl = TextEditingController(text: product.mfgDate ?? '');
  final expDateCtrl = TextEditingController(text: product.expireDate ?? '');

  // Pre-select stock if batch number exists
  if (product.batchNumber != null && stocks.isNotEmpty) {
    try {
      selectedStock = stocks.firstWhere((s) => s.batchNo == product.batchNumber);
      if (selectedWarehouseId == null) currentWarehouseId = selectedStock.warehouseId;
    } catch (_) {}
  }

  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final businessData = ref.watch(businessInfoProvider).value?.data;
          final bool isWarehouseEnabled = businessData?.addons?.warehouseAddon == true;
          final bool isSerialEnabled = product.isSerialEnabled && (businessData?.addons?.serialCodeAddon == true);

          return StatefulBuilder(
            builder: (context, setState) {
              // --- Price Calculator Logic ---
              void calculatePrice(String source) {
                num incPrice = num.tryParse(purchaseIncCtrl.text) ?? 0;
                num salePrice = num.tryParse(salePriceCtrl.text) ?? 0;
                num margin = num.tryParse(profitMarginCtrl.text) ?? 0;
                num vatRate = product.vatRate ?? 0;

                num excPrice = incPrice / (1 + vatRate / 100);
                num baseCost = product.vatType.toLowerCase() == 'exclusive' ? excPrice : incPrice;

                if (source == 'purchase_inc' || source == 'margin') {
                  // Calculate Sale Price based on new Purchase Price or Margin
                  salePrice = baseCost + (baseCost * margin / 100);
                  salePriceCtrl.text = salePrice.toStringAsFixed(2);
                } else if (source == 'mrp') {
                  // Calculate Margin based on new Sale Price
                  if (baseCost > 0) {
                    margin = ((salePrice - baseCost) / baseCost) * 100;
                    profitMarginCtrl.text = margin.toStringAsFixed(2);
                  }
                }
              }

              // --- Apply Selected Stock Logic ---
              void applyStockDetails(Stock stock) {
                batchCtrl.text = stock.batchNo ?? '';
                purchaseIncCtrl.text = stock.productPurchasePrice?.toString() ?? '0';
                salePriceCtrl.text = stock.productSalePrice?.toString() ?? '0';
                wholeSaleCtrl.text = stock.productWholeSalePrice?.toString() ?? '0';
                dealerPriceCtrl.text = stock.productDealerPrice?.toString() ?? '0';
                mfgDateCtrl.text = stock.mfgDate ?? '';
                expDateCtrl.text = stock.expireDate ?? '';

                if (selectedWarehouseId == null) currentWarehouseId = stock.warehouseId;
                calculatePrice('mrp'); // Re-calculate margin
              }

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Header ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.S.of(context).addVariantDetails, style: theme.textTheme.titleMedium),
                            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                          ],
                        ),
                        const Divider(color: kBorderColor),
                        const SizedBox(height: 12),

                        // --- Dropdowns (Warehouse & Stock) ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isWarehouseEnabled)
                              Expanded(
                                child: ref.watch(fetchWarehouseListProvider).when(
                                      data: (warehouseModel) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(lang.S.of(context).warehouse,
                                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(height: 5),
                                            DropdownButtonFormField<num>(
                                              value: currentWarehouseId,
                                              isExpanded: true,
                                              decoration: kInputDecoration.copyWith(
                                                hintText: lang.S.of(context).select,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                fillColor: selectedWarehouseId != null ? Colors.grey.shade200 : null,
                                                filled: selectedWarehouseId != null,
                                              ),
                                              items: (warehouseModel.data ?? []).map((warehouse) {
                                                return DropdownMenuItem<num>(
                                                  value: warehouse.id,
                                                  child: Text(warehouse.name ?? 'Unknown',
                                                      overflow: TextOverflow.ellipsis),
                                                );
                                              }).toList(),
                                              onChanged: selectedWarehouseId != null
                                                  ? null
                                                  : (val) => setState(() => currentWarehouseId = val),
                                            ),
                                          ],
                                        );
                                      },
                                      error: (e, s) => const SizedBox.shrink(),
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                    ),
                              ),
                            if (isWarehouseEnabled && product.productType != 'single') const SizedBox(width: 12),
                            if (product.productType != 'single')
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lang.S.of(context).stockOrVariant,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 5),
                                    DropdownButtonFormField<Stock>(
                                      value: selectedStock,
                                      isExpanded: true,
                                      decoration: kInputDecoration.copyWith(
                                        // Dynamic hintText based on product.variantName
                                        hintText: (product.variantName != null && product.variantName!.isNotEmpty)
                                            ? product.variantName
                                            : lang.S.of(context).selectStock,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      items: stocks.map((stock) {
                                        String name = stock.batchNo ?? lang.S.of(context).noBatch;
                                        if (stock.variantName != null) name = "${stock.variantName} ($name)";
                                        return DropdownMenuItem<Stock>(
                                          value: stock,
                                          child: Text(name, overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedStock = val;
                                          if (val != null) applyStockDetails(val);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Batch & Quantity ---
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: batchCtrl,
                                decoration: kInputDecoration.copyWith(
                                  labelText: lang.S.of(context).batchNo,
                                  hintText: lang.S.of(context).enterBatchNo,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: isSerialEnabled
                                  ? TextFormField(
                                      controller: stockCtrl,
                                      readOnly: true,
                                      validator: (val) => (num.tryParse(val ?? '') ?? 0) <= 0
                                          ? lang.S.of(context).purchaseQuantityRequired
                                          : null,
                                      decoration: kInputDecoration.copyWith(
                                        labelText: lang.S.of(context).quantity,
                                        hintText: "0",
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            List<dynamic> oldSerials =
                                                stocks.expand((e) => e.serialNumbers ?? []).toList();
                                            showSerialModal(
                                              oldSerials: oldSerials,
                                              context: context,
                                              initialSerials: serialList,
                                              onSave: (updatedList) {
                                                setState(() {
                                                  serialList = updatedList;
                                                  stockCtrl.text = serialList.length.toString();
                                                });
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: 44,
                                            decoration: BoxDecoration(
                                              color: const Color(0xffD8D8D8).withOpacity(0.3),
                                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                                            ),
                                            child: const Icon(Icons.playlist_add, color: kMainColor, size: 26),
                                          ),
                                        ),
                                      ),
                                    )
                                  : TextFormField(
                                      controller: stockCtrl,
                                      inputFormatters: decimalFormatter,
                                      keyboardType: TextInputType.number,
                                      decoration: kInputDecoration.copyWith(
                                        labelText: lang.S.of(context).quantity,
                                        hintText: lang.S.of(context).enterQuantity,
                                      ),
                                      validator: (val) => (num.tryParse(val ?? '') ?? 0) <= 0
                                          ? lang.S.of(context).purchaseQuantityRequired
                                          : null,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Pricing ---
                        if (permissionService.hasPermission(Permit.purchasesPriceView.value)) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: purchaseIncCtrl,
                                  onChanged: (_) => setState(() => calculatePrice('purchase_inc')),
                                  inputFormatters: decimalFormatter,
                                  keyboardType: TextInputType.number,
                                  decoration: kInputDecoration.copyWith(labelText: lang.S.of(context).purchaseIn),
                                  validator: (val) =>
                                      (num.tryParse(val ?? '') ?? 0) <= 0 ? lang.S.of(context).purchaseInReq : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: profitMarginCtrl,
                                  onChanged: (_) => setState(() => calculatePrice('margin')),
                                  inputFormatters: decimalFormatter,
                                  keyboardType: TextInputType.number,
                                  decoration: kInputDecoration.copyWith(labelText: lang.S.of(context).profitMargin),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: salePriceCtrl,
                                  onChanged: (_) => setState(() => calculatePrice('mrp')),
                                  inputFormatters: decimalFormatter,
                                  keyboardType: TextInputType.number,
                                  decoration: kInputDecoration.copyWith(labelText: lang.S.of(context).mrp),
                                  validator: (val) =>
                                      (num.tryParse(val ?? '') ?? 0) <= 0 ? lang.S.of(context).saleReq : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // --- Wholesale & Dealer ---
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: wholeSaleCtrl,
                                inputFormatters: decimalFormatter,
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(labelText: lang.S.of(context).wholeSalePrice),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: dealerPriceCtrl,
                                inputFormatters: decimalFormatter,
                                keyboardType: TextInputType.number,
                                decoration: kInputDecoration.copyWith(labelText: lang.S.of(context).dealerPrice),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Dates ---
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: mfgDateCtrl,
                                readOnly: true,
                                decoration: kInputDecoration.copyWith(
                                  labelText: lang.S.of(context).manufactureDate,
                                  suffixIcon: IconButton(
                                    icon: const Icon(IconlyLight.calendar),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015),
                                          lastDate: DateTime(2101));
                                      if (picked != null)
                                        setState(() => mfgDateCtrl.text = DateFormat.yMd().format(picked));
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: expDateCtrl,
                                readOnly: true,
                                decoration: kInputDecoration.copyWith(
                                  labelText: lang.S.of(context).expDate,
                                  suffixIcon: IconButton(
                                    icon: const Icon(IconlyLight.calendar),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2015),
                                          lastDate: DateTime(2101));
                                      if (picked != null)
                                        setState(() => expDateCtrl.text = DateFormat.yMd().format(picked));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Action Buttons ---
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xffF68A3D))),
                                child:
                                    Text(lang.S.of(context).cancel, style: const TextStyle(color: Color(0xffF68A3D))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Generate Cart Item
                                    final cartProduct = CartProductModelPurchase(
                                      isSerialEnabled: isSerialEnabled,
                                      warehouseId: currentWarehouseId,
                                      productId: product.productId,
                                      variantName: product.productType == 'single'
                                          ? product.variantName
                                          : (selectedStock?.variantName ?? product.variantName),
                                      brandName: product.brandName,
                                      productName: product.productName,
                                      productType: product.productType,
                                      vatAmount: product.vatAmount,
                                      vatRate: product.vatRate,
                                      vatType: product.vatType,
                                      batchNumber: batchCtrl.text,
                                      productDealerPrice: num.tryParse(dealerPriceCtrl.text),
                                      productPurchasePrice: num.tryParse(purchaseIncCtrl.text),
                                      productSalePrice: num.tryParse(salePriceCtrl.text),
                                      productWholeSalePrice: num.tryParse(wholeSaleCtrl.text),
                                      quantities: num.tryParse(stockCtrl.text),
                                      profitPercent: num.tryParse(profitMarginCtrl.text),
                                      expireDate: dateFormateChange(date: expDateCtrl.text),
                                      mfgDate: dateFormateChange(date: mfgDateCtrl.text),
                                      serialNumber: serialList,
                                    );

                                    // Execution Logic
                                    if (fromStock) {
                                      bool success = await ProductRepo().updateVariation(
                                          stockId: stockId.toString(), data: cartProduct, context: context, ref: ref);
                                      if (success) {
                                        ref.refresh(productProvider);
                                        ref.refresh(fetchProductDetails(product.productId.toString()));
                                        Navigator.pop(context);
                                      }
                                    } else if (fromUpdate) {
                                      ref
                                          .read(cartNotifierPurchaseNew)
                                          .updateProduct(index: index, newProduct: cartProduct);
                                      Navigator.pop(context);
                                    } else {
                                      ref.read(cartNotifierPurchaseNew).addToCartRiverPod(
                                          cartItem: cartProduct,
                                          isVariation: product.productType == ProductType.variant.name);
                                      // Close modal and product list sheet
                                      int count = 0;
                                      Navigator.popUntil(context, (_) => count++ == 2);
                                    }
                                  }
                                },
                                child: Text(lang.S.of(context).saveVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

// Helper: Formats Date
String dateFormateChange({required String? date}) {
  if (date == null || date.trim().isEmpty) return '';
  try {
    DateTime parsed = date.contains('-') ? DateTime.parse(date) : DateFormat("M/d/yyyy").parse(date);
    return DateFormat("yyyy-MM-dd").format(parsed);
  } catch (_) {
    return '';
  }
}
