import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../Screens/Income/Model/income_modle.dart';
import '../../Screens/PDF/pdf.dart';
import '../../model/business_info_model.dart';
import '../ledger_report/generate_pdf_date_range.dart';

Future<void> generateComboReportPdf(
  BuildContext context,
  List<Product>? data,
  BusinessInformationModel? business,
) async {
  if (data == null || business == null) {
    EasyLoading.showError('Invalid data for report generation');
    return;
  }

  final pw.Document pdf = pw.Document();
  EasyLoading.show(status: 'Generating PDF...');

  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;
  final fonts = await loadPdfFonts();

  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final englishBold = pw.Font.ttf(await rootBundle.load('fonts/NotoSans/NotoSans-Medium.ttf'));
  final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

  bool containsBangla(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

  final bool isRTL = isCheckRtl(context);
  //--------localized Text--------------
  pw.Widget localizedText(
    String text, {
    double size = 10,
    bool bold = false,
    PdfColor color = PdfColors.black,
    pw.TextAlign alignment = pw.TextAlign.start,
  }) {
    // Handle Arabic text with full bidi transformation
    // Use LTR direction since fixArabic() handles RTL text direction
    if (localeCode == 'ar') {
      final processedText = fixArabic(text);
      return pdfText(
        processedText,
        fonts: fonts,
        bold: bold,
        align: alignment,
        size: size,
        color: color,
        langCode: 'ar',
        textDirection: pw.TextDirection.ltr,
      );
    }

    if (localeCode == 'bn') {
      final bool isBanglaData = containsBangla(text);
      return getLocalizedPdfText(
        text,
        textAlignment: alignment,
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
        text,
        fonts: fonts,
        bold: bold,
        align: alignment,
        size: size,
        color: color,
      );
    }
  }

  double totalAmount = 0;
  for (var item in data) {
    totalAmount += item.productSalePrice ?? 0;
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),

        //-------------pdf header-------------
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                localizedText(
                  business.data?.companyName ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                localizedText(
                  _lang.comboProductReport, // Localized "Combo Product Report"
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
              ],
            ),
          );
        },

        //-------------pdf footer-------------
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              localizedText('${business.data?.developByLevel ?? ''} ${business.data?.developBy ?? ''}'),
              localizedText('${_lang.page}-${context.pageNumber}'),
            ],
          );
        },

        build: (pw.Context context) {
          final List<List<pw.Widget>> tableData = [];

          for (int i = 0; i < data.length; i++) {
            tableData.add([
              localizedText('${i + 1}', alignment: pw.TextAlign.center),
              localizedText(data[i].productName ?? '', alignment: pw.TextAlign.center),
              localizedText(data[i].productCode ?? '', alignment: pw.TextAlign.center),
              localizedText(data[i].comboProducts?.length.toString() ?? '', alignment: pw.TextAlign.center),
              localizedText(data[i].unit?.unitName ?? '', alignment: pw.TextAlign.center),
              localizedText(data[i].productSalePrice?.toStringAsFixed(2) ?? '', alignment: pw.TextAlign.center),
            ]);
          }

          // Totals row
          tableData.add([
            localizedText(_lang.total, bold: true, alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText(totalAmount.toStringAsFixed(2), bold: true, alignment: pw.TextAlign.center),
          ]);

          // Table headers
          final headers = [
            localizedText(_lang.sl, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.productName, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.code, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.product, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.unit, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.price, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
          ];

          return [
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: RtlTableHelper.reverseColumnWidths({
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
                4: pw.FlexColumnWidth(2),
                5: pw.FlexColumnWidth(2),
              }, isRTL: isRTL),
              children: [
                // Header row
                RtlTableHelper.createRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
                    children: headers.map((h) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: h)).toList(),
                    isRTL: isRTL),
                // Data rows
                ...tableData.map((row) {
                  return RtlTableHelper.createRow(
                      children:
                          row.map((cell) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: cell)).toList(),
                      isRTL: isRTL);
                }),
              ],
            ),
          ];
        },
      ),
    );

    // Save PDF
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${appsName}-combo-report.pdf');
    await file.writeAsBytes(bytes);

    await EasyLoading.dismiss();
    EasyLoading.showSuccess('Generate Complete');

    // Print PDF
    if (context.mounted) {
      await Printing.layoutPdf(
        name: _lang.comboProductReport,
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  } catch (e) {
    await EasyLoading.dismiss();
    EasyLoading.showError('Error: $e');
    debugPrint('Error during PDF generation: $e');
  }
}
