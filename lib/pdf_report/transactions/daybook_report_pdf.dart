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
import '../../Screens/all_transaction/model/transaction_model.dart' as tmodel;
import '../../model/business_info_model.dart';

Future<void> generateDayBookReportPdf(
  BuildContext context,
  tmodel.TransactionModel data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final pw.Document pdf = pw.Document();

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

  pw.Widget localizedText(
    String text, {
    double size = 10,
    bool bold = false,
    PdfColor color = PdfColors.black,
    pw.TextAlign alignment = pw.TextAlign.center,
  }) {
    final processedText = isRTL ? reshapeArabicOnly(text) : text;
    final adjustedAlignment = RtlTableHelper.adjustAlignment(alignment, isRTL);

    if (localeCode == 'bn') {
      return getLocalizedPdfText(
        text,
        textAlignment: adjustedAlignment,
        pw.TextStyle(
          font: containsBangla(text) ? banglaFont : englishFont,
          fontSize: size,
          color: color,
          fontFallback: [englishFont, banglaFont],
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

  num getMoneyIn(tmodel.TransactionModelData t) => t.type == 'credit' ? (t.amount ?? 0) : 0;

  num getMoneyOut(tmodel.TransactionModelData t) => t.type == 'debit' ? (t.amount ?? 0) : 0;

  pw.Widget buildLocalizedTable() {
    final headers = [
      _lang.reference,
      _lang.customer,
      _lang.date,
      _lang.type,
      _lang.total,
      _lang.moneyIn,
      _lang.moneyOut,
    ];

    final rows = <List<String>>[];

    for (final t in data.data ?? []) {
      rows.add([
        t.referenceId?.toString() ?? '',
        t.party?.name ?? '',
        t.date ?? '',
        t.type ?? '',
        formatPointNumber(t.totalAmount ?? 0),
        formatPointNumber(getMoneyIn(t)),
        formatPointNumber(getMoneyOut(t)),
      ]);
    }

    rows.add([
      _lang.total,
      '',
      '',
      '',
      formatPointNumber(data.totalAmount ?? 0),
      formatPointNumber(data.moneyIn ?? 0),
      formatPointNumber(data.moneyOut ?? 0),
    ]);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(5),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(4),
        ],
        isRTL: isRTL,
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(kPdfColor),
          ),
          children: RtlTableHelper.reverseChildren(
            headers
                .map(
                  (h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: localizedText(
                      h,
                      bold: true,
                      color: PdfColors.white,
                    ),
                  ),
                )
                .toList(),
            isRTL: isRTL,
          ),
        ),
        ...rows.map(
          (row) => pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rows.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              row
                  .map(
                    (cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: localizedText(cell),
                    ),
                  )
                  .toList(),
              isRTL: isRTL,
            ),
          ),
        ),
      ],
      isRTL: isRTL,
    );
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.symmetric(horizontal: 16),
        header: (context) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                business?.data?.companyName ?? '',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              localizedText(
                _lang.dayBookReport,
                size: 14,
                bold: true,
              ),
              if (fromDate != null)
                localizedText(
                  '${_lang.duration}: '
                  '${DateFormat('dd-MM-yyyy').format(fromDate)}'
                  ' - '
                  '${DateFormat('dd-MM-yyyy').format(toDate!)}',
                ),
            ],
          ),
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText(
              '${business?.data?.developByLevel ?? ''} '
              '${business?.data?.developBy ?? ''}',
              alignment: pw.TextAlign.start,
            ),
            localizedText(
              '${_lang.page}-${context.pageNumber}',
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 16),
          buildLocalizedTable(),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-day-book-report.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Day Book Report',
        onLayout: (_) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
  }
}
