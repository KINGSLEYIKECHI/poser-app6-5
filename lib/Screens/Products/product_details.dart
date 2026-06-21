import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import for Shimmer
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/Products/add%20product/serial_code_section.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/product_provider.dart';
import '../../service/check_actions_when_no_branch.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../../widgets/key_values/key_values_widget.dart';
import '../Purchase/Repo/purchase_repo.dart';
import '../Purchase/purchase_product_buttom_sheet.dart';
import 'Repo/product_repo.dart';
import 'add product/add_product.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({super.key, required this.details});

  final Product details;

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  final TextEditingController productStockController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();

  @override
  void dispose() {
    productStockController.dispose();
    salePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerData = ref.watch(fetchProductDetails(widget.details.id.toString()));
    final permissionService = PermissionService(ref);
    final _lang = lang.S.of(context);

    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: _buildAppBar(context, ref, widget.details, _lang), // Appbar remains static initially
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: providerData.when(
            data: (snapshot) {
              bool isSingleWithMultipleStocks = snapshot.productType == 'single' && (snapshot.stocks?.length ?? 0) > 1;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (permissionService.hasPermission(Permit.productsRead.value)) ...[
                      _buildImageSection(snapshot),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductHeader(snapshot, theme),
                            const SizedBox(height: 10),
                            _buildAttributesCard(snapshot, isSingleWithMultipleStocks, _lang),
                          ],
                        ),
                      ),
                      if (snapshot.productType == 'variant' || isSingleWithMultipleStocks)
                        _buildStockList(snapshot, isSingleWithMultipleStocks, theme, _lang),
                      if (snapshot.productType == 'combo') _buildComboList(snapshot, theme, _lang),
                    ] else
                      const Center(child: PermitDenyWidget()),
                  ],
                ),
              );
            },
            error: (e, stack) => Center(child: Text(e.toString())),
            loading: () => _buildShimmerLoading(), // Called Shimmer Loading here
          ),
        ),
      ),
    );
  }

  // ==================== WIDGET BUILDERS ====================

  AppBar _buildAppBar(BuildContext context, WidgetRef ref, Product snapshot, lang.S _lang) {
    return AppBar(
      backgroundColor: kWhite,
      surfaceTintColor: kWhite,
      title: Text(_lang.productDetails),
      centerTitle: true,
      elevation: 0.0,
      actions: [
        IconButton(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          padding: EdgeInsets.zero,
          onPressed: () async {
            bool result = await checkActionWhenNoBranch(ref: ref, context: context);
            if (!result) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProduct(productModel: snapshot)),
            );
          },
          icon: const Icon(Icons.edit, color: Colors.green, size: 22),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onPressed: () async {
            bool confirmDelete = await showDeleteConfirmationDialog(context: context, itemName: 'product');
            if (confirmDelete) {
              EasyLoading.show(status: _lang.deleting);
              await ProductRepo().deleteProduct(id: snapshot.id.toString(), context: context, ref: ref);
              Navigator.pop(context);
            }
          },
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: kMainColor, size: 22),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // ==================== SHIMMER LOADING UI ====================
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 256,
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Placeholder
                  Container(height: 20, width: 200, color: Colors.white),
                  const SizedBox(height: 8),
                  // Category Placeholder
                  Container(height: 15, width: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  // Attributes Box Placeholder
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stock List Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, width: 120, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 60, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 60, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Product snapshot) {
    return Container(
      height: 256,
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xffF5F3F3),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF5F3F3),
          borderRadius: BorderRadius.circular(5),
          image: snapshot.productPicture == null
              ? DecorationImage(fit: BoxFit.cover, image: AssetImage(noProductImageUrl))
              : DecorationImage(fit: BoxFit.cover, image: NetworkImage('${snapshot.productPicture}')),
        ),
      ),
    );
  }

  Widget _buildProductHeader(Product snapshot, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          snapshot.productName ?? 'Unknown Product',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          snapshot.category?.categoryName ?? 'n/a',
          style: theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildAttributesCard(Product snapshot, bool isSingleWithMultipleStocks, lang.S _lang) {
    Map<String, String> attributes = {};

    if (snapshot.productType == 'single') {
      attributes = {
        _lang.skuOrCode: snapshot.productCode ?? 'n/a',
        _lang.brand: snapshot.brand?.brandName ?? 'n/a',
        _lang.model: snapshot.productModel?.name ?? 'n/a',
        _lang.units: snapshot.unit?.unitName ?? 'n/a',
        _lang.rack: snapshot.rack?.name ?? 'n/a',
        _lang.shelf: snapshot.shelf?.name ?? 'n/a',
        _lang.stock: snapshot.stocksSumProductStock?.toString() ?? '0',
        _lang.lowStockAlert: snapshot.alertQty?.toString() ?? 'n/a',
        if (!isSingleWithMultipleStocks) _lang.warehouse: snapshot.stocks?.firstOrNull?.warehouse?.name ?? 'n/a',
        _lang.taxType: snapshot.vatType ?? 'n/a',
        _lang.tax: snapshot.vatAmount?.toString() ?? 'n/a',
      };

      if (!isSingleWithMultipleStocks &&
          snapshot.stocks?.isNotEmpty == true &&
          snapshot.stocks!.first.serialNumbers?.isNotEmpty == true) {
        attributes['Serial Number'] = snapshot.stocks!.first.serialNumbers!.join(', ');
      }

      final firstStock = snapshot.stocks?.firstOrNull;
      attributes.addAll({
        _lang.costExclusionTax: '$currency${firstStock?.exclusivePrice ?? '0'}',
        _lang.costInclusionTax: '$currency${firstStock?.productPurchasePrice ?? '0'}',
        '${_lang.profitMargin} (%)': firstStock?.profitPercent?.toString() ?? '0',
        _lang.mrpOrSalePrice: '$currency${firstStock?.productSalePrice ?? '0'}',
        _lang.wholeSalePrice: '$currency${firstStock?.productWholeSalePrice ?? '0'}',
        _lang.dealerPrice: '$currency${firstStock?.productDealerPrice ?? '0'}',
        _lang.manufactureDate: _formatDate(firstStock?.mfgDate),
        _lang.expiredDate: _formatDate(firstStock?.expireDate),
        _lang.warranty:
            '${snapshot.warrantyGuaranteeInfo?.warrantyDuration ?? ''} ${snapshot.warrantyGuaranteeInfo?.warrantyUnit ?? 'n/a'}',
        _lang.guarantee:
            '${snapshot.warrantyGuaranteeInfo?.guaranteeDuration ?? ''} ${snapshot.warrantyGuaranteeInfo?.guaranteeUnit ?? 'n/a'}',
      });
    } else if (snapshot.productType == 'variant') {
      attributes = {
        _lang.skuOrCode: snapshot.productCode ?? 'n/a',
        _lang.brand: snapshot.brand?.brandName ?? 'n/a',
        _lang.model: snapshot.productModel?.name ?? 'n/a',
        _lang.rack: snapshot.shelf?.name ?? 'n/a',
        _lang.lowStockAlert: snapshot.alertQty?.toString() ?? 'n/a',
        _lang.taxReport: snapshot.vatType ?? 'n/a',
        _lang.tax: snapshot.vatAmount?.toString() ?? 'n/a',
        _lang.warranty:
            '${snapshot.warrantyGuaranteeInfo?.warrantyDuration ?? ''} ${snapshot.warrantyGuaranteeInfo?.warrantyUnit ?? 'n/a'}',
        _lang.guarantee:
            '${snapshot.warrantyGuaranteeInfo?.guaranteeDuration ?? ''} ${snapshot.warrantyGuaranteeInfo?.guaranteeUnit ?? 'n/a'}',
      };
    } else if (snapshot.productType == 'combo') {
      final netTotal = (snapshot.productSalePrice != null && snapshot.profitPercent != null)
          ? (snapshot.productSalePrice! / (1 + (snapshot.profitPercent! / 100))).toStringAsFixed(2)
          : 'n/a';

      attributes = {
        _lang.skuOrCode: snapshot.productCode ?? 'n/a',
        _lang.brand: snapshot.brand?.brandName ?? 'n/a',
        _lang.model: snapshot.productModel?.name ?? 'n/a',
        _lang.units: snapshot.unit?.unitName ?? 'n/a',
        _lang.rack: snapshot.rack?.name ?? 'n/a',
        _lang.shelf: snapshot.shelf?.name ?? 'n/a',
        _lang.lowStockAlert: snapshot.alertQty?.toString() ?? 'n/a',
        _lang.type: snapshot.productType ?? 'n/a',
        _lang.taxType: snapshot.vatType ?? 'n/a',
        _lang.tax: snapshot.vatAmount?.toString() ?? 'n/a',
        _lang.netTotalAmount: netTotal,
        '${_lang.profitMargin} (%)': '${snapshot.profitPercent ?? 0}%',
        _lang.sellingPrice: '$currency${snapshot.productSalePrice ?? 0}',
        _lang.warranty:
            '${snapshot.warrantyGuaranteeInfo?.warrantyDuration ?? ''} ${snapshot.warrantyGuaranteeInfo?.warrantyUnit ?? 'n/a'}',
        _lang.guarantee:
            '${snapshot.warrantyGuaranteeInfo?.guaranteeDuration ?? ''} ${snapshot.warrantyGuaranteeInfo?.guaranteeUnit ?? 'n/a'}',
      };
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xffFEF0F1),
      ),
      child: Column(
        children: attributes.entries.map((entry) {
          return KeyValueRow(
            title: entry.key,
            titleFlex: 6,
            description: entry.value,
            descriptionFlex: 8,
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'n/a';
    try {
      return DateFormat('d MMMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return 'n/a';
    }
  }

  Widget _buildStockList(Product snapshot, bool isSingleWithMultipleStocks, ThemeData theme, lang.S _lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16, bottom: 6),
          child: Text(
            isSingleWithMultipleStocks ? _lang.stockList : _lang.variationsProduct,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.stocks?.length ?? 0,
          separatorBuilder: (_, __) => const Divider(thickness: 0.3, color: kBorderColorTextField),
          itemBuilder: (context, index) {
            final stock = snapshot.stocks?[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      isSingleWithMultipleStocks ? (snapshot.productName ?? 'n/a') : (stock?.variantName ?? 'n/a'),
                      maxLines: 1,
                      style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor, fontSize: 16),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${_lang.sale}: $currency${stock?.productSalePrice ?? '0'}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: kTitleColor, fontWeight: FontWeight.w400, fontSize: 16),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${_lang.batch}: ${stock?.batchNo ?? 'N/A'}',
                      maxLines: 1,
                      style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor, fontSize: 14),
                    ),
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: '${_lang.stock}: ',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: kNeutralColor, fontWeight: FontWeight.w400, fontSize: 14),
                        children: [
                          TextSpan(
                            text: stock?.productStock?.toString() ?? '0',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xff34C759), fontWeight: FontWeight.w400, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              trailing: _buildPopupMenu(snapshot, stock, index, theme, _lang),
              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopupMenu(Product snapshot, Stock? stock, int index, ThemeData theme, lang.S _lang) {
    return SizedBox(
      width: 30,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconColor: kPeraColor,
        onSelected: (value) {
          switch (value) {
            case 'view':
              viewModal(context, snapshot, index, _lang);
              break;
            case 'edit':
              final cartProduct = CartProductModelPurchase(
                isSerialEnabled: snapshot.hasSerial.toString() == '1',
                productId: snapshot.id ?? 0,
                variantName: stock?.variantName,
                brandName: snapshot.brand?.brandName,
                productName: snapshot.productName ?? '',
                productDealerPrice: stock?.productDealerPrice,
                productPurchasePrice: stock?.productPurchasePrice,
                productSalePrice: stock?.productSalePrice,
                productWholeSalePrice: stock?.productWholeSalePrice,
                quantities: stock?.productStock,
                productType: snapshot.productType ?? '',
                vatAmount: snapshot.vatAmount ?? 0,
                vatRate: snapshot.vat?.rate ?? 0,
                vatType: snapshot.vatType ?? 'exclusive',
                expireDate: stock?.expireDate,
                mfgDate: stock?.mfgDate,
                profitPercent: stock?.profitPercent ?? 0,
                stock: stock?.productStock,
                batchNumber: stock?.batchNo,
                serialNumber: stock?.serialNumbers,
                exclusivePrice: stock?.exclusivePrice,
              );
              addProductInPurchaseCartButtomSheet(
                stockId: stock?.id,
                selectedWarehouseId: snapshot.stocks?[index].warehouse?.id,
                context: context,
                product: cartProduct,
                ref: ref,
                fromUpdate: false,
                index: index,
                fromStock: true,
                stocks: [],
              );
              break;
            case 'add_stock':
              final GlobalKey<FormState> formKey = GlobalKey<FormState>();
              productStockController.text = '1';
              salePriceController.text = snapshot.stocks?[index].productSalePrice?.toString() ?? '0.0';
              addStockPopUp(context, formKey, theme, snapshot, index, _lang);
              break;
            case 'delete':
              showEditDeletePopUp(
                context: context,
                data: snapshot.stocks?[index],
                ref: ref,
                productId: widget.details.id.toString(),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'view', child: Text(_lang.view)),
          PopupMenuItem(value: 'edit', child: Text(_lang.edit)),
          PopupMenuItem(value: 'add_stock', child: Text(_lang.addStock)),
          PopupMenuItem(value: 'delete', child: Text(_lang.delete)),
        ],
      ),
    );
  }

  Widget _buildComboList(Product snapshot, ThemeData theme, lang.S _lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16, bottom: 6),
          child: Text(
            _lang.comboProducts,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.comboProducts?.length ?? 0,
          separatorBuilder: (_, __) => const Divider(thickness: 0.3, color: kBorderColorTextField),
          itemBuilder: (context, index) {
            final combo = snapshot.comboProducts![index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${combo.stock?.product?.productName ?? 'n/a'} ${combo.stock?.variantName ?? ''}',
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor, fontSize: 16),
                  ),
                  Text(
                    '${_lang.qty}: ${combo.quantity ?? '0'}',
                    style: theme.textTheme.bodyLarge?.copyWith(color: kPeraColor),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_lang.code}: ${combo.stock?.product?.productCode ?? 'n/a'}, ${_lang.batchNo}: ${combo.stock?.batchNo ?? 'n/a'}',
                    maxLines: 1,
                    style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                  ),
                  Text(
                    '$currency${combo.stock?.productSalePrice ?? 0}',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            );
          },
        ),
      ],
    );
  }

  // ==================== MODALS & POPUPS ====================

  Future<dynamic> addStockPopUp(
      BuildContext context, GlobalKey<FormState> formKey, ThemeData theme, Product snapshot, int index, lang.S _lang) {
    final businessInfo = ref.read(businessInfoProvider).value;
    final bool isSerialEnabled = (snapshot.hasSerial == 1) && (businessInfo?.data?.addons?.serialCodeAddon == true);
    List<String> newSerialList = [];

    productStockController.text = isSerialEnabled ? '0' : '1';

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _lang.addStock,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: kTitleColor, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: kTitleColor, size: 16),
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Color(0xffEEF3FF)),
                            padding: WidgetStatePropertyAll(EdgeInsets.zero),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 0.3, color: kBorderColorTextField, height: 0),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isSerialEnabled)
                          TextFormField(
                            controller: productStockController,
                            readOnly: true,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: _lang.stock,
                              hintText: "0",
                              border: const OutlineInputBorder(),
                              suffixIcon: InkWell(
                                onTap: () {
                                  showSerialModal(
                                    context: context,
                                    initialSerials: newSerialList,
                                    oldSerials: [],
                                    onSave: (updatedList) {
                                      setState(() {
                                        newSerialList = updatedList;
                                        productStockController.text = newSerialList.length.toString();
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: kMainColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(Icons.playlist_add, color: kMainColor),
                                ),
                              ),
                            ),
                          )
                        else
                          TextFormField(
                            textAlign: TextAlign.center,
                            controller: productStockController,
                            validator: (value) {
                              final int? enteredStock = int.tryParse(value ?? '');
                              if (enteredStock == null || enteredStock < 1) return _lang.stockWarn;
                              return null;
                            },
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: _lang.enterStock,
                              prefixIcon: _buildQuantityAction(
                                icon: Icons.remove,
                                onTap: () {
                                  int qty = int.tryParse(productStockController.text) ?? 1;
                                  if (qty > 1) productStockController.text = (--qty).toString();
                                },
                              ),
                              suffixIcon: _buildQuantityAction(
                                icon: Icons.add,
                                color: kMainColor.withOpacity(0.15),
                                iconColor: theme.colorScheme.primary,
                                onTap: () {
                                  int qty = int.tryParse(productStockController.text) ?? 1;
                                  productStockController.text = (++qty).toString();
                                },
                              ),
                              border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE0E2E7))),
                              enabledBorder:
                                  const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE0E2E7))),
                              focusedBorder:
                                  const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffE0E2E7))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                            ),
                          ),
                        const SizedBox(height: 24),
                        TextFormField(
                          readOnly: true,
                          controller: salePriceController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _lang.salePrice,
                            hintText: _lang.enterAmount,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xffF68A3D))),
                                child: Text(_lang.cancel, style: const TextStyle(color: Color(0xffF68A3D))),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                child: Text(_lang.save),
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ?? false) {
                                    final int newStock = int.tryParse(productStockController.text) ?? 0;

                                    if (newStock <= 0) {
                                      EasyLoading.showError("Stock must be greater than 0");
                                      return;
                                    }

                                    if (isSerialEnabled && newSerialList.isEmpty) {
                                      EasyLoading.showError("Please add serial numbers");
                                      return;
                                    }

                                    try {
                                      EasyLoading.show(status: _lang.updating);
                                      final repo = ProductRepo();
                                      final String stockId = snapshot.stocks?[index].id.toString() ?? '';

                                      final bool success = await repo.addStock(
                                        context: context,
                                        ref: ref,
                                        productId: widget.details.id.toString(),
                                        id: stockId,
                                        qty: newStock.toString(),
                                        serialNumbers: isSerialEnabled ? newSerialList : [],
                                      );

                                      EasyLoading.dismiss();

                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text(_lang.updateSuccess)));
                                        ref.refresh(fetchProductDetails(widget.details.id.toString()));
                                        ref.refresh(productProvider);
                                        productStockController.clear();
                                        salePriceController.clear();
                                        newSerialList.clear();
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text(_lang.updateFailed)));
                                      }
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildQuantityAction({required IconData icon, Color? color, Color? iconColor, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 26,
      width: 26,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? const Color(0xffE0E2E7)),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Icon(icon, color: iconColor ?? const Color(0xff4A4A52)),
      ),
    );
  }

  Future<dynamic> viewModal(BuildContext context, Product snapshot, int index, lang.S _lang) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) {
        final stock = snapshot.stocks![index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_lang.view,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 18)),
                ],
              ),
            ),
            const Divider(color: kBorderColor, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: snapshot.stocks != null && snapshot.stocks!.isNotEmpty && index < snapshot.stocks!.length
                  ? Column(
                      children: {
                        if (stock.warehouse?.name != null) _lang.warehouse: stock.warehouse!.name!,
                        _lang.batchNo: stock.batchNo ?? 'n/a',
                        _lang.qty: stock.productStock?.toString() ?? '0',
                        if (stock.serialNumbers?.isNotEmpty == true) 'Serial Number': stock.serialNumbers!.join(', '),
                        _lang.costExclusionTax: stock.exclusivePrice?.toString() ?? 'n/a',
                        _lang.costInclusionTax: stock.productPurchasePrice?.toString() ?? 'n/a',
                        '${_lang.profitMargin} (%)': stock.profitPercent?.toString() ?? 'n/a',
                        _lang.salePrice: stock.productSalePrice?.toString() ?? 'n/a',
                        _lang.wholeSalePrice: stock.productWholeSalePrice?.toString() ?? 'n/a',
                        _lang.dealerPrice: stock.productDealerPrice?.toString() ?? 'n/a',
                        _lang.manufactureDate: _formatDate(stock.mfgDate),
                        _lang.expiredDate: _formatDate(stock.expireDate),
                      }
                          .entries
                          .map((entry) =>
                              KeyValueRow(title: entry.key, titleFlex: 6, description: entry.value, descriptionFlex: 8))
                          .toList(),
                    )
                  : Text(_lang.noStockAvailable),
            ),
          ],
        );
      },
    );
  }
}

Future<void> showEditDeletePopUp(
    {required BuildContext context, Stock? data, required WidgetRef ref, required String productId}) async {
  final _lang = lang.S.of(context);
  return await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _lang.deleteBatchWarn,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 26),
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xffF68A3D).withOpacity(0.1)),
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset('images/trash.svg', height: 146, width: 146),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(_lang.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final success = await ProductRepo().deleteStock(id: data?.id.toString() ?? '');
                        if (success) {
                          ref.refresh(fetchProductDetails(productId));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(_lang.deletedSuccessFully)));
                          Navigator.pop(context);
                        }
                      },
                      child: Text(_lang.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
