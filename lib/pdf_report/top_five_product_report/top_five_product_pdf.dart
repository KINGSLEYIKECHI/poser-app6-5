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
import '../../model/business_info_model.dart';

Future<void> generateTopFiveReportPdf(
  BuildContext context,
  List<Product>? data,
  BusinessInformationModel? business,
) async {
  if (data == null || business == null) {
    EasyLoading.showError('Invalid data for report generation');
    return;
  }

  final pw.Document pdf = pw.Document();
  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;
  final fonts = await loadPdfFonts();
  final isRTL = isCheckRtl(context);

  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

  bool containsBangla(String text) {
    return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
  }

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
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
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

  double totalAmount = 0;
  for (var item in data) {
    totalAmount += item.totalSaleAmount ?? 0;
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
                  _lang.top5Product, // Localized "Top 5 Product Report"
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
            tableData.add([
              localizedText('${i + 1}', alignment: pw.TextAlign.center),
              localizedText(data[i].productName ?? 'N/A', alignment: pw.TextAlign.center),
              localizedText(data[i].productCode ?? 'N/A', alignment: pw.TextAlign.center),
              localizedText(data[i].saleCount?.toString() ?? '0', alignment: pw.TextAlign.center),
              localizedText(data[i].totalSaleAmount?.toStringAsFixed(2) ?? '0', alignment: pw.TextAlign.center),
            ]);
          }

          // Table headers
          final headers = [
            localizedText(_lang.sl, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.productName, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.productCode, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.totalSales, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.totalAmount, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
          ];

          // Add totals row
          tableData.add([
            localizedText(_lang.total, bold: true, alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText(totalAmount.toStringAsFixed(2), bold: true, alignment: pw.TextAlign.center),
          ]);

          return [
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              columnWidths: RtlTableHelper.createColumnWidths(
                widths: const [
                  pw.FlexColumnWidth(1),
                  pw.FlexColumnWidth(3),
                  pw.FlexColumnWidth(2),
                  pw.FlexColumnWidth(2),
                  pw.FlexColumnWidth(2),
                ],
                isRTL: isRTL,
              ),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
                  children: RtlTableHelper.reverseChildren(
                    headers.map((h) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: h)).toList(),
                    isRTL: isRTL,
                  ),
                ),
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

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${appsName}-top-5-product.pdf');
    await file.writeAsBytes(bytes);
    EasyLoading.showSuccess(_lang.generateComplete);

    if (context.mounted) {
      await Printing.layoutPdf(
        name: _lang.top5Product,
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('${_lang.error}: $e');
    debugPrint('Error during PDF generation: $e');
  }
}
