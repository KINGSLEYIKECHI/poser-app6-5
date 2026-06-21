import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../model/business_info_model.dart';
import '../../model/tax_report_model.dart' as trm;

Future<void> generateTaxReportPdf(
  BuildContext context,
  trm.TaxReportModel data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate, {
  bool isPurchase = false,
}) async {
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

  pw.Widget buildLocalizedTaxTable() {
    final invoices = data.getInvoices(isPurchase: isPurchase);
    final rowMap = data.getRowMap(isPurchase: isPurchase);
    final returnRowMap = data.getRowMap(isPurchase: isPurchase, isReturn: true);
    final vats = data.activeVats;

    final headers = [
      _lang.date,
      _lang.invoice,
      _lang.customer,
      'Tax Number',
      _lang.totalAmount,
      _lang.paymentMethod,
      _lang.discount,
      ...vats.map((vat) => vat.displayName),
    ];

    final baseWidths = [
      const pw.FlexColumnWidth(2.5),
      const pw.FlexColumnWidth(2),
      const pw.FlexColumnWidth(2.5),
      const pw.FlexColumnWidth(2.5),
      const pw.FlexColumnWidth(2.5),
      const pw.FlexColumnWidth(2),
      const pw.FlexColumnWidth(2),
    ];

    final taxColumnWidths = vats.map((_) => const pw.FlexColumnWidth(2)).toList();
    final columnWidths = [...baseWidths, ...taxColumnWidths];

    final rows = <List<String>>[];

    for (int i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];
      final baseRow = [
        invoice.transactionDate == null ? "N/A" : DateFormat("dd MMM, yyyy").format(invoice.transactionDate!),
        invoice.invoiceNumber ?? "N/A",
        invoice.partyName ?? "N/A",
        "",
        formatPointNumber(invoice.amount ?? 0),
        invoice.paymentType ?? "N/A",
        formatPointNumber(invoice.discountAmount ?? 0),
      ];

      final taxValues = vats.map((vat) {
        // Calculate VAT following web logic: totalVat = productVat + invoiceVat - returnVat
        final amount = invoice.calculateVatAmount(vat.id, rowMap, returnRowMap);
        return formatPointNumber(amount);
      }).toList();

      rows.add([...baseRow, ...taxValues]);
    }

    final totalBaseCells = [
      _lang.total,
      "",
      "",
      "",
      formatPointNumber(invoices.totalAmount),
      "",
      formatPointNumber(invoices.totalDiscountAmount),
    ];

    final totalTaxCells = vats.map((vat) {
      // Calculate grand total following web logic:
      // grandVatTotal = (vatTotals - returnVatTotals) + sum of invoice.vatAmount where vatId matches
      final total = data.calculateGrandVatTotal(vatId: vat.id, isPurchase: isPurchase);
      return formatPointNumber(total);
    }).toList();
    rows.add([...totalBaseCells, ...totalTaxCells]);

    // Light grey color for header and total row
    final headerColor = PdfColor.fromInt(0xffF5F5F5);
    final borderColor = PdfColor.fromInt(0xffE0E0E0);

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: borderColor),
      columnWidths: RtlTableHelper.createColumnWidths(
        widths: columnWidths,
        isRTL: isRTL,
      ),
      children: [
        // Header row - light grey background with black text
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: RtlTableHelper.reverseChildren(
            headers.map((h) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: localizedText(
                  h,
                  bold: true,
                  color: PdfColors.black,
                  alignment: pw.TextAlign.center,
                  size: 8,
                ),
              );
            }).toList(),
            isRTL: isRTL,
          ),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isTotalRow = index == rows.length - 1;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isTotalRow
                  ? headerColor // Light grey for total row
                  : (index.isOdd ? PdfColor.fromInt(0xffF9F9F9) : PdfColors.white),
            ),
            children: RtlTableHelper.reverseChildren(
              row.asMap().entries.map((cellEntry) {
                final cellIndex = cellEntry.key;
                final cell = cellEntry.value;
                final isFirstColumn = cellIndex == 0;
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: localizedText(
                    cell,
                    alignment: isFirstColumn && isTotalRow ? pw.TextAlign.center : pw.TextAlign.center,
                    size: 8,
                    color: PdfColors.black,
                    bold: isTotalRow,
                  ),
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
        pageFormat: PdfPageFormat.a4.landscape.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                localizedText(
                  business?.data?.companyName.toString() ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                localizedText(
                  '${_lang.taxReport} (${isPurchase ? _lang.purchase : _lang.sales})',
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                if (fromDate != null && toDate != null)
                  localizedText(
                    '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} ${_lang.to} ${DateFormat('dd-MM-yyyy').format(toDate)}',
                    size: 12,
                  ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              localizedText('${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}'),
              localizedText('${_lang.page}-${context.pageNumber}'),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),
            buildLocalizedTaxTable(),
          ];
        },
      ),
    );

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-tax-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Tax Report',
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
