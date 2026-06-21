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
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../model/business_info_model.dart';
import '../../model/sale_transaction_model.dart';

Future<void> generateSaleReturnReportPdf(
  BuildContext context,
  List<SalesTransactionModel>? data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final pdf = pw.Document();
  final interFont = await PdfGoogleFonts.notoSansRegular();

  EasyLoading.show(status: 'Generating PDF');

  // Totals
  double total = 0;
  double totalPaid = 0;
  double totalDue = 0;
  double totalReturnedAmount = 0;

  if (data != null) {
    for (var item in data) {
      total += item.totalAmount ?? 0;
      totalPaid += item.paidAmount ?? 0;
      totalDue += item.dueAmount ?? 0;
      for (var salesReturn in item.salesReturns ?? []) {
        for (var detail in salesReturn.salesReturnDetails ?? []) {
          totalReturnedAmount += detail.returnAmount ?? 0;
        }
      }
    }
  }

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

  pw.Widget buildLocalizedTable(List<SalesTransactionModel> data) {
    final headers = [
      _lang.reference,
      _lang.date,
      _lang.customer,
      _lang.status,
      _lang.total,
      _lang.paid,
      _lang.due,
      _lang.returnAmount,
    ];

    final rows = data.map((item) {
      double returnedAmount = 0;
      for (var salesReturn in item.salesReturns ?? []) {
        for (var detail in salesReturn.salesReturnDetails ?? []) {
          returnedAmount += detail.returnAmount ?? 0;
        }
      }

      return [
        item.invoiceNumber ?? 'n/a',
        DateFormat('dd-MM-yyyy').format(DateTime.parse(item.saleDate.toString())),
        item.party?.name ?? 'n/a',
        item.isPaid == true ? _lang.paid : _lang.unPaid,
        formatPointNumber(item.totalAmount ?? 0),
        formatPointNumber(item.paidAmount ?? 0),
        formatPointNumber(item.dueAmount ?? 0),
        formatPointNumber(returnedAmount),
      ];
    }).toList();

    // Add totals row
    rows.add([
      _lang.total,
      '',
      '',
      '',
      formatPointNumber(total),
      formatPointNumber(totalPaid),
      formatPointNumber(totalDue),
      formatPointNumber(totalReturnedAmount),
    ]);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(3),
        ],
        isRTL: isRTL,
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
          children: RtlTableHelper.reverseChildren(
            headers.map((h) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(h, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
              );
            }).toList(),
            isRTL: isRTL,
          ),
        ),
        ...rows.map((row) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rows.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              row.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: localizedText(cell, alignment: pw.TextAlign.center),
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

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        header: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              localizedText(business?.data?.companyName ?? '', size: 20, bold: true),
              localizedText(_lang.salesReturnReport, size: 16, bold: true),
              pw.SizedBox(height: 4),
              localizedText(
                fromDate != null
                    ? '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} ${_lang.to} ${DateFormat('dd-MM-yyyy').format(toDate!)}'
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
          buildLocalizedTable(data!),
        ],
      ),
    );

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${appsName}-sales-return-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Sales Return Report',
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
