import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_text.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/PDF%20Invoice/universal_image_widget.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:nb_utils/nb_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Screens/Products/add product/modle/create_product_model.dart';
import '../Screens/Purchase/Model/purchase_transaction_model.dart';
import '../model/business_info_model.dart';
import 'arabic_fonts.dart';
import 'check_rtl.dart';
import 'convert_number_arabic.dart';
import 'pdf_common_functions.dart';

class PurchaseInvoicePDF {
  static Future<void> generatePurchaseDocument(
      PurchaseTransaction transactions, BusinessInformationModel personalInformation, BuildContext context,
      {bool? isShare, bool? download, bool? showPreview}) async {
    final pw.Document doc = pw.Document();

    final _lang = l.S.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    String productName({required num detailsId}) {
      final details = transactions.details?[transactions.details!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ''}]' : ''}" ??
          '';
    }

    num productPrice({required num detailsId}) {
      return transactions.details!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturnDiscount +=
                  ((productPrice(detailsId: details.purchaseDetailId ?? 0) * (details.returnQty ?? 0)) -
                      ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = transactions.details?.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (transactions.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              if (details.purchaseDetailId == detailsId) {
                totalQuantity += details.returnQty ?? 0;
              }
            }
          }
        }
      }

      return totalQuantity;
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in transactions.details!) {
        num productPrice = element.priceWithoutTax ?? 0;
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);

        total += productPrice * productQuantity;
      }

      return total;
    }

    num getTotalVatAmountForOldInvoice() {
      num total = 0;
      for (var element in transactions.details!) {
        num productPrice = (element.productPurchasePrice ?? 0) - (element.priceWithoutTax ?? 0);
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);

        total += productPrice * productQuantity;
      }

      return total;
    }

    EasyLoading.show(status: _lang.generatingPdf);

    final String imageUrl =
        '${(personalInformation.data?.showA4InvoiceLogo == 1) ? personalInformation.data?.a4InvoiceLogo : ''}';
    dynamic imageData = await PDFCommonFunctions().getNetworkImage(imageUrl);
    imageData ??= (personalInformation.data?.showA4InvoiceLogo == 1)
        ? await PDFCommonFunctions().loadAssetImage('images/logo.png')
        : null;
    final localeCode = Localizations.localeOf(context).languageCode;
    final fonts = await loadPdfFonts();

    final englishFont = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final arabicFonts = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'));
    final hebrewFonts = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSansHebrew-Regular.ttf'));
    final banglaFont = pw.Font.ttf(await rootBundle.load('assets/fonts/siyam_rupali_ansi.ttf'));

    bool containsBangla(String text) {
      return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
    }

    bool isRTLLanguage(String localeCode) {
      return [
        'ar',
        'ur',
        'fa',
        'he',
      ].contains(localeCode);
    }

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
      }

      if (isRTLLanguage(localeCode)) {
        return pw.Text(
          fixArabic(text),
          textDirection: pw.TextDirection.ltr,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            font: arabicFonts,
            fontSize: size,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
            fontFallback: [
              arabicFonts,
              hebrewFonts,
              englishFont,
            ],
          ),
        );
      }
      return pdfText(
        text,
        fonts: fonts,
        bold: bold,
        align: alignment,
        size: size,
        color: color,
      );
    }

    final bool isRTL = isCheckRtl(context);

    final bankTransactions =
        transactions.transactions?.where((t) => t.transactionType == 'bank_payment').toList() ?? [];

    final latestBankTransaction = bankTransactions.isNotEmpty ? bankTransactions.last : null;

    final showWarranty = personalInformation.data?.showWarranty == 1 &&
        (personalInformation.data?.warrantyVoidLabel != null || personalInformation.data?.warrantyVoid != null);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Directionality(
              textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Padding(
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
                        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end,
                        children: [
                          if (personalInformation.data?.meta?.showAddress == 1)
                            localizedText(
                              '${_lang.address}: ${personalInformation.data?.address ?? ''}',
                              alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                            ),
                          if (personalInformation.data?.meta?.showPhoneNumber == 1)
                            localizedText(
                              '${_lang.mobile}: ${personalInformation.data?.phoneNumber ?? ''}',
                              alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                            ),
                          if (personalInformation.data?.meta?.showEmail == 1)
                            localizedText(
                              '${_lang.emailText}: ${personalInformation.data?.invoiceEmail ?? ''}',
                              alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                            ),
                          //vat Name
                          if (personalInformation.data?.meta?.showVat == 1)
                            if (personalInformation.data?.vatNo != null && personalInformation.data?.meta?.showVat == 1)
                              localizedText(
                                '${personalInformation.data?.vatName ?? _lang.vatNumber}: ${personalInformation.data?.vatNo ?? ''}',
                                alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                              ),
                        ],
                      ),
                    ]),
                    pw.SizedBox(height: 10.0),
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
                    pw.SizedBox(height: 10),
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        //customer name
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 60.0,
                            child: localizedText(
                              _lang.customer,
                              alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start,
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
                              transactions.party?.name ?? '',
                              alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start,
                            ),
                          ),
                        ]),
                        //Address
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 60.0,
                            child: localizedText(
                              _lang.address,
                              alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start,
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
                              transactions.party?.address ?? 'N/a',
                              alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start,
                            ),
                          ),
                        ]),
                        //mobile
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 60.0,
                            child: localizedText(
                              _lang.mobile,
                              alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start,
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
                              transactions.party?.phone ?? (transactions.party?.phone ?? _lang.guest),
                              alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start,
                            ),
                          )
                        ]),
                      ]),
                      pw.Column(children: [
                        //Invoice Number
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 100.0,
                            child: localizedText(
                              _lang.invoiceNumber,
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
                            child: pw.Text(
                              '#${transactions.invoiceNumber}',
                              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black),
                            ),
                          ),
                        ]),
                        //date
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 100.0,
                            child: localizedText(
                              _lang.date,
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
                              DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.purchaseDate ?? '')),
                              // DateTimeFormat.format(DateTime.parse(transactions.saleDate ?? ''), format: 'D, M j'),
                            ),
                          ),
                        ]),
                        //Time
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 100.0,
                            child: localizedText(
                              _lang.time,
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
                              DateFormat('hh:mm a').format(DateTime.parse(transactions.purchaseDate!)),
                            ),
                          ),
                        ]),
                        //Sales by
                        pw.Row(children: [
                          pw.SizedBox(
                            width: 100.0,
                            child: localizedText(
                              _lang.purchasedBy,
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
                              transactions.user?.role == "shop-owner" ? _lang.admin : transactions.user?.name ?? '',
                            ),
                          ),
                        ]),
                      ]),
                    ]),
                  ],
                ),
              ));
        },
        footer: (pw.Context context) {
          return pw.Directionality(
              textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Column(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10.0),
                  child: pw.Column(children: [
                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
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
                    pw.SizedBox(height: 5),
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
                  ]),
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
              ]));
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              children: [
                // Main products table with RTL support
                pw.Table(
                    border: pw.TableBorder(
                      horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      top: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    ),
                    columnWidths: RtlTableHelper.reverseColumnWidths({
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(4),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(2),
                      5: const pw.FlexColumnWidth(2),
                    }, isRTL: isRTL),
                    children: [
                      // Table header with RTL support
                      RtlTableHelper.createRow(
                        isRTL: isRTL,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.sl,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.item,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.quantity,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.unitPrice,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              'Price (Exc.)',
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.totalPrice,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                            ),
                          ),
                        ],
                      ),
                      // Table rows with RTL support
                      for (int i = 0; i < transactions.details!.length; i++)
                        RtlTableHelper.createRow(
                          isRTL: isRTL,
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: pw.Text(
                                '${i + 1}',
                                textAlign: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                              ),
                            ),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(8.0),
                                child: pw.Column(
                                    crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                                    children: [
                                      localizedText(
                                        "${transactions.details!.elementAt(i).product?.productName.toString()}${transactions.details!.elementAt(i).product?.productType == ProductType.variant.name ? ' [${transactions.details!.elementAt(i).stock?.batchNo ?? ''}]' : ''}",
                                        alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                      ),
                                      // -------------- Added Serial Number Display Here -----------------
                                      if (transactions.details![i].serialNumbers != null &&
                                          transactions.details![i].serialNumbers!.isNotEmpty)
                                        localizedText(
                                          '${_lang.serial}: ${transactions.details![i].serialNumbers!.join(", ")}',
                                          alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                        ),
                                      // -----------------------------------------------------------------
                                    ])),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: localizedText(
                                (getProductQuantity(detailsId: transactions.details!.elementAt(i).id ?? 0)).toString(),
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: localizedText(
                                formatPointNumber(transactions.details!.elementAt(i).productPurchasePrice ?? 0),
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: localizedText(
                                formatPointNumber(transactions.details!.elementAt(i).priceWithoutTax ?? 0),
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: localizedText(
                                ((transactions.details!.elementAt(i).productPurchasePrice ?? 0) *
                                        getProductQuantity(detailsId: transactions.details!.elementAt(i).id ?? 0))
                                    .toStringAsFixed(2),
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                              ),
                            ),
                          ],
                        ),
                    ]),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left column - Payment information (ONLY when NO returns)
                      if (transactions.purchaseReturns != null || transactions.purchaseReturns!.isNotEmpty)
                        pw.SizedBox(),
                      if (transactions.purchaseReturns == null || transactions.purchaseReturns!.isEmpty)
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 5),
                              // Amount in words
                              pw.SizedBox(
                                width: 350,
                                child: localizedText(
                                  locale == 'ar'
                                      ? numberToArabicWords(transactions.totalAmount?.toInt() ?? 0)
                                      : PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0),
                                  bold: true,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              // Paid via
                              pw.Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  localizedText(
                                    '${_lang.paidVia} :',
                                    bold: true,
                                  ),
                                  ...?transactions.transactions?.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;

                                    String label;
                                    switch (item.transactionType) {
                                      case 'cash_payment':
                                        label = _lang.cash;
                                        break;
                                      case 'cheque_payment':
                                        label = _lang.cheque;
                                        break;
                                      case 'wallet_payment':
                                        label = _lang.wallet;
                                        break;
                                      default:
                                        label = item.paymentType?.name ?? 'n/a';
                                    }

                                    final isLast = index == transactions.transactions!.length - 1;
                                    final text = isLast ? label : '$label,';

                                    return localizedText(
                                      text,
                                      bold: true,
                                    );
                                  }),
                                ],
                              ),
                              pw.SizedBox(height: 5),
                              if ((!personalInformation.data!.invoiceNote.isEmptyOrNull ||
                                      !personalInformation.data!.invoiceNoteLevel.isEmptyOrNull) &&
                                  personalInformation.data!.showNote == 1)
                                pw.Row(children: [
                                  localizedText('${personalInformation.data?.invoiceNoteLevel ?? ''}: ', bold: true),
                                  localizedText(personalInformation.data?.invoiceNote ?? ''),
                                ]),

                              pw.SizedBox(height: 10),

                              if (latestBankTransaction != null)
                                pw.Container(
                                  width: 256,
                                  height: 120,
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(color: PdfColors.black),
                                  ),
                                  child: pw.Column(
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        child: localizedText(
                                          _lang.bankDetails,
                                          bold: true,
                                        ),
                                      ),
                                      pw.Divider(color: PdfColors.black, height: 1),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: pw.Column(
                                          children: [
                                            pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: localizedText(
                                                  _lang.name,
                                                )),
                                                pw.Expanded(
                                                    child: localizedText(
                                                  ': ${latestBankTransaction.paymentType?.name ?? ''}',
                                                )),
                                              ],
                                            ),
                                            pw.SizedBox(height: 4),
                                            pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: localizedText(
                                                  _lang.accountNumber,
                                                )),
                                                pw.Expanded(
                                                    child: localizedText(
                                                  ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.accountNumber ?? ''}',
                                                )),
                                              ],
                                            ),
                                            pw.SizedBox(height: 4),
                                            pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: localizedText(
                                                  _lang.ifscCode,
                                                )),
                                                pw.Expanded(
                                                    child: localizedText(
                                                  ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.ifscCode ?? ''}',
                                                )),
                                              ],
                                            ),
                                            pw.SizedBox(height: 4),
                                            pw.Row(
                                              children: [
                                                pw.Expanded(
                                                    child: localizedText(
                                                  _lang.holderName,
                                                )),
                                                pw.Expanded(
                                                    child: localizedText(
                                                  ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.holderName ?? ''}',
                                                )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${_lang.subTotal}: ${getTotalForOldInvoice().toStringAsFixed(2)}",
                              bold: true,
                            ),

                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${personalInformation.data?.vatName ?? _lang.vat}: ${((transactions.vatAmount ?? 0) + getTotalVatAmountForOldInvoice()).toStringAsFixed(2)}",
                              bold: true,
                            ),
                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${_lang.shippingCharge}: ${((transactions.shippingCharge ?? 0)).toStringAsFixed(2)}",
                              bold: true,
                            ),
                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${_lang.discount}: ${((transactions.discountAmount ?? 0) + getReturndDiscountAmount()).toStringAsFixed(2)}",
                              bold: true,
                            ),

                            pw.SizedBox(height: 5.0),

                            localizedText(
                              "${_lang.totalAmount}: ${((transactions.totalAmount ?? 0) + getTotalReturndAmount()).toStringAsFixed(2)}",
                              bold: true,
                            ),
                            // Payment summary for non-return invoices
                            if (transactions.purchaseReturns == null || transactions.purchaseReturns!.isEmpty)
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                    "${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}",
                                    bold: true,
                                  ),
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                    "${_lang.paidAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}",
                                    bold: true,
                                  ),
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                      (transactions.dueAmount ?? 0) > 0
                                          ? "${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}"
                                          : (transactions.changeAmount ?? 0) > 0
                                              ? "${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}"
                                              : '',
                                      bold: true),
                                  // pw.SizedBox(height: 10.0),
                                ],
                              ),
                          ]),
                    ]),
                (transactions.purchaseReturns != null && transactions.purchaseReturns!.isNotEmpty)
                    ? pw.Container(height: 10)
                    : pw.Container(),

                ///-----return_table-----
                (transactions.purchaseReturns != null && transactions.purchaseReturns!.isNotEmpty)
                    ? pw.Column(children: [
                        // Returns table with RTL support
                        pw.Table(
                          border: pw.TableBorder(
                            horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            top: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                            bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                          ),
                          columnWidths: RtlTableHelper.reverseColumnWidths({
                            0: const pw.FlexColumnWidth(1),
                            1: const pw.FlexColumnWidth(3),
                            2: const pw.FlexColumnWidth(4),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                          }, isRTL: isRTL),
                          children: [
                            // Table header with RTL support
                            RtlTableHelper.createRow(
                              isRTL: isRTL,
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: localizedText(
                                    _lang.sl,
                                    bold: true,
                                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: localizedText(
                                    _lang.date,
                                    bold: true,
                                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: localizedText(
                                    _lang.returnedItem,
                                    bold: true,
                                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: localizedText(
                                    _lang.quantity,
                                    bold: true,
                                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: localizedText(
                                    _lang.totalReturned,
                                    bold: true,
                                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                                  ),
                                ),
                              ],
                            ),
                            // Table rows with RTL support
                            for (int i = 0; i < (transactions.purchaseReturns?.length ?? 0); i++)
                              for (int j = 0;
                                  j < (transactions.purchaseReturns?[i].purchaseReturnDetails?.length ?? 0);
                                  j++)
                                RtlTableHelper.createRow(
                                  isRTL: isRTL,
                                  decoration: PDFCommonFunctions().serialNumber.isOdd
                                      ? const pw.BoxDecoration(
                                          color: PdfColors.white,
                                        ) // Odd row color
                                      : const pw.BoxDecoration(
                                          color: PdfColors.blue50,
                                        ),
                                  children: [
                                    //serial number
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: localizedText(
                                        '${PDFCommonFunctions().serialNumber++}',
                                        alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                      ),
                                    ),
                                    //Date
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: localizedText(
                                        DateFormat.yMMMd().format(DateTime.parse(
                                          transactions.purchaseReturns?[i].returnDate ?? '0',
                                        )),
                                        alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                      ),
                                    ),
                                    //Total return
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                                        localizedText(
                                          productName(
                                              detailsId: transactions
                                                      .purchaseReturns?[i].purchaseReturnDetails?[j].purchaseDetailId ??
                                                  0),
                                          alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                        ),
                                        // -------------- Added Serial Number Display Here -----------------
                                        if (transactions.purchaseReturns![i].purchaseReturnDetails![i].serialNumbers !=
                                                null &&
                                            transactions.purchaseReturns![i].purchaseReturnDetails![i].serialNumbers!
                                                .isNotEmpty)
                                          localizedText(
                                            '${_lang.serial}: ${transactions.purchaseReturns![i].purchaseReturnDetails![i].serialNumbers!.join(", ")}',
                                            alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                          ),
                                        // -----------------------------------------------------------------
                                      ]),
                                    ),
                                    //Quantity
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: localizedText(
                                        transactions.purchaseReturns?[i].purchaseReturnDetails?[j].returnQty
                                                ?.toString() ??
                                            '0',
                                        alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                                      ),
                                    ),
                                    //Total Return
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: localizedText(
                                        transactions.purchaseReturns?[i].purchaseReturnDetails?[j].returnAmount
                                                ?.toStringAsFixed(2) ??
                                            '0',
                                        alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ])
                    : pw.SizedBox.shrink(),
                // Payment information below returns table (ONLY when there ARE returns)
                if (transactions.purchaseReturns != null && transactions.purchaseReturns!.isNotEmpty)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left column - Payment information (ONLY when there ARE returns)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 12),
                            // Amount in words
                            pw.SizedBox(
                              width: 350,
                              child: localizedText(
                                locale == 'ar'
                                    ? numberToArabicWords(transactions.totalAmount?.toInt() ?? 0)
                                    : PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0),
                                bold: true,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            // Paid via
                            pw.Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                localizedText(
                                  '${_lang.paidVia} :',
                                  bold: true,
                                ),
                                ...?transactions.transactions?.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  String label;
                                  switch (item.transactionType) {
                                    case 'cash_payment':
                                      label = _lang.cash;
                                      break;
                                    case 'cheque_payment':
                                      label = _lang.cheque;
                                      break;
                                    case 'wallet_payment':
                                      label = _lang.wallet;
                                      break;
                                    default:
                                      label = item.paymentType?.name ?? 'n/a';
                                  }

                                  final isLast = index == transactions.transactions!.length - 1;
                                  final text = isLast ? label : '$label,';

                                  return localizedText(
                                    text,
                                    bold: true,
                                  );
                                }),
                              ],
                            ),
                            pw.SizedBox(height: 10),
                            if ((!personalInformation.data!.invoiceNote.isEmptyOrNull ||
                                    !personalInformation.data!.invoiceNoteLevel.isEmptyOrNull) &&
                                personalInformation.data!.showNote == 1)
                              pw.Row(children: [
                                localizedText('${personalInformation.data?.invoiceNoteLevel ?? ''}: ', bold: true),
                                localizedText(
                                  personalInformation.data?.invoiceNote ?? '',
                                )
                              ]),
                            // pw.RichText(
                            //     text: pw.TextSpan(
                            //         text: '${personalInformation.data?.invoiceNoteLevel ?? ''}: ',
                            //         style: pw.TextStyle(
                            //           font: getFont(bold: true),
                            //         ),
                            //         children: [
                            //       pw.TextSpan(
                            //           text: personalInformation.data?.invoiceNote ?? '',
                            //           style: pw.TextStyle(
                            //             font: getFont(bold: true),
                            //           ))
                            //     ])),

                            pw.SizedBox(height: 10),

                            if (latestBankTransaction != null)
                              pw.Container(
                                width: 256,
                                height: 120,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.black),
                                ),
                                child: pw.Column(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: localizedText(
                                        _lang.bankDetails,
                                      ),
                                    ),
                                    pw.Divider(color: PdfColors.black, height: 1),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: pw.Column(
                                        children: [
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                  child: localizedText(
                                                _lang.name,
                                              )),
                                              pw.Expanded(
                                                  child: localizedText(
                                                      ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.bankName ?? ''}')),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                  child: localizedText(
                                                _lang.accountNumber,
                                              )),
                                              pw.Expanded(
                                                  child: localizedText(
                                                ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.accountNumber ?? ''}',
                                              )),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                  child: localizedText(
                                                _lang.ifscCode,
                                              )),
                                              pw.Expanded(
                                                  child: localizedText(
                                                ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.ifscCode ?? ''}',
                                              )),
                                            ],
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(
                                                  child: localizedText(
                                                _lang.holderName,
                                              )),
                                              pw.Expanded(
                                                  child: localizedText(
                                                ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.holderName ?? ''}',
                                              )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Right column - Return amount summary
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.SizedBox(height: 10.0),
                          pw.Row(children: [
                            localizedText('${_lang.totalReturnAmount}: ', bold: true),
                            localizedText(formatPointNumber(getTotalReturndAmount())),
                          ]),
                          // pw.RichText(
                          //   text: pw.TextSpan(
                          //     text: '${_lang.totalReturnAmount}: ',
                          //     style: pw.TextStyle(
                          //       color: PdfColors.black,
                          //       font: getFont(bold: true),
                          //       fontFallback: [englishFont],
                          //       fontWeight: pw.FontWeight.bold,
                          //     ),
                          //     children: [
                          //       pw.TextSpan(
                          //         text: formatPointNumber(getTotalReturndAmount()),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          pw.SizedBox(height: 5.0),
                          localizedText(
                            "${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}",
                            bold: true,
                          ),
                          pw.SizedBox(height: 5.0),
                          localizedText(
                            "${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}",
                            bold: true,
                          ),
                          pw.SizedBox(height: 5.0),
                          localizedText(
                            (transactions.dueAmount ?? 0) > 0
                                ? "${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}"
                                : (transactions.changeAmount ?? 0) > 0
                                    ? "${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}"
                                    : '',
                            bold: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                pw.SizedBox(height: 10.0),
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

                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );
    EasyLoading.showSuccess('Pdf Generate Successfully');
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
        invoice: transactions.invoiceNumber ?? '',
        doc: doc,
        isShare: isShare,
        download: download,
      );
    }
  }
}
