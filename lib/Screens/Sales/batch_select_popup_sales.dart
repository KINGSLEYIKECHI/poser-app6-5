import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Sales/sale_serial_selection_widget.dart';
import 'package:mobile_pos/Screens/Sales/provider/sales_cart_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../Provider/profile_provider.dart';
import '../../currency.dart';
import 'model/sale_add_to_cart_model.dart';

Future<void> showAddItemPopup({
  required BuildContext mainContext,
  required Product productModel,
  required WidgetRef ref,
  required String? customerType,
  required bool fromPOSSales,
}) async {
  TextEditingController searchController = TextEditingController();
  final product = productModel;

  // --- 1. Fetch Addon Status ---
  final businessInfo = ref.read(businessInfoProvider);
  final bool isSerialAddon = businessInfo.value?.data?.addons?.serialCodeAddon ?? false;

  List<SaleCartModel> tempCartItemList = [];
  List<TextEditingController> controllers = [];

  // List to store selected serials corresponding to each stock index
  List<List<dynamic>> stockWiseSelectedSerials = [];

  if (product.stocks?.isNotEmpty ?? false) {
    final cartList = ref.read(cartNotifier).cartItemList;

    for (var element in product.stocks!) {
      num sentProductPrice;

      // --- Determine Price based on Customer Type ---
      if (customerType != null) {
        if (customerType.contains('Dealer')) {
          sentProductPrice = element.productDealerPrice ?? 0;
        } else if (customerType.contains('Wholesaler')) {
          sentProductPrice = element.productWholeSalePrice ?? 0;
        } else if (customerType.contains('Supplier')) {
          sentProductPrice = element.productPurchasePrice ?? 0;
        } else {
          sentProductPrice = element.productSalePrice ?? 0;
        }
      } else {
        sentProductPrice = element.productSalePrice ?? 0;
      }

      // --- Check if item already exists in cart ---
      final existingCartItem = cartList.firstWhere(
        (cartItem) => cartItem.productId == product.id && cartItem.stockId == element.id,
        orElse: () => SaleCartModel(productId: -1, batchName: '', stockId: 0),
      );

      final existingQuantity = existingCartItem.productId != -1 ? existingCartItem.quantity : 0;

      // --- Load existing serials (Using List.from for Deep Copy) ---
      List<dynamic> existingSerials = List.from(existingCartItem.serialNumber ?? []);

      controllers.add(TextEditingController(text: existingQuantity.toString()));
      stockWiseSelectedSerials.add(existingSerials); // Initialize List for this batch

      tempCartItemList.add(SaleCartModel(
        batchName: element.batchNo ?? 'N/A',
        productName: product.productName,
        stockId: element.id ?? 0,
        unitPrice: sentProductPrice,
        productType: product.productType,
        productCode: product.productCode,
        productPurchasePrice: element.productPurchasePrice,
        stock: element.productStock,
        productId: product.id ?? 0,
        quantity: existingQuantity,
        serialNumber: existingSerials,
      ));
    }
  }

  showDialog(
    context: mainContext,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        // --- Logic: Update Quantity for Non-Serial Items ---
        void updateQuantity(int change, int index) {
          int currentQty = int.tryParse(controllers[index].text) ?? 0;
          int updatedQty = currentQty + change;

          if (updatedQty > (tempCartItemList[index].stock ?? 0)) return;
          if (updatedQty < 0) return;
          setState(() {
            controllers[index].text = updatedQty.toString();
          });
        }

        searchController.addListener(() {
          setState(() {});
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Header: Title & Close Button ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.productName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- Search Field (Filter Batches) ---
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: lang.S.of(context).searchBatchNo,
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Batch List Area ---
                  SizedBox(
                    height: 250,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...productModel.stocks!.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;

                            // Filter logic for Batch Name
                            if (!(searchController.text.isEmpty ||
                                (item.batchNo?.toLowerCase().contains(searchController.text.toLowerCase()) ?? true))) {
                              return const SizedBox.shrink();
                            }

                            // --- Logic: Check Serial Availability ---
                            // 1. Addon Enabled? 2. Item has serials?
                            bool hasSerial = isSerialAddon && (item.serialNumbers?.isNotEmpty ?? false);

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // --- Batch Info ---
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${lang.S.of(context).batch}: ${item.batchNo ?? 'N/A'}',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '${lang.S.of(context).stock}: ${item.productStock}',
                                            style: const TextStyle(color: Colors.green),
                                          ),
                                          if (hasSerial)
                                            const Text(
                                              "Serial Item",
                                              style: TextStyle(fontSize: 10, color: kMainColor),
                                            )
                                        ],
                                      ),
                                    ),

                                    // --- Price ---
                                    Text(
                                      '$currency${item.productSalePrice}',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),

                                    const SizedBox(width: 12),

                                    // --- Quantity Control Section ---
                                    hasSerial
                                        ?
                                        // Case A: Serial Enabled Item (Open Serial Selection Widget)
                                        InkWell(
                                            onTap: () {
                                              // Open BatchSerialSelectionWidget
                                              showDialog(
                                                context: context,
                                                builder: (context) => BatchSerialSelectionWidget(
                                                  availableSerials: item.serialNumbers ?? [],
                                                  preSelectedSerials: stockWiseSelectedSerials[index],
                                                  onConfirmed: (selectedList) {
                                                    setState(() {
                                                      // Update selection list and Quantity text
                                                      stockWiseSelectedSerials[index] = selectedList;
                                                      controllers[index].text = selectedList.length.toString();
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: kMainColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: kMainColor),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.qr_code_scanner, size: 16, color: kMainColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${controllers[index].text} Selected",
                                                    style: const TextStyle(
                                                      color: kMainColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        :
                                        // Case B: Normal Item (+/- Buttons)
                                        Row(
                                            children: [
                                              // Decrease Button
                                              InkWell(
                                                onTap: () => updateQuantity(-1, index),
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: const Icon(Icons.remove, size: 16),
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              // Quantity TextField
                                              Container(
                                                width: 60,
                                                height: 32,
                                                alignment: Alignment.center,
                                                child: TextFormField(
                                                  controller: controllers[index],
                                                  textAlign: TextAlign.center,
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(fontSize: 14),
                                                  decoration: InputDecoration(
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                  onChanged: (val) {
                                                    final parsed = int.tryParse(val);
                                                    if (parsed == null ||
                                                        parsed < 0 ||
                                                        parsed > (item.productStock ?? 0)) {
                                                      controllers[index].text = '';
                                                    }
                                                  },
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              // Increase Button
                                              InkWell(
                                                onTap: () => updateQuantity(1, index),
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: const Icon(Icons.add, size: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                                const Divider(),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Add to Cart Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        for (var element in tempCartItemList) {
                          int index = tempCartItemList.indexOf(element);
                          // Update quantity from controller
                          element.quantity = num.tryParse(controllers[index].text) ?? 0;

                          // Update serials from local list to the model
                          if (stockWiseSelectedSerials.isNotEmpty && stockWiseSelectedSerials.length > index) {
                            element.serialNumber = List<String>.from(stockWiseSelectedSerials[index]);
                          }
                        }

                        // Remove items with zero quantity
                        tempCartItemList.removeWhere((element) => element.quantity <= 0);

                        // Add remaining items to the provider
                        for (var element in tempCartItemList) {
                          ref
                              .read(cartNotifier)
                              .addToCartRiverPod(cartItem: element, fromEditSales: false, isVariant: true);
                        }

                        // Close dialogs based on flow
                        if (!fromPOSSales) Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        lang.S.of(context).addedToCart,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
