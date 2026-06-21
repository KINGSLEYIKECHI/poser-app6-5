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
import 'package:printing/printing.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../PDF Invoice/pdf_text.dart';
import '../../PDF Invoice/arabic_fonts.dart';
import '../../PDF Invoice/table_rtl_helper.dart';
import '../../PDF Invoice/check_rtl.dart';
import '../../model/business_info_model.dart';
import '../../model/sale_transaction_model.dart';

Future<void> generateSaleReportPdf(BuildContext context, List<SalesTransactionModel>? data,
    BusinessInformationModel? business, DateTime? fromDate, DateTime? toDate) async {
  final pw.Document pdf = pw.Document();
  final interFont = await PdfGoogleFonts.notoSansRegular();

  // Show loading indicator
  EasyLoading.show(status: 'Generating PDF');
  double total = 0;
  double totalDue = 0;
  double totalPaid = 0;

// Calculate totals from data
  if (data != null) {
    for (var item in data) {
      final totalAmounts = item.totalAmount ?? 0;
      total += totalAmounts;
    }
  }

  //total due
  if (data != null) {
    for (var item in data) {
      final due = item.paidAmount ?? 0;
      totalDue += due;
    }
  }

  //total paid
  if (data != null) {
    for (var item in data) {
      final paid = item.dueAmount ?? 0;
      totalPaid += paid;
    }
  }

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
      final bool isBanglaData = containsBangla(text);
      return getLocalizedPdfText(
        text,
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

  pw.Widget buildLocalizedTable(List<SalesTransactionModel> data) {
    // Table headers localized
    final headers = [
      _lang.reference,
      _lang.date,
      _lang.customer,
      _lang.status,
      _lang.total,
      _lang.paid,
      _lang.due,
    ];

    // Table rows
    final rows = data.map((item) {
      return [
        item.invoiceNumber ?? 'n/a',
        DateFormat('dd-MM-yyyy').format(DateTime.parse(item.saleDate.toString())),
        item.party?.name ?? 'n/a',
        item.isPaid == true ? _lang.paid : _lang.unPaid,
        formatPointNumber(item.totalAmount ?? 0),
        formatPointNumber(item.paidAmount ?? 0),
        formatPointNumber(item.dueAmount ?? 0),
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

    return RtlTableHelper.createTable(
      border: pw.TableBorder.all(color: PdfColors.grey),
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
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(kPdfColor)),
          children: RtlTableHelper.reverseChildren(
            headers.map((h) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: localizedText(
                  h,
                  bold: true,
                  color: PdfColors.white,
                  alignment: pw.TextAlign.center,
                ),
              );
            }).toList(),
            isRTL: isRTL,
          ),
        ),

        // Data rows
        ...rows.map((row) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: rows.indexOf(row).isOdd ? PdfColor.fromInt(kPdfRowColor) : PdfColors.white,
            ),
            children: RtlTableHelper.reverseChildren(
              row.map((cell) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: localizedText(
                    cell,
                    alignment: pw.TextAlign.center,
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
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      margin: pw.EdgeInsets.symmetric(horizontal: 16),
      //----------------pdf header--------------
      header: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                business?.data?.companyName.toString() ?? '',
                style: pw.TextStyle(
                  // font: interFont,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              localizedText(
                // 'বিক্রয় প্রতিবেদন',
                _lang.salesReport,
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
      //-----------------pdf footer-------------
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
          buildLocalizedTable(data!),
        ];
      },
    ));

    final byteData = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${appsName}-loss-profit-report.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    EasyLoading.showSuccess('Generate Complete');
    //print pdf
    if (context.mounted) {
      await Printing.layoutPdf(
        name: 'Sales Report',
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PDFViewerPage(path: file.path),
    //   ),
    // );
  } catch (e) {
    EasyLoading.showError('Error: $e');
    print('Error during PDF generation: $e');
  }
}
