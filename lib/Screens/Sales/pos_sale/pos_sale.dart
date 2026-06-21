import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../../Provider/product_provider.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../core/helpers/helpers.export.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../currency.dart';
import '../../../generated/l10n.dart' as l;
import '../../../service/check_actions_when_no_branch.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../Products/Model/product_model.dart' as product_model;
import '../../Products/Model/product_total_stock_model.dart' as product_paginated_model;
import '../../Products/add product/modle/create_product_model.dart';
import '../../product_category/model/category_model.dart';
import '../../product_category/provider/product_category_provider/product_unit_provider.dart';
import '../../warehouse/warehouse_provider/warehouse_provider.dart';
import '../add_sales.dart';
import '../batch_select_popup_sales.dart';
import '../model/sale_add_to_cart_model.dart' as sale_cart_model;
import '../provider/sales_cart_provider.dart';
import '../sale_serial_selection_widget.dart';
import '_customer_search_field.dart';

class PosSaleScreen extends ConsumerStatefulWidget {
  const PosSaleScreen({super.key});

  @override
  ConsumerState<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends _$PosSaleScreenState {
  num _getDynamicPrice(product_model.Product product) {
    bool isCombo = product.productType?.toLowerCase().contains('combo') ?? false;
    if (isCombo) {
      return product.productSalePrice ?? 0;
    }

    final stock = product.stocks?.isNotEmpty == true ? product.stocks!.last : null;
    if (stock == null) return 0;

    final partyType = selectedFilterNotifier.value.customer?.type ?? 'Retailer';

    if (partyType.contains('Dealer')) return stock.productDealerPrice ?? 0;
    if (partyType.contains('Wholesaler')) return stock.productWholeSalePrice ?? 0;
    if (partyType.contains('Supplier')) return stock.productPurchasePrice ?? 0;

    return stock.productSalePrice ?? 0;
  }

  void _processAdd(
    product_model.Product product,
    product_model.Stock? stock,
    bool isCombo, {
    List<dynamic>? selectedList,
  }) {
    final providerData = ref.read(cartNotifier);

    String getPriceByCustomerType() {
      if (isCombo) return product.productSalePrice.toString();
      if (stock == null) return '0';

      final partyType = selectedFilterNotifier.value.customer?.type ?? 'Retailer';

      if (partyType.contains('Dealer')) return stock.productDealerPrice.toString();
      if (partyType.contains('Wholesaler')) return stock.productWholeSalePrice.toString();
      if (partyType.contains('Supplier')) return stock.productPurchasePrice.toString();
      return stock.productSalePrice.toString();
    }

    num qty = 1;
    if (selectedList != null) {
      qty = selectedList.length;
    }

    final cartItem = sale_cart_model.SaleCartModel(
      productName: product.productName,
      batchName: stock?.batchNo ?? '',
      stockId: stock?.id?.round() ?? 0,
      unitPrice: num.tryParse(getPriceByCustomerType()),
      productCode: product.productCode,
      productPurchasePrice: stock?.productPurchasePrice ?? 0,
      stock: product.stocksSumProductStock ?? 0,
      productType: product.productType,
      productId: product.id ?? 0,
      quantity: qty,
      serialNumber: selectedList != null ? List<String>.from(selectedList) : null,
    );

    providerData.addToCartRiverPod(cartItem: cartItem);
  }

  void _processRemove(product_model.Product product) {
    final providerData = ref.read(cartNotifier);
    providerData.deleteAllVariant(productId: product.id ?? 0);
  }

  @override
  void initState() {
    super.initState();
    ref.refresh(cartNotifier);

    // Listen for customer type changes to clear cart
    String currentCustomerType = selectedFilterNotifier.value.customer?.type ?? 'Retailer';
    selectedFilterNotifier.addListener(() {
      String newCustomerType = selectedFilterNotifier.value.customer?.type ?? 'Retailer';
      if (currentCustomerType != newCustomerType) {
        ref.read(cartNotifier).clearCart();
        currentCustomerType = newCustomerType;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessInfoAsync = ref.watch(businessInfoProvider);
    final providerData = ref.watch(cartNotifier);
    final permissionService = PermissionService(ref);

    final lang = l.S.of(context);
    final _theme = Theme.of(context);

    return GlobalPopup(
      child: GestureDetector(
        onTap: FocusManager.instance.primaryFocus?.unfocus,
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(lang.posSale),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Search & Filters
              ValueListenableBuilder(
                valueListenable: selectedFilterNotifier,
                builder: (_, filter, __) {
                  return Padding(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                    child: Column(
                      children: [
                        // Customer
                        CustomerSearchField(
                          selectedCustomer: filter.customer,
                          onCustomerSelected: (v) {
                            selectedFilterNotifier.value = filter.copyWith(customer: v);
                          },
                        ),
                        const SizedBox.square(dimension: 16),

                        // Search Field & Barcode
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextFormField(
                                controller: productSearchController,
                                decoration: InputDecoration(
                                  hintText: lang.searchWith,
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (productSearchController.text.isNotEmpty)
                                        IconButton(
                                          visualDensity: const VisualDensity(horizontal: -4),
                                          tooltip: 'Clear',
                                          onPressed: () {
                                            selectedFilterNotifier.value =
                                                product_paginated_model.PaginatedProductListFilter();
                                            return productSearchController.clear();
                                          },
                                          icon: const Icon(Icons.close, size: 20, color: kSubPeraColor),
                                        ),
                                      GestureDetector(
                                        onTap: () => _showFilterBottomSheet(context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Container(
                                            width: 50,
                                            height: 45,
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: kMainColor50,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(5),
                                                bottomRight: Radius.circular(5),
                                              ),
                                            ),
                                            child: SvgPicture.asset('assets/filter.svg'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onChanged: (value) {
                                  selectedFilterNotifier.value = filter.copyWith(search: value);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () async {
                                  await showDialog<void>(
                                    context: context,
                                    builder: (barcodeContext) => BarcodeScannerWidget(
                                      onBarcodeFound: (String code) {
                                        productSearchController.text = code;
                                        selectedFilterNotifier.value = filter.copyWith(search: code);
                                      },
                                    ),
                                  );
                                },
                                child: const BarCodeButton(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox.square(dimension: 12),

                        // Warehouse Filter
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
                                  padding: const EdgeInsets.only(top: 10),
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
                                        value: filter.warehouseId,
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
                                        onChanged: (val) => selectedFilterNotifier.value = filter.copyWith(
                                          warehouseId: val,
                                        ),
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
                    ),
                  );
                },
              ),

              // Products
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(pagingController.refresh),
                  child: PagedGridView<int, product_model.Product>(
                    padding: const EdgeInsets.all(16).copyWith(top: 8),
                    pagingController: pagingController,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 0.85,
                      maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
                      mainAxisExtent: 180,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, product, index) {
                        bool isSelected = providerData.cartItemList.any((item) => item.productId == product.id);

                        // Calculate total quantity across all batches/variants for this product
                        num totalQuantity = 0;
                        if (isSelected) {
                          totalQuantity = providerData.cartItemList
                              .where((item) => item.productId == product.id)
                              .fold(0, (sum, item) => sum + item.quantity);
                        }

                        return GestureDetector(
                          onTap: () => _handleAddToCart(product),
                          child: _buildProductCard(product, isSelected, totalQuantity, _theme, providerData),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              providerData.cartItemList.isNotEmpty ? _buildBottomContinueButton(permissionService, context) : null,
        ),
      ),
    );
  }

  Future<void> _showFilterBottomSheet(BuildContext context) async {
    final _existingFilter = selectedFilterNotifier.value;
    final modalFilterNotifier = ValueNotifier<product_paginated_model.PaginatedProductListFilter>(
      _existingFilter,
    );

    final _result = await showModalBottomSheet<product_paginated_model.PaginatedProductListFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      builder: (modalContext) {
        return Consumer(
          builder: (_, ref, child) {
            final categoryData = ref.watch(categoryProvider);

            final lang = l.S.of(modalContext);
            final _theme = Theme.of(modalContext);

            return ValueListenableBuilder(
              valueListenable: modalFilterNotifier,
              builder: (_, modalFilter, __) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang.filter,
                              style: _theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(modalContext);
                              },
                              icon: const Icon(Icons.close, size: 18),
                            )
                          ],
                        ),
                      ),
                      const Divider(color: kBorderColor, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            categoryData.when(
                              data: (catSnap) {
                                return DropdownButtonFormField2<CategoryModel>(
                                  value: modalFilter.category,
                                  hint: Text(lang.selectOne),
                                  items: catSnap.map((category) {
                                    return DropdownMenuItem<CategoryModel>(
                                      value: category,
                                      child: Text(category.categoryName ?? 'Unnamed'),
                                    );
                                  }).toList(),
                                  onChanged: (CategoryModel? value) {
                                    modalFilterNotifier.value = modalFilter.copyWith(category: value);
                                  },
                                  decoration: InputDecoration(
                                    labelText: lang.category,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                );
                              },
                              error: (e, stack) => Text('Error: $e'),
                              loading: () => const Center(child: CircularProgressIndicator()),
                            ),
                            const SizedBox(height: 10),
                            ...[
                              (
                                value: "low_to_high",
                                label: lang.lowToHighPrice,
                              ),
                              (
                                value: "high_to_low",
                                label: lang.highToLowPrice,
                              ),
                            ].map((entry) {
                              return RadioListTile<String>(
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                                contentPadding: EdgeInsets.zero,
                                value: entry.value,
                                title: Text(entry.label),
                                groupValue: modalFilter.priceSort,
                                onChanged: (value) {
                                  modalFilterNotifier.value = modalFilter.copyWith(priceSort: value);
                                },
                              );
                            }),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(
                                      modalContext,
                                      const product_paginated_model.PaginatedProductListFilter(),
                                    ),
                                    child: Text(lang.cancel),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(modalContext, modalFilter),
                                    child: Text(lang.apply),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (_result != null) {
      selectedFilterNotifier.value = _result;
    }
  }

  Future<void> _handleAddToCart(product_model.Product product) async {
    final providerData = ref.read(cartNotifier);
    final profileInfo = ref.read(businessInfoProvider);
    final _theme = Theme.of(context);

    bool isSerialAddonEnabled = profileInfo.value?.data?.addons?.serialCodeAddon == true;
    bool hasSerial = product.hasSerial == 1;

    if (hasSerial && !isSerialAddonEnabled) {
      EasyLoading.showError("Serial add-on is disabled. Cannot sell serial product.");
      return;
    }

    bool hasMultipleBatches = (product.stocks?.length ?? 0) > 1;

    if (product.productType == ProductType.variant.name || hasMultipleBatches) {
      await showAddItemPopup(
        mainContext: context,
        productModel: product,
        ref: ref,
        customerType: selectedFilterNotifier.value.customer?.type ?? 'Retailer',
        fromPOSSales: true,
      );
      return;
    }

    bool isCombo = product.productType?.toLowerCase().contains('combo') ?? false;

    num availableStock = 0;
    if (selectedFilterNotifier.value.warehouseId != null) {
      if (product.stocks != null) {
        for (var s in product.stocks!) {
          if (s.warehouseId == selectedFilterNotifier.value.warehouseId) {
            availableStock += (s.productStock ?? 0);
          }
        }
      }
    } else {
      availableStock = product.stocksSumProductStock ?? 0;
    }

    if (!isCombo && availableStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          l.S.of(context).outOfStock,
          style: _theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: kMainColor,
      ));
      return;
    }

    final activeStock = product.stocks?.firstOrNull;

    if (hasSerial && isSerialAddonEnabled && !isCombo && activeStock != null) {
      final existingItem = providerData.cartItemList.firstWhere(
        (element) => element.productId == product.id && element.stockId == activeStock.id,
        orElse: () => sale_cart_model.SaleCartModel(productId: -1, batchName: '', stockId: -1),
      );

      List<dynamic> preSelected = existingItem.productId != -1 ? (existingItem.serialNumber ?? []) : [];

      await showDialog(
        context: context,
        builder: (context) => BatchSerialSelectionWidget(
          availableSerials: activeStock.serialNumbers ?? [],
          preSelectedSerials: preSelected,
          onConfirmed: (selectedList) {
            if (selectedList.isNotEmpty) {
              _processAdd(product, activeStock, isCombo, selectedList: selectedList);
            }
          },
        ),
      );
      return;
    }

    _processAdd(product, activeStock, isCombo);
  }

  Widget _buildProductCard(
    product_model.Product product,
    bool isSelected,
    num totalQuantity,
    ThemeData theme,
    CartNotifier providerData,
  ) {
    bool isCombo = product.productType?.toLowerCase().contains('combo') ?? false;

    String displayPrice() {
      num price = _getDynamicPrice(product);
      return '$currency${price % 1 == 0 ? price.toInt() : price.toStringAsFixed(2)}';
    }

    String displayStock() {
      if (isCombo) return "Combo";

      num stockCount = 0;
      if (selectedFilterNotifier.value.warehouseId != null) {
        if (product.stocks != null) {
          for (var s in product.stocks!) {
            if (s.warehouseId == selectedFilterNotifier.value.warehouseId) {
              stockCount += (s.productStock ?? 0);
            }
          }
        }
      } else {
        stockCount = product.stocksSumProductStock ?? 0;
      }
      return "${l.S.of(context).stock}: $stockCount";
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            border: Border.all(
              color: isSelected ? kMainColor : kBottomBorder,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: product.productPicture?.isNotEmpty ?? false
                    ? Image.network(
                        fit: BoxFit.cover,
                        '${product.productPicture}',
                      )
                    : Image.asset(
                        fit: BoxFit.cover,
                        noProductImageUrl,
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                product.productName ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kPeraColor,
                  fontSize: 12,
                ),
              ),
              Text(
                displayPrice(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                displayStock(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kPeraColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Positioned(
            top: 5,
            right: 5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete/Trash Button
                GestureDetector(
                  onTap: () {
                    _processRemove(product);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: kMainColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Total Quantity Display
                Container(
                  alignment: Alignment.center,
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: kMainColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    totalQuantity.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomContinueButton(PermissionService permissionService, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(thickness: 0.2, color: kBorderColorTextField),
        Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () async {
              if (!permissionService.hasPermission(Permit.saleReturnsRead.value)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: kMainColor,
                    content: Text(l.S.of(context).inventoryPermission),
                  ),
                );
                return;
              }
              final branchResult = await checkActionWhenNoBranch(context: context, ref: ref);
              if (!branchResult) {
                return;
              }

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSalesScreen(
                    customerModel: selectedFilterNotifier.value.customer,
                    isFromPos: true,
                  ),
                ),
              );

              if (result == true) {
                selectedFilterNotifier.value = product_paginated_model.PaginatedProductListFilter();
              }
            },
            child: Text(l.S.of(context).continueE),
          ),
        ),
      ],
    );
  }
}

abstract class _$PosSaleScreenState extends ConsumerState<PosSaleScreen>
    with PaginatedControllerMixin<product_model.Product> {
  //-----------------------------State Vars-----------------------------//
  final _apiDebouncer = Debouncer(delay: Durations.long4);
  late final productSearchController = TextEditingController();
  late final selectedFilterNotifier = ValueNotifier<product_paginated_model.PaginatedProductListFilter>(
    product_paginated_model.PaginatedProductListFilter(),
  );
  //-----------------------------State Vars-----------------------------//

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiDebouncer.dispose();
    super.dispose();
  }

  @override
  Future<product_paginated_model.PaginatedProductListModel> fetchData(int page) {
    return ref.read(productPaginatedListProvider(selectedFilterNotifier.value).future);
  }

  @override
  void initRefreshListener() {
    selectedFilterNotifier.addListener(() => _apiDebouncer.run(pagingController.refresh));
    super.initRefreshListener();
  }
}
