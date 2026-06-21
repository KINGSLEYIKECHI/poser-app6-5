import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/Screens/Report/Screens/cashflow_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../model/business_info_model.dart';
import '../../model/cashflow_model.dart' as cf;

Future<void> generateCashflowReportPdf(
  BuildContext context,
  cf.CashflowModel data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final pw.Document pdf = pw.Document();

  // Show loading indicator
  EasyLoading.show(status: 'Generating PDF');

  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;

  // Load fonts
  final fonts = await loadPdfFonts();
  final isRTL = isCheckRtl(context);
  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final englishBold = pw.Font.ttf(await rootBundle.load('fonts/NotoSans/NotoSans-Medium.ttf'));
  final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

  // Detect Bangla
  bool containsBangla(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  // Localized text helper
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
          fontFallback: [englishFont, banglaFont],
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

  num initialRunningCash = data.initialRunningCash ?? 0;

  // Build localized table
  pw.Widget buildLocalizedCashflowTable() {
    // Table headers localized
    final headers = [
      _lang.sl,
      _lang.date,
      _lang.invoice,
      _lang.customer,
      _lang.type,
      _lang.cashIn,
      _lang.cashOut,
      _lang.runningCash,
      _lang.payment,
    ];

    // Table rows
    final rows = <List<String>>[];

    for (int i = 0; i < (data.data?.length ?? 0); i++) {
      final _transaction = [...?data.data][i];
      final _runningCash = _transaction.type == 'credit'
          ? initialRunningCash + (_transaction.amount ?? 0)
          : initialRunningCash - (_transaction.amount ?? 0);

      rows.add([
        "${i + 1}",
        _transaction.date == null ? "N/A" : DateFormat("dd MMM, yyyy").format(_transaction.date!),
        _transaction.invoiceNo ?? "N/A",
        _transaction.partyName ?? "N/A",
        _transaction.type?.toTitleCase() ?? "N/A",
        _transaction.type == "credit" ? formatPointNumber(_transaction.amount ?? 0) : "0",
        _transaction.type == "debit" ? formatPointNumber(_transaction.amount ?? 0) : "0",
        formatPointNumber(initialRunningCash = _runningCash),
        _transaction.paymentType ?? _transaction.transactionType?.split('_')[0].toTitleCase() ?? "N/A",
      ]);
    }

    // Add totals row
    rows.add([
      _lang.total,
      '',
      '',
      '',
      '',
      formatPointNumber(data.cashIn ?? 0),
      formatPointNumber(data.cashOut ?? 0),
      formatPointNumber(initialRunningCash),
      '',
    ]);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(2),
          pw.FlexColumnWidth(5),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(4),
        ],
        isRTL: isRTL,
      ),
      children: [
        // Header row
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
        ...rows.map((row) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rows.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
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
        }),
      ],
      isRTL: isRTL,
    );
  }

  // Generate PDF
  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),

        //----------------pdf header--------------
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                localizedText(
                  business?.data?.companyName.toString() ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                localizedText(
                  _lang.cashFlow,
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                if (fromDate != null && toDate != null)
                  localizedText(
                    '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} ${_lang.to} ${DateFormat('dd-MM-yyyy').format(toDate)}',
                    size: 12,
                  ),
              ],
            ),
          );
        },

        //-----------------pdf footer-------------
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              localizedText('${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}'),
              localizedText('${_lang.page}-${context.pageNumber}'),
            ],
          );
        },

        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),
            buildLocalizedCashflowTable(),
          ];
        },
      ),
    );

    // Save PDF
    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-cashflow-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Cash Flow Report',
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
