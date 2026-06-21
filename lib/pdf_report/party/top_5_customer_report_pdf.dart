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
import 'package:printing/printing.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../PDF Invoice/pdf_text.dart';
import '../../Screens/Customers/Model/parties_model.dart';
import '../../model/business_info_model.dart';

Future<void> generateTop5CustomerReportPdf(
  BuildContext context,
  List<Party>? data,
  BusinessInformationModel? business,
) async {
  final pdf = pw.Document();

  EasyLoading.show(status: 'Generating PDF');

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

  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.symmetric(horizontal: 16),

        //----------------pdf header--------------
        header: (_) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              localizedText(
                business?.data?.companyName ?? '',
                size: 20,
                bold: true,
              ),
              pw.SizedBox(height: 4),
              localizedText(
                _lang.top5Customer,
                size: 16,
                bold: true,
              ),
            ],
          ),
        ),

        //-----------------pdf footer-------------
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

        //-----------------pdf body-------------
        build: (_) {
          final headers = [
            _lang.customerName,
            _lang.phone,
            _lang.email,
            _lang.totalSales,
          ];

          final rows = data?.map((party) {
                return [
                  party.name ?? 'N/A',
                  party.phone ?? 'N/A',
                  party.email ?? 'N/A',
                  formatPointNumber(party.saleCount ?? 0),
                ];
              }).toList() ??
              [];

          return [
            pw.SizedBox(height: 16),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromInt(0xffD9D9D9)),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: RtlTableHelper.reverseColumnWidths(const {
                0: pw.FlexColumnWidth(4),
                1: pw.FlexColumnWidth(4),
                2: pw.FlexColumnWidth(4),
                3: pw.FlexColumnWidth(3),
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
                ...rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  return RtlTableHelper.createRow(
                      decoration: pw.BoxDecoration(
                        color: index.isOdd ? PdfColor.fromInt(kPdfRowColor) : PdfColors.white,
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
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$appsName-top5-customers-report.pdf');
    await file.writeAsBytes(bytes);

    EasyLoading.showSuccess('Generate Complete');

    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Top 5 Customers Report',
        dynamicLayout: true,
        onLayout: (_) async => pdf.save(),
      );
    }
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('PDF Error: $e');
  }
}
