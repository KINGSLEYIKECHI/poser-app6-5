import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/Screens/Purchase/bulk%20purchase/bulk_purchase.dart';
import 'package:mobile_pos/Screens/Purchase/purchase_product_buttom_sheet.dart';
import 'package:mobile_pos/Screens/Purchase/purchase_products.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../../Repository/API/future_invoice.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/multipal payment mathods/multi_payment_widget.dart';
import '../Customers/Model/parties_model.dart' as party;
import '../Home/home.dart';
import '../Products/add product/modle/create_product_model.dart';
import '../Purchase List/purchase_list_screen.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../invoice_details/purchase_invoice_details.dart';
import '../vat_&_tax/model/vat_model.dart';
import '../vat_&_tax/provider/text_repo.dart';
import 'Repo/purchase_repo.dart';

class AddAndUpdatePurchaseScreen extends ConsumerStatefulWidget {
  AddAndUpdatePurchaseScreen({super.key, required this.customerModel, this.transitionModel});

  party.Party? customerModel;
  final PurchaseTransaction? transitionModel;

  @override
  AddSalesScreenState createState() => AddSalesScreenState();
}

class AddSalesScreenState extends ConsumerState<AddAndUpdatePurchaseScreen> {
  // Key to access MultiPaymentWidget State
  final GlobalKey<MultiPaymentWidgetState> paymentWidgetKey = GlobalKey();

  bool isProcessing = false;
  DateTime selectedDate = DateTime.now();

  TextEditingController dateController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
  TextEditingController phoneController = TextEditingController();
  TextEditingController receivedAmountController = TextEditingController();

  // Flag to prevent unwanted rebuilds during initialization
  bool _initializingFirstTime = false;

  String flatValue = 'Flat';
  String percentValue = 'Percent';
  bool hasPreselected = false;
  String discountType = 'Flat';

  @override
  void initState() {
    super.initState();

    // Listener to calculate prices when payment widget updates the total amount
    receivedAmountController.addListener(() {
      final cart = ref.read(cartNotifierPurchaseNew);
      cart.calculatePrice(receivedAmount: receivedAmountController.text, stopRebuild: !_initializingFirstTime);
    });

    // Initialize data if we are in "Edit/Update" mode
    if (widget.transitionModel != null) {
      final editedPurchase = widget.transitionModel;
      dateController.text = editedPurchase?.purchaseDate?.substring(0, 10) ?? '';
      receivedAmountController.text = editedPurchase?.paidAmount.toString() ?? '';
      widget.customerModel = party.Party(
        id: widget.transitionModel?.party?.id,
        name: widget.transitionModel?.party?.name,
      );
      if (widget.transitionModel?.discountType == 'flat') {
        discountType = 'Flat';
      } else {
        discountType = 'Percent';
      }
      addProductsInCartFromEditList();
    }
    _initializingFirstTime = true;
  }

  @override
  void dispose() {
    dateController.dispose();
    phoneController.dispose();
    receivedAmountController.dispose();
    super.dispose();
  }

  /// Populates the cart with existing products when editing a purchase
  void addProductsInCartFromEditList() {
    final cart = ref.read(cartNotifierPurchaseNew);

    if (widget.transitionModel?.details?.isNotEmpty ?? false) {
      for (var detail in widget.transitionModel!.details!) {
        cart.addToCartRiverPod(
            cartItem: CartProductModelPurchase(
              serialNumber: detail.serialNumbers ?? [],
              isSerialEnabled: detail.product?.hasSerial.toString() == '1',
              warehouseId: detail.stock?.warehouseId,
              productName: detail.product?.productName ?? '',
              productId: detail.productId ?? 0,
              quantities: detail.quantities,
              vatType: detail.product?.vatType ?? 'exclusive',
              vatRate: detail.product?.vat?.rate ?? 0,
              vatAmount: detail.product?.vatAmount ?? 0,
              productType: detail.product?.productType ?? ProductType.single.name,
              profitPercent: detail.profitPercent,
              mfgDate: detail.mfgDate,
              expireDate: detail.expireDate,
              batchNumber: detail.stock?.batchNo,
              productWholeSalePrice: detail.productWholeSalePrice ?? 0,
              productSalePrice: detail.productSalePrice ?? 0,
              productPurchasePrice: detail.productPurchasePrice,
              productDealerPrice: detail.productDealerPrice ?? 0,
              stock: detail.productStock ?? 0,
              variantName: detail.stock?.variantName,
            ),
            fromEditSales: true,
            isVariation: detail.product?.productType == ProductType.variant.name);
      }
    }

    // Restore Financial Details
    cart.discountAmount = widget.transitionModel?.discountAmount ?? 0;
    if (widget.transitionModel?.discountType == 'flat') {
      cart.discountTextControllerFlat.text = widget.transitionModel?.discountAmount.toString() ?? '';
    } else {
      cart.discountTextControllerFlat.text = widget.transitionModel?.discountPercent?.toString() ?? '';
    }
    cart.finalShippingCharge = widget.transitionModel?.shippingCharge ?? 0;
    cart.shippingChargeController.text = widget.transitionModel?.shippingCharge.toString() ?? '';

    cart.vatAmountController.text = widget.transitionModel?.vatAmount.toString() ?? '';
    cart.calculatePrice(receivedAmount: widget.transitionModel?.paidAmount.toString(), stopRebuild: true);
  }

  @override
  Widget build(BuildContext context) {
    final providerData = ref.watch(cartNotifierPurchaseNew);
    final personalData = ref.watch(businessInfoProvider);
    final taxesData = ref.watch(taxProvider);
    final permissionService = PermissionService(ref);
    final _theme = Theme.of(context);

    return personalData.when(data: (data) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.transitionModel == null ? lang.S.of(context).addPurchase : 'Update Purchase',
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 2.0,
            surfaceTintColor: kWhite,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  /// ---------------------------------------------------------
                  /// Section 1: Invoice Number & Date
                  /// ---------------------------------------------------------
                  Row(
                    children: [
                      widget.transitionModel == null
                          ? FutureBuilder(
                              future: FutureInvoice().getFutureInvoice(tag: 'purchases'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final invoiceValue =
                                      (snapshot.data != null) ? snapshot.data.toString().replaceAll('"', '') : '';
                                  return Expanded(
                                    child: AppTextField(
                                      textFieldType: TextFieldType.NAME,
                                      initialValue: invoiceValue,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).inv,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).inv,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                initialValue: widget.transitionModel?.invoiceNumber,
                                readOnly: true,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).inv,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: dateController,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).date,
                            suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            suffixIcon: IconButton(
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                  context: context,
                                );
                                if (picked != null && picked != selectedDate) {
                                  setState(() {
                                    selectedDate = selectedDate.copyWith(
                                      year: picked.year,
                                      month: picked.month,
                                      day: picked.day,
                                    );
                                    dateController.text = selectedDate.toString().substring(0, 10);
                                  });
                                }
                              },
                              icon: const Icon(IconlyLight.calendar),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// ---------------------------------------------------------
                  /// Section 2: Supplier/Party Selection & Due Info
                  /// ---------------------------------------------------------
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(lang.S.of(context).dueAmount),
                          Text(
                            widget.customerModel?.due == null ? '$currency 0' : '$currency${widget.customerModel?.due}',
                            style: const TextStyle(color: Color(0xFFFF8C34)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        readOnly: true,
                        initialValue: widget.customerModel?.name ?? 'Guest',
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).customerName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Visibility(
                        visible: widget.customerModel == null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: AppTextField(
                            controller: phoneController,
                            textFieldType: TextFieldType.PHONE,
                            decoration: kInputDecoration.copyWith(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).customerPhoneNumber,
                              hintText: lang.S.of(context).enterCustomerPhoneNumber,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// ---------------------------------------------------------
                  /// Section 3: Cart Items List
                  /// ---------------------------------------------------------
                  if (providerData.cartItemList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          collapsedBackgroundColor: kMainColor2,
                          backgroundColor: kMainColor2,
                          splashColor: kMainColor2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: kLineColor, width: 1),
                          ),
                          title: Text(
                            lang.S.of(context).itemAdded,
                            style: _theme.textTheme.titleMedium,
                          ),
                          children: [
                            Container(
                              color: Colors.white,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: providerData.cartItemList.length,
                                itemBuilder: (context, index) {
                                  final cartItem = providerData.cartItemList[index];
                                  // Check if the product has serial numbers enabled
                                  bool isSerialProduct = cartItem.isSerialEnabled ?? false;

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: ListTile(
                                      onTap: () {
                                        addProductInPurchaseCartButtomSheet(
                                          product: cartItem,
                                          ref: ref,
                                          fromUpdate: true,
                                          context: context,
                                          index: index,
                                          fromStock: false,
                                          stocks: [],
                                        );
                                      },
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Text(cartItem.productName.toString()),
                                      subtitle: permissionService.hasPermission(Permit.purchasesPriceView.value)
                                          ? Text(
                                              '${cartItem.quantities} X ${cartItem.productPurchasePrice} = ${formatPointNumber((cartItem.quantities ?? 0) * (cartItem.productPurchasePrice ?? 0))} ${cartItem.productType == ProductType.variant.name ? "[${cartItem.batchNumber.isEmptyOrNull ? 'N/A' : cartItem.batchNumber}]" : ''}')
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                /// Minus Button
                                                GestureDetector(
                                                  onTap: () {
                                                    if (isSerialProduct) {
                                                      EasyLoading.showToast(
                                                          'Serial items cannot be decreased manually. Tap item to manage serials.');
                                                    } else {
                                                      providerData.quantityDecrease(index);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 18,
                                                    width: 18,
                                                    decoration: BoxDecoration(
                                                      color: isSerialProduct ? Colors.grey : kMainColor,
                                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons.remove, size: 14, color: Colors.white),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 5),

                                                /// Quantity Text
                                                SizedBox(
                                                  width: 30,
                                                  child: Center(
                                                    child: Text(
                                                      cartItem.quantities.toString(),
                                                      style: TextStyle(
                                                        color: isSerialProduct ? Colors.grey : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 5),

                                                /// Plus Button
                                                GestureDetector(
                                                  onTap: () {
                                                    if (isSerialProduct) {
                                                      EasyLoading.showToast(
                                                          'Serial items cannot be increased manually. Tap item to manage serials.');
                                                    } else {
                                                      providerData.quantityIncrease(index);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 18,
                                                    width: 18,
                                                    decoration: BoxDecoration(
                                                      color: isSerialProduct ? Colors.grey : kMainColor,
                                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(Icons.add, size: 14, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          /// Delete Button
                                          GestureDetector(
                                            onTap: () {
                                              providerData.deleteToCart(index);
                                            },
                                            child: const HugeIcon(
                                              icon: HugeIcons.strokeRoundedDelete03,
                                              size: 19,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                  /// ---------------------------------------------------------
                  /// Section 4: Add Buttons
                  /// ---------------------------------------------------------
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            PurchaseProducts(
                              customerModel: widget.customerModel,
                            ).launch(context);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: kMainColor2,
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: Text(
                            lang.S.of(context).addItems,
                            style: _theme.textTheme.titleMedium?.copyWith(
                              color: kMainColor,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const BulkPurchaseUploader()));
                        },
                        child: Container(
                          height: 48,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Center(
                            child: Image(
                              height: 40,
                              width: 40,
                              image: AssetImage('images/file-upload.png'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// ---------------------------------------------------------
                  /// Section 5: Calculations (Subtotal, Discount, Tax)
                  /// ---------------------------------------------------------
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey.shade300, width: 1)),
                    child: Column(
                      children: [
                        /// Subtotal Header
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xffFEF0F1),
                            borderRadius:
                                BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).subTotal,
                                style: _theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                formatPointNumber(providerData.totalAmount),
                                style: _theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        /// Discount Section
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).discount,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: kPeraColor,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: kBorder, width: 1)),
                                  ),
                                  child: DropdownButton<String?>(
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    isDense: true,
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: kPeraColor, size: 18),
                                    hint: Text(
                                      lang.S.of(context).select,
                                      style: _theme.textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
                                    ),
                                    value: discountType,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: flatValue,
                                        child: Text(lang.S.of(context).flat),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: percentValue,
                                        child: Text(lang.S.of(context).percent),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        discountType = value!;
                                        providerData.calculateDiscount(
                                          value: providerData.discountTextControllerFlat.text,
                                          selectedTaxType: discountType,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextField(
                                  controller: providerData.discountTextControllerFlat,
                                  onChanged: (value) {
                                    setState(() {
                                      providerData.calculateDiscount(
                                        value: value,
                                        selectedTaxType: discountType,
                                      );
                                    });
                                  },
                                  textAlign: TextAlign.right,
                                  style: _theme.textTheme.titleSmall,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleMedium?.copyWith(color: kPeraColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: const UnderlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// VAT/Tax Section
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang.S.of(context).vat,
                                style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                              ),
                              const Spacer(),
                              taxesData.when(
                                data: (data) {
                                  List<VatModel> dataList = data.where((tax) => tax.status == true).toList();
                                  if (widget.transitionModel != null &&
                                      widget.transitionModel?.vatId != null &&
                                      !hasPreselected) {
                                    VatModel matched = dataList.firstWhere(
                                      (element) => element.id == widget.transitionModel?.vatId,
                                      orElse: () => VatModel(),
                                    );
                                    if (matched.id != null) {
                                      hasPreselected = true;
                                      providerData.selectedVat = matched;
                                    }
                                  }
                                  return SizedBox(
                                    width: context.width() / 4,
                                    height: 30,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: kBorder, width: 1)),
                                      ),
                                      child: DropdownButton<VatModel?>(
                                        icon: providerData.selectedVat != null
                                            ? GestureDetector(
                                                onTap: () => providerData.changeSelectedVat(data: null),
                                                child: const Icon(Icons.close, color: Colors.red, size: 16),
                                              )
                                            : const Icon(Icons.keyboard_arrow_down, color: kPeraColor, size: 18),
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        isDense: true,
                                        padding: EdgeInsets.zero,
                                        hint: Text(
                                          lang.S.of(context).selectOne,
                                          style: _theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                                        ),
                                        value: providerData.selectedVat,
                                        items: dataList.map((VatModel tax) {
                                          return DropdownMenuItem<VatModel>(
                                            value: tax,
                                            child: Text(
                                              '${tax.name ?? ''} (${tax.rate ?? 0}%)',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: _theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (VatModel? newValue) {
                                          providerData.changeSelectedVat(data: newValue);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                error: (error, stackTrace) => Text(error.toString()),
                                loading: () => const SizedBox.shrink(),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: providerData.vatAmountController,
                                  style: _theme.textTheme.titleSmall,
                                  readOnly: true,
                                  onChanged: (value) => providerData.calculateDiscount(
                                    value: value,
                                    selectedTaxType: discountType.toString(),
                                  ),
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: const UnderlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Shipping Charge Section
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).shippingCharge,
                                style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                              ),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: providerData.shippingChargeController,
                                  style: _theme.textTheme.titleSmall,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>
                                      providerData.calculatePrice(shippingCharge: value.isEmpty ? '0' : value),
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: const UnderlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Total Amount
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).total,
                                style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                              ),
                              Text(
                                formatPointNumber(providerData.totalPayableAmount),
                                style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                              ),
                            ],
                          ),
                        ),

                        /// Paid Amount
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).paidAmount,
                                style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                              ),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextField(
                                  controller: receivedAmountController,
                                  // Lock field if multiple payments are active
                                  readOnly: (paymentWidgetKey.currentState?.getPaymentEntries().length ?? 1) > 1,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  style: _theme.textTheme.titleSmall,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: const UnderlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Change Amount
                        Visibility(
                          visible: providerData.changeAmount > 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10, top: 13, bottom: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).changeAmount,
                                  style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                ),
                                Text(
                                  formatPointNumber(providerData.changeAmount),
                                  style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// Due Amount
                        Visibility(
                          visible: providerData.dueAmount > 0 ||
                              (providerData.changeAmount == 0 && providerData.dueAmount == 0),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10, top: 13, bottom: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).dueAmount,
                                  style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                ),
                                Text(
                                  formatPointNumber(providerData.dueAmount),
                                  style: _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// ---------------------------------------------------------
                  /// Section 6: Payment Methods
                  /// ---------------------------------------------------------
                  MultiPaymentWidget(
                    key: paymentWidgetKey,
                    showWalletOption: true,
                    totalAmountController: receivedAmountController,
                    showChequeOption: false,
                    initialTransactions: widget.transitionModel?.transactions,
                    onPaymentListChanged: () {
                      providerData.calculatePrice(receivedAmount: receivedAmountController.text);
                    },
                  ),

                  const SizedBox(height: 24),

                  /// ---------------------------------------------------------
                  /// Section 7: Bottom Action Buttons (Cancel / Save)
                  /// ---------------------------------------------------------
                  Row(
                    children: [
                      /// Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            maximumSize: const Size(double.infinity, 48),
                            minimumSize: const Size(double.infinity, 48),
                            disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                          onPressed: () async {
                            const Home().launch(context, isNewTask: true);
                          },
                          child: Text(
                            lang.S.of(context).cancel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: _theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      /// Save Button
                      Expanded(
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            maximumSize: const Size(double.infinity, 48),
                            minimumSize: const Size(double.infinity, 48),
                            disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                          onPressed: () async {
                            // Validation checks
                            if (providerData.cartItemList.isEmpty) {
                              EasyLoading.showError(lang.S.of(context).addProductFirst);
                              return;
                            }
                            if (widget.customerModel == null && providerData.dueAmount > 0) {
                              EasyLoading.showError(lang.S.of(context).dueSaleWarn);
                              return;
                            }

                            // Validate Payments from the Widget
                            List<PaymentEntry> payments = paymentWidgetKey.currentState?.getPaymentEntries() ?? [];
                            if (payments.isEmpty) {
                              EasyLoading.showError('Please select at least one payment method');
                              return;
                            }

                            // Prevent multiple clicks
                            if (isProcessing) return;

                            setState(() {
                              isProcessing = true;
                            });

                            try {
                              EasyLoading.show(status: lang.S.of(context).loading, dismissOnTap: false);

                              // Serialize Payment List for API
                              List<Map<String, dynamic>> paymentData = payments.map((e) => e.toJson()).toList();

                              PurchaseRepo repo = PurchaseRepo();
                              PurchaseTransaction? purchaseData;

                              /// CREATE MODE
                              if (widget.transitionModel == null) {
                                if (!permissionService.hasPermission(Permit.purchasesCreate.value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(lang.S.of(context).purchaseWarn),
                                    ),
                                  );
                                  return;
                                }

                                purchaseData = await repo.createPurchase(
                                  ref: ref,
                                  context: context,
                                  vatId: providerData.selectedVat?.id,
                                  totalAmount: providerData.totalPayableAmount,
                                  purchaseDate: selectedDate.toIso8601String(),
                                  products: providerData.cartItemList,
                                  vatAmount: providerData.vatAmount,
                                  vatPercent: providerData.selectedVat?.rate ?? 0,
                                  paymentType: paymentData,
                                  partyId: widget.customerModel?.id ?? 0,
                                  isPaid: providerData.dueAmount <= 0,
                                  dueAmount: providerData.dueAmount <= 0 ? 0 : providerData.dueAmount,
                                  discountAmount: providerData.discountAmount,
                                  changeAmount: providerData.changeAmount,
                                  shippingCharge: providerData.finalShippingCharge,
                                  discountPercent: providerData.discountPercent,
                                  discountType: discountType.toLowerCase(),
                                );

                                // Navigate to details after success
                                if (purchaseData != null) {
                                  final refreshed = await repo.getSinglePurchase((purchaseData.id ?? 0).toInt());
                                  providerData.cartItemList.clear();

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseInvoiceDetails(
                                        businessInfo: personalData.value!,
                                        transitionModel: refreshed ?? purchaseData!,
                                        isFromPurchase: true,
                                      ),
                                    ),
                                  );
                                }
                              }

                              /// UPDATE MODE
                              else {
                                if (!permissionService.hasPermission(Permit.purchasesUpdate.value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(lang.S.of(context).purchaseUpdateWarn),
                                    ),
                                  );
                                  return;
                                }

                                purchaseData = await repo.updatePurchase(
                                  id: widget.transitionModel!.id!,
                                  ref: ref,
                                  context: context,
                                  vatId: providerData.selectedVat?.id,
                                  totalAmount: providerData.totalPayableAmount,
                                  purchaseDate: selectedDate.toString(),
                                  products: providerData.cartItemList,
                                  vatAmount: providerData.vatAmount,
                                  vatPercent: providerData.selectedVat?.rate ?? 0,
                                  paymentType: paymentData,
                                  changeAmount: providerData.changeAmount,
                                  partyId: widget.transitionModel?.party?.id ?? 0,
                                  isPaid: providerData.dueAmount <= 0,
                                  dueAmount: providerData.dueAmount <= 0 ? 0 : providerData.dueAmount,
                                  discountAmount: providerData.discountAmount,
                                );

                                if (purchaseData != null) {
                                  const PurchaseListScreen().launch(context);
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            } finally {
                              EasyLoading.dismiss();
                              setState(() {
                                isProcessing = false;
                              });
                            }
                          },
                          child: Text(
                            lang.S.of(context).save,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: _theme.colorScheme.primaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }, error: (e, stack) {
      return Center(child: Text(e.toString()));
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }
}
