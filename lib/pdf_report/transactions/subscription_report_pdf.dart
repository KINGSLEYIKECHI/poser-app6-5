import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../model/subscription_report_model.dart' as model;
import '../../model/business_info_model.dart';

Future<void> generateSubscriptionReportPdf(
  BuildContext context,
  List<model.SubscriptionReportModel> data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final pdf = pw.Document();

  // Show loading
  EasyLoading.show(status: 'Generating PDF');

  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;
  final fonts = await loadPdfFonts();
  final isRTL = isCheckRtl(context);

  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final englishBold = pw.Font.ttf(await rootBundle.load('fonts/NotoSans/NotoSans-Medium.ttf'));
  final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

  bool containsBangla(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  //--------localized Text--------------
  pw.Widget localizedText(
    String text, {
    double size = 10,
    bool bold = false,
    PdfColor color = PdfColors.black,
    pw.TextAlign alignment = pw.TextAlign.start,
  }) {
    final processedText = isRTL ? reshapeArabicOnly(text) : text;
    final adjustedAlignment = RtlTableHelper.adjustAlignment(alignment, isRTL);

    if (localeCode == 'bn') {
      final bool isBanglaData = containsBangla(text);
      return getLocalizedPdfText(
        text,
        textAlignment: adjustedAlignment,
        pw.TextStyle(
          font: isBanglaData ? banglaFont : englishFont,
          fontSize: size,
          color: color,
          fontFallback: [
            englishFont,
            banglaFont,
          ],
        ),
      );
    } else {
      return pdfText(
        processedText,
        fonts: fonts,
        bold: bold,
        align: adjustedAlignment,
        size: size,
        color: color,
      );
    }
  }

  // Prepare table headers
  final headers = [
    _lang.sl, // SL
    _lang.date, // Date
    _lang.package, // Package
    _lang.started, // Started
    _lang.end, // End
    _lang.paymentBy, // Payment By
    _lang.status, // Status
  ];

  // Prepare table data
  final tableData = data.asMap().entries.map((entry) {
    final index = entry.key;
    final subscription = entry.value;
    return [
      "${index + 1}",
      subscription.startDate == null ? "N/A" : DateFormat('dd MMM yyyy').format(subscription.startDate!),
      subscription.name ?? "N/A",
      subscription.startDate == null ? "N/A" : DateFormat('dd MMM yyyy').format(subscription.startDate!),
      subscription.endDate == null ? "N/A" : DateFormat('dd MMM yyyy').format(subscription.endDate!),
      subscription.paymentBy ?? "N/A",
      subscription.isPaid ? _lang.paid : _lang.unPaid,
    ];
  }).toList();

  // Build table widget
  pw.Widget buildLocalizedTable(List<List<String>> data) {
    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(2),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
        ],
        isRTL: isRTL,
      ),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
          children: RtlTableHelper.reverseChildren(
            headers.map((h) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(
                  h,
                  bold: true,
                  color: PdfColors.white,
                  alignment: pw.TextAlign.center,
                ),
              );
            }).toList(),
            isRTL: isRTL,
          ),
        ),
        // Data rows
        ...data.map((row) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: data.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              row.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: localizedText(
                    cell,
                    alignment: pw.TextAlign.center,
                  ),
                );
              }).toList(),
              isRTL: isRTL,
            ),
          );
        }).toList(),
      ],
      isRTL: isRTL,
    );
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        header: (context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              localizedText(business?.data?.companyName ?? '', size: 20, bold: true),
              localizedText(_lang.subscriptionReports, size: 16, bold: true),
              localizedText(
                fromDate != null
                    ? '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} ${_lang.to} ${DateFormat('dd-MM-yyyy').format(toDate!)}'
                    : '',
                size: 12,
              ),
            ],
          ),
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText('${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}'),
            localizedText('${_lang.page}-${context.pageNumber}'),
          ],
        ),
        build: (context) => [pw.SizedBox(height: 16), buildLocalizedTable(tableData)],
      ),
    );

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-subscription-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    EasyLoading.showSuccess('PDF Generated');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Subscription Report',
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
    print('Error during PDF generation: $e');
  }
}
