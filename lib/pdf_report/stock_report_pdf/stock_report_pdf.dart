import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';

import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../Screens/PDF/pdf.dart';
import '../../Screens/Products/Model/product_total_stock_model.dart';
import '../../model/business_info_model.dart';

Future<void> generateStockReportPdf(
  BuildContext context,
  List<Product>? data,
  BusinessInformationModel? business,
  ProductListResponse? stockValue,
  bool? isLowStock,
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

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                localizedText(
                  business.data?.companyName.toString() ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                localizedText(
                  _lang.stockReport, // Localized "Stock Report"
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
              ],
            ),
          );
        },
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
            final stockPrice = (data[i].stocks != null && data[i].stocks!.isNotEmpty)
                ? (data[i].stocks!.last.productPurchasePrice?.toString() ?? '0')
                : '0';
            tableData.add([
              localizedText('${i + 1}', alignment: pw.TextAlign.center),
              localizedText(data[i].productName ?? 'n/a', alignment: pw.TextAlign.center),
              localizedText(data[i].stocksSumProductStock?.toString() ?? '0', alignment: pw.TextAlign.center),
              localizedText(stockPrice, alignment: pw.TextAlign.center),
            ]);
          }

          // Calculate total stock value
          double totalStockValue = isLowStock == true ? 0 : stockValue?.totalStockValue ?? 0;

          // Add totals row
          tableData.add([
            localizedText(_lang.total, bold: true, alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText(totalStockValue.toStringAsFixed(2), bold: true, alignment: pw.TextAlign.center),
          ]);

          // Table headers
          final headers = [
            localizedText(_lang.sl, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.productName, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.quantity, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.cost, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
          ];

          return [
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              columnWidths: RtlTableHelper.createColumnWidths(
                widths: const [
                  pw.FlexColumnWidth(1),
                  pw.FlexColumnWidth(3),
                  pw.FlexColumnWidth(4),
                  pw.FlexColumnWidth(4),
                ],
                isRTL: isRTL,
              ),
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
                  children: RtlTableHelper.reverseChildren(
                    headers.map((h) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: h)).toList(),
                    isRTL: isRTL,
                  ),
                ),
                // Data rows
                ...tableData.map((row) {
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: tableData.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
                    ),
                    children: RtlTableHelper.reverseChildren(
                      row.map((cell) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: cell)).toList(),
                      isRTL: isRTL,
                    ),
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    // Save the PDF
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/$appsName-stock-report-$timestamp.pdf');
    await file.writeAsBytes(bytes);

    await EasyLoading.dismiss();

    // Print PDF
    if (context.mounted) {
      await Printing.layoutPdf(
        name: _lang.stockReport,
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  } catch (e) {
    await EasyLoading.dismiss();
    if (context.mounted) {
      EasyLoading.showError('Failed to generate PDF: ${e.toString()}');
    }
    debugPrint('Error during PDF generation: $e');
  }
}
