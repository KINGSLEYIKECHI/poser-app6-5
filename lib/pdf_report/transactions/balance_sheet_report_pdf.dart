import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../model/balance_sheet_model.dart' as model;
import '../../model/business_info_model.dart';

Future<void> generateBalanceSheetReportPdf(
  BuildContext context,
  model.BalanceSheetModel data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final pw.Document pdf = pw.Document();

  // Show loading indicator
  EasyLoading.show(status: 'Generating PDF');

  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;
  final fonts = await loadPdfFonts();
  final isRTL = isCheckRtl(context);

  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

  bool containsBangla(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  // -------- Localized Text Helper ----------
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
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
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

  // -------- Build Localized Table ----------
  pw.Widget buildBalanceSheetTable() {
    final rows = <List<String>>[];

    for (var item in data.data ?? []) {
      rows.add([
        item.name ?? '',
        formatPointNumber(item.amount ?? 0, addComma: true),
      ]);
    }

    // Add total row
    rows.add([
      _lang.total,
      formatPointNumber(data.totalAsset ?? 0, addComma: true),
    ]);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: const PdfColor.fromInt(0xffD9D9D9)),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(5),
          pw.FlexColumnWidth(5),
        ],
        isRTL: isRTL,
      ),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(kPdfColor),
          ),
          children: RtlTableHelper.reverseChildren(
            [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(
                  _lang.assets,
                  bold: true,
                  color: PdfColors.white,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(
                  _lang.amount,
                  bold: true,
                  color: PdfColors.white,
                  alignment: pw.TextAlign.right,
                ),
              ),
            ],
            isRTL: isRTL,
          ),
        ),

        // Data rows
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isOdd ? const PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: localizedText(row[0]),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: localizedText(
                    row[1],
                    alignment: pw.TextAlign.right,
                    bold: row[0] == _lang.total,
                  ),
                ),
              ],
              isRTL: isRTL,
            ),
          );
        }),
      ],
      isRTL: isRTL,
    );
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.symmetric(horizontal: 16),

        // -------- Header ----------
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                localizedText(
                  business?.data?.companyName ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                localizedText(
                  _lang.balanceSheet,
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                localizedText(
                  fromDate != null
                      ? '${_lang.duration}: '
                          '${DateFormat('dd-MM-yyyy').format(fromDate)} '
                          '${_lang.to} '
                          '${DateFormat('dd-MM-yyyy').format(toDate!)}'
                      : '',
                  size: 12,
                ),
              ],
            ),
          );
        },

        // -------- Footer ----------
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              localizedText(
                '${business?.data?.developByLevel ?? ''} '
                '${business?.data?.developBy ?? ''}',
              ),
              localizedText('${_lang.page}-${context.pageNumber}'),
            ],
          );
        },

        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),
            buildBalanceSheetTable(),
          ];
        },
      ),
    );

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-balance-sheet-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Balance Sheet Report',
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('Error during PDF generation: $e');
  }
}
