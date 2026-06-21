import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';
import 'package:mobile_pos/Screens/party%20ledger/model/party_ledger_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../Screens/PDF/pdf.dart';
import '../../Screens/Products/Model/product_total_stock_model.dart';
import '../../currency.dart';
import '../../model/business_info_model.dart';
import 'generate_pdf_date_range.dart';

Future<void> generateLedgerReportPdf(
  BuildContext context,
  List<PartyLedgerModel>? data,
  BusinessInformationModel business,
  DateTime? fromDate,
  DateTime? toDate,
  String selectedTime,
) async {
  if (data == null || data.isEmpty) {
    EasyLoading.showInfo('No transactions to generate PDF');
    return;
  }

  final pdf = pw.Document();
  EasyLoading.show(status: 'Generating PDF...');

  try {
    //---------------- Totals ----------------
    double creditBalance = 0;
    double debitBalance = 0;

    for (var item in data) {
      creditBalance += item.creditAmount ?? 0;
      debitBalance += item.debitAmount ?? 0;
    }

    //---------------- Locale & Fonts ----------------
    final _lang = l.S.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final fonts = await loadPdfFonts();

    final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

    bool containsBangla(String text) {
      return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
    }

    //---------------- Localized Text ----------------
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

    //---------------- Date Range ----------------
    final pdfDateRange = getPdfDateRangeForSelectedTime(
      selectedTime,
      fromDate: fromDate,
      toDate: toDate,
    );

    //---------------- Ledger Table ----------------
    pw.Widget buildLedgerTable() {
      final headers = [
        _lang.date,
        _lang.reference,
        _lang.description,
        _lang.credit,
        _lang.debit,
        _lang.balance,
      ];

      final rows = data.map((item) {
        final isOpening = item.platform == 'opening_balance';
        return [
          DateFormat('dd-MM-yyyy').format(DateTime.parse(item.date.toString())),
          item.invoiceNumber ?? '--',
          isOpening ? _lang.openingBalance : (item.platform?.replaceAll('_', ' ') ?? _lang.transactions),
          '$currency${formatPointNumber(item.creditAmount ?? 0)}',
          '$currency${formatPointNumber(item.debitAmount ?? 0)}',
          '$currency${formatPointNumber(item.balance ?? 0)}',
        ];
      }).toList();

      rows.add([
        '',
        '',
        _lang.total,
        '$currency${formatPointNumber(creditBalance)}',
        '$currency${formatPointNumber(debitBalance)}',
        '$currency${formatPointNumber(data.last.balance ?? 0)}',
      ]);

      return pw.Table(
        border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        columnWidths: RtlTableHelper.reverseColumnWidths(const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(4),
          2: pw.FlexColumnWidth(4),
          3: pw.FlexColumnWidth(3),
          4: pw.FlexColumnWidth(3),
          5: pw.FlexColumnWidth(3),
        }, isRTL: isRTL),
        children: [
          // Header
          RtlTableHelper.createRow(
              decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xffF7F7F7)),
              children: headers
                  .map(
                    (h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        h,
                        bold: true,
                        alignment: pw.TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
              isRTL: isRTL),

          // Rows
          ...rows.map(
            (row) => RtlTableHelper.createRow(
                children: row
                    .map(
                      (cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: localizedText(cell, alignment: pw.TextAlign.center),
                      ),
                    )
                    .toList(),
                isRTL: isRTL),
          ),
        ],
      );
    }

    //---------------- PDF Page ----------------
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.symmetric(horizontal: 16),
        header: (_) => pw.Center(
          child: pw.Column(
            children: [
              localizedText(
                appsName,
                size: 20,
                bold: true,
              ),
              localizedText(
                _lang.partyLedger,
                size: 16,
                bold: true,
              ),
              pw.SizedBox(height: 4),
              localizedText(
                '${pdfDateRange['from']} ${_lang.to} ${pdfDateRange['to']}',
                size: 12,
              ),
            ],
          ),
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText('${business.data?.developByLevel ?? ''} ${business.data?.developBy ?? ''}'),
            localizedText('${_lang.page}-${context.pageNumber}'),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 16),
          buildLedgerTable(),
        ],
      ),
    );

    //---------------- Save & Print ----------------
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-ledger-report-${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Ledger Report',
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (_) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Failed to generate PDF: $e');
  }
}
