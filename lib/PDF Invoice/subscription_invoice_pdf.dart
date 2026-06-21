import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_text.dart';
import 'package:mobile_pos/PDF%20Invoice/universal_image_widget.dart';
import 'package:mobile_pos/Screens/all_transaction/model/transaction_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/model/sale_transaction_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Screens/Products/add product/modle/create_product_model.dart';
import '../model/business_info_model.dart';
import '../model/subscription_report_model.dart';
import 'arabic_fonts.dart';
import 'pdf_common_functions.dart';

class SubscriptionInvoicePdf {
  static Future<void> generateSaleDocument(
      List<SubscriptionReportModel> subscription, BusinessInformationModel personalInformation, BuildContext context,
      {bool? share, bool? download, bool? showPreview}) async {
    final pw.Document doc = pw.Document();
    final _lang = l.S.of(context);

    final String imageUrl =
        '${(personalInformation.data?.showA4InvoiceLogo == 1) ? personalInformation.data?.a4InvoiceLogo : ''}';
    dynamic imageData = await PDFCommonFunctions().getNetworkImage(imageUrl);
    imageData ??= (personalInformation.data?.showA4InvoiceLogo == 1)
        ? await PDFCommonFunctions().loadAssetImage('images/logo.png')
        : null;
    final localeCode = Localizations.localeOf(context).languageCode;
    final fonts = await loadPdfFonts();

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
      // Handle Arabic text with full bidi transformation
      // Use LTR direction since fixArabic() handles RTL text direction
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

    final showWarranty = personalInformation.data?.showWarranty == 1 &&
        (personalInformation.data?.warrantyVoidLabel != null || personalInformation.data?.warrantyVoid != null);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20.0),
            child: pw.Column(
              children: [
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Container(
                    height: 54.12,
                    width: 200,
                    child: universalImage(
                      imageData,
                      w: 200,
                      h: 54.12,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (personalInformation.data?.meta?.showAddress == 1)
                        pw.SizedBox(
                          width: 200,
                          child: localizedText(
                            '${_lang.address}: ${personalInformation.data?.address ?? ''}',
                            alignment: pw.TextAlign.end,
                          ),
                        ),
                      if (personalInformation.data?.meta?.showPhoneNumber == 1)
                        pw.SizedBox(
                          width: 200,
                          child: localizedText(
                            '${_lang.mobile}: ${personalInformation.data?.phoneNumber ?? ''}',
                            alignment: pw.TextAlign.end,
                          ),
                        ),
                      if (personalInformation.data?.meta?.showEmail == 1)
                        pw.SizedBox(
                          width: 200,
                          child: localizedText(
                            '${_lang.emailText}: ${personalInformation.data?.invoiceEmail ?? ''}',
                            alignment: pw.TextAlign.end,
                          ),
                        ),
                      //vat Name
                      if (personalInformation.data?.meta?.showVat == 1)
                        if (personalInformation.data?.vatNo != null && personalInformation.data?.meta?.showVat == 1)
                          pw.SizedBox(
                            width: 200,
                            child: localizedText(
                              '${personalInformation.data?.vatName ?? _lang.vatNumber}: ${personalInformation.data?.vatNo ?? ''}',
                              alignment: pw.TextAlign.end,
                            ),
                          ),
                    ],
                  ),
                ]),
                pw.SizedBox(height: 16.0),
                pw.Center(
                  child: pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(color: PdfColors.black),
                    ),
                    child: localizedText(
                      _lang.INVOICE,
                      bold: true,
                      size: 18,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    //customer name
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: localizedText(
                          _lang.billTO,
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 100.0,
                        child: localizedText(
                          personalInformation.data?.user?.name ?? '',
                        ),
                      ),
                    ]),
                    //mobile
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: localizedText(
                          _lang.mobile,
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 100.0,
                        child: localizedText(
                          personalInformation.data?.phoneNumber ?? 'n/a',
                        ),
                      ),
                    ]),
                    //Address
                    pw.Row(children: [
                      pw.SizedBox(
                        width: 60.0,
                        child: localizedText(
                          _lang.address,
                        ),
                      ),
                      pw.SizedBox(
                        width: 10.0,
                        child: pw.Text(
                          ':',
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                        ),
                      ),
                      pw.SizedBox(
                        width: 150.0,
                        child: localizedText(
                          personalInformation.data?.address ?? '',
                        ),
                      ),
                    ]),
                  ]),
                ]),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Column(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(10.0),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 2.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    localizedText(
                      _lang.customerSignature,
                    )
                  ]),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                  child: pw.Column(children: [
                    pw.Container(
                      width: 120.0,
                      height: 2.0,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4.0),
                    localizedText(
                      _lang.authorizedSignature,
                    )
                  ]),
                ),
              ]),
            ),
            if (showWarranty)
              pw.Padding(
                padding: pw.EdgeInsets.symmetric(horizontal: 10),
                child: pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Row(children: [
                    if (personalInformation.data?.warrantyVoidLabel != null)
                      localizedText('${personalInformation.data!.warrantyVoidLabel!}- ', bold: true),
                    if (personalInformation.data?.warrantyVoid != null)
                      localizedText(personalInformation.data!.warrantyVoid!, bold: true),
                  ]),
                ),
              ),
            pw.SizedBox(height: 10),
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 10),
              child: pw.Center(
                child: localizedText(
                  '${personalInformation.data?.developByLevel ?? ''} ${personalInformation.data?.developBy ?? ''}',
                ),
              ),
            ),
          ]);
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Main products table
                pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    top: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                  ),
                  columnWidths: <int, pw.TableColumnWidth>{
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                    5: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    // Table header
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(
                            _lang.sl,
                            bold: true,
                            alignment: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(
                            _lang.date,
                            alignment: pw.TextAlign.start,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(
                            _lang.packageName,
                            bold: true,
                            alignment: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(
                            _lang.started,
                            bold: true,
                            alignment: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(
                            _lang.end,
                            bold: true,
                            alignment: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(
                            _lang.paymentMethod,
                            bold: true,
                            alignment: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Table rows for products
                    for (int i = 0; i < subscription.length; i++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${i + 1}', textAlign: pw.TextAlign.center),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              alignment: pw.TextAlign.center,
                              subscription[i].startDate == null
                                  ? "N/A"
                                  : DateFormat('dd MMM yyyy').format(subscription[i].startDate!),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              alignment: pw.TextAlign.center,
                              subscription[i].name ?? 'n/a',
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              alignment: pw.TextAlign.center,
                              subscription[i].startDate == null
                                  ? "N/A"
                                  : DateFormat('dd MMM yyyy').format(subscription[i].startDate!),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              alignment: pw.TextAlign.center,
                              subscription[i].endDate == null
                                  ? "N/A"
                                  : DateFormat('dd MMM yyyy').format(subscription[i].startDate!),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              alignment: pw.TextAlign.center,
                              subscription[i].paymentBy ?? 'n/a',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                pw.SizedBox(height: 20.0),
                if ((!personalInformation.data!.invoiceNote.isEmptyOrNull ||
                        !personalInformation.data!.invoiceNoteLevel.isEmptyOrNull) &&
                    personalInformation.data!.showNote == 1)
                  pw.Row(children: [
                    localizedText('${personalInformation.data?.invoiceNoteLevel ?? ''}: ', bold: true),
                    localizedText(
                      personalInformation.data?.invoiceNote ?? '',
                    ),
                  ]),
                pw.SizedBox(height: 30),

                if (personalInformation.data?.showGratitudeMsg == 1)
                  if (!personalInformation.data!.gratitudeMessage.isEmptyOrNull)
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.only(bottom: 8.0),
                      child: pw.Center(
                          child: pw.Text(
                        personalInformation.data!.gratitudeMessage ?? '',
                      )),
                    ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );

    if (showPreview == true) {
      await Printing.layoutPdf(
          name: personalInformation.data?.companyName ?? '',
          usePrinterSettings: true,
          dynamicLayout: true,
          forceCustomPrintPaper: true,
          onLayout: (PdfPageFormat format) async => doc.save());
    } else {
      await PDFCommonFunctions.savePdfAndShowPdf(
        context: context,
        shopName: personalInformation.data?.companyName ?? '',
        invoice: '1',
        doc: doc,
        isShare: share,
        download: download,
      );
    }
  }
}
