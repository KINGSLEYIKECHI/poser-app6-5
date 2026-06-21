import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_common_function.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_common_functions.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_text.dart';
import 'package:mobile_pos/PDF%20Invoice/universal_image_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:printing/printing.dart';
import '../../constant.dart';
import '../../model/business_info_model.dart';
import '../Screens/transfer/model/transfer_details_model.dart';

///-------------------sales details pdf------------------
Future<void> generateWarehouseTransferInvoice(
  BuildContext context,
  TransferDetailsModel? transfer,
  BusinessInformationModel? shopInfo, {
  bool? isShare,
  bool? download,
  bool? showPreview,
}) async {
  final pdf = pw.Document();
  final _lang = l.S.of(context);
  final localeCode = Localizations.localeOf(context).languageCode;
  final fonts = await loadPdfFonts();

  //image data
  final String imageUrl = '${(shopInfo?.data?.showA4InvoiceLogo == 1) ? shopInfo?.data?.a4InvoiceLogo : ''}';
  dynamic imageData = await PDFCommonFunctions().getNetworkImage(imageUrl);
  imageData ??=
      (shopInfo?.data?.showA4InvoiceLogo == 1) ? await PDFCommonFunctions().loadAssetImage('images/logo.png') : null;

  final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  final englishBold = pw.Font.ttf(await rootBundle.load('fonts/NotoSans/NotoSans-Medium.ttf'));
  final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

  // Helper function
  pw.Font getFont({bool bold = false}) {
    switch (selectedLanguage) {
      case 'en':
        return bold ? englishBold : englishFont;
      case 'bn':
        // Bold not available, fallback to regular
        return banglaFont;
      default:
        return bold ? englishBold : englishFont;
    }
  }

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

  final showWarranty = shopInfo?.data?.showWarranty == 1 &&
      (shopInfo?.data?.warrantyVoidLabel != null || shopInfo?.data?.warrantyVoid != null);

  // Create a page with the layout
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
    margin: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  if (shopInfo?.data?.meta?.showAddress == 1)
                    pw.SizedBox(
                      width: 200,
                      child: localizedText(
                        alignment: pw.TextAlign.end,
                        '${_lang.address}: ${shopInfo?.data?.address ?? ''}',
                      ),
                    ),
                  if (shopInfo?.data?.meta?.showPhoneNumber == 1)
                    pw.SizedBox(
                      width: 200,
                      child: localizedText(
                        alignment: pw.TextAlign.end,
                        '${_lang.mobile} ${shopInfo?.data?.phoneNumber ?? ''}',
                      ),
                    ),
                  if (shopInfo?.data?.meta?.showEmail == 1)
                    pw.SizedBox(
                      width: 200,
                      child: localizedText(
                        alignment: pw.TextAlign.end,
                        '${_lang.emailText}: ${shopInfo?.data?.invoiceEmail ?? ''}',
                      ),
                    ),
                  //vat Name
                  if (shopInfo?.data?.meta?.showVat == 1 && shopInfo?.data?.vatNo != null)
                    pw.SizedBox(
                      width: 200,
                      child: localizedText(
                        alignment: pw.TextAlign.end,
                        '${shopInfo?.data?.vatName ?? _lang.vatNumber}: ${shopInfo?.data?.vatNo ?? ''}',
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
                child: getLocalizedPdfText(
                  _lang.transferInvoice,
                  pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: PdfColors.black,
                    font: getFont(bold: true),
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                //customer name
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                  localizedText(
                    _lang.invoice,
                    alignment: pw.TextAlign.start,
                  ),
                  pw.SizedBox(
                    width: 10.0,
                    child: pw.Text(
                      ':',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    ),
                  ),
                  localizedText(
                    transfer?.data?.invoiceNo ?? '',
                    alignment: pw.TextAlign.start,
                  ),
                ]),
                //status
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                  localizedText(
                    _lang.status,
                    alignment: pw.TextAlign.start,
                  ),
                  pw.SizedBox(
                    width: 10.0,
                    child: pw.Text(
                      ':',
                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                    ),
                  ),
                  localizedText(
                    transfer?.data?.status ?? '',
                    alignment: pw.TextAlign.start,
                  ),
                ]),
              ]),
              pw.Column(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                //date
                pw.Row(children: [
                  pw.SizedBox(
                    width: 100.0,
                    child: localizedText(
                      _lang.date,
                      alignment: pw.TextAlign.start,
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
                    width: 75.0,
                    child: localizedText(
                      transfer?.data?.transferDate?.isNotEmpty == true
                          ? DateFormat('d MMM, yyyy').format(DateTime.parse(transfer!.data!.transferDate!))
                          : '',
                      alignment: pw.TextAlign.start,
                    ),
                  ),
                ]),
                //Time
                pw.Row(children: [
                  pw.SizedBox(
                    width: 100.0,
                    child: localizedText(
                      _lang.time,
                      alignment: pw.TextAlign.start,
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
                    width: 75.0,
                    child: localizedText(
                      transfer?.data?.transferDate?.isNotEmpty == true
                          ? DateFormat('hh:mm a').format(DateTime.parse(transfer!.data!.transferDate!))
                          : '',
                      alignment: pw.TextAlign.start,
                    ),
                  ),
                ]),
              ]),
            ]),
            pw.SizedBox(height: 10),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              //Form warehouse
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                //From
                localizedText(
                  alignment: pw.TextAlign.start,
                  _lang.from,
                  bold: true,
                ),
                localizedText('WH: ${transfer?.data?.fromWarehouse?.name ?? ''}'),
                localizedText(transfer?.data?.fromWarehouse?.address ?? ''),
              ]),
              //To Warehouse
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                //From
                localizedText(
                  alignment: pw.TextAlign.start,
                  _lang.to,
                  bold: true,
                ),
                localizedText('WH: ${transfer?.data?.toWarehouse?.name ?? ''}'),
                localizedText(transfer?.data?.toWarehouse?.address ?? ''),
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
                if (shopInfo?.data?.showWarranty == 1 && shopInfo?.data?.warrantyVoidLabel != null)
                  localizedText(
                    bold: true,
                    '${shopInfo?.data?.warrantyVoidLabel ?? ''}- ',
                  ),
                if (shopInfo?.data?.warrantyVoid != null) localizedText(shopInfo?.data?.warrantyVoid ?? ''),
              ]),
              // child: pw.RichText(
              //   text: pw.TextSpan(
              //     children: [
              //       if (shopInfo?.data?.warrantyVoidLabel != null)
              //         pw.TextSpan(
              //           text: '${shopInfo!.data?.warrantyVoidLabel!}- ',
              //           style: pw.TextStyle(
              //             color: PdfColors.black,
              //             font: getFont(bold: true),
              //             fontFallback: [englishFont],
              //           ),
              //         ),
              //       if (shopInfo?.data?.warrantyVoid != null)
              //         pw.TextSpan(
              //           text: shopInfo!.data?.warrantyVoid!,
              //           style: pw.TextStyle(
              //             color: PdfColors.black,
              //             font: getFont(),
              //             fontFallback: [englishFont],
              //           ),
              //         ),
              //     ],
              //   ),
              // ),
            ),
          ),
        pw.SizedBox(height: 10),
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 10),
          child: pw.Center(
            child: pw.Text(
              '${shopInfo?.data?.developByLevel ?? ''} ${shopInfo?.data?.developBy ?? ''}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ]);
    },
    build: (pw.Context context) => <pw.Widget>[
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: pw.Column(
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
                1: const pw.FlexColumnWidth(5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                // Table header
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        _lang.sl,
                        alignment: pw.TextAlign.center,
                        bold: true,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        _lang.item,
                        bold: true,
                        alignment: pw.TextAlign.start,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        _lang.quantity,
                        bold: true,
                        alignment: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        _lang.unitPrice,
                        bold: true,
                        alignment: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: localizedText(
                        _lang.totalPrice,
                        bold: true,
                        alignment: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // Table rows for products
                for (int i = 0; i < (transfer?.data?.transferProducts?.length ?? 0); i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          '${i + 1}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            localizedText(
                              transfer?.data?.transferProducts?.elementAt(i).product?.productName.toString() ?? '',
                              alignment: pw.TextAlign.center,
                            ),
                            if (transfer?.data?.transferProducts?[i].serialNumbers?.isNotEmpty == true)
                              getLocalizedPdfText(
                                '${_lang.serial}: ${transfer?.data?.transferProducts?[i].serialNumbers?.join(", ") ?? ''}',
                                pw.TextStyle(
                                  fontSize: 8,
                                  font: getFont(),
                                  fontFallback: [englishFont],
                                ),
                                textAlignment: pw.TextAlign.left,
                              ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: localizedText(
                          transfer?.data?.transferProducts?[i].quantity.toString() ?? '',
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: localizedText(
                          formatPointNumber(transfer?.data?.transferProducts?.elementAt(i).unitPrice ?? 0),
                          alignment: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: localizedText(
                          formatPointNumber(
                            ((transfer?.data?.transferProducts?[i].unitPrice ?? 0) *
                                    (transfer?.data?.transferProducts?[i].quantity ?? 0)) -
                                ((transfer?.data?.transferProducts?[i].discount ?? 0) *
                                    (transfer?.data?.transferProducts?[i].quantity ?? 0)),
                          ),
                          alignment: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (shopInfo?.data?.showGratitudeMsg == 1 && shopInfo?.data?.gratitudeMessage?.isNotEmpty == true)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(bottom: 8.0),
                child: pw.Center(
                    child: pdfText(
                  shopInfo?.data?.gratitudeMessage ?? '',
                  fonts: fonts,
                  langCode: localeCode,
                )),
              ),
            // pw.SizedBox(height: 4),
            // Right column - Amount calculation (ALWAYS shows)
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 10.0),
                      localizedText(
                        "${_lang.subTotal}: ${formatPointNumber(transfer?.data?.subTotal ?? 0)}",
                      ),
                      pw.SizedBox(height: 5.0),
                      localizedText(
                        "${_lang.tax}: ${formatPointNumber(transfer?.data?.totalTax ?? 0)}",
                      ),
                      pw.SizedBox(height: 5.0),
                      localizedText(
                        "${_lang.discount}: ${formatPointNumber(transfer?.data?.totalDiscount ?? 0)}",
                      ),
                      pw.SizedBox(height: 5.0),
                      localizedText(
                        "${_lang.shippingCharge}: ${formatPointNumber(transfer?.data?.shippingCharge ?? 0)}",
                      ),
                      pw.SizedBox(height: 5.0),
                      localizedText(
                        "${_lang.totalPayable}: ${formatPointNumber(transfer?.data?.grandTotal ?? 0)}",
                        bold: true,
                      ),
                    ],
                  ),
                ]),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
          ],
        ),
      ),
    ],
  ));
  //
  EasyLoading.showSuccess(_lang.pdfGenerateSuccessfully);

  if (showPreview == true) {
    await Printing.layoutPdf(
      name: shopInfo?.data?.companyName ?? '',
      usePrinterSettings: true,
      dynamicLayout: true,
      forceCustomPrintPaper: true,
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } else {
    await PDFFunctions.savePdfAndShowPdf(
      context: context,
      shopName: shopInfo?.data?.companyName ?? '',
      invoice: transfer?.data?.invoiceNo ?? '',
      doc: pdf,
      isShare: isShare,
      download: download,
    );
  }
}

// pw.Padding(
// padding: const pw.EdgeInsets.all(8.0),
// child: pw.Column(children: [
// localizedText(
// "${transactions.salesDetails!.elementAt(i).product?.productName.toString() ?? ''}${transactions.salesDetails?.elementAt(i).product?.productType == ProductType.variant.name ? ' [${transactions.salesDetails?.elementAt(i).stock?.batchNo ?? ''}]' : ''}",
// alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
// ),
// // -------------- Added Serial Number Display Here -----------------
// if (transactions.salesDetails![i].serialNumbers != null &&
// transactions.salesDetails![i].serialNumbers!.isNotEmpty)
// localizedText(
// '${_lang.serial}: ${transactions.salesDetails![i].serialNumbers!.join(", ")}',
// alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
// ),
// // -----------------------------------------------------------------
// ]),
// ),
