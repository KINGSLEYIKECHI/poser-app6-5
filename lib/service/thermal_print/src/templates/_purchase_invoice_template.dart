import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/add%20product/modle/create_product_model.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:mobile_pos/thermal%20priting%20invoices/model/print_transaction_model.dart';

import '../../thermer/thermer.dart' as thermer;

class PurchaseThermalInvoiceTemplate {
  PurchaseThermalInvoiceTemplate({
    required this.printTransactionModel,
    required this.productList,
    required this.is58mm,
    required this.context,
    required this.isRTL,
  });

  final PrintPurchaseTransactionModel printTransactionModel;
  final List<PurchaseDetails>? productList;
  final bool is58mm;
  final BuildContext context;
  final bool isRTL;

  // --- Helpers: Styles & Formats ---

  thermer.TextStyle _commonStyle({double fontSize = 24, bool isBold = false}) {
    return thermer.TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? thermer.FontWeight.bold : thermer.FontWeight.w500,
      color: thermer.Colors.black,
    );
  }

  String formatPointNumber(num number, {bool addComma = false}) {
    if (addComma) return NumberFormat("#,###.##", "en_US").format(number);
    return number.toStringAsFixed(2);
  }

  // --- Data Logic (Adapted from your provided code) ---

  num _getProductPrice(num detailsId) {
    return productList!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
  }

  String _getProductName(num detailsId) {
    final details = printTransactionModel.purchaseTransitionModel?.details?.firstWhere(
      (element) => element.id == detailsId,
      orElse: () => PurchaseDetails(),
    );
    String name = details?.product?.productName ?? '';
    if (details?.product?.productType == ProductType.variant.name) {
      name += ' [${details?.stock?.batchNo ?? ''}]';
    }
    return name;
  }

  num _getProductQuantity(num detailsId) {
    num totalQuantity = productList?.where((element) => element.id == detailsId).first.quantities ?? 0;

    // Add returned quantities logic
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
        if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.purchaseReturnDetails!) {
            if (details.purchaseDetailId == detailsId) {
              totalQuantity += details.returnQty ?? 0;
            }
          }
        }
      }
    }
    return totalQuantity;
  }

  num _getTotalForOldInvoice() {
    num total = 0;
    if (productList != null) {
      for (var element in productList!) {
        num productPrice = element.priceWithoutTax ?? 0;
        num productQuantity = _getProductQuantity(element.id ?? 0);
        total += productPrice * productQuantity;
      }
    }
    return total;
  }

  num _getTotalVatAmountForOldInvoice() {
    num total = 0;
    if (productList != null) {
      for (var element in productList!) {
        num productVatAmount = (element.productPurchasePrice ?? 0) - (element.priceWithoutTax ?? 0);
        num productQuantity = _getProductQuantity(element.id ?? 0);
        total += productVatAmount * productQuantity;
      }
    }
    return total;
  }

  num _getReturnedDiscountAmount() {
    num totalReturnDiscount = 0;
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
        if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.purchaseReturnDetails!) {
            totalReturnDiscount += ((_getProductPrice(details.purchaseDetailId ?? 0) * (details.returnQty ?? 0)) -
                ((details.returnAmount ?? 0)));
          }
        }
      }
    }
    return totalReturnDiscount;
  }

  num _getTotalReturnedAmount() {
    num totalReturn = 0;
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
        if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
          for (var details in returns.purchaseReturnDetails!) {
            totalReturn += details.returnAmount ?? 0;
          }
        }
      }
    }
    return totalReturn;
  }

  // --- Main Generator ---

  Future<List<int>> get template async {
    String _printProfiles = printTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    final _profile = await CapabilityProfile.load(name: _printProfiles);
    final _generator = Generator(is58mm ? PaperSize.mm58 : PaperSize.mm80, _profile);

    final _imageBytes = await _generateLayout();
    final _image = img.decodeImage(_imageBytes);

    if (_image == null) throw Exception('Failed to generate invoice.');

    List<int> _bytes = [];
    _bytes += _generator.image(_image);
    _bytes += _generator.cut();
    return _bytes;
  }

  Future<Uint8List> _generateLayout() async {
    final data = printTransactionModel.purchaseTransitionModel;
    final info = printTransactionModel.personalInformationModel.data;
    final _lang = lang.S.of(context);

    // 1. Prepare Logo
    thermer.ThermerImage? _logo;
    if (info?.thermalInvoiceLogo != null && info?.showThermalInvoiceLogo == 1) {
      try {
        _logo = await thermer.ThermerImage.network(
          "${info?.thermalInvoiceLogo ?? ''}",
          width: is58mm ? 120 : 184,
          height: is58mm ? 120 : 184,
        );
      } catch (_) {}
    }

    //qr logo
    thermer.ThermerImage? _qrLogo;
    if (info?.invoiceScannerLogo != null && info?.showInvoiceScannerLogo == 1) {
      try {
        _qrLogo = await thermer.ThermerImage.network(
          (info?.invoiceScannerLogo ?? ''),
          width: is58mm ? 120 : 140,
          height: is58mm ? 120 : 140,
        );
      } catch (_) {}
    }

    // 2. Prepare Product Rows
    final productRows = _buildProductRows();

    // 3. Prepare Returns
    final returnWidgets = _buildReturnSection(_lang);

    // 4. Build Layout
    final _layout = thermer.ThermerLayout(
      paperSize: is58mm ? thermer.PaperSize.mm58 : thermer.PaperSize.mm80,
      textDirection: isRTL ? thermer.TextDirection.rtl : thermer.TextDirection.ltr,
      widgets: [
        // --- Header ---
        if (_logo != null) ...[thermer.ThermerAlign(child: _logo), thermer.ThermerSizedBox(height: 16)],

        if (info?.meta?.showCompanyName == 1)
          thermer.ThermerText(
            info?.companyName ?? '',
            style: _commonStyle(fontSize: is58mm ? 46 : 54),
            textAlign: thermer.TextAlign.center,
          ),

        if (data?.branch?.name != null)
          thermer.ThermerText('${_lang.branch}: ${data?.branch?.name}',
              style: _commonStyle(), textAlign: thermer.TextAlign.center),

        if (info?.meta?.showAddress == 1)
          if (data?.branch?.address != null || info?.address != null)
            thermer.ThermerText(
              '${_lang.address}: ${data?.branch?.address ?? info?.address ?? ''}',
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        if (info?.meta?.showPhoneNumber == 1)
          if (data?.branch?.phone != null || info?.phoneNumber != null)
            thermer.ThermerText(
              '${_lang.mobile} ${data?.branch?.phone ?? info?.phoneNumber ?? ''}',
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        if (info?.meta?.showVat == 1)
          if (info?.vatNo != null && info?.meta?.showVat == 1)
            thermer.ThermerText(
              "${info?.vatName ?? _lang.vatNumber}: ${info?.vatNo}",
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        thermer.ThermerSizedBox(height: 16),
        thermer.ThermerText(
          _lang.invoice,
          style: _commonStyle(fontSize: is58mm ? 30 : 48, isBold: true)
              .copyWith(decoration: thermer.TextDecoration.underline),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // --- Info Section ---
        ..._buildInfoSection(_lang),

        thermer.ThermerSizedBox(height: 8),

        // --- Product Table ---
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            if (!is58mm) thermer.ThermerText(_lang.sl, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.item, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.qty, textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.price, textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.total, textAlign: thermer.TextAlign.end, style: _commonStyle(isBold: true)),
          ]),
          data: productRows,
          cellWidths: is58mm
              ? {0: null, 1: 0.2, 2: 0.2, 3: 0.25} // 58mm
              : {0: 0.1, 1: null, 2: 0.15, 3: 0.15, 4: 0.2}, // 80mm
          columnSpacing: 10.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        // --- Calculations ---
        if (!is58mm)
          thermer.ThermerRow(
            children: [
              thermer.ThermerExpanded(flex: 4, child: thermer.ThermerAlign(child: _buildPaymentInfoText(_lang))),
              thermer.ThermerExpanded(flex: 6, child: _buildCalculationColumn(_lang, info)),
            ],
          )
        else ...[
          _buildCalculationColumn(_lang, info),
          thermer.ThermerDivider.horizontal(),
          _buildPaymentInfoText(_lang),
        ],

        thermer.ThermerSizedBox(height: 16),

        // --- Returns ---
        ...returnWidgets,

        // --- Footer ---
        if (info?.gratitudeMessage != null && info?.showGratitudeMsg == 1)
          thermer.ThermerText(info?.gratitudeMessage ?? '',
              textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),

        if (data?.purchaseDate != null)
          thermer.ThermerText(
            DateFormat('M/d/yyyy h:mm a').format(DateTime.parse(data!.purchaseDate!)),
            textAlign: thermer.TextAlign.center,
            style: _commonStyle(),
          ),

        thermer.ThermerSizedBox(height: 16),

        if (info?.showNote == 1)
          thermer.ThermerText(
            '${info?.invoiceNoteLevel ?? _lang.note}: ${info?.invoiceNote ?? ''}',
            textAlign: thermer.TextAlign.left,
            style: _commonStyle(),
          ),

        thermer.ThermerSizedBox(height: 16),
        if (_qrLogo != null) ...[thermer.ThermerAlign(child: _qrLogo), thermer.ThermerSizedBox(height: 1)],
        // if (info?.developByLink != null)
        //   thermer.ThermerAlign(child: thermer.ThermerQRCode(data: info?.developByLink ?? '', size: 120)),

        if (info?.developBy != null)
          thermer.ThermerText(
            '${info?.developByLevel ?? _lang.developedBy}: ${info?.developBy}',
            textAlign: thermer.TextAlign.center,
            style: _commonStyle(),
          ),

        thermer.ThermerSizedBox(height: 200), // Cutter Space
      ],
    );

    return _layout.toUint8List();
  }

  // --- Sub-Builders ---

  List<thermer.ThermerWidget> _buildInfoSection(lang.S _lang) {
    final data = printTransactionModel.purchaseTransitionModel;
    final dateStr = data?.purchaseDate != null ? DateFormat.yMd().format(DateTime.parse(data!.purchaseDate!)) : '';
    final timeStr = data?.purchaseDate != null ? DateFormat.jm().format(DateTime.parse(data!.purchaseDate!)) : '';

    final invText = '${_lang.invoice}: ${data?.invoiceNumber ?? 'Not Provided'}';
    final dateText = '${_lang.date}: $dateStr';
    final timeText = '${_lang.time}: $timeStr';
    final nameText = '${_lang.name}: ${data?.party?.name ?? 'Guest'}';
    final mobileText = '${_lang.mobile} ${data?.party?.phone ?? ''}';
    final purchaseByText = '${_lang.purchaseBy} ${data?.user?.role == "shop-owner" ? 'Admin' : data?.user?.name ?? ''}';

    if (is58mm) {
      return [
        thermer.ThermerText(invText, style: _commonStyle()),
        if (data?.purchaseDate != null) thermer.ThermerText("$dateText $timeStr", style: _commonStyle()),
        thermer.ThermerText(nameText, style: _commonStyle()),
        thermer.ThermerText(mobileText, style: _commonStyle()),
        thermer.ThermerText(purchaseByText, style: _commonStyle()),
      ];
    } else {
      return [
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(invText, style: _commonStyle()),
            if (data?.purchaseDate != null) thermer.ThermerText(dateText, style: _commonStyle()),
          ],
        ),
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(nameText, style: _commonStyle()),
            thermer.ThermerText(timeText, style: _commonStyle()),
          ],
        ),
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(mobileText, style: _commonStyle()),
            thermer.ThermerText(purchaseByText, style: _commonStyle()),
          ],
        ),
      ];
    }
  }

  List<thermer.ThermerTableRow> _buildProductRows() {
    List<thermer.ThermerTableRow> rows = [];
    if (productList == null) return rows;

    for (var index = 0; index < productList!.length; index++) {
      final item = productList?[index];
      final qty = _getProductQuantity(item?.id ?? 0);
      final price = item?.productPurchasePrice ?? 0;
      final amount = price * qty;

      rows.add(thermer.ThermerTableRow([
        if (!is58mm) thermer.ThermerText('${index + 1}', style: _commonStyle()),
        thermer.ThermerText(_getProductName(item?.id ?? 0), style: _commonStyle()),
        thermer.ThermerText(formatPointNumber(qty, addComma: true),
            textAlign: thermer.TextAlign.center, style: _commonStyle()),
        thermer.ThermerText(formatPointNumber(price, addComma: true),
            textAlign: thermer.TextAlign.center, style: _commonStyle()),
        thermer.ThermerText(formatPointNumber(amount, addComma: true),
            textAlign: thermer.TextAlign.end, style: _commonStyle()),
      ]));
      if (item?.serialNumbers?.isNotEmpty ?? false) {
        rows.add(thermer.ThermerTableRow([
          if (!is58mm) thermer.ThermerText('', style: _commonStyle()),
          thermer.ThermerText('${lang.S.of(context).serial}: ${item?.serialNumbers}', style: _commonStyle()),
          thermer.ThermerText('', style: _commonStyle()),
          thermer.ThermerText('', style: _commonStyle()),
          thermer.ThermerText('', style: _commonStyle()),
        ]));
      }
    }
    return rows;
  }

  thermer.ThermerColumn _buildCalculationColumn(lang.S _lang, BusinessInfoData? info) {
    final data = printTransactionModel.purchaseTransitionModel;

    thermer.ThermerRow calcRow(String label, num value, {bool bold = false, bool isCurrency = true}) {
      return thermer.ThermerRow(
        mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        children: [
          thermer.ThermerText(label, style: _commonStyle(isBold: bold)),
          thermer.ThermerText(
            isCurrency ? formatPointNumber(value) : formatPointNumber(value), // Updated here
            textAlign: thermer.TextAlign.end,
            style: _commonStyle(isBold: bold),
          ),
        ],
      );
    }

    return thermer.ThermerColumn(children: [
      calcRow('${_lang.subTotal}:', _getTotalForOldInvoice()),
      calcRow('${info?.vatName ?? _lang.vat}:', _getTotalVatAmountForOldInvoice() + (data?.vatAmount ?? 0)),
      calcRow('${_lang.shippingCharge}:', (data?.shippingCharge ?? 0)),
      calcRow('${_lang.discount}:', (data?.discountAmount ?? 0) + _getReturnedDiscountAmount()),
      thermer.ThermerDivider.horizontal(),
      if (_getTotalReturnedAmount() > 0) calcRow('${_lang.returnAmount}:', _getTotalReturnedAmount()),
      calcRow('${_lang.totalPayable}:', data?.totalAmount ?? 0, bold: true),
      calcRow('${_lang.paidAmount}:', ((data?.totalAmount ?? 0) - (data?.dueAmount ?? 0)) + (data?.changeAmount ?? 0)),
      if ((data?.dueAmount ?? 0) > 0) calcRow('${_lang.dueAmount}', data?.dueAmount ?? 0),
      if ((data?.changeAmount ?? 0) > 0) calcRow('${_lang.changeAmount}:', data?.changeAmount ?? 0),
    ]);
  }

  thermer.ThermerText _buildPaymentInfoText(lang.S _lang) {
    final transactions = printTransactionModel.purchaseTransitionModel?.transactions ?? [];
    List<String> labels = [];

    for (var item in transactions) {
      String label = item.paymentType?.name ?? 'n/a';
      if (item.transactionType == 'cash_payment') label = _lang.cash;
      if (item.transactionType == 'cheque_payment') label = _lang.cheque;
      if (item.transactionType == 'wallet_payment') label = _lang.wallet;
      labels.add(label);
    }
    return thermer.ThermerText(
      "${_lang.paidVia}: ${labels.join(', ')}",
      style: _commonStyle(),
      textAlign: is58mm ? thermer.TextAlign.left : thermer.TextAlign.left,
    );
  }

  List<thermer.ThermerWidget> _buildReturnSection(lang.S _lang) {
    final returns = printTransactionModel.purchaseTransitionModel?.purchaseReturns;
    if (returns?.isEmpty ?? true) return [];

    List<thermer.ThermerWidget> widgets = [];
    List<String> processedDates = [];

    for (var i = 0; i < (returns?.length ?? 0); i++) {
      final dateStr = returns![i].returnDate?.substring(0, 10);
      if (dateStr != null && !processedDates.contains(dateStr)) {
        processedDates.add(dateStr);
        widgets.add(thermer.ThermerDivider.horizontal());

        // Return Header
        widgets.add(thermer.ThermerRow(
          children: [
            if (!is58mm) thermer.ThermerText(_lang.sl, style: _commonStyle(isBold: true)),
            thermer.ThermerText('${_lang.retur}-${DateFormat.yMd().format(DateTime.parse(returns[i].returnDate!))}',
                style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.qty, textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.total, textAlign: thermer.TextAlign.end, style: _commonStyle(isBold: true)),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ));
      }

      widgets.add(
        thermer.ThermerTable(
          data: (returns[i].purchaseReturnDetails ?? []).expand((d) {
            List<thermer.ThermerTableRow> rows = [];

            // 🔹 Main Product Row
            rows.add(
              thermer.ThermerTableRow([
                if (!is58mm) thermer.ThermerText('*', style: _commonStyle()),
                thermer.ThermerText(
                  _getProductName(d.purchaseDetailId ?? 0),
                  style: _commonStyle(),
                ),
                thermer.ThermerText(
                  formatPointNumber(d.returnQty ?? 0), // Updated here
                  textAlign: thermer.TextAlign.center,
                  style: _commonStyle(),
                ),
                thermer.ThermerText(
                  formatPointNumber(d.returnAmount ?? 0, addComma: true),
                  textAlign: thermer.TextAlign.end,
                  style: _commonStyle(),
                ),
              ]),
            );
            // 🔹 Serial Number Row (Product name এর নিচে)
            if (d.serialNumbers != null && d.serialNumbers!.isNotEmpty) {
              rows.add(
                thermer.ThermerTableRow([
                  if (!is58mm) thermer.ThermerText('', style: _commonStyle()),
                  thermer.ThermerText(
                    '${_lang.serial}: ${d.serialNumbers}',
                    style: _commonStyle(fontSize: 18),
                  ),
                  thermer.ThermerText('', style: _commonStyle()),
                  thermer.ThermerText('', style: _commonStyle()),
                ]),
              );
            }

            return rows;
          }).toList(),
          cellWidths: is58mm ? {0: null, 1: 0.2, 2: 0.25} : {0: 0.1, 1: null, 2: 0.15, 3: 0.2},
        ),
      );
    }

    // Add Total Return Footer inside Calculation Column generally,
    // but if you want separate divider:
    widgets.add(thermer.ThermerDivider.horizontal());

    return widgets;
  }
}
