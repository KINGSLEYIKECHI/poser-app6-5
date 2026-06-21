import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Sales/sale_serial_selection_widget.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_cart_data_model.dart';
import 'package:mobile_pos/Screens/transfer/provider/transfer_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../currency.dart';

class TransferProductList extends StatefulWidget {
  final String? fromBranchId;
  final String? fromWarehouseId;

  const TransferProductList({super.key, this.fromBranchId, this.fromWarehouseId});

  @override
  // ignore: library_private_types_in_public_api
  _TransferProductListState createState() => _TransferProductListState();
}

class _TransferProductListState extends State<TransferProductList> {
  String productCode = '0000';
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);

    return GlobalPopup(
      child: Consumer(builder: (context, ref, __) {
        final productList = ref.watch(productProvider);
        final profileInfo = ref.watch(businessInfoProvider);
        final cartList = ref.watch(transferCartProvider);

        return Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(_lang.addTransferItem),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar & Scanner Row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppTextField(
                            controller: codeController,
                            textFieldType: TextFieldType.NAME,
                            onChanged: (value) {
                              setState(() {
                                productCode = value.trim();
                              });
                            },
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).productCode,
                              hintText: (productCode == '0000' || productCode == '-1' || productCode.isEmpty)
                                  ? lang.S.of(context).scanCode
                                  : productCode,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) => BarcodeScannerWidget(
                                onBarcodeFound: (String code) {
                                  setState(() {
                                    productCode = code;
                                    codeController.text = productCode;
                                  });
                                },
                              ),
                            );
                          },
                          child: const BarCodeButton(),
                        ),
                      ),
                    ],
                  ),

                  // Product List
                  productList.when(
                    data: (products) {
                      final filteredProducts = products.where((product) {
                        final codeMatch = product.productCode == productCode ||
                            productCode == '0000' ||
                            productCode == '-1' ||
                            productCode.isEmpty;
                        final nameMatch =
                            (product.productName?.toLowerCase() ?? '').contains(productCode.toLowerCase());

                        // Validate if stock exists based on conditions
                        bool hasStock = false;

                        if (widget.fromWarehouseId != null) {
                          // Filter by Warehouse ID
                          hasStock = product.stocks?.any((s) =>
                                  s.warehouseId.toString() == widget.fromWarehouseId && (s.productStock ?? 0) > 0) ??
                              false;
                        } else if (widget.fromBranchId != null) {
                          // Filter by Branch ID
                          hasStock = product.stocks?.any(
                                  (s) => s.branchId.toString() == widget.fromBranchId && (s.productStock ?? 0) > 0) ??
                              false;
                        } else {
                          // No branch or warehouse provided (allow anything with stock)
                          hasStock = product.stocksSumProductStock != null && product.stocksSumProductStock! > 0;
                        }

                        return (codeMatch || nameMatch) && hasStock;
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: Text(lang.S.of(context).noProductFound),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        itemBuilder: (_, i) {
                          final product = filteredProducts[i];

                          // Filter Valid Stocks
                          List<Stock> validStocks = [];

                          if (widget.fromWarehouseId != null) {
                            validStocks = product.stocks
                                    ?.where((s) => s.warehouseId.toString() == widget.fromWarehouseId)
                                    .toList() ??
                                [];
                          } else if (widget.fromBranchId != null) {
                            validStocks =
                                product.stocks?.where((s) => s.branchId.toString() == widget.fromBranchId).toList() ??
                                    [];
                          } else {
                            // If no condition, show all valid stock records
                            validStocks = product.stocks?.where((s) => (s.productStock ?? 0) > 0).toList() ?? [];
                          }

                          if (validStocks.isEmpty) return const SizedBox();

                          // Display Calculation
                          num displayPrice = validStocks.first.productPurchasePrice ?? 0;
                          num totalQty = validStocks.fold(0, (sum, item) => sum + (item.productStock ?? 0));
                          String stockDisplayText = '${lang.S.of(context).stocks}: $totalQty';

                          return GestureDetector(
                            onTap: () async {
                              // Serial Logic
                              final bool isSerialAddonEnabled =
                                  profileInfo.value?.data?.addons?.serialCodeAddon == true;
                              final bool hasSerial = product.hasSerial == 1;

                              if (hasSerial && !isSerialAddonEnabled) {
                                EasyLoading.showError("Serial add-on is disabled. Cannot transfer serial product.");
                                return;
                              }

                              // Multi-Batch / Variant Logic (Popup)
                              if (product.productType == 'variant' || validStocks.length > 1) {
                                await showTransferBatchPopup(
                                  context: context,
                                  ref: ref,
                                  product: product,
                                  validStocks: validStocks,
                                  hasSerial: hasSerial,
                                  isSerialAddonEnabled: isSerialAddonEnabled,
                                  cartList: cartList,
                                );
                              }
                              // Single Batch Logic (Direct)
                              else {
                                final stock = validStocks.first;
                                _handleAddProductLogic(
                                  context: context,
                                  ref: ref,
                                  product: product,
                                  stock: stock,
                                  hasSerial: hasSerial,
                                  isSerialAddonEnabled: isSerialAddonEnabled,
                                  cartList: cartList,
                                );
                              }
                            },
                            child: TransferProductCard(
                              productTitle: product.productName.toString(),
                              productPrice: displayPrice,
                              productImage: product.productPicture,
                              stockInfo: stockDisplayText,
                            ),
                          );
                        },
                      );
                    },
                    error: (e, stack) => Center(child: Text('Error: ${e.toString()}')),
                    loading: () => const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- Logic to Handle Adding Product ---
  void _handleAddProductLogic({
    required BuildContext context,
    required WidgetRef ref,
    required Product product,
    required Stock stock,
    required bool hasSerial,
    required bool isSerialAddonEnabled,
    required List<TransferCartItem> cartList,
  }) {
    num availableQty = stock.productStock ?? 0;

    if (availableQty <= 0) {
      EasyLoading.showError(lang.S.of(context).outOfStock);
      return;
    }

    // Serial Product
    if (hasSerial && isSerialAddonEnabled) {
      final existingItemIndex =
          cartList.indexWhere((element) => element.productId == product.id.toString() && element.stockId == stock.id);

      List<String> preSelected = [];
      if (existingItemIndex != -1) {
        preSelected = List.from(cartList[existingItemIndex].serialNumber ?? []);
      }

      List<String> availableSerials = stock.serialNumbers?.map((e) => e.toString()).toList() ?? [];

      if (availableSerials.isEmpty) {
        EasyLoading.showError("No serial numbers available for this stock.");
        return;
      }

      showDialog(
        context: context,
        builder: (context) => BatchSerialSelectionWidget(
          availableSerials: availableSerials,
          preSelectedSerials: preSelected,
          onConfirmed: (selectedList) {
            if (selectedList.isNotEmpty) {
              if (existingItemIndex != -1) {
                ref.read(transferCartProvider.notifier).removeItem(existingItemIndex);
              }
              TransferCartItem cartItem = TransferCartItem(
                productId: product.id.toString(),
                productName: product.productName.toString(),
                stockId: stock.id ?? 0,
                productCode: product.productCode.toString(),
                purchasePrice: stock.productPurchasePrice ?? 0,
                quantity: selectedList.length,
                currentStock: availableQty,
                serialNumber: selectedList,
              );

              ref.read(transferCartProvider.notifier).addItem(cartItem);
              EasyLoading.showSuccess("Added: ${product.productName} (${selectedList.length})");
              Navigator.pop(context); // Close Serial Dialog
            }
          },
        ),
      );
    }
    // Standard Product
    else {
      TransferCartItem cartItem = TransferCartItem(
        productId: product.id.toString(),
        productName: product.productName.toString(),
        stockId: stock.id ?? 0,
        productCode: product.productCode.toString(),
        purchasePrice: stock.productPurchasePrice ?? 0,
        quantity: 1,
        currentStock: availableQty,
        serialNumber: null,
      );

      ref.read(transferCartProvider.notifier).addItem(cartItem);
      EasyLoading.showSuccess("Added: ${product.productName}");
      Navigator.pop(context); // Close Screen
    }
  }

  // --- UPDATED BATCH POPUP (Sales Style) ---
  Future<void> showTransferBatchPopup({
    required BuildContext context,
    required WidgetRef ref,
    required Product product,
    required List<Stock> validStocks,
    required bool hasSerial,
    required bool isSerialAddonEnabled,
    required List<TransferCartItem> cartList,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        final _lang = lang.S.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _lang.selectBranch,
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Product Info
                Text(
                  product.productName ?? '',
                  style: const TextStyle(fontSize: 14.0, color: kGreyTextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Divider(),
                // Batch List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: validStocks.length,
                    itemBuilder: (context, index) {
                      final stock = validStocks[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _handleAddProductLogic(
                            context: context,
                            ref: ref,
                            product: product,
                            stock: stock,
                            hasSerial: hasSerial,
                            isSerialAddonEnabled: isSerialAddonEnabled,
                            cartList: cartList,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            children: [
                              // Batch Icon/Text
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kMainColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  stock.batchNo ?? 'N/A',
                                  style: const TextStyle(color: kMainColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${lang.S.of(context).stocks}: ${stock.productStock}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_lang.price}: $currency${stock.productPurchasePrice}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class TransferProductCard extends StatelessWidget {
  TransferProductCard({
    super.key,
    required this.productTitle,
    required this.productPrice,
    required this.productImage,
    required this.stockInfo,
  });

  String productTitle;
  num productPrice;
  String stockInfo;
  String? productImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: productImage == null
                        ? BoxDecoration(
                            image: DecorationImage(image: AssetImage(noProductImageUrl), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(90.0),
                          )
                        : BoxDecoration(
                            image: DecorationImage(image: NetworkImage("$productImage"), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(90.0),
                          ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          productTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium!.copyWith(fontSize: 16),
                        ),
                        Text(
                          stockInfo,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currency$productPrice',
                style: theme.textTheme.titleMedium!.copyWith(fontSize: 16),
              ),
              Text(
                lang.S.of(context).purchasePrice,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              )
            ],
          ),
        ],
      ),
    );
  }
}
