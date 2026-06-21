import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

// Project Imports
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/Screens/invoice%20return/repo/invoice_return_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../Sales/model/sale_add_to_cart_model.dart';
import '../../model/sale_transaction_model.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../widgets/multipal payment mathods/multi_payment_widget.dart';

class InvoiceReturnScreen extends StatefulWidget {
  const InvoiceReturnScreen({super.key, this.saleTransactionModel, this.purchaseTransaction});

  final SalesTransactionModel? saleTransactionModel;
  final PurchaseTransaction? purchaseTransaction;

  @override
  State<InvoiceReturnScreen> createState() => _InvoiceReturnScreenState();
}

class _InvoiceReturnScreenState extends State<InvoiceReturnScreen> {
  // --- Controllers & Keys ---
  final GlobalKey<MultiPaymentWidgetState> _paymentKey = GlobalKey<MultiPaymentWidgetState>();
  final TextEditingController _totalReturnAmountController = TextEditingController();

  // --- Data Lists ---
  List<SaleCartModel> returnList = [];
  List<TextEditingController> controllers = [];
  List<FocusNode> focus = [];

  // --- Serial Number Management ---
  List<List<String>> availableSerials = [];
  List<List<String>> selectedReturnSerials = [];

  // --- Helpers ---
  bool get isPurchase => widget.purchaseTransaction != null;
  bool get isSale => widget.saleTransactionModel != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (isPurchase && widget.purchaseTransaction?.details != null) {
      for (var element in widget.purchaseTransaction!.details!) {
        num unitPrice = calculateDiscountForEachProduct(
          productPrice: (element.productPurchasePrice ?? 0),
          quantity: (element.quantities ?? 0),
          totalDiscount: (widget.purchaseTransaction?.discountAmount ?? 0),
          totalPrice:
              ((widget.purchaseTransaction?.totalAmount ?? 0) + (widget.purchaseTransaction?.discountAmount ?? 0)) -
                  ((widget.purchaseTransaction?.vatAmount ?? 0) + (widget.purchaseTransaction?.shippingCharge ?? 0)),
        );

        List<String> serials = [];
        if (element.serialNumbers != null) {
          serials = element.serialNumbers!.map((e) => e.toString()).toList();
        }

        _addItemToList(
          name: element.product?.productName,
          batch: element.stock?.batchNo,
          stockId: element.stock?.id,
          unitPrice: unitPrice,
          detailId: element.id,
          productId: element.product?.id,
          stockQty: element.quantities,
          lossProfit: 0,
          serials: serials,
        );
      }
    } else if (isSale && widget.saleTransactionModel?.salesDetails != null) {
      for (var element in widget.saleTransactionModel!.salesDetails!) {
        num unitPrice = calculateDiscountForEachProduct(
          productPrice: (element.price ?? 0) - (element.discount ?? 0),
          quantity: (element.quantities ?? 0),
          totalDiscount:
              (widget.saleTransactionModel?.discountAmount ?? 0) - (widget.saleTransactionModel?.roundingAmount ?? 0),
          totalPrice:
              ((widget.saleTransactionModel?.totalAmount ?? 0) + (widget.saleTransactionModel?.discountAmount ?? 0)) -
                  ((widget.saleTransactionModel?.vatAmount ?? 0) + (widget.saleTransactionModel?.shippingCharge ?? 0)),
        );

        List<String> serials = [];
        if (element.serialNumbers != null) {
          serials = element.serialNumbers!.map((e) => e.toString()).toList();
        }

        _addItemToList(
          name: element.product?.productName,
          batch: element.stock?.batchNo,
          stockId: element.stock?.id,
          unitPrice: unitPrice,
          detailId: element.id,
          productId: element.product?.id,
          stockQty: element.quantities,
          lossProfit: element.lossProfit,
          serials: serials,
        );
      }
    }
    _updateTotalController();
  }

  void _addItemToList({
    String? name,
    String? batch,
    num? stockId,
    required num unitPrice,
    num? detailId,
    num? productId,
    num? stockQty,
    num? lossProfit,
    required List<String> serials,
  }) {
    returnList.add(SaleCartModel(
      productName: name,
      batchName: batch ?? '',
      stockId: stockId ?? 0,
      unitPrice: unitPrice,
      productId: detailId ?? 0,
      quantity: 0,
      productCode: productId.toString(),
      stock: stockQty ?? 0,
      lossProfit: lossProfit,
    ));

    controllers.add(TextEditingController(text: "0"));
    focus.add(FocusNode());
    availableSerials.add(serials);
    selectedReturnSerials.add([]);
  }

  void _updateTotalController() {
    _totalReturnAmountController.text = getTotalReturnAmount().toStringAsFixed(2);
  }

  num calculateDiscountForEachProduct(
      {required num totalDiscount, required num productPrice, required num totalPrice, required num quantity}) {
    if (totalPrice <= 0) return productPrice;
    num thisProductDiscount = (totalDiscount * (productPrice * quantity)) / totalPrice;
    return productPrice - (thisProductDiscount / (quantity == 0 ? 1 : quantity));
  }

  num getTotalReturnAmount() {
    num returnAmount = 0;
    for (var element in returnList) {
      if (element.quantity > 0) {
        returnAmount += element.quantity * (num.tryParse(element.unitPrice.toString()) ?? 0);
      }
    }
    return returnAmount;
  }

  void _openSerialSelectionPopup(int index) {
    List<String> tempSelected = List.from(selectedReturnSerials[index]);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Select Serial (${returnList[index].productName})"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableSerials[index].map((serial) {
                      return CheckboxListTile(
                        title: Text(serial),
                        value: tempSelected.contains(serial),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelected.add(serial);
                            } else {
                              tempSelected.remove(serial);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(lang.S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedReturnSerials[index] = tempSelected;
                      returnList[index].quantity = tempSelected.length;
                      controllers[index].text = returnList[index].quantity.toString();
                      _updateTotalController();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(lang.S.of(context).save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReturn(WidgetRef ref, PermissionService permissionService, BuildContext context) async {
    EasyLoading.show();

    List<ReturnProductModel> returnProducts = [];
    bool hasItems = false;

    for (int i = 0; i < returnList.length; i++) {
      if (returnList[i].quantity > 0) {
        hasItems = true;
        returnProducts.add(ReturnProductModel(
          detailId: returnList[i].productId,
          returnQty: returnList[i].quantity,
          serialNumbers: selectedReturnSerials[i],
        ));
      }
    }

    if (!hasItems) {
      EasyLoading.dismiss();
      EasyLoading.showError(lang.S.of(context).pleaseSelectForProductReturn);
      return;
    }

    String requiredPermission = isPurchase ? Permit.purchaseReturnsCreate.value : Permit.saleReturnsCreate.value;

    if (!permissionService.hasPermission(requiredPermission)) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(lang.S.of(context).permissionDenied)));
      return;
    }

    try {
      ReturnDataModel data = ReturnDataModel(
        transactionId:
            isPurchase ? widget.purchaseTransaction?.id.toString() : widget.saleTransactionModel?.id.toString(),
        products: returnProducts,
        payments: [],
      );

      List<PaymentEntry> payments = _paymentKey.currentState?.getPaymentEntries() ?? [];
      data.payments = payments.map((e) => e.toJson()).toList();

      InvoiceReturnRepo repo = InvoiceReturnRepo();
      bool? result;

      if (isPurchase) {
        result = await repo.createPurchaseReturn(ref: ref, context: context, returnData: data);
      } else {
        result = await repo.createSalesReturn(ref: ref, context: context, salesReturn: data);
      }

      EasyLoading.dismiss();

      if (result ?? false) {
        if (mounted) Navigator.pop(context);
      } else {
        EasyLoading.showError(lang.S.of(context).failedToProcessReturn);
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = lang.S.of(context);

    // FIX: Added safe fallbacks for missing data
    final invoiceNumber = isPurchase
        ? (widget.purchaseTransaction?.invoiceNumber ?? 'N/A')
        : (widget.saleTransactionModel?.invoiceNumber ?? 'N/A');

    final dateString = isPurchase
        ? (widget.purchaseTransaction?.purchaseDate ?? DateTime.now().toString())
        : (widget.saleTransactionModel?.saleDate ?? DateTime.now().toString());

    final partyName = isPurchase
        ? (widget.purchaseTransaction?.user?.name ?? 'Guest')
        : (widget.saleTransactionModel?.party?.name ?? 'Guest');

    final vatAmount = isPurchase
        ? ((widget.purchaseTransaction?.vatAmount ?? 0) + (widget.purchaseTransaction?.shippingCharge ?? 0))
        : ((widget.saleTransactionModel?.vatAmount ?? 0) + (widget.saleTransactionModel?.shippingCharge ?? 0));

    // FIX: Bypassing the translation bug dynamically.
    // If the l10n file incorrectly mapped purchaseReturn as 'Sales Return', this forces 'Purchase Return'.
    final String appBarTitle = isPurchase ? 'Purchase Return' : _lang.salesReturn;

    return Consumer(builder: (context, consumerRef, __) {
      final permissionService = PermissionService(consumerRef);

      return GlobalPopup(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(appBarTitle),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          initialValue: invoiceNumber,
                          decoration: InputDecoration(
                              labelText: _lang.invoiceNumber,
                              border: const OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.always),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          initialValue: DateFormat.yMMMd().format(DateTime.parse(dateString)),
                          decoration: InputDecoration(
                              labelText: lang.S.of(context).date,
                              border: const OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.always),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    readOnly: true,
                    initialValue: partyName,
                    decoration: InputDecoration(
                        labelText: lang.S.of(context).customerName,
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.always),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: theme.colorScheme.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xff000000).withValues(alpha: 0.08),
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                            blurRadius: 24)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xffFEF0F1),
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lang.S.of(context).itemAdded, style: const TextStyle(fontSize: 16)),
                                Text(lang.S.of(context).quantity, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: returnList.length,
                          itemBuilder: (context, index) {
                            focus[index].addListener(() {
                              if (!focus[index].hasFocus) setState(() {});
                            });
                            bool hasSerials = availableSerials[index].isNotEmpty;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(returnList[index].productName.toString(),
                                            maxLines: 2, overflow: TextOverflow.ellipsis),
                                        if (hasSerials && selectedReturnSerials[index].isNotEmpty)
                                          Text(
                                            "Serial: ${selectedReturnSerials[index].join(', ')}",
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          )
                                      ],
                                    )),
                                    Text(_lang.returnQuantity),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${formatPointNumber((returnList[index].stock ?? 0) - returnList[index].quantity)} X ${formatPointNumber(returnList[index].unitPrice ?? 0)}'),
                                    SizedBox(
                                      width: 120,
                                      child: hasSerials
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton.icon(
                                                onPressed: () => _openSerialSelectionPopup(index),
                                                icon: const Icon(Icons.qr_code, size: 16),
                                                label: Text(returnList[index].quantity.toString(),
                                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                                style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    backgroundColor: Colors.blue.withOpacity(0.1)),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                _buildQtyBtn(Icons.remove, () {
                                                  setState(() {
                                                    if (returnList[index].quantity > 0) {
                                                      returnList[index].quantity--;
                                                      controllers[index].text = returnList[index].quantity.toString();
                                                      _updateTotalController();
                                                    }
                                                  });
                                                }),
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    controller: controllers[index],
                                                    focusNode: focus[index],
                                                    textAlign: TextAlign.center,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                                                    ],
                                                    onChanged: (value) {
                                                      num stock = returnList[index].stock ?? 1;
                                                      num newVal = num.tryParse(value) ?? 0;
                                                      if (newVal <= stock) {
                                                        returnList[index].quantity = newVal;
                                                        _updateTotalController();
                                                      } else {
                                                        controllers[index].text = '0';
                                                        EasyLoading.showError(lang.S.of(context).outOfStock);
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: focus[index].hasFocus
                                                            ? null
                                                            : returnList[index].quantity.toString()),
                                                  ),
                                                ),
                                                _buildQtyBtn(Icons.add, () {
                                                  if (returnList[index].quantity < (returnList[index].stock ?? 0)) {
                                                    setState(() {
                                                      returnList[index].quantity++;
                                                      controllers[index].text = returnList[index].quantity.toString();
                                                      _updateTotalController();
                                                    });
                                                  } else {
                                                    EasyLoading.showError(_lang.outOfStock);
                                                  }
                                                }),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ).visible(returnList.isNotEmpty),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xff000000).withValues(alpha: 0.08),
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                            blurRadius: 24)
                      ],
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_lang.totalReturnAmount}:', style: const TextStyle(fontSize: 16)),
                            Text('$currency ${getTotalReturnAmount().toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text('${_lang.nonFoundableDiscount}:', style: const TextStyle(fontSize: 16))),
                            Text('$currency ${vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MultiPaymentWidget(
                    key: _paymentKey,
                    totalAmountController: _totalReturnAmountController,
                    showWalletOption: true,
                    hideAddButton: true,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        lang.S.of(context).cancel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      onPressed: () => _submitReturn(consumerRef, permissionService, context),
                      child: Text(
                        _lang.confirmReturn,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20,
        width: 20,
        decoration: const BoxDecoration(color: kMainColor, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
