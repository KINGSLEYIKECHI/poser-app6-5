import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

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
import '../../model/loss_profit_model.dart' as model;

Future<void> generateLossProfitReportPdf(BuildContext context, model.LossProfitModel data,
    BusinessInformationModel? business, DateTime? fromDate, DateTime? toDate) async {
  final pw.Document pdf = pw.Document();
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
      final bool isBanglaData = containsBangla(processedText);
      return getLocalizedPdfText(
        processedText,
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

  pw.Widget buildLocalizedLossProfitTable(model.LossProfitModel data) {
    final _length = math.max(
      (data.expenseSummary?.length ?? 0),
      (data.incomeSummary?.length ?? 0),
    );

    final List<List<String>> tableData = [];

    for (int i = 0; i < _length; i++) {
      final _income = (i < (data.incomeSummary?.length ?? 0)) ? data.incomeSummary![i] : null;
      final _expense = (i < (data.expenseSummary?.length ?? 0)) ? data.expenseSummary![i] : null;

      tableData.add([
        _income?.type ?? '',
        _income?.totalIncome == null ? '' : formatPointNumber(_income!.totalIncome!),
        _expense?.type ?? '',
        _expense?.totalExpense == null ? '' : formatPointNumber(_expense!.totalExpense!),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
          defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
          columnWidths: RtlTableHelper.createColumnWidths(widths: [
            pw.FlexColumnWidth(6),
            pw.FlexColumnWidth(4),
            pw.FlexColumnWidth(6),
            pw.FlexColumnWidth(4),
          ], isRTL: isRTL),
          children: [
            // Header row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
              children: RtlTableHelper.reverseChildren(
                [
                  localizedText(_lang.incomeType, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                  localizedText(_lang.amount, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                  localizedText(_lang.expenseType, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                  localizedText(_lang.amount, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                ],
                isRTL: isRTL,
              ),
            ),

            // Data rows
            ...tableData.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: index.isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
                ),
                children: RtlTableHelper.reverseChildren(
                  row.map((cell) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(cell, alignment: pw.TextAlign.center),
                    );
                  }).toList(),
                  isRTL: isRTL,
                ),
              );
            }).toList(),
          ],
        ),

        // Totals row
        pw.Table(
          border: const pw.TableBorder(
            left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
            right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
            bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
          ),
          columnWidths: RtlTableHelper.createColumnWidths(widths: [
            pw.FlexColumnWidth(6),
            pw.FlexColumnWidth(4),
            pw.FlexColumnWidth(6),
            pw.FlexColumnWidth(4),
          ], isRTL: isRTL),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
              children: RtlTableHelper.reverseChildren(
                [
                  localizedText(_lang.grossProfit, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                  localizedText(formatPointNumber(data.grossIncomeProfit ?? 0),
                      bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                  localizedText(_lang.totalExpense, bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                  localizedText(formatPointNumber(data.totalExpenses ?? 0),
                      bold: true, color: PdfColors.white, alignment: pw.TextAlign.center),
                ],
                isRTL: isRTL,
              ),
            ),
          ],
        ),
      ],
    );
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 16),
        header: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                localizedText(
                  business?.data?.companyName ?? '',
                  size: 20,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                localizedText(
                  _lang.profitAndLossReport, // Use localized string
                  size: 16,
                  bold: true,
                  alignment: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                localizedText(
                  fromDate != null
                      ? '${_lang.duration}: ${DateFormat('dd-MM-yyyy').format(fromDate)} ${_lang.to} ${DateFormat('dd-MM-yyyy').format(toDate!)}'
                      : '',
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
            buildLocalizedLossProfitTable(data),
          ];
        },
      ),
    );

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-loss-profit-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: _lang.profitAndLossReport,
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
