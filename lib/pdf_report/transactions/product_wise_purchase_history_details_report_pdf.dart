import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart' as intl;
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
import '../../model/product_history_model.dart' as phlm;

Future<void> generateProductWisePurchaseHistoryDetailsReportPdf(
  BuildContext context,
  phlm.ProductHistoryDetailsModel data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final pdf = pw.Document();

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

  pw.Widget buildLocalizedTable(phlm.ProductHistoryDetailsModel data) {
    final headers = [
      _lang.sl,
      _lang.invoice,
      _lang.date,
      _lang.type,
      _lang.qty,
      _lang.costPrice,
    ];

    final rows = data.items?.map((item) {
          final index = data.items!.indexOf(item) + 1;
          return [
            '$index',
            item.invoiceNo ?? 'N/A',
            item.transactionDate != null ? intl.DateFormat('dd-MM-yyyy').format(item.transactionDate!) : '',
            item.type ?? 'N/A',
            formatPointNumber(item.quantities ?? 0),
            formatPointNumber(item.purchasePrice ?? 0, addComma: true),
          ];
        }).toList() ??
        [];

    // Totals row
    rows.add([
      '',
      _lang.total,
      '',
      '',
      formatPointNumber(data.totalQuantities ?? 0),
      formatPointNumber(data.totalPurchasePrice ?? 0, addComma: true),
    ]);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(1.5),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(4),
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
            headers
                .map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        h,
                        bold: true,
                        color: PdfColors.white,
                        alignment: pw.TextAlign.center,
                      ),
                    ))
                .toList(),
            isRTL: isRTL,
          ),
        ),
        // Data rows
        ...rows.map((row) {
          final isTotalRow = row[1] == 'Total';
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rows.indexOf(row).isOdd && !isTotalRow ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              row
                  .map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: localizedText(
                          cell,
                          alignment: pw.TextAlign.center,
                          bold: isTotalRow,
                        ),
                      ))
                  .toList(),
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
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        header: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              localizedText(
                business?.data?.companyName ?? '',
                size: 20,
                bold: true,
              ),
              localizedText(
                data.productName ?? 'N/A',
                size: 16,
                bold: true,
              ),
              pw.SizedBox(height: 4),
              localizedText(
                fromDate != null
                    ? '${_lang.duration}: ${intl.DateFormat('dd-MM-yyyy').format(fromDate)} ${_lang.to} ${intl.DateFormat('dd-MM-yyyy').format(toDate!)}'
                    : '',
                size: 12,
              ),
            ],
          ),
        ),
        footer: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText('${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}'),
            localizedText('${_lang.page}-${context.pageNumber}'),
          ],
        ),
        build: (pw.Context context) => [
          pw.SizedBox(height: 16),
          buildLocalizedTable(data),
        ],
      ),
    );

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-product-purchase-history-details.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Product Purchase History Details',
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
