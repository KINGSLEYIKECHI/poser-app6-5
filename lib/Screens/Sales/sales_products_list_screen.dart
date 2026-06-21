import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Sales/sale_serial_selection_widget.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import 'provider/sales_cart_provider.dart';
import '../../currency.dart';
import 'model/sale_add_to_cart_model.dart';
import '../Products/add product/modle/create_product_model.dart';
import 'batch_select_popup_sales.dart';

class SaleProductsList extends ConsumerStatefulWidget {
  const SaleProductsList({super.key, this.customerModel});

  final Party? customerModel;

  @override
  ConsumerState<SaleProductsList> createState() => _SaleProductsListState();
}

class _SaleProductsListState extends ConsumerState<SaleProductsList> {
  // State Variables
  String productCode = '';
  TextEditingController codeController = TextEditingController();
  int? _selectedWarehouseId; // Null means All Warehouses

  // --- Helper Method for Floating-Point Precision Fix ---
  num _round(num value) {
    return num.parse(value.toStringAsFixed(2));
  }

  @override
  void initState() {
    super.initState();
    codeController.addListener(() {
      setState(() {
        productCode = codeController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  // --- UI Builders ---

  /// Builds Search Bar and Warehouse Dropdown
  Widget _buildTopControls() {
    final businessInfoAsync = ref.watch(businessInfoProvider);

    return Column(
      spacing: 10,
      children: [
        // 1. Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              Flexible(
                child: AppTextField(
                  controller: codeController,
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    hintText: lang.S.of(context).scanCode,
                    prefixIcon: const Icon(Icons.search, color: kGreyTextColor),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kMainColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: kMainColor50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
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
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedIrisScan,
                    color: kMainColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Warehouse Dropdown (Conditional)
        businessInfoAsync.when(
          data: (info) {
            final bool isWarehouseAddonEnabled = info.data?.addons?.warehouseAddon ?? false;
            if (!isWarehouseAddonEnabled) return const SizedBox.shrink();

            final warehouseListAsync = ref.watch(fetchWarehouseListProvider);

            return warehouseListAsync.when(
              data: (data) {
                final warehouses = data.data ?? [];
                if (warehouses.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Filter by Warehouse',
                      labelStyle: const TextStyle(color: kPeraColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedWarehouseId,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        icon: const Icon(Icons.keyboard_arrow_down, color: kPeraColor),
                        hint: const Text("All Warehouses"),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("All Warehouses"),
                          ),
                          ...warehouses.map((w) {
                            return DropdownMenuItem<int?>(
                              value: w.id?.toInt(),
                              child: Text(w.name ?? ''),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedWarehouseId = val;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Builds Shimmer Loading Effect
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        itemCount: 8,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 16, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 100, height: 12, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(width: 50, height: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productListAsync = ref.watch(productProvider);

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          title: Text(lang.S.of(context).addItems),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Column(
          children: [
            // Top Controls (Search & Warehouse)
            _buildTopControls(),

            // Product List
            Expanded(
              child: productListAsync.when(
                data: (products) {
                  // --- Filtering Logic ---
                  final filteredProducts = products.where((product) {
                    final query = productCode.toLowerCase();

                    // 1. Basic Code/Name Match
                    final codeMatch = (product.productCode ?? '').toLowerCase() == query ||
                        product.productCode == '0000' ||
                        productCode.isEmpty;
                    final nameMatch = (product.productName?.toLowerCase() ?? '').contains(query);

                    // 2. Serial Number Match
                    bool serialMatch = false;
                    if (query.isNotEmpty && product.stocks != null) {
                      for (var stock in product.stocks!) {
                        if (stock.serialNumbers != null) {
                          for (var serial in stock.serialNumbers!) {
                            if (serial.toString().toLowerCase() == query) {
                              serialMatch = true;
                              break;
                            }
                          }
                        }
                        if (serialMatch) break;
                      }
                    }

                    // 3. Stock Availability Check
                    bool isCombo = product.productType?.toLowerCase().contains('combo') ?? false;
                    bool hasStock = (product.stocksSumProductStock ?? 0) > 0;

                    // 4. Warehouse Filter Check
                    bool warehouseMatch = true;
                    if (_selectedWarehouseId != null) {
                      final stocks = product.stocks;
                      if (stocks == null || stocks.isEmpty) {
                        warehouseMatch = false;
                      } else {
                        // Check if ANY stock belongs to selected warehouse
                        warehouseMatch = stocks.any((s) => s.warehouseId == _selectedWarehouseId);
                      }
                    }

                    if (!isCombo && !hasStock) return false;

                    return (codeMatch || nameMatch || serialMatch) && warehouseMatch;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(child: Text(lang.S.of(context).noProductFound));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, i) {
                      final product = filteredProducts[i];
                      return _buildProductItem(product);
                    },
                  );
                },
                error: (e, stack) => Center(child: Text('Error: ${e.toString()}')),
                loading: () => _buildShimmerLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Product Item & Logic ---

  Widget _buildProductItem(dynamic product) {
    final isCombo = product.productType?.toLowerCase().contains('combo') ?? false;
    final stocks = product.stocks ?? [];

    // --- 1. Price Logic (With Rounding Fix) ---
    num displayPrice = 0;
    final firstStock = stocks.isNotEmpty ? stocks.first : null;

    if (isCombo) {
      displayPrice = _round(product.productSalePrice ?? 0);
    } else {
      if (widget.customerModel?.type != null) {
        final type = widget.customerModel!.type!;
        if (type.contains('Dealer')) {
          displayPrice = _round(firstStock?.productDealerPrice ?? 0);
        } else if (type.contains('Wholesaler')) {
          displayPrice = _round(firstStock?.productWholeSalePrice ?? 0);
        } else if (type.contains('Supplier')) {
          displayPrice = _round(firstStock?.productPurchasePrice ?? 0);
        } else {
          displayPrice = _round(firstStock?.productSalePrice ?? 0);
        }
      } else {
        displayPrice = _round(firstStock?.productSalePrice ?? 0);
      }
    }

    // --- 2. Stock Logic (Warehouse Aware) ---
    String stockDisplayText;
    if (isCombo) {
      stockDisplayText = "Combo";
    } else {
      num stockCount = 0;
      if (_selectedWarehouseId != null) {
        // Calculate stock ONLY for selected warehouse
        for (var s in stocks) {
          if (s.warehouseId == _selectedWarehouseId) {
            stockCount += (s.productStock ?? 0);
          }
        }
      } else {
        // All warehouses
        stockCount = product.stocksSumProductStock ?? 0;
      }
      stockDisplayText = '${lang.S.of(context).stocks}$stockCount';
    }

    return GestureDetector(
      onTap: () => _handleProductTap(product, isCombo, stocks, displayPrice),
      child: ProductCard(
        productTitle: product.productName.toString(),
        productPrice: displayPrice,
        productImage: product.productPicture,
        stockInfo: stockDisplayText,
      ),
    );
  }

  Future<void> _handleProductTap(dynamic product, bool isCombo, List<dynamic> stocks, num displayPrice) async {
    final providerData = ref.read(cartNotifier);
    final profileInfo = ref.read(businessInfoProvider);

    // 1. Check Out of Stock (Total)
    if (!isCombo && (product.stocksSumProductStock ?? 0) <= 0) {
      EasyLoading.showError(lang.S.of(context).outOfStock);
      return;
    }

    // 2. Check Serial Addon Status
    final bool isSerialAddonEnabled = profileInfo.value?.data?.addons?.serialCodeAddon == true;
    final bool hasSerial = product.hasSerial == 1;

    if (hasSerial && !isSerialAddonEnabled) {
      EasyLoading.showError("Serial add-on is disabled. Cannot sell serial product.");
      return;
    }

    // 3. Logic: Variant OR Multiple Batches
    // (Note: We might want to filter batches by warehouse here too, but for now keeping original logic
    // which opens a popup. The popup typically handles stock selection).
    if (product.productType == ProductType.variant.name || stocks.length > 1) {
      await showAddItemPopup(
        mainContext: context,
        productModel: product,
        ref: ref,
        customerType: widget.customerModel?.type,
        fromPOSSales: false,
      );
    }
    // 4. Single Stock Logic
    else {
      final stock = stocks.firstOrNull;
      if (stock == null && !isCombo) return;

      // 4.1 Serial Logic
      if (hasSerial && isSerialAddonEnabled && !isCombo) {
        // Find existing item in cart
        final existingItem = providerData.cartItemList.firstWhere(
          (element) => element.productId == product.id && element.stockId == stock?.id,
          orElse: () => SaleCartModel(
            batchName: '',
            productId: -1,
            stockId: -1,
            unitPrice: 0,
          ),
        );

        List<dynamic> preSelected = existingItem.productId != -1 ? (existingItem.serialNumber ?? []) : [];

        showDialog(
          context: context,
          builder: (context) => BatchSerialSelectionWidget(
            availableSerials: stock?.serialNumbers ?? [],
            preSelectedSerials: preSelected,
            onConfirmed: (selectedList) {
              if (selectedList.isNotEmpty) {
                SaleCartModel cartItem = SaleCartModel(
                  productName: product.productName,
                  batchName: stock?.batchNo ?? '',
                  stockId: stock?.id ?? 0,
                  unitPrice: displayPrice,
                  productCode: product.productCode,
                  productPurchasePrice:
                      stock?.productPurchasePrice != null ? _round(stock!.productPurchasePrice!) : null,
                  stock: stock?.productStock,
                  productType: product.productType,
                  productId: product.id ?? 0,
                  quantity: selectedList.length,
                  serialNumber: selectedList,
                );

                providerData.addToCartRiverPod(cartItem: cartItem, fromEditSales: false);
                Navigator.pop(context);
              }
            },
          ),
        );
      }
      // 4.2 Standard Product Logic
      else {
        SaleCartModel cartItem = SaleCartModel(
          productName: product.productName,
          batchName: stock?.batchNo ?? '',
          stockId: stock?.id ?? 0,
          unitPrice: displayPrice,
          productCode: product.productCode,
          productPurchasePrice: stock?.productPurchasePrice != null ? _round(stock!.productPurchasePrice!) : null,
          stock: stock?.productStock,
          productType: product.productType,
          productId: product.id ?? 0,
          quantity: (stock?.productStock ?? 0) < 1 ? (isCombo ? 1 : 10) : 1,
        );
        providerData.addToCartRiverPod(cartItem: cartItem, fromEditSales: false);
        Navigator.pop(context);
      }
    }
  }
}

// --- Product Card Widget ---

class ProductCard extends StatelessWidget {
  final String productTitle;
  final num productPrice;
  final String stockInfo;
  final String? productImage;

  const ProductCard({
    super.key,
    required this.productTitle,
    required this.productPrice,
    required this.productImage,
    required this.stockInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- Number Formatting Logic ---
    String formattedPrice = productPrice % 1 == 0 ? productPrice.toInt().toString() : productPrice.toStringAsFixed(2);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.grey.shade100,
                      image: productImage == null
                          ? DecorationImage(image: AssetImage(noProductImageUrl), fit: BoxFit.cover)
                          : DecorationImage(
                              image: NetworkImage("$productImage"),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
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
                        const SizedBox(height: 4),
                        Text(
                          stockInfo,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$currency$formattedPrice',
              style: theme.textTheme.titleMedium!.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
