import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/Screens/Expense/Model/expense_modle.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../Screens/PDF/pdf.dart';
import '../../model/business_info_model.dart';
import '../ledger_report/generate_pdf_date_range.dart';

Future<void> generateExpenseReportPdf(
  BuildContext context,
  List<Expense>? data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
  String selectedTime,
) async {
  final pdf = pw.Document();
  final interFont = await PdfGoogleFonts.notoSansRegular();

  EasyLoading.show(status: 'Generating PDF');
  double totalAmount = 0;

  if (data != null) {
    for (var item in data) {
      totalAmount += item.amount ?? 0;
    }
  }

  // PDF date range calculation
  final pdfDateRange = getPdfDateRangeForSelectedTime(
    selectedTime,
    fromDate: fromDate,
    toDate: toDate,
  );
  final fromDateStr = pdfDateRange['from']!;
  final toDateStr = pdfDateRange['to']!;

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

  pw.Widget buildLocalizedTable(List<Expense> data) {
    // Localized headers
    final headers = [
      _lang.sl,
      _lang.date,
      _lang.expenseFor,
      _lang.category,
      _lang.amount,
    ];

    // Table rows
    final rows = data.map((item) {
      return [
        '${data.indexOf(item) + 1}',
        DateFormat('dd-MM-yyyy').format(DateTime.parse(item.expenseDate.toString())),
        item.expanseFor ?? 'n/a',
        item.category?.categoryName ?? 'n/a',
        formatPointNumber(item.amount ?? 0),
      ];
    }).toList();

    // Add totals row
    rows.add([
      _lang.total,
      '',
      '',
      '',
      formatPointNumber(totalAmount),
    ]);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: RtlTableHelper.reverseColumnWidths(const {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(4),
        3: pw.FlexColumnWidth(4),
        4: pw.FlexColumnWidth(2),
      }, isRTL: isRTL),
      children: [
        // Header row
        RtlTableHelper.createRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
            children: headers
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
            isRTL: isRTL),
        // Data rows
        ...rows.map((row) {
          final isTotalRow = row[0] == _lang.total;
          return RtlTableHelper.createRow(
              decoration: pw.BoxDecoration(
                color: rows.indexOf(row).isOdd && !isTotalRow ? PdfColor.fromInt(kPdfRowColor) : PdfColors.white,
              ),
              children: row.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: localizedText(
                    cell,
                    alignment: pw.TextAlign.center,
                    bold: isTotalRow,
                  ),
                );
              }).toList(),
              isRTL: isRTL);
        }),
      ],
    );
  }

  try {
    pdf.addPage(pw.MultiPage(
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
              _lang.expenseReport,
              size: 16,
              bold: true,
            ),
            pw.SizedBox(height: 4),
            localizedText(
              '$fromDateStr ${_lang.to} $toDateStr',
              size: 12,
            ),
          ],
        ),
      ),
      footer: (pw.Context context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          localizedText(
            '${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}',
          ),
          localizedText('${_lang.page}-${context.pageNumber}'),
        ],
      ),
      build: (pw.Context context) => [
        pw.SizedBox(height: 16),
        buildLocalizedTable(data!),
      ],
    ));

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-expense-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Expense Report',
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
