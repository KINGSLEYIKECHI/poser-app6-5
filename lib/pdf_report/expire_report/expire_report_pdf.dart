import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';

Future<void> generateExpireReportPdf(
  BuildContext context,
  List<Product>? data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  if (data == null || business == null) {
    EasyLoading.showError('Invalid data for report generation');
    return;
  }

  final pw.Document pdf = pw.Document();
  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;
  final fonts = await loadPdfFonts();

  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
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

  double totalPurchase = 0;
  double totalSalePrice = 0;

  for (var item in data) {
    totalPurchase += item.stocks?.first.productPurchasePrice ?? 0;
    totalSalePrice += item.stocks?.first.productSalePrice ?? 0;
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
                  _lang.expiredList, // Localized "Expired List"
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                if (fromDate != null && toDate != null)
                  localizedText(
                    '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} - ${DateFormat('dd-MM-yyyy').format(toDate)}',
                    size: 12,
                    alignment: pw.TextAlign.center,
                  ),
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
              localizedText(data[i].stocks?.first.productStock.toString() ?? '0', alignment: pw.TextAlign.center),
              localizedText(data[i].stocks?.first.expireDate ?? 'N/A', alignment: pw.TextAlign.center),
              localizedText(data[i].stocks?.first.productPurchasePrice?.toStringAsFixed(2) ?? '0',
                  alignment: pw.TextAlign.center),
              localizedText(data[i].stocks?.first.productSalePrice?.toStringAsFixed(2) ?? '0',
                  alignment: pw.TextAlign.center),
            ]);
          }

          // Table headers
          final headers = [
            localizedText(_lang.sl, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.product, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.code, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.stock, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.expiredIn, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.purchase, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.sale, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
          ];

          // Add totals row
          tableData.add([
            localizedText(_lang.total, bold: true, alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText('', alignment: pw.TextAlign.center),
            localizedText(totalPurchase.toStringAsFixed(2), bold: true, alignment: pw.TextAlign.center),
            localizedText(totalSalePrice.toStringAsFixed(2), bold: true, alignment: pw.TextAlign.center),
          ]);

          return [
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: RtlTableHelper.reverseColumnWidths(const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(4),
                2: pw.FlexColumnWidth(3),
                3: pw.FlexColumnWidth(3),
                4: pw.FlexColumnWidth(3),
                5: pw.FlexColumnWidth(3),
                6: pw.FlexColumnWidth(3),
              }, isRTL: isRTL),
              children: [
                RtlTableHelper.createRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
                  children: headers.map((h) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: h)).toList(),
                  isRTL: isRTL,
                ),
                ...tableData.map((row) {
                  return RtlTableHelper.createRow(
                      decoration: pw.BoxDecoration(
                        color: tableData.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
                      ),
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

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-expire-list-report.pdf');
    await file.writeAsBytes(bytes);
    EasyLoading.showSuccess(_lang.generateComplete);

    if (context.mounted) {
      await Printing.layoutPdf(
        name: _lang.expiredList,
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
