import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Import EasyLoading
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Products/add%20product/add_product.dart';
import 'package:mobile_pos/Screens/Purchase/Repo/purchase_repo.dart';
import 'package:mobile_pos/Screens/Purchase/purchase_product_buttom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/bar_code_scaner_widget.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart'; // Import Profile Provider for Addon Check
import '../../core/theme/_app_colors.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Products/Model/product_model.dart';
import '../Products/add product/modle/create_product_model.dart';

class PurchaseProducts extends StatefulWidget {
  PurchaseProducts({super.key, this.customerModel});

  Party? customerModel;

  @override
  State<PurchaseProducts> createState() => _PurchaseProductsState();
}

class _PurchaseProductsState extends State<PurchaseProducts> {
  String productCode = '0000';
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final _theme = Theme.of(context);
      final productList = ref.watch(productProvider);
      final profileInfo = ref.watch(businessInfoProvider); // Watch Business Info for Addon Status

      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).productList,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: codeController,
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            setState(() {
                              productCode = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).productCode,
                            hintText: productCode == '0000' || productCode == '-1'
                                ? lang.S.of(context).scanCode
                                : productCode,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                ),
                productList.when(data: (products) {
                  final filteredProducts =
                      products.where((element) => element.productType?.toLowerCase() != 'combo').toList();

                  return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (_, i) {
                        return Visibility(
                          visible: ((filteredProducts[i].productCode == productCode ||
                                  productCode == '0000' ||
                                  productCode == '-1')) ||
                              filteredProducts[i].productName!.toLowerCase().contains(productCode.toLowerCase()),
                          child: ListTile(
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            leading: filteredProducts[i].productPicture == null
                                ? CircleAvatarWidget(
                                    name: filteredProducts[i].productName,
                                    size: const Size(50, 50),
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '${filteredProducts[i].productPicture!}',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    filteredProducts[i].productName.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  lang.S.of(context).stock,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    filteredProducts[i].brand?.brandName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: DAppColors.kSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${filteredProducts[i].stocksSumProductStock ?? 0}',
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: DAppColors.kSecondary,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              final product = filteredProducts[i];

                              // -------------------------------------------------------------
                              // CHECK: Block if Serial Addon is OFF but Product has Serial
                              // -------------------------------------------------------------
                              final bool isSerialAddonEnabled =
                                  profileInfo.value?.data?.addons?.serialCodeAddon == true;
                              final bool hasSerial = product.hasSerial == 1;

                              if (hasSerial && !isSerialAddonEnabled) {
                                EasyLoading.showError("Serial add-on is disabled. Cannot purchase serial product.");
                                return;
                              }
                              // -------------------------------------------------------------

                              final Stock? stock = ((product.stocks?.isEmpty ?? true) || product.stocks == null)
                                  ? null
                                  : product.stocks?.first;

                              final cartProduct = CartProductModelPurchase(
                                isSerialEnabled: hasSerial, // Use the variable
                                productId: product.id ?? 0,
                                brandName: product.brand?.brandName ?? '',
                                productName: product.productName ?? '',
                                productDealerPrice: stock?.productDealerPrice ?? 0,
                                productPurchasePrice: stock?.productPurchasePrice ?? 0,
                                productSalePrice: stock?.productSalePrice ?? 0,
                                productWholeSalePrice: stock?.productWholeSalePrice ?? 0,
                                quantities: 1,
                                productType: product.productType ?? ProductType.single.name,
                                vatAmount: product.vatAmount ?? 0,
                                vatRate: product.vat?.rate ?? 0,
                                vatType: product.vatType ?? 'exclusive',
                                expireDate: stock?.expireDate,
                                mfgDate: stock?.mfgDate,
                                profitPercent: stock?.profitPercent ?? 0,
                                stock: product.stocksSumProductStock,
                                exclusivePrice: stock?.productPurchasePrice,
                              );
                              addProductInPurchaseCartButtomSheet(
                                  context: context,
                                  product: cartProduct,
                                  ref: ref,
                                  fromUpdate: false,
                                  index: 0,
                                  fromStock: false,
                                  stocks: product.stocks ?? []);
                            },
                          ),
                        );
                      });
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard(
      {super.key,
      required this.productTitle,
      required this.productDescription,
      required this.stock,
      required this.productImage});

  // final Product product;
  String productTitle, productDescription, stock;
  String? productImage;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: 50,
                width: 50,
                decoration: widget.productImage == null
                    ? BoxDecoration(
                        image: DecorationImage(image: AssetImage(noProductImageUrl), fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(90.0),
                      )
                    : BoxDecoration(
                        image: DecorationImage(image: NetworkImage("${widget.productImage}"), fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(90.0),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.productTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Text(
                    widget.productDescription,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lang.S.of(context).stock,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.stock,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: kGreyTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
