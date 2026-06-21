import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Sales/provider/sales_cart_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Sales/Repo/sales_repo.dart';
import 'package:mobile_pos/Screens/Sales/sales_cart_widget.dart';
import 'package:mobile_pos/Screens/Sales/sales_products_list_screen.dart';
import 'package:mobile_pos/Screens/Settings/sales%20settings/model/amount_rounding_dropdown_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Repository/API/future_invoice.dart';
import '../../constant.dart';
import '../../currency.dart';
import 'model/sale_add_to_cart_model.dart';
import '../../model/sale_transaction_model.dart';
import '../../widgets/multipal payment mathods/multi_payment_widget.dart';
import '../Customers/Model/parties_model.dart';
import '../Home/home.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../Products/add product/modle/create_product_model.dart';
import '../invoice_details/sales_invoice_details_screen.dart';
import '../vat_&_tax/model/vat_model.dart';
import '../vat_&_tax/provider/text_repo.dart';

class AddSalesScreen extends ConsumerStatefulWidget {
  AddSalesScreen({
    super.key,
    required this.customerModel,
    this.transitionModel,
    this.isFromPos,
  });

  Party? customerModel;
  final SalesTransactionModel? transitionModel;
  bool? isFromPos;

  @override
  AddSalesScreenState createState() => AddSalesScreenState();
}

class AddSalesScreenState extends ConsumerState<AddSalesScreen> {
  // Key to access MultiPaymentWidget State
  final GlobalKey<MultiPaymentWidgetState> paymentWidgetKey = GlobalKey();

  bool isProcessing = false;

  DateTime selectedDate = DateTime.now();

  TextEditingController dateController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
  TextEditingController recevedAmountController = TextEditingController();

  TextEditingController noteController = TextEditingController();
  bool _initialingFirstTime = false;

  // --- Helper Method for Floating-Point Precision Fix ---
  num _round(num value) {
    return num.parse(value.toStringAsFixed(2));
  }

  @override
  void initState() {
    super.initState();

    // Listener for Received Amount Controller to calculate prices
    recevedAmountController.addListener(() {
      final cart = ref.read(cartNotifier);
      cart.calculatePrice(receivedAmount: recevedAmountController.text, stopRebuild: !_initialingFirstTime);
    });

    if (widget.transitionModel != null) {
      final editedSales = widget.transitionModel;
      dateController.text = editedSales?.saleDate?.substring(0, 10) ?? '';

      // Fixed Precision Issue Here
      recevedAmountController.text = editedSales?.paidAmount != null ? _round(editedSales!.paidAmount!).toString() : '';

      widget.customerModel = Party(
        id: widget.transitionModel?.party?.id,
        name: widget.transitionModel?.party?.name,
      );
      if (widget.transitionModel?.discountType == 'flat') {
        discountType = 'Flat';
      } else {
        discountType = 'Percent';
      }
      // Note: Pre-populating multi-payment from edit model would require parsing editedSales.paymentType or similar
      addProductsInCartFromEditList();
    }
    _initialingFirstTime = true;
  }

  @override
  void dispose() {
    dateController.dispose();
    recevedAmountController.dispose();
    super.dispose();
  }

  void addProductsInCartFromEditList() {
    final cart = ref.read(cartNotifier);
    cart.roundedOption = widget.transitionModel?.roundingOption ?? roundingMethods[0].value;

    if (widget.transitionModel?.salesDetails?.isNotEmpty ?? false) {
      for (var detail in widget.transitionModel!.salesDetails!) {
        SaleCartModel cartItem = SaleCartModel(
          productType: detail.product?.productType,
          productName: detail.product?.productName,
          // Fixed Precision Issues Here
          discountAmount: _round(detail.discount ?? 0),
          unitPrice: _round(detail.price ?? 0),
          batchName: detail.stock?.batchNo,
          lossProfit: _round(detail.lossProfit ?? 0),
          quantity: detail.quantities ?? 0,
          productCode: detail.product?.productCode,
          productPurchasePrice: _round(detail.product?.productPurchasePrice ?? 0),
          stock: detail.stock?.productCurrentStock,
          productId: detail.productId!,
          stockId: detail.stock?.id ?? 0,
          serialNumber: detail.serialNumbers ?? [],
        );
        cart.addToCartRiverPod(
            cartItem: cartItem,
            fromEditSales: true,
            isVariant: detail.product?.productType == ProductType.variant.name);
      }
    }

    cart.discountAmount = _round(widget.transitionModel?.discountAmount ?? 0);
    noteController.text = widget.transitionModel?.meta?.note?.toString() ?? '';

    if (widget.transitionModel?.discountType == 'flat') {
      cart.discountTextControllerFlat.text = widget.transitionModel?.discountAmount != null
          ? _round(widget.transitionModel!.discountAmount!).toString()
          : '';
    } else {
      cart.discountTextControllerFlat.text = widget.transitionModel?.discountPercent != null
          ? _round(widget.transitionModel!.discountPercent!).toString()
          : '';
    }

    cart.finalShippingCharge = _round(widget.transitionModel?.shippingCharge ?? 0);
    cart.shippingChargeController.text = widget.transitionModel?.shippingCharge != null
        ? _round(widget.transitionModel!.shippingCharge!).toString()
        : '';

    cart.vatAmountController.text =
        widget.transitionModel?.vatAmount != null ? _round(widget.transitionModel!.vatAmount!).toString() : '';

    cart.calculatePrice(
        receivedAmount:
            widget.transitionModel?.paidAmount != null ? _round(widget.transitionModel!.paidAmount!).toString() : null,
        stopRebuild: true);
  }

  bool hasPreselected = false; // Flag to ensure preselection happens only once

  String flatValue = 'Flat';
  String percentValue = 'Percent';

  String discountType = 'Flat';

  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    double _height = 100;
    final providerData = ref.watch(cartNotifier);
    final personalData = ref.watch(businessInfoProvider);
    final taxesData = ref.watch(taxProvider);
    final permissionService = PermissionService(ref);
    return personalData.when(data: (data) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).addSales,
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
                  ///_______Invoice_And_Date_____________________________________________________
                  Row(
                    children: [
                      widget.transitionModel == null
                          ? FutureBuilder(
                              future: FutureInvoice().getFutureInvoice(tag: 'sales'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final invoiceValue =
                                      (snapshot.data != null) ? snapshot.data.toString().replaceAll('"', '') : '';
                                  return Expanded(
                                    child: AppTextField(
                                      textFieldType: TextFieldType.NAME,
                                      initialValue: invoiceValue ?? '',
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: dateController,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).date,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            suffixIcon: IconButton(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
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
                              icon: Icon(
                                IconlyLight.calendar,
                                color: kPeraColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  ///______Selected_Due_And_Customer___________________________________________
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(lang.S.of(context).dueAmount),
                          Text(
                            widget.customerModel?.due == null
                                ? '$currency 0'
                                : '$currency ${formatPointNumber(widget.customerModel?.due ?? 0)}',
                            style: const TextStyle(color: Color(0xFFFF8C34)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                    ],
                  ),
                  SizedBox(height: 12),

                  ///_______Add_Button__________________________________________________
                  if (widget.isFromPos != true)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SaleProductsList(
                              customerModel: widget.customerModel,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: kMainColor2,
                        minimumSize: Size.fromHeight(40),
                      ),
                      child: Text(lang.S.of(context).addItems,
                          style: _theme.textTheme.titleMedium?.copyWith(
                            color: kMainColor,
                          )),
                    ),
                  const SizedBox(height: 12),

                  ///_______Added_Items_List_________________________________________________
                  SalesCartListWidget(),

                  ///_____Total_Section_____________________________
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey.shade300, width: 1)),
                    child: Column(
                      children: [
                        ///________Total_title_reader_________________________
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: kMainColor2,
                              borderRadius:
                                  BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).subTotal,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$currency ${formatPointNumber(providerData.totalAmount)}',
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///_________Discount___________________________________
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text for "Discount"
                              Text(
                                lang.S.of(context).discount,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: kPeraColor,
                                ),
                              ),

                              Spacer(),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: kBorder, width: 1)),
                                  ),
                                  child: DropdownButton<String?>(
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: kPeraColor,
                                      size: 18,
                                    ),
                                    dropdownColor: Colors.white,
                                    isExpanded: true,
                                    isDense: true,
                                    padding: EdgeInsets.zero,
                                    hint: Text(
                                      lang.S.of(context).select,
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                        color: kGreyTextColor,
                                      ),
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
                                child: TextFormField(
                                  style: _theme.textTheme.titleSmall,
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
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleMedium?.copyWith(
                                      color: kPeraColor,
                                    ),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///_________Vat_Dropdown_______________________________
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                lang.S.of(context).vat,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  color: kPeraColor,
                                ),
                              ),
                              const SizedBox(width: 10),
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
                                        border: Border(
                                          bottom: BorderSide(color: kBorder, width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButton<VatModel?>(
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                color: kPeraColor,
                                                size: 18,
                                              ),
                                              dropdownColor: Colors.white,
                                              isExpanded: true,
                                              isDense: true,
                                              padding: EdgeInsets.zero,
                                              underline: const SizedBox(),
                                              hint: Text(
                                                lang.S.of(context).selectOne,
                                                style: _theme.textTheme.bodyMedium?.copyWith(
                                                  color: kPeraColor,
                                                ),
                                              ),
                                              value: providerData.selectedVat,
                                              items: dataList.map((VatModel tax) {
                                                return DropdownMenuItem<VatModel>(
                                                  value: tax,
                                                  child: Text(
                                                    '${tax.name ?? ''} (${tax.rate ?? 0}%)',
                                                    maxLines: 1,
                                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                                      color: kPeraColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (VatModel? newValue) =>
                                                  providerData.changeSelectedVat(data: newValue),
                                            ),
                                          ),

                                          // Close / Clear Button
                                          if (providerData.selectedVat != null)
                                            GestureDetector(
                                              onTap: () {
                                                providerData.changeSelectedVat(data: null);
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.only(left: 4.0, right: 2.0),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.redAccent,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                error: (error, stackTrace) {
                                  return Text(error.toString());
                                },
                                loading: () {
                                  return const SizedBox.shrink();
                                },
                              ),

                              const SizedBox(width: 10),

                              // VAT Amount Input Field
                              SizedBox(
                                height: 30,
                                width: 100,
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
                                    hintStyle: _theme.textTheme.titleSmall?.copyWith(
                                      color: kPeraColor,
                                    ),
                                    border: const UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: const UnderlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).shippingCharge,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  color: kPeraColor,
                                ),
                              ),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: providerData.shippingChargeController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>
                                      providerData.calculatePrice(shippingCharge: value, stopRebuild: false),
                                  textAlign: TextAlign.right,
                                  style: _theme.textTheme.titleSmall,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleSmall?.copyWith(
                                      color: kPeraColor,
                                    ),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________Total_______________________________________
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).total,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$currency ${formatPointNumber(providerData.actualTotalAmount)}',
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________Rounded Total_______________________________________
                        Visibility(
                          // visible: providerData.roundingAmount != 0,
                          child: Column(
                            children: [
                              ///________Rounded Amount_______________________________________
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).roundings,
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        color: kPeraColor,
                                      ),
                                    ),
                                    Text(
                                      '$currency ${formatPointNumber(providerData.roundingAmount)}',
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        color: kPeraColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).roundingTotal,
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        color: kPeraColor,
                                      ),
                                    ),
                                    Text(
                                      '$currency ${formatPointNumber(providerData.totalPayableAmount)}',
                                      style: _theme.textTheme.titleSmall?.copyWith(
                                        color: kPeraColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________paid_Amount__________________________________
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.S.of(context).receivedAmount,
                                style: _theme.textTheme.titleSmall?.copyWith(
                                  color: kPeraColor,
                                ),
                              ),
                              SizedBox(
                                width: context.width() / 4,
                                height: 30,
                                child: TextFormField(
                                  controller: recevedAmountController,
                                  readOnly: (paymentWidgetKey.currentState?.getPaymentEntries().length ?? 1) > 1,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.right,
                                  style: _theme.textTheme.titleSmall,
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: _theme.textTheme.titleSmall?.copyWith(
                                      color: kPeraColor,
                                    ),
                                    border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                    focusedBorder: UnderlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///________Change amount_________________________________
                        Visibility(
                          visible: providerData.changeAmount > 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10, top: 13, bottom: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).changeAmount,
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    color: kPeraColor,
                                  ),
                                ),
                                Text(
                                  '$currency ${formatPointNumber(providerData.changeAmount)}',
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    color: kPeraColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ///_______Due_amount_____________________________________
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
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    color: kPeraColor,
                                  ),
                                ),
                                Text(
                                  '$currency ${formatPointNumber(providerData.dueAmount)}',
                                  style: _theme.textTheme.titleSmall?.copyWith(
                                    color: kPeraColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///_______Payment_Type_______________________________
                  MultiPaymentWidget(
                    key: paymentWidgetKey,
                    showWalletOption: true,
                    totalAmountController: recevedAmountController,
                    showChequeOption: true,
                    initialTransactions: widget.transitionModel?.transactions,
                    onPaymentListChanged: () {
                      providerData.calculatePrice(receivedAmount: recevedAmountController.text);
                    },
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56, // Set a fixed height for the Row
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          // Use Expanded to allow the TextFormField to take available space
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                            ),
                            child: TextFormField(
                              controller: noteController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: lang.S.of(context).opinion,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  _height = (text.split('\n').length * 24).toDouble();
                                });
                              },
                              style: _theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _imageFile == null
                            ? widget.transitionModel?.image?.isNotEmpty ?? false
                                ? InkWell(
                                    onTap: () {
                                      showImagePickerDialog(context, _theme.textTheme);
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 48,
                                        minHeight: 48,
                                        maxWidth: 107,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: const Color(0xffF5F3F3),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              '${widget.transitionModel?.image.toString()}',
                                            ),
                                            fit: BoxFit.contain),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      showImagePickerDialog(context, _theme.textTheme);
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 48,
                                        minHeight: 48,
                                        maxWidth: 107,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: const Color(0xffF5F3F3),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(IconlyLight.camera),
                                          SizedBox(width: 4.0),
                                          Text(lang.S.of(context).image),
                                        ],
                                      ),
                                    ),
                                  )
                            : InkWell(
                                onTap: () {
                                  showImagePickerDialog(context, _theme.textTheme);
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 48,
                                    minHeight: 48,
                                    maxWidth: 107,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  ///_____Action_Button_____________________________________
                  const SizedBox(height: 24),
                  Row(
                    children: [
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
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            maximumSize: const Size(double.infinity, 48),
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: isProcessing
                                ? _theme.colorScheme.primary.withOpacity(0.15)
                                : _theme.colorScheme.primary,
                          ),
                          onPressed: () async {
                            if (providerData.cartItemList.isEmpty) {
                              EasyLoading.showError(lang.S.of(context).addProductFirst);
                              return;
                            }

                            bool isGuestDueSaleAllowed =
                                data.data?.allowDueSale == 1 || data.data?.allowDueSale.toString() == '1';

                            if (widget.customerModel == null && providerData.dueAmount > 0 && !isGuestDueSaleAllowed) {
                              EasyLoading.showError(
                                lang.S.of(context).dueSaleWarn,
                              );
                              return;
                            }

                            List<PaymentEntry> payments = paymentWidgetKey.currentState?.getPaymentEntries() ?? [];
                            if (payments.isEmpty) {
                              EasyLoading.showError('Please select at least one payment method');
                              return;
                            }

                            if (isProcessing) return;

                            setState(() {
                              isProcessing = true;
                            });

                            try {
                              EasyLoading.show(
                                status: lang.S.of(context).loading,
                                dismissOnTap: false,
                              );

                              List<CartSaleProducts> selectedProductList = providerData.cartItemList.map((element) {
                                return CartSaleProducts(
                                  productName: element.productName ?? '',
                                  stockId: element.stockId,
                                  quantities: element.quantity,
                                  price: _round(num.tryParse(element.unitPrice.toString()) ?? 0),
                                  productId: element.productId,
                                  discount: _round(element.discountAmount ?? 0),
                                  serialNumber: element.serialNumber,
                                );
                              }).toList();

                              File? imageFile;
                              if (_imageFile != null) {
                                final file = File(_imageFile!.path);
                                if (await file.exists()) {
                                  imageFile = file;
                                }
                              }

                              SaleRepo repo = SaleRepo();

                              List<Map<String, dynamic>> paymentData = payments.map((e) => e.toJson()).toList();
                              String paymentTypeData = jsonEncode(paymentData);

                              if (widget.transitionModel == null) {
                                if (!permissionService.hasPermission(Permit.salesCreate.value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        lang.S.of(context).createSaleWarn,
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                SalesTransactionModel? saleData = await repo.createSale(
                                  ref: ref,
                                  context: context,
                                  totalAmount: providerData.totalPayableAmount,
                                  purchaseDate: selectedDate.toIso8601String(),
                                  products: selectedProductList,
                                  paymentType: paymentTypeData,
                                  partyId: widget.customerModel?.id,
                                  customerPhone: null,
                                  vatAmount: providerData.vatAmount,
                                  vatPercent: providerData.selectedVat?.rate ?? 0,
                                  vatId: providerData.selectedVat?.id,
                                  isPaid: providerData.isFullPaid,
                                  dueAmount: providerData.dueAmount,
                                  discountAmount: providerData.discountAmount,
                                  changeAmount: providerData.changeAmount,
                                  discountType: discountType.toLowerCase() ?? '',
                                  roundedOption: providerData.roundedOption,
                                  roundingAmount: providerData.roundingAmount,
                                  unRoundedTotalAmount: providerData.actualTotalAmount,
                                  note: noteController.text,
                                  shippingCharge: providerData.finalShippingCharge,
                                  image: imageFile,
                                  discountPercent: providerData.discountPercent,
                                );

                                if (saleData != null && personalData.value != null) {
                                  final refreshed = await repo.getSingleSale((saleData.id ?? 0).toInt());

                                  if (refreshed == null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SalesInvoiceDetails(
                                          businessInfo: personalData.value!,
                                          saleTransaction: refreshed!,
                                          fromSale: true,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SalesInvoiceDetails(
                                        businessInfo: personalData.value!,
                                        saleTransaction: refreshed,
                                        fromSale: true,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                if (!permissionService.hasPermission(Permit.salesUpdate.value)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(lang.S.of(context).updateSaleWarn),
                                    ),
                                  );
                                  return;
                                }

                                await repo.updateSale(
                                  id: widget.transitionModel?.id ?? 0,
                                  ref: ref,
                                  context: context,
                                  roundingAmount: providerData.roundingAmount,
                                  totalAmount: providerData.totalPayableAmount,
                                  purchaseDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                    DateTime.parse(
                                      selectedDate.toString(),
                                    ),
                                  ),
                                  products: selectedProductList,
                                  paymentType: paymentTypeData,
                                  partyId: widget.transitionModel?.party?.id,
                                  roundedOption: providerData.roundedOption,
                                  vatAmount: providerData.vatAmount,
                                  vatPercent: providerData.selectedVat?.rate ?? 0,
                                  vatId: providerData.selectedVat?.id,
                                  isPaid: providerData.isFullPaid,
                                  dueAmount: providerData.dueAmount,
                                  discountAmount: providerData.discountAmount,
                                  unRoundedTotalAmount: providerData.actualTotalAmount,
                                  changeAmount: providerData.changeAmount,
                                  discountType: discountType.toLowerCase(),
                                  note: noteController.text,
                                  shippingCharge: providerData.finalShippingCharge,
                                  image: imageFile,
                                  discountPercent: providerData.discountPercent,
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              EasyLoading.dismiss();
                              setState(() {
                                isProcessing = false;
                              });
                            }
                          },
                          child: isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _theme.colorScheme.primaryContainer,
                                  ),
                                )
                              : Text(
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
      return Center(
        child: Text(e.toString()),
      );
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }

  Future<dynamic> showImagePickerDialog(BuildContext context, TextTheme textTheme) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext contexts) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          title: Text(
            lang.S.of(context).uploadImage,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Column(
                children: [
                  const Icon(IconlyLight.image, size: 30.0),
                  Text(
                    lang.S.of(context).useGallery,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onPressed: () async {
                _pickImage(ImageSource.gallery);
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pop(context);
                });
              },
            ),
            CupertinoDialogAction(
              child: Column(
                children: [
                  const Icon(IconlyLight.camera, size: 30.0),
                  Text(
                    lang.S.of(context).openCamera,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              onPressed: () async {
                _pickImage(ImageSource.camera);
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
