import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/due_collection_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../model/business_info_model.dart';
import 'due_status.dart';

Future<void> generateDueReportPdf(
  BuildContext context,
  List<DueCollection>? data,
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

  if (data != null) {
    for (var item in data) {
      total += item.totalDue ?? 0;
      totalPaid += item.payDueAmount ?? 0;
      totalDue += item.dueAmountAfterPay ?? 0;
    }
  }

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

  pw.Widget buildLocalizedTable(List<DueCollection> data) {
    final headers = [
      _lang.reference,
      _lang.date,
      _lang.name,
      _lang.status,
      _lang.total,
      _lang.paid,
      _lang.due,
    ];

    final rows = data.map((item) {
      final status = getDueStatus(item); // your existing function to get status
      return [
        item.invoiceNumber ?? 'n/a',
        DateFormat('dd-MM-yyyy').format(DateTime.parse(item.paymentDate.toString())),
        item.party?.name ?? item.sale?.invoiceNumber ?? 'n/a',
        status,
        formatPointNumber(item.totalDue ?? 0),
        formatPointNumber(item.payDueAmount ?? 0),
        formatPointNumber(item.dueAmountAfterPay ?? 0),
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
    ]);

    // Reverse table for Bangla (RTL)
    final displayedHeaders = localeCode == 'bn' ? headers.reversed.toList() : headers;
    final displayedRows = localeCode == 'bn' ? rows.map((r) => r.reversed.toList()).toList() : rows;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: RtlTableHelper.reverseColumnWidths(
        {
          0: pw.FlexColumnWidth(4),
          1: pw.FlexColumnWidth(5),
          2: pw.FlexColumnWidth(4),
          3: pw.FlexColumnWidth(3),
          4: pw.FlexColumnWidth(4),
          5: pw.FlexColumnWidth(4),
          6: pw.FlexColumnWidth(4),
        },
        isRTL: isRTL,
      ),
      children: [
        RtlTableHelper.createRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
            children: displayedHeaders.map((h) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(h, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
              );
            }).toList(),
            isRTL: isRTL),
        ...displayedRows.map((row) {
          return RtlTableHelper.createRow(
              decoration: pw.BoxDecoration(
                color: rows.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
              ),
              children: row.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: localizedText(cell, alignment: pw.TextAlign.center),
                );
              }).toList(),
              isRTL: isRTL);
        }),
      ],
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
              localizedText(_lang.dueReport, size: 16, bold: true),
              pw.SizedBox(height: 4),
              localizedText(
                fromDate != null
                    ? '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} to ${DateFormat('dd-MM-yyyy').format(toDate!)}'
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
    final file = File('${dir.path}/${appsName}-due-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Due Report',
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
