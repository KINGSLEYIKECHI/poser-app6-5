import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/business_info_model.dart';
import '../../../../thermal priting invoices/model/print_transaction_model.dart';
import '../../thermer/thermer.dart' as thermer;

class WarehouseThermalInvoiceTemplate {
  WarehouseThermalInvoiceTemplate({
    required this.transferInvoice,
    required this.is58mm,
    required this.business,
    required this.context,
    required this.isRTL,
  });

  final PrintWhTransferTransactionModel transferInvoice;
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

  String formatPointNumber(num number, {bool addComma = false}) {
    if (addComma) return NumberFormat("#,###.##", "en_US").format(number);
    return number.toStringAsFixed(2);
  }

  // --- Main Generator ---

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
          business.data!.thermalInvoiceLogo!,
          width: is58mm ? 120 : 200,
          height: is58mm ? 120 : 200,
        );
      } catch (_) {}
    }

    //qr logo
    thermer.ThermerImage? _qrLogo;
    if (business.data?.invoiceScannerLogo != null && business.data?.showInvoiceScannerLogo == 1) {
      try {
        _qrLogo = await thermer.ThermerImage.network(
          business.data!.invoiceScannerLogo!,
          width: is58mm ? 120 : 140,
          height: is58mm ? 120 : 140,
        );
      } catch (_) {}
    }

    // 2. Prepare Product Rows
    final productRows = _buildProductRows();

    // 3. Prepare Return Section

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

        if (business.data?.meta?.showAddress == 1)
          if (business.data?.address != null)
            thermer.ThermerText(
              business.data?.address ?? 'N/A',
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        if (business.data?.meta?.showPhoneNumber == 1)
          if (business.data?.phoneNumber != null)
            thermer.ThermerText(
              '${_lang.mobile} ${business.data?.phoneNumber ?? "N/A"}',
              style: _commonStyle(),
              textAlign: thermer.TextAlign.center,
            ),

        if (business.data?.vatName != null && business.data?.meta?.showVat == 1)
          thermer.ThermerText("${business.data?.vatName}: ${business.data?.vatNo}",
              style: _commonStyle(), textAlign: thermer.TextAlign.center),

        thermer.ThermerSizedBox(height: 16),
        thermer.ThermerText(
          _lang.transferInvoice,
          style: _commonStyle(fontSize: is58mm ? 35 : 48, isBold: true)
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
            thermer.ThermerText(_lang.amount, textAlign: thermer.TextAlign.end, style: _commonStyle(isBold: true)),
          ]),
          data: productRows,
          cellWidths: is58mm
              ? {0: null, 1: 0.2, 2: 0.15, 3: 0.2} // 58mm layout
              : {0: 0.1, 1: null, 2: 0.15, 3: 0.2, 4: 0.2}, // 80mm layout
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        // --- Totals Section ---
        if (!is58mm)
          // 80mm Split Layout
          thermer.ThermerRow(
            children: [
              thermer.ThermerExpanded(flex: 6, child: _buildCalculationColumn(_lang)),
            ],
          )
        else ...[
          // 58mm Stacked Layout
          _buildCalculationColumn(_lang),
        ],

        thermer.ThermerSizedBox(height: 16),
        // --- Footer ---
        if (business.data?.gratitudeMessage != null && business.data?.showGratitudeMsg == 1)
          thermer.ThermerText(business.data?.gratitudeMessage ?? '',
              textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),

        if (business.data?.showNote == 1)
          thermer.ThermerText('${business.data?.invoiceNoteLevel ?? _lang.note}: ${business.data?.invoiceNote}',
              textAlign: thermer.TextAlign.center, style: _commonStyle()),

        thermer.ThermerSizedBox(height: 16),
        if (_qrLogo != null) ...[thermer.ThermerAlign(child: _qrLogo), thermer.ThermerSizedBox(height: 1)],
        // if (business.data?.developByLink != null)
        //   thermer.ThermerAlign(child: thermer.ThermerQRCode(data: business.data?.developByLink ?? '', size: 120)),

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

    if (transferInvoice.transfer?.data?.transferDate != null &&
        transferInvoice.transfer!.data!.transferDate!.isNotEmpty) {
      saleDateTime = DateTime.tryParse(transferInvoice.transfer!.data!.transferDate!);
    }

    final formattedDate = saleDateTime != null
        ? DateFormat('dd MMMM yyyy').format(saleDateTime) // 25 January 2026
        : '';

    final formattedTime = saleDateTime != null
        ? DateFormat('hh:mm a').format(saleDateTime).toLowerCase() // 12:55 pm
        : '';

    final invText = '${_lang.invoice}: ${transferInvoice.transfer?.data?.invoiceNo ?? ''}';
    final statusText = "${_lang.status}: ${transferInvoice.transfer?.data?.status ?? ''}";
    final dateText = '${_lang.date}: $formattedDate';
    final timeText = "${_lang.time}: $formattedTime";
    final fromText = _lang.from;
    final fromWarehouse = "${_lang.WH}: $formattedTime";
    final fromWarehouseAddress = transferInvoice.transfer?.data?.fromWarehouse?.address ?? '';
    final toText = _lang.to;
    final toWarehouse = "${_lang.WH}: $formattedTime";
    final toWarehouseAddress = transferInvoice.transfer?.data?.toWarehouse?.address ?? '';

    if (is58mm) {
      // 58mm: Vertical Stack (One below another)
      return [
        thermer.ThermerText(invText, style: _commonStyle()),
        thermer.ThermerText(statusText, style: _commonStyle()),
        if (transferInvoice.transfer?.data?.transferDate != null) thermer.ThermerText(dateText, style: _commonStyle()),
        thermer.ThermerText(fromText, style: _commonStyle()),
        thermer.ThermerText(fromWarehouse, style: _commonStyle()),
        if (transferInvoice.transfer?.data?.fromWarehouse?.address != null)
          thermer.ThermerText(fromWarehouseAddress, style: _commonStyle()),
        thermer.ThermerText(toText, style: _commonStyle()),
        thermer.ThermerText(toWarehouse, style: _commonStyle()),
        if (transferInvoice.transfer?.data?.toWarehouse?.address != null)
          thermer.ThermerText(toWarehouseAddress, style: _commonStyle()),
      ];
    } else {
      // 80mm: Two columns (Side by side)
      return [
        // Row 1: Invoice | Date
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(invText, style: _commonStyle()),
            if (transferInvoice.transfer?.data?.transferDate != null)
              thermer.ThermerText(dateText, style: _commonStyle()),
          ],
        ),
        // Row 2: Name | Time
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(statusText, style: _commonStyle()),
            thermer.ThermerText(timeText, style: _commonStyle()),
          ],
        ),
        // Row 3: Mobile | Sales By
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(fromText, style: _commonStyle()),
            thermer.ThermerText(toText, style: _commonStyle()),
          ],
        ),
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(fromWarehouse, style: _commonStyle()),
            thermer.ThermerText(toWarehouse, style: _commonStyle()),
          ],
        ),
        if (transferInvoice.transfer?.data?.fromWarehouse?.address != null)
          thermer.ThermerRow(
            mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
            children: [
              thermer.ThermerText(fromWarehouseAddress, style: _commonStyle()),
              thermer.ThermerText(toWarehouseAddress, style: _commonStyle()),
            ],
          ),
      ];
    }
  }

  List<thermer.ThermerTableRow> _buildProductRows() {
    List<thermer.ThermerTableRow> rows = [];
    if (transferInvoice.transfer?.data?.transferProducts == null) return rows;

    for (var index = 0; index < transferInvoice.transfer!.data!.transferProducts!.length; index++) {
      final item = transferInvoice.transfer?.data!.transferProducts![index].product?.productName ?? '';
      final qty = transferInvoice.transfer?.data!.transferProducts![index].quantity ?? 0;
      final price = transferInvoice.transfer?.data!.transferProducts![index].unitPrice ?? 0;
      final amount = (qty * price);

      // Main Row
      rows.add(thermer.ThermerTableRow([
        if (!is58mm) thermer.ThermerText((index + 1).toString(), style: _commonStyle()),
        thermer.ThermerText(item, style: _commonStyle()),
        thermer.ThermerText(formatPointNumber(qty), textAlign: thermer.TextAlign.center, style: _commonStyle()),
        thermer.ThermerText('$price', textAlign: thermer.TextAlign.center, style: _commonStyle()),
        thermer.ThermerText(formatPointNumber(amount), textAlign: thermer.TextAlign.end, style: _commonStyle()),
      ]));
    }
    return rows;
  }

  // thermer.ThermerTableRow _buildInfoRow(String text) {
  //   return thermer.ThermerTableRow([
  //     if (!is58mm) thermer.ThermerText(""),
  //     thermer.ThermerText(text, style: _commonStyle(fontSize: 20)),
  //     thermer.ThermerText(""),
  //     thermer.ThermerText(""),
  //     thermer.ThermerText(""),
  //   ]);
  // }

  thermer.ThermerColumn _buildCalculationColumn(lang.S _lang) {
    thermer.ThermerRow calcRow(String label, num value, {bool bold = false, bool isCurrency = true}) {
      return thermer.ThermerRow(
        mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        children: [
          thermer.ThermerText(label, style: _commonStyle(isBold: bold)),
          thermer.ThermerText(
            isCurrency ? formatPointNumber(value, addComma: true) : value.toString(),
            textAlign: thermer.TextAlign.end,
            style: _commonStyle(isBold: bold),
          ),
        ],
      );
    }

    // num subTotal = 0;
    // num totalDiscount = 0;
    // if (transferInvoice.salesDetails != null) {
    //   for (var e in transferInvoice.salesDetails!) {
    //     final q = _getProductQty(e.id ?? 0);
    //     subTotal += ((e.price ?? 0) * q) - ((e.discount ?? 0) * q);
    //     totalDiscount += (e.discount ?? 0) * q;
    //   }
    // }
    //
    // num returnDiscount = 0;
    // if (transferInvoice.salesReturns != null) {
    //   for (var ret in transferInvoice.salesReturns!) {
    //     for (var det in ret.salesReturnDetails ?? []) {
    //       final price = transferInvoice.salesDetails
    //               ?.firstWhere((e) => e.id == det.saleDetailId, orElse: () => SalesDetails())
    //               .price ??
    //           0;
    //       returnDiscount += ((price * (det.returnQty ?? 0)) - (det.returnAmount ?? 0));
    //     }
    //   }
    // }

    return thermer.ThermerColumn(
      children: [
        calcRow('${_lang.subTotal}: ', transferInvoice.transfer?.data?.subTotal ?? 0),
        calcRow('${_lang.discount}: ', transferInvoice.transfer?.data?.totalDiscount ?? 0),
        calcRow("${_lang.tax}: ", transferInvoice.transfer?.data?.totalTax ?? 0),
        calcRow('${_lang.shippingCharge}:', transferInvoice.transfer?.data?.shippingCharge ?? 0, isCurrency: false),
        calcRow('${_lang.totalPayable}:', transferInvoice.transfer?.data?.grandTotal ?? 0, isCurrency: false),
        thermer.ThermerDivider.horizontal(),
      ],
    );
  }
}
