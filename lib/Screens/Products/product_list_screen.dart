// File: product_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart'; // Import Shimmer

// --- Local Imports ---
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/product_details.dart';
import 'package:mobile_pos/Screens/Products/product_setting/provider/setting_provider.dart';
import 'package:mobile_pos/Screens/product%20variation/product_variation_list_screen.dart';
import 'package:mobile_pos/Screens/product_unit/unit_list.dart';
import 'package:mobile_pos/Screens/shelfs/shelf_list_screen.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart'; // Import Warehouse Provider
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../service/check_actions_when_no_branch.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../barcode/gererate_barcode.dart';
import '../product racks/product_racks_list.dart';
import '../product_brand/brands_list.dart';
import '../product_category/product_category_list_screen.dart';
import '../product_model/product_model_list.dart';
import '../product_category/provider/product_category_provider/product_unit_provider.dart';
import 'Repo/product_repo.dart';
import 'add product/add_product.dart';
import 'bulk product upload/bulk_product_upload_screen.dart';
import '../../widgets/deleteing_alart_dialog.dart';

class ProductList extends ConsumerStatefulWidget {
  const ProductList({super.key});

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  // --- State Variables ---
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _productRepo = ProductRepo();

  // Warehouse Filter State (null = All Warehouses)
  int? _selectedWarehouseId;

  // --- Helper Method for Floating-Point Precision Fix ---
  num _round(num value) {
    return num.parse(value.toStringAsFixed(2));
  }

  // --- Data Refresh Logic ---
  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    // Invalidate main providers to force reload from API
    ref.invalidate(productProvider);
    ref.invalidate(businessInfoProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(fetchSettingProvider);
    ref.invalidate(fetchWarehouseListProvider); // Refresh warehouses too

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to search input changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- UI Components ---

  /// Builds the popup menu for additional product actions (Add Category, Brand, etc.)
  Widget _buildProductMenu() {
    final _theme = Theme.of(context);

    PopupMenuItem<void> buildItem({
      required VoidCallback onTap,
      List<List<dynamic>>? hugeIcons,
      IconData? icon,
      required String text,
    }) {
      return PopupMenuItem(
        onTap: onTap,
        child: Row(
          children: [
            hugeIcons != null
                ? HugeIcon(icon: hugeIcons, color: kPeraColor, size: 20)
                : Icon(icon, color: kPeraColor, size: 20),
            const SizedBox(width: 8),
            Text(text, style: _theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    return PopupMenuButton<void>(
      itemBuilder: (context) => [
        buildItem(
          onTap: () => const CategoryList(isFromProductList: true).launch(context),
          hugeIcons: HugeIcons.strokeRoundedAddToList,
          text: lang.S.of(context).productCategory,
        ),
        buildItem(
          onTap: () => const BrandsList(isFromProductList: true).launch(context),
          hugeIcons: HugeIcons.strokeRoundedSecurityCheck,
          text: lang.S.of(context).brand,
        ),
        buildItem(
          onTap: () => const ProductModelList(fromProductList: true).launch(context),
          hugeIcons: HugeIcons.strokeRoundedDrawingMode,
          text: lang.S.of(context).model,
        ),
        buildItem(
          onTap: () => const UnitList(isFromProductList: true).launch(context),
          hugeIcons: HugeIcons.strokeRoundedCells,
          text: lang.S.of(context).productUnit,
        ),
        buildItem(
          onTap: () => const ProductShelfList(isFromProductList: true).launch(context),
          icon: Bootstrap.bookshelf,
          text: lang.S.of(context).shelf,
        ),
        buildItem(
          onTap: () => const ProductRackList(isFromProductList: true).launch(context),
          icon: Bootstrap.hdd_rack,
          text: lang.S.of(context).racks,
        ),
        buildItem(
          onTap: () => const ProductVariationList().launch(context),
          hugeIcons: HugeIcons.strokeRoundedPackage,
          text: lang.S.of(context).variations,
        ),
        buildItem(
          onTap: () async {
            bool result = await checkActionWhenNoBranch(ref: ref, context: context);
            if (result) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BulkUploader()),
              );
            }
          },
          hugeIcons: HugeIcons.strokeRoundedInboxUpload,
          text: lang.S.of(context).bulk,
        ),
        buildItem(
          onTap: () => const BarcodeGeneratorScreen().launch(context),
          hugeIcons: HugeIcons.strokeRoundedBarCode01,
          text: lang.S.of(context).barcodeGen,
        ),
      ],
      offset: const Offset(0, 40),
      color: kWhite,
      padding: EdgeInsets.zero,
      elevation: 2,
    );
  }

  /// Builds the Search Field and Warehouse Dropdown
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
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: lang.S.of(context).searchH,
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 16),
                      child: Icon(AntDesign.search_outline, color: kPeraColor),
                    ),
                    contentPadding: EdgeInsetsDirectional.zero,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
                            _searchController.text = code;
                            _searchQuery = code;
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

        // --- 2. Warehouse Filter Dropdown ---
        businessInfoAsync.when(
          data: (info) {
            final bool isWarehouseAddonEnabled = info.data?.addons?.warehouseAddon ?? false;

            if (!isWarehouseAddonEnabled) {
              return const SizedBox.shrink();
            }

            final warehouseListAsync = ref.watch(fetchWarehouseListProvider);

            return warehouseListAsync.when(
              data: (data) {
                final warehouses = data.data ?? [];
                if (warehouses.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Warehouse',
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kMainColor),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedWarehouseId,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        icon: const Icon(Icons.keyboard_arrow_down, color: kPeraColor),
                        hint: const Text("All Warehouses"), // Default hint
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

  /// Builds the Shimmer Effect for Loading State
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        itemCount: 10,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 16, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 150, height: 12, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 30, height: 30, color: Colors.white),
          ],
        ),
      ),
    );
  }

  /// Builds the Main List of Products
  Widget _buildProductList(List<dynamic> products) {
    // 1. Filter by Search Query
    List<dynamic> filteredProducts = products.where((product) {
      final query = _searchQuery.toLowerCase();
      final name = product.productName?.toLowerCase() ?? '';
      final code = product.productCode?.toLowerCase() ?? '';
      return name.contains(query) || code.contains(query);
    }).toList();

    // 2. Filter by Selected Warehouse
    if (_selectedWarehouseId != null) {
      filteredProducts = filteredProducts.where((product) {
        // Assuming 'stocks' list contains warehouse_id
        final stocks = product.stocks as List<dynamic>?;
        if (stocks == null || stocks.isEmpty) return false;

        return stocks.any((stock) => stock.warehouseId == _selectedWarehouseId);
      }).toList();
    }

    // Permission Check
    final permissionService = PermissionService(ref);
    if (!permissionService.hasPermission(Permit.productsRead.value)) {
      return const Center(child: PermitDenyWidget());
    }

    // Empty States
    if (filteredProducts.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text(lang.S.of(context).noProductMatchYourSearch),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Text(
            lang.S.of(context).addProduct,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ),
      );
    }

    final _theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredProducts.length,
      itemBuilder: (_, i) {
        final product = filteredProducts[i];

        // --- Calculate Stock to Display with Fixes ---
        String displayedStock = '0';

        if (product.productType == 'combo') {
          displayedStock = lang.S.of(context).combo;
        } else {
          if (_selectedWarehouseId != null) {
            num warehouseStock = 0;
            if (product.stocks != null) {
              for (var stock in product.stocks!) {
                if (stock.warehouseId == _selectedWarehouseId) {
                  warehouseStock += (stock.productStock ?? 0);
                }
              }
            }
            num roundedStock = _round(warehouseStock);
            displayedStock = roundedStock % 1 == 0 ? roundedStock.toInt().toString() : roundedStock.toString();
          } else {
            num totalStock = _round(product.stocksSumProductStock ?? 0);
            displayedStock = totalStock % 1 == 0 ? totalStock.toInt().toString() : totalStock.toString();
          }
        }

        // --- Calculate Price to Display with Fixes ---
        num displayPrice = 0;
        if (product.productType == 'combo') {
          displayPrice = _round(product.productSalePrice ?? 0);
        } else {
          if (product.stocks != null && product.stocks!.isNotEmpty) {
            displayPrice = _round(product.stocks!.first.productSalePrice ?? 0);
          }
        }
        String formattedPrice = displayPrice % 1 == 0 ? displayPrice.toInt().toString() : displayPrice.toString();

        return ListTile(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetails(details: product))),
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: product.productPicture == null
              ? CircleAvatarWidget(
                  name: product.productName,
                  size: const Size(50, 50),
                )
              : Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage('${product.productPicture!}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  product.productName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$currency$formattedPrice',
                style: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${lang.S.of(context).type} : ${product.productType == 'single' ? lang.S.of(context).single : product.productType == 'variant' ? (locale == 'en' ? 'Variant' : lang.S.of(context).variations) : product.productType == 'combo' ? lang.S.of(context).combo : product.productType}",
                style: _theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: kPeraColor,
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '${lang.S.of(context).stock} : ',
                  style: _theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                  children: [
                    TextSpan(
                      text: displayedStock,
                      style: _theme.textTheme.bodyMedium?.copyWith(color: DAppColors.kSuccess),
                    )
                  ],
                ),
              ),
            ],
          ),
          trailing: _buildItemActions(product),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(color: const Color(0xff808191).withAlpha(50));
      },
    );
  }

  /// Builds the Edit/Delete Action Menu for List Items
  Widget _buildItemActions(dynamic product) {
    return SizedBox(
      width: 30,
      child: PopupMenuButton<int>(
        style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            onTap: () async {
              bool result = await checkActionWhenNoBranch(ref: ref, context: context);
              if (!result) return;
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct(productModel: product)));
            },
            child: Row(
              children: [
                const Icon(IconlyBold.edit, color: kGreyTextColor),
                const SizedBox(width: 10),
                Text(lang.S.of(context).edit, style: const TextStyle(color: kGreyTextColor)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            onTap: () async {
              bool confirmDelete = await showDeleteConfirmationDialog(context: context, itemName: 'product');
              if (confirmDelete) {
                EasyLoading.show(status: lang.S.of(context).deleting);
                await _productRepo.deleteProduct(id: product.id.toString(), context: context, ref: ref);
              }
            },
            child: Row(
              children: [
                const Icon(IconlyBold.delete, color: kGreyTextColor),
                const SizedBox(width: 10),
                Text(lang.S.of(context).delete, style: const TextStyle(color: kGreyTextColor)),
              ],
            ),
          ),
        ],
        offset: const Offset(0, 40),
        color: kWhite,
        padding: EdgeInsets.zero,
        elevation: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: kWhite,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(lang.S.of(context).productList),
          actions: [_buildProductMenu()],
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kMainColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () async {
            bool result = await checkActionWhenNoBranch(ref: ref, context: context);
            if (result) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProduct()));
            }
          },
          child: const Icon(Icons.add, color: kWhite),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Search & Warehouse Filter (Pinned at top)
              _buildTopControls(),

              // Product List
              Expanded(
                child: Consumer(builder: (context, ref, __) {
                  final providerData = ref.watch(productProvider);
                  final businessInfo = ref.watch(businessInfoProvider);

                  return businessInfo.when(
                    data: (_) => providerData.when(
                      data: (products) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildProductList(products),
                      ),
                      // Error State
                      error: (e, stack) => Center(child: Text('Error: ${e.toString()}')),
                      // Loading State -> Replaced with Shimmer
                      loading: () => _buildShimmerEffect(),
                    ),
                    error: (e, stack) => Center(child: Text('Error: ${e.toString()}')),
                    loading: () => _buildShimmerEffect(),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
