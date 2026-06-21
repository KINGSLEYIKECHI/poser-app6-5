import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mobile_pos/Screens/all_transaction/all_transaction.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../Screens/all_transaction/model/transaction_model.dart' as tmodel;
import '../../model/business_info_model.dart';

Future<void> generateAllTransactionReportPdf(
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

  bool containsBangla(String text) => RegExp(r'[\u0980-\u09FF]').hasMatch(text);

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

  pw.Widget buildLocalizedTable() {
    final headers = [
      _lang.sl,
      _lang.date,
      _lang.reference,
      _lang.type,
      _lang.amount,
    ];

    final rows = <List<String>>[];

    for (int i = 0; i < (data.data?.length ?? 0); i++) {
      final t = data.data![i];
      rows.add([
        '${i + 1}',
        t.date == null ? '' : DateFormat('dd MMM, yyyy').format(DateTime.parse(t.date!)),
        t.invoiceNo ?? '',
        t.platform?.toTitleCase() ?? '',
        formatPointNumber(t.amount ?? 0),
      ]);
    }

    rows.add([
      _lang.total,
      '',
      '',
      '',
      formatPointNumber(data.totalAmount ?? 0),
    ]);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: const [
          pw.FlexColumnWidth(2),
          pw.FlexColumnWidth(5),
          pw.FlexColumnWidth(4),
          pw.FlexColumnWidth(3),
          pw.FlexColumnWidth(4),
        ],
        isRTL: isRTL,
      ),
      children: [
        /// HEADER
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
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

        /// DATA ROWS
        ...rows.map(
          (row) => pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rows.indexOf(row).isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              row
                  .map(
                    (cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
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

        /// HEADER
        header: (_) => pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                business?.data?.companyName ?? '',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              localizedText(
                _lang.allTransactionReport,
                size: 16,
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

        /// FOOTER
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText(
              '${business?.data?.developByLevel ?? ''} '
              '${business?.data?.developBy ?? ''}',
              alignment: pw.TextAlign.start,
            ),
            localizedText('${_lang.page}-${context.pageNumber}'),
          ],
        ),

        /// BODY
        build: (_) => [
          pw.SizedBox(height: 16),
          buildLocalizedTable(),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-all-transaction-report.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'All Transaction Report',
        onLayout: (_) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
  }
}
