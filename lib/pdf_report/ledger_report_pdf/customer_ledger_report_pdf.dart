import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../Screens/Customers/Model/parties_model.dart';
import '../../model/business_info_model.dart';

Future<void> generateCustomerLedgerReportPdf(
  BuildContext context,
  List<Party>? data,
  BusinessInformationModel? business,
) async {
  final pdf = pw.Document();

  // Loading
  EasyLoading.show(status: 'Generating PDF');

  // ---------- totals ----------
  final totalAmount = data?.fold<num>(0, (p, e) => p + (e.totalSaleAmount ?? 0)) ?? 0;
  final paidAmount = data?.fold<num>(0, (p, e) => p + (e.totalSalePaid ?? 0)) ?? 0;
  final dueAmount = data?.fold<num>(0, (p, e) => p + (e.due ?? 0)) ?? 0;

  // ---------- localization ----------
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

  // ---------- table headers ----------
  final headers = [
    _lang.customerName,
    _lang.phone,
    _lang.totalSales,
    _lang.amount,
    _lang.paid,
    _lang.due,
  ];

  // ---------- table rows ----------
  final rows = data?.map((item) {
        return [
          item.name ?? 'n/a',
          item.phone ?? 'n/a',
          formatPointNumber(item.saleCount ?? 0),
          formatPointNumber(item.totalSaleAmount ?? 0),
          formatPointNumber(item.totalSalePaid ?? 0),
          formatPointNumber(item.due ?? 0),
        ];
      }).toList() ??
      [];

  // ---------- totals row ----------
  rows.add([
    _lang.total,
    '',
    '',
    formatPointNumber(totalAmount),
    formatPointNumber(paidAmount),
    formatPointNumber(dueAmount),
  ]);

  // ---------- table builder ----------
  pw.Table buildLocalizedTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: RtlTableHelper.reverseColumnWidths(const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(5),
        2: pw.FlexColumnWidth(4),
        3: pw.FlexColumnWidth(4),
        4: pw.FlexColumnWidth(4),
        5: pw.FlexColumnWidth(4),
      }, isRTL: isRTL),
      children: [
        // Header
        RtlTableHelper.createRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
            children: headers.map((h) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(
                  h,
                  bold: true,
                  alignment: pw.TextAlign.center,
                  color: PdfColors.white,
                ),
              );
            }).toList(),
            isRTL: isRTL),
        // Rows
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return RtlTableHelper.createRow(
              decoration: pw.BoxDecoration(
                color: index.isOdd ? PdfColor.fromInt(kPdfRowColor) : PdfColors.white,
              ),
              children: row.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: localizedText(
                    cell,
                    alignment: pw.TextAlign.center,
                  ),
                );
              }).toList(),
              isRTL: isRTL);
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isOdd ? PdfColor.fromInt(kPdfRowColor) : PdfColors.white,
            ),
            children: row.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: localizedText(
                  cell,
                  alignment: pw.TextAlign.center,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.symmetric(horizontal: 16),

        // ---------- header ----------
        header: (context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              localizedText(
                business?.data?.companyName ?? '',
                size: 20,
                bold: true,
              ),
              localizedText(
                _lang.customerLedgerReport,
                size: 16,
                bold: true,
              ),
            ],
          ),
        ),

        // ---------- footer ----------
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText('${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}'),
            localizedText('${_lang.page}-${context.pageNumber}'),
          ],
        ),

        // ---------- body ----------
        build: (context) => [
          pw.SizedBox(height: 16),
          buildLocalizedTable(),
        ],
      ),
    );

    // Save file
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-customer-ledger-report.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Customer Ledger Report',
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (_) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('PDF Error: $e');
  }
}
