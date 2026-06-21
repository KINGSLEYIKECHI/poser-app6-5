import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
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
import '../../model/business_info_model.dart';

Future<void> generateProductPurchaseReport(
  BuildContext context,
  List<PurchaseTransaction>? data,
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
      final bool isBanglaData = containsBangla(processedText);
      return getLocalizedPdfText(
        processedText,
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

  double totalAmount = data.fold<double>(0, (sum, item) => sum + (item.totalAmount ?? 0));

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
                  business.data?.companyName ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                localizedText(
                  _lang.productWisePurchase, // Localized "Product Wise Purchase Report"
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                localizedText(
                  fromDate != null
                      ? '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} - ${DateFormat('dd-MM-yyyy').format(toDate!)}'
                      : '',
                  size: 12,
                  alignment: pw.TextAlign.center,
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
              localizedText('${business.data?.developByLevel ?? ''} ${business.data?.developBy ?? ''}'),
              localizedText('${_lang.page}-${context.pageNumber}'),
            ],
          );
        },

        build: (pw.Context context) {
          final List<List<pw.Widget>> tableData = [];

          for (int i = 0; i < data.length; i++) {
            final detail = data[i].details;
            tableData.add([
              localizedText(data[i].invoiceNumber ?? 'N/A', alignment: pw.TextAlign.center),
              localizedText(DateFormat('dd-MM-yyyy').format(DateTime.parse(data[i].purchaseDate.toString())),
                  alignment: pw.TextAlign.center),
              localizedText(data[i].party?.name ?? 'N/A', alignment: pw.TextAlign.center),
              localizedText(detail != null && detail.isNotEmpty ? detail.first.product?.productName ?? 'N/A' : 'N/A',
                  alignment: pw.TextAlign.center),
              localizedText(detail != null && detail.isNotEmpty ? detail.first.quantities.toString() : '0',
                  alignment: pw.TextAlign.center),
              localizedText(formatPointNumber(data[i].totalAmount ?? 0), alignment: pw.TextAlign.center),
            ]);
          }

          final headers = [
            localizedText(_lang.reference, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.date, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.supplier, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.productName, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.purchaseQty, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
            localizedText(_lang.totalAmount, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
          ];

          return [
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: RtlTableHelper.createColumnWidths(
                widths: [
                  pw.FlexColumnWidth(2),
                  pw.FlexColumnWidth(3),
                  pw.FlexColumnWidth(3),
                  pw.FlexColumnWidth(3),
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
                // Totals row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
                  children: RtlTableHelper.reverseChildren(
                    [
                      localizedText(_lang.total, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                      pw.SizedBox(),
                      pw.SizedBox(),
                      pw.SizedBox(),
                      pw.SizedBox(),
                      localizedText(formatPointNumber(totalAmount),
                          bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                    ],
                    isRTL: isRTL,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${appsName}-purchase-report.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess(_lang.generateComplete);

    if (context.mounted) {
      await Printing.layoutPdf(
        name: _lang.productWisePurchase,
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
