import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../Screens/Customers/Model/parties_model.dart';
import '../../model/business_info_model.dart';

Future<void> generatePartyWiseLossProfitReportPdf(
  BuildContext context,
  List<Party>? data,
  BusinessInformationModel? business,
) async {
  final pdf = pw.Document();

  EasyLoading.show(status: 'Generating PDF');

  // ---------- totals ----------
  final totalSaleAmount = data?.fold<num>(0, (p, e) => p + (e.totalSaleAmount ?? 0)) ?? 0;
  final totalProfitAmount = data?.fold<num>(0, (p, e) => p + (e.totalSaleProfit ?? 0)) ?? 0;
  final totalLossAmount = data?.fold<num>(0, (p, e) => p + (e.totalSaleLoss ?? 0)) ?? 0;

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
    _lang.sl, // SL.
    _lang.partyName, // Party Name
    _lang.saleAmount, // Sale Amount
    _lang.profit, // Profit
    _lang.loss, // Loss
  ];

  // ---------- table rows ----------
  final rows = data?.asMap().entries.map((entry) {
        final index = entry.key;
        final party = entry.value;
        return [
          "${index + 1}",
          party.name ?? 'N/A',
          formatPointNumber(party.totalSaleAmount ?? 0),
          formatPointNumber(party.totalSaleProfit ?? 0),
          formatPointNumber(party.totalSaleLoss ?? 0),
        ];
      }).toList() ??
      [];

  // ---------- add totals row ----------
  rows.add([
    _lang.total,
    '',
    formatPointNumber(totalSaleAmount),
    formatPointNumber(totalProfitAmount),
    formatPointNumber(totalLossAmount),
  ]);

  // ---------- table builder ----------
  pw.Table buildLocalizedTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: RtlTableHelper.reverseColumnWidths(const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(5),
        2: pw.FlexColumnWidth(4),
        3: pw.FlexColumnWidth(3),
        4: pw.FlexColumnWidth(3),
      }, isRTL: isRTL),
      children: [
        // Header row
        RtlTableHelper.createRow(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(kPdfColor),
            ),
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
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return RtlTableHelper.createRow(
              decoration: pw.BoxDecoration(
                color: index.isOdd ? PdfColor.fromInt(0xffF7F7F7) : PdfColors.white,
              ),
              children: row
                  .map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: localizedText(
                          cell,
                          alignment: pw.TextAlign.center,
                        ),
                      ))
                  .toList(),
              isRTL: isRTL);
        }),
      ],
    );
  }

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.symmetric(horizontal: 16),
        header: (_) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              localizedText(
                business?.data?.companyName ?? '',
                size: 20,
                bold: true,
                alignment: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              localizedText(
                _lang.partyWiseLossProfitReport, // localized header
                size: 16,
                bold: true,
                alignment: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            localizedText(
              '${business?.data?.developByLevel ?? ''} ${business?.data?.developBy ?? ''}',
              size: 9,
            ),
            localizedText('${_lang.page}-${ctx.pageNumber}', size: 9),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 16),
          buildLocalizedTable(),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-party-wise-loss-profit.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Party Wise Loss & Profit Report',
        dynamicLayout: true,
        onLayout: (_) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('PDF Error: $e');
  }
}
