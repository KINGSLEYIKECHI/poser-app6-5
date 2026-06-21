import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/thermal%20priting%20invoices/model/print_transaction_model.dart';
import '../../thermer/thermer.dart' as thermer;

class DueThermalInvoiceTemplate {
  DueThermalInvoiceTemplate({
    required this.printDueTransactionModel,
    required this.is58mm,
    required this.context,
    required this.isRTL,
  });

  final PrintDueTransactionModel printDueTransactionModel;
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

  // --- Main Generator ---

  Future<List<int>> get template async {
    final _lang = lang.S.of(context);
    String _printProfiles = printDueTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    final _profile = await CapabilityProfile.load(name: _printProfiles);
    final _generator = Generator(is58mm ? PaperSize.mm58 : PaperSize.mm80, _profile);

    final _imageBytes = await _generateLayout(_lang);
    final _image = img.decodeImage(_imageBytes);

    if (_image == null) throw Exception('Failed to generate receipt.');

    List<int> _bytes = [];
    _bytes += _generator.image(_image);
    _bytes += _generator.cut();
    return _bytes;
  }

  Future<Uint8List> _generateLayout(lang.S _lang) async {
    final data = printDueTransactionModel.dueTransactionModel;
    final info = printDueTransactionModel.personalInformationModel.data;

    // 1. Prepare Logo
    thermer.ThermerImage? _logo;
    if (info?.thermalInvoiceLogo != null && info?.showThermalInvoiceLogo == 1) {
      try {
        _logo = await thermer.ThermerImage.network(
          "${info?.thermalInvoiceLogo}",
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
          info!.invoiceScannerLogo!,
          width: is58mm ? 120 : 140,
          height: is58mm ? 120 : 140,
        );
      } catch (_) {}
    }

    // 2. Prepare Payment Labels
    final paymentLabels = _buildPaymentLabels();

    // 3. Build Layout
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
          thermer.ThermerText('Branch: ${data?.branch?.name}',
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
          _lang.receipt, // Due collection is usually a Receipt
          style: _commonStyle(fontSize: is58mm ? 30 : 48, isBold: true)
              .copyWith(decoration: thermer.TextDecoration.underline),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // --- Info Section ---
        ..._buildInfoSection(_lang),

        thermer.ThermerSizedBox(height: 16),

        // --- Data Table (Single Row for Due Context) ---
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            if (!is58mm) thermer.ThermerText(_lang.sl, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.invoice, style: _commonStyle(isBold: true)),
            thermer.ThermerText(_lang.dueAmount, textAlign: thermer.TextAlign.end, style: _commonStyle(isBold: true)),
          ]),
          data: [
            thermer.ThermerTableRow([
              if (!is58mm) thermer.ThermerText('1', style: _commonStyle()),
              thermer.ThermerText(data?.invoiceNumber ?? '', style: _commonStyle()),
              thermer.ThermerText(formatPointNumber(data?.totalDue ?? 0, addComma: true),
                  textAlign: thermer.TextAlign.end, style: _commonStyle()),
            ])
          ],
          cellWidths: is58mm ? {0: null, 1: 0.3} : {0: 0.1, 1: null, 2: 0.3},
        ),
        thermer.ThermerDivider.horizontal(),

        // --- Calculations ---
        _buildCalculationColumn(_lang),

        thermer.ThermerDivider.horizontal(),
        thermer.ThermerSizedBox(height: 8),

        // --- Payment Info ---
        thermer.ThermerText(
          "${_lang.paidVia} : ${paymentLabels.join(', ')}",
          style: _commonStyle(),
          textAlign: thermer.TextAlign.left,
        ),

        thermer.ThermerSizedBox(height: 16),

        // --- Footer ---
        if (info?.gratitudeMessage != null && info?.showGratitudeMsg == 1)
          thermer.ThermerText(info?.gratitudeMessage ?? '',
              textAlign: thermer.TextAlign.center, style: _commonStyle(isBold: true)),

        if (data?.paymentDate != null)
          thermer.ThermerText(
            DateFormat('M/d/yyyy h:mm a').format(DateTime.parse(data!.paymentDate!)),
            textAlign: thermer.TextAlign.center,
            style: _commonStyle(),
          ),

        if (info?.showNote == 1)
          thermer.ThermerText(
            '${info?.invoiceNoteLevel ?? _lang.note}: ${info?.invoiceNote ?? ''}',
            textAlign: thermer.TextAlign.left,
            style: _commonStyle(),
          ),

        thermer.ThermerSizedBox(height: 16),
        if (_qrLogo != null) ...[thermer.ThermerAlign(child: _qrLogo), thermer.ThermerSizedBox(height: 1)],

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
    final data = printDueTransactionModel.dueTransactionModel;
    final dateStr = data?.paymentDate != null ? DateFormat.yMd().format(DateTime.parse(data!.paymentDate!)) : '';
    final timeStr = data?.paymentDate != null ? DateFormat.jm().format(DateTime.parse(data!.paymentDate!)) : '';

    final receiptText = '${_lang.receipt}: ${data?.invoiceNumber ?? 'Not Provided'}';
    final dateText = '${_lang.date}: $dateStr';
    final timeText = '${_lang.time}: $timeStr';
    final nameText = '${_lang.receivedFrom}: ${data?.party?.name ?? data?.sale?.invoiceNumber ?? ''}';
    final mobileText = '${_lang.mobile} ${data?.party?.phone ?? ''}';
    final receivedByText =
        '${_lang.receivedBy}: ${data?.user?.role == "shop-owner" ? 'Admin' : data?.user?.name ?? ''}';

    if (is58mm) {
      // 58mm: Stacked
      return [
        thermer.ThermerText(receiptText, style: _commonStyle()),
        if (data?.paymentDate != null) thermer.ThermerText("$dateText $timeStr", style: _commonStyle()),
        thermer.ThermerText(nameText, style: _commonStyle()),
        thermer.ThermerText(mobileText, style: _commonStyle()),
        thermer.ThermerText(receivedByText, style: _commonStyle()),
      ];
    } else {
      // 80mm: Two Columns
      return [
        thermer.ThermerRow(
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
          children: [
            thermer.ThermerText(receiptText, style: _commonStyle()),
            if (data?.paymentDate != null) thermer.ThermerText(dateText, style: _commonStyle()),
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
            thermer.ThermerText(receivedByText, style: _commonStyle()),
          ],
        ),
      ];
    }
  }

  thermer.ThermerColumn _buildCalculationColumn(lang.S _lang) {
    final data = printDueTransactionModel.dueTransactionModel;

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

    return thermer.ThermerColumn(children: [
      calcRow('${_lang.totalDue}:', data?.totalDue ?? 0),
      calcRow('${_lang.paymentsAmount}:', data?.payDueAmount ?? 0, bold: true),
      calcRow('${_lang.remainingDue}:', data?.dueAmountAfterPay ?? 0, bold: true),
    ]);
  }

  List<String> _buildPaymentLabels() {
    final transactions = printDueTransactionModel.dueTransactionModel?.transactions ?? [];
    List<String> labels = [];

    for (var item in transactions) {
      String label = item.paymentType?.name ?? 'n/a';
      if (item.transactionType == 'cash_payment') label = lang.S.of(context).cash;
      if (item.transactionType == 'cheque_payment') label = lang.S.of(context).cheque;
      if (item.transactionType == 'wallet_payment') label = lang.S.of(context).wallet;
      labels.add(label);
    }
    return labels;
  }
}
