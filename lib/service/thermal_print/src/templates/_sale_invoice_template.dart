import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';
import '../../thermer/thermer.dart' as thermer;

class SaleThermalInvoiceTemplate {
  SaleThermalInvoiceTemplate({
    required this.saleInvoice,
    required this.is58mm,
    required this.business,
    required this.context,
    required this.isRTL,
  });

  final SalesTransactionModel saleInvoice;
  final BusinessInformationModel business;
  final bool is58mm;
  final bool isRTL;
  final BuildContext context;

  // --- Helpers: Styles & Formats ---

  /// Centralized Text Style to ensure Black Color everywhere
  thermer.TextStyle _commonStyle({double fontSize = 24, bool isBold = false}) {
    return thermer.TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? thermer.FontWeight.bold : thermer.FontWeight.w500,
      color: thermer.Colors.black,
    );
  }

  // --- Data Logic ---

  String _getProductName(num detailsId) {
    final details = saleInvoice.salesDetails?.firstWhere(
      (e) => e.id == detailsId,
      orElse: () => SalesDetails(),
    );
    String name = details?.product?.productName ?? '';
    if (details?.product?.productType == 'variant' && details?.stock?.batchNo != null) {
      name += ' [${details!.stock!.batchNo}]';
    }
    return name;
  }

  num _getProductQty(num detailsId) {
    num totalQty =
        saleInvoice.salesDetails?.firstWhere((e) => e.id == detailsId, orElse: () => SalesDetails()).quantities ?? 0;

    // Add returned quantities back logic
    if (saleInvoice.salesReturns?.isNotEmpty ?? false) {
      for (var ret in saleInvoice.salesReturns!) {
        for (var det in ret.salesReturnDetails ?? []) {
          if (det.saleDetailId == detailsId) totalQty += det.returnQty ?? 0;
        }
      }
    }
    return totalQty;
  }

  // --- Main Generator ---

  @override
  Future<List<int>> get template async {
    String _printProfiles = business.data?.profilePrinter ?? 'default';
    final _profile = await CapabilityProfile.load(name: _printProfiles);
    final _generator = Generator(is58mm ? PaperSize.mm58 : PaperSize.mm80, _profile);

    // Generate Layout
    final _imageBytes = await _generateLayout();
    final _image = img.decodeImage(_imageBytes);

    if (_image == null) throw Exception('Failed to generate invoice.');

    List<int> _bytes = [];
    _bytes += _generator.image(_image);
    _bytes += _generator.cut();
    return _bytes;
  }

  Future<Uint8List> _generateLayout() async {
    final _lang = lang.S.of(context);
    // 1. Prepare Logo
    thermer.ThermerImage? _logo;
    if (business.data?.thermalInvoiceLogo != null && business.data?.showThermalInvoiceLogo == 1) {
      try {
        _logo = await thermer.ThermerImage.network(
          (business.data?.thermalInvoiceLogo ?? ''),
          width: is58mm ? 120 : 200,
          height: is58mm ? 120 : 200,
        );
      } catch (_) {}
    }

    // QR logo
    thermer.ThermerImage? _qrLogo;
    if (business.data?.invoiceScannerLogo != null && business.data?.showInvoiceScannerLogo == 1) {
      try {
        _qrLogo = await thermer.ThermerImage.network(
          (business.data?.invoiceScannerLogo ?? ''),
          width: is58mm ? 120 : 140,
          height: is58mm ? 120 : 140,
        );
      } catch (_) {}
    }

    // 2. Prepare Product Rows
    final productRows = _buildProductRows();

    // 3. Prepare Return Section
    final returnWidgets = _buildReturnSection(context);

    // 4. Build Layout
    final _layout = thermer.ThermerLayout(
      textDirection: isRTL ? thermer.TextDirection.rtl : thermer.TextDirection.ltr,
      paperSize: is58mm ? thermer.PaperSize.mm58 : thermer.PaperSize.mm80,
      widgets: [
        // --- Header Section ---
        if (_logo != null) ...[thermer.ThermerAlign(child: _logo), thermer.ThermerSizedBox(height: 16)],

        if (business.data?.meta?.showCompanyName == 1)
          thermer.ThermerText(
            business.data?.companyName ?? "N/A",
            style: _commonStyle(fontSize: is58mm ? 46 : 54, isBold: false),
            textAlign: thermer.TextAlign.center,
          ),

        if (saleInvoice.branch?.name != null)
          thermer.ThermerText('${_lang.branch}: ${saleInvoice.branch?.name}',
              style: _commonStyle(), textAlign: thermer.TextAlign.center),

        if (business.data?.meta?.showAddress == 1)
          if (business.data?.address != null || saleInvoice.branch?.address != null)
            thermer.ThermerText(
              saleInvoice.branch?.address ?? business.data?.address ?? 'N/A',
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        if (business.data?.meta?.showPhoneNumber == 1)
          if (business.data?.phoneNumber != null || saleInvoice.branch?.phone != null)
            thermer.ThermerText(
              '${_lang.mobile} ${saleInvoice.branch?.phone ?? business.data?.phoneNumber ?? "N/A"}',
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        if (business.data?.vatName != null && business.data?.meta?.showVat == 1)
          thermer.ThermerText("${business.data?.vatName}: ${business.data?.vatNo}",
              style: _commonStyle(), textAlign: thermer.TextAlign.center),

        thermer.ThermerSizedBox(height: 16),
        thermer.ThermerText(
          _lang.invoice,
          style: _commonStyle(fontSize: is58mm ? 30 : 48, isBold: true)
              .copyWith(decoration: thermer.TextDecoration.underline),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // --- Info Section (Layout adjusted based on is58mm) ---
        ..._buildInfoSection(_lang),

        thermer.ThermerSizedBox(height: 8),

        // --- Product Table ---
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            if (!is58mm) thermer.ThermerText(_lang.sl, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.item, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.qty, textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.price, textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),
            if (!is58mm && business.data?.allowProductDiscount == 1)
              thermer.ThermerText('Dis.', textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.amount, textAlign: thermer.TextAlign.end, style: _commonStyle(isBold: true)),
          ]),
          data: productRows,
          cellWidths: is58mm
              ? {0: null, 1: 0.2, 2: 0.2, 3: 0.25} // 58mm layout
              : (business.data?.allowProductDiscount == 1)
                  ? {0: 0.1, 1: null, 2: 0.12, 3: 0.18, 4: 0.15, 5: 0.2} // 80mm with discount
                  : {0: 0.1, 1: null, 2: 0.15, 3: 0.2, 4: 0.2}, // 80mm without discount
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        // --- Totals Section ---
        if (!is58mm)
          // 80mm Split Layout
          thermer.ThermerRow(
            children: [
              thermer.ThermerExpanded(flex: 4, child: thermer.ThermerAlign(child: _buildPaymentInfoText(_lang))),
              thermer.ThermerExpanded(flex: 6, child: _buildCalculationColumn(_lang)),
            ],
          )
        else ...[
          // 58mm Stacked Layout
          _buildCalculationColumn(_lang),
          thermer.ThermerDivider.horizontal(),
          _buildPaymentInfoText(_lang),
        ],

        thermer.ThermerSizedBox(height: 16),

        // --- Returns ---
        ...returnWidgets,

        // --- Footer ---
        if (business.data?.gratitudeMessage != null && business.data?.showGratitudeMsg == 1)
          thermer.ThermerText(business.data?.gratitudeMessage ?? '',
              textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),

        if (business.data?.showNote == 1)
          thermer.ThermerText('${business.data?.invoiceNoteLevel ?? _lang.note}: ${business.data?.invoiceNote}',
              textAlign: thermer.TextAlign.center, style: _commonStyle()),

        thermer.ThermerSizedBox(height: 16),
        if (_qrLogo != null) ...[thermer.ThermerAlign(child: _qrLogo), thermer.ThermerSizedBox(height: 1)],

        if (business.data?.developBy != null)
          thermer.ThermerText('${business.data?.developByLevel ?? _lang.developedBy} ${business.data?.developBy}',
              textAlign: thermer.TextAlign.center, style: _commonStyle()),

        thermer.ThermerSizedBox(height: 200), // Cutter space
      ],
    );

    return _layout.toUint8List();
  }

  // --- Sub-Builders ---

  List<thermer.ThermerWidget> _buildInfoSection(lang.S _lang) {
    DateTime? saleDateTime;

    if (saleInvoice.saleDate != null && saleInvoice.saleDate!.isNotEmpty) {
      saleDateTime = DateTime.tryParse(saleInvoice.saleDate!);
    }

    final formattedDate = saleDateTime != null
        ? DateFormat('dd MMMM yyyy').format(saleDateTime) // 25 January 2026
        : '';

    final formattedTime = saleDateTime != null
        ? DateFormat('hh:mm a').format(saleDateTime).toLowerCase() // 12:55 pm
        : '';

    final invText = '${_lang.invoice}: ${saleInvoice.invoiceNumber ?? ''}';
    final dateText = '${_lang.date}: ${formattedDate ?? ''}';
    final timeText = "${_lang.time}: ${formattedTime ?? ''}";
    final nameText = '${_lang.name}: ${saleInvoice.party?.name ?? 'Guest'}';
    final mobileText = '${_lang.mobile} ${saleInvoice.party?.phone ?? 'N/A'}';
    final salesByText =
        "${_lang.salesBy} ${saleInvoice.user?.role == 'shop-owner' ? _lang.admin : saleInvoice.user?.role ?? "N/A"}";

    if (is58mm) {
      // 58mm: Vertical Stack (One below another)
      return [
        thermer.ThermerText(
          invText,
          style: _commonStyle(),
        ),
        if (saleInvoice.saleDate != null) thermer.ThermerText(dateText, style: _commonStyle()),
        thermer.ThermerText(nameText, style: _commonStyle()),
        thermer.ThermerText(mobileText, style: _commonStyle()),
        thermer.ThermerText(salesByText, style: _commonStyle()),
      ];
    } else {
      // 80mm: Two columns (Side by side)
      return [
        // Row 1: Invoice | Date
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(invText, style: _commonStyle()),
            if (saleInvoice.saleDate != null) thermer.ThermerText(dateText, style: _commonStyle()),
          ],
        ),
        // Row 2: Name | Time
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(nameText, style: _commonStyle()),
            thermer.ThermerText(timeText, style: _commonStyle()),
          ],
        ),
        // Row 3: Mobile | Sales By
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(mobileText, style: _commonStyle()),
            thermer.ThermerText(salesByText, style: _commonStyle()),
          ],
        ),
      ];
    }
  }

  List<thermer.ThermerTableRow> _buildProductRows() {
    List<thermer.ThermerTableRow> rows = [];
    if (saleInvoice.salesDetails == null) return rows;

    for (var index = 0; index < saleInvoice.salesDetails!.length; index++) {
      final item = saleInvoice.salesDetails?[index];
      final qty = _getProductQty(item?.id ?? 0);
      final price = item?.price ?? 0;
      final discount = item?.discount ?? 0;
      final amount = (price * qty) - (discount * qty);

      // Main Row
      rows.add(thermer.ThermerTableRow([
        if (!is58mm) thermer.ThermerText((index + 1).toString(), style: _commonStyle()),
        thermer.ThermerText(_getProductName(item?.id ?? 0), style: _commonStyle()),
        thermer.ThermerText(formatPointNumber(qty), textAlign: thermer.TextAlign.center, style: _commonStyle()),
        thermer.ThermerText('$currency ${formatPointNumber(price)}',
            textAlign: thermer.TextAlign.center, style: _commonStyle()),
        if (!is58mm && business.data?.allowProductDiscount == 1)
          thermer.ThermerText('$currency ${formatPointNumber(discount)}',
              textAlign: thermer.TextAlign.center, style: _commonStyle()),
        thermer.ThermerText('$currency ${formatPointNumber(amount)}',
            textAlign: thermer.TextAlign.end, style: _commonStyle()),
      ]));

      if (saleInvoice.salesDetails?[index].serialNumbers?.isNotEmpty ?? false) {
        rows.add(thermer.ThermerTableRow([
          if (!is58mm) thermer.ThermerText('', style: _commonStyle()),
          thermer.ThermerText('${lang.S.of(context).serial}: ${saleInvoice.salesDetails![index].serialNumbers}',
              style: _commonStyle()),
          thermer.ThermerText('', style: _commonStyle()),
          thermer.ThermerText('', style: _commonStyle()),
          if (!is58mm && business.data?.allowProductDiscount == 1) thermer.ThermerText('', style: _commonStyle()),
          thermer.ThermerText('', style: _commonStyle()),
        ]));
      }

      // Warranty/Guarantee
      final w = item?.warrantyInfo;
      if (w?.warrantyDuration != null) {
        rows.add(_buildInfoRow("${lang.S.of(context).warranty} : ${w!.warrantyDuration} ${w.warrantyUnit}"));
      }
      if (w?.guaranteeDuration != null) {
        rows.add(_buildInfoRow("${lang.S.of(context).guarantee} : ${w!.guaranteeDuration} ${w.guaranteeUnit}"));
      }
    }
    return rows;
  }

  thermer.ThermerTableRow _buildInfoRow(String text) {
    return thermer.ThermerTableRow([
      if (!is58mm) thermer.ThermerText(""),
      thermer.ThermerText(text, style: _commonStyle(fontSize: 20)),
      thermer.ThermerText(""),
      thermer.ThermerText(""),
      if (!is58mm && business.data?.allowProductDiscount == 1) thermer.ThermerText(""),
      thermer.ThermerText(""),
    ]);
  }

  thermer.ThermerColumn _buildCalculationColumn(lang.S _lang) {
    thermer.ThermerRow calcRow(String label, num value, {bool bold = false, bool isCurrency = true}) {
      return thermer.ThermerRow(
        mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        children: [
          thermer.ThermerText(label, style: _commonStyle(isBold: bold)),
          thermer.ThermerText(
            isCurrency ? '$currency ${formatPointNumber(value)}' : formatPointNumber(value).toString(),
            textAlign: thermer.TextAlign.end,
            style: _commonStyle(isBold: bold),
          ),
        ],
      );
    }

    num subTotal = 0;
    num totalProductExcVat = 0;
    if (saleInvoice.salesDetails != null) {
      for (var e in saleInvoice.salesDetails!) {
        final q = _getProductQty(e.id ?? 0);
        subTotal += ((e.priceWithoutTax ?? e.price ?? 0) * q);
        totalProductExcVat += (((e.price ?? 0) - (e.discount ?? 0)) * q) - ((e.priceWithoutTax ?? 0) * q);
      }
    }

    num returnDiscount = 0;
    if (saleInvoice.salesReturns != null) {
      for (var ret in saleInvoice.salesReturns!) {
        for (var det in ret.salesReturnDetails ?? []) {
          final price = saleInvoice.salesDetails
                  ?.firstWhere((e) => e.id == det.saleDetailId, orElse: () => SalesDetails())
                  .price ??
              0;
          returnDiscount += ((price * (det.returnQty ?? 0)) - (det.returnAmount ?? 0));
        }
      }
    }

    return thermer.ThermerColumn(
      children: [
        calcRow('${_lang.subTotal}: ', subTotal),
        calcRow("${business.data?.vatName ?? _lang.vat}: ", totalProductExcVat + (saleInvoice.vatAmount ?? 0)),
        calcRow('${_lang.discount}: ', (saleInvoice.discountAmount ?? 0) + returnDiscount),
        calcRow('${_lang.shippingCharge}:', saleInvoice.shippingCharge ?? 0),
        if ((saleInvoice.roundingAmount ?? 0) != 0) ...[
          calcRow('${_lang.total}:', saleInvoice.actualTotalAmount ?? 0),
          thermer.ThermerRow(
            mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
            children: [
              thermer.ThermerText('${_lang.rounding}:', style: _commonStyle()),
              thermer.ThermerText(
                "${!(saleInvoice.roundingAmount?.isNegative ?? true) ? '+' : ''}$currency ${formatPointNumber(saleInvoice.roundingAmount ?? 0)}",
                textAlign: thermer.TextAlign.end,
                style: _commonStyle(),
              ),
            ],
          ),
        ],
        thermer.ThermerDivider.horizontal(),
        calcRow('${_lang.totalPayable}: ', saleInvoice.totalAmount ?? 0, bold: true),
        calcRow('${_lang.paidAmount}: ',
            ((saleInvoice.totalAmount ?? 0) - (saleInvoice.dueAmount ?? 0)) + (saleInvoice.changeAmount ?? 0)),
        if ((saleInvoice.dueAmount ?? 0) > 0) calcRow('${_lang.dueAmount}: ', saleInvoice.dueAmount ?? 0),
        if ((saleInvoice.changeAmount ?? 0) > 0) calcRow('${_lang.changeAmount}: ', saleInvoice.changeAmount ?? 0),
      ],
    );
  }

  thermer.ThermerText _buildPaymentInfoText(lang.S _lang) {
    List<String> labels = [];
    if (saleInvoice.transactions != null) {
      for (var item in saleInvoice.transactions!) {
        String label = item.paymentType?.name ?? 'n/a';
        if (item.transactionType == 'cash_payment') label = _lang.cash;
        if (item.transactionType == 'cheque_payment') label = _lang.cheque;
        if (item.transactionType == 'wallet_payment') label = _lang.wallet;
        labels.add(label);
      }
    }
    return thermer.ThermerText(
      "${_lang.paidVia} : ${labels.join(', ')}",
      style: _commonStyle(),
      textAlign: is58mm ? thermer.TextAlign.center : thermer.TextAlign.start,
    );
  }

  List<thermer.ThermerWidget> _buildReturnSection(BuildContext context) {
    final _lang = lang.S.of(context);
    if (saleInvoice.salesReturns?.isEmpty ?? true) return [];

    List<thermer.ThermerWidget> widgets = [];
    List<String> processedDates = [];
    num totalReturnedAmount = 0;

    for (var ret in saleInvoice.salesReturns!) {
      final dateStr = ret.returnDate?.substring(0, 10);
      if (dateStr != null && !processedDates.contains(dateStr)) {
        processedDates.add(dateStr);
        widgets.add(thermer.ThermerDivider.horizontal());
        widgets.add(thermer.ThermerText('${_lang.retur}-$dateStr', style: _commonStyle(isBold: true)));
      }

      widgets.add(
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            thermer.ThermerText(_lang.item, style: _commonStyle(fontSize: 22, isBold: true)),
            thermer.ThermerText(_lang.qty,
                textAlign: thermer.TextAlign.center, style: _commonStyle(fontSize: 22, isBold: true)),
            thermer.ThermerText(_lang.total,
                textAlign: thermer.TextAlign.end, style: _commonStyle(fontSize: 22, isBold: true)),
          ]),
          data: (ret.salesReturnDetails ?? []).expand((d) {
            totalReturnedAmount += d.returnAmount ?? 0;

            List<thermer.ThermerTableRow> rows = [];

            // Main Product Row
            rows.add(
              thermer.ThermerTableRow([
                thermer.ThermerText(
                  _getProductName(d.saleDetailId ?? 0),
                  style: _commonStyle(fontSize: 22),
                ),
                thermer.ThermerText(
                  formatPointNumber(d.returnQty ?? 0),
                  textAlign: thermer.TextAlign.center,
                  style: _commonStyle(fontSize: 22),
                ),
                thermer.ThermerText(
                  '$currency ${formatPointNumber(d.returnAmount ?? 0)}',
                  textAlign: thermer.TextAlign.end,
                  style: _commonStyle(fontSize: 22),
                ),
              ]),
            );

            // Serial Number Row (Below Product name)
            if (d.serialNumbers != null && d.serialNumbers!.isNotEmpty) {
              rows.add(
                thermer.ThermerTableRow([
                  thermer.ThermerText(
                    '${_lang.serial}: ${d.serialNumbers}',
                    style: _commonStyle(fontSize: 20),
                  ),
                  thermer.ThermerText(''),
                  thermer.ThermerText(''),
                ]),
              );
            }

            return rows;
          }).toList(),
          cellWidths: {0: null, 1: 0.2, 2: 0.25},
        ),
      );
    }

    widgets.add(thermer.ThermerDivider.horizontal());
    widgets.add(
      thermer.ThermerRow(
        mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        children: [
          thermer.ThermerText(_lang.returnAmount, style: _commonStyle()),
          thermer.ThermerText('$currency ${formatPointNumber(totalReturnedAmount)}',
              textAlign: thermer.TextAlign.end, style: _commonStyle()),
        ],
      ),
    );
    widgets.add(thermer.ThermerSizedBox(height: 10));

    return widgets;
  }
}
