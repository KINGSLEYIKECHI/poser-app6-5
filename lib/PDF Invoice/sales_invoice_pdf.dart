import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_text.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/PDF%20Invoice/universal_image_widget.dart';
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
import 'arabic_fonts.dart';
import 'check_rtl.dart';
import 'convert_number_arabic.dart';
import 'pdf_common_functions.dart';

/// ----------------------------------------------------------------------------
/// PDF Generator for Sales Invoices
/// ----------------------------------------------------------------------------
class SaleInvoicePdf {
  /// Generates, displays, or downloads a Sale Invoice in PDF format.
  static Future<void> generateSaleDocument(
    SalesTransactionModel transactions,
    BusinessInformationModel personalInformation,
    BuildContext context, {
    bool? share,
    bool? download,
    bool? showPreview,
  }) async {
    final pw.Document doc = pw.Document();
    final _lang = l.S.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // --- Helper Functions for Calculations ---

    /// Calculates the total monetary amount of all returned products.
    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    /// Fetches the unit price of a specific product using its detail ID.
    num productPrice({required num detailsId}) {
      return transactions.salesDetails!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    /// Calculates the total discount amount that was applied to returned products.
    num returnedDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              final originalPrice = productPrice(detailsId: details.saleDetailId ?? 0);
              final returnQty = details.returnQty ?? 0;
              final returnAmount = details.returnAmount ?? 0;
              totalReturnDiscount += ((originalPrice * returnQty) - returnAmount);
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    /// Calculates the total subtotal of the invoice before tax, considering discounts.
    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in transactions.salesDetails!) {
        final qty = PDFCommonFunctions().getProductQuantity(
          detailsId: element.id ?? 0,
          transactions: transactions,
        );
        total += ((element.price ?? 0) * qty) - ((element.discount ?? 0) * qty);
      }
      return total;
    }

    /// Constructs the product name, appending the batch/variant number if applicable.
    String productName({required num detailsId}) {
      final details = transactions.salesDetails?.firstWhere(
        (element) => element.id == detailsId,
      );
      final isVariant = details?.product?.productType == ProductType.variant.name;
      final batchInfo = isVariant ? ' [${details?.stock?.batchNo ?? ""}]' : '';
      return "${details?.product?.productName}$batchInfo";
    }

    /// Calculates the total amount for the invoice excluding VAT/Tax.
    num getTotalForOldInvoiceWithoutTax() {
      num total = 0;
      for (var element in transactions.salesDetails!) {
        final qty = PDFCommonFunctions().getProductQuantity(
          detailsId: element.id ?? 0,
          transactions: transactions,
        );
        total += ((element.priceWithoutTax ?? 0) * qty);
      }
      return total;
    }

    /// Calculates the total VAT amount across all products.
    num getTotalForOldInvoiceVat() {
      num total = 0;
      for (var element in transactions.salesDetails!) {
        final qty = PDFCommonFunctions().getProductQuantity(
          detailsId: element.id ?? 0,
          transactions: transactions,
        );
        final priceAfterDiscount = (element.price ?? 0) - (element.discount ?? 0);
        final priceWithoutTax = element.priceWithoutTax ?? 0;

        total += (priceAfterDiscount * qty) - (priceWithoutTax * qty);
      }
      return total;
    }

    // --- Image & Font Loading ---

    final String imageUrl =
        (personalInformation.data?.showA4InvoiceLogo == 1) ? personalInformation.data?.a4InvoiceLogo ?? '' : '';

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
      return ['ar', 'ur', 'fa', 'he'].contains(localeCode);
    }

    /// Custom widget to render localized text, automatically handling RTL and specific fonts.
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
            fontFallback: [englishFont, banglaFont],
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
            fontFallback: [arabicFonts, hebrewFonts, englishFont],
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

    // --- UI State Variables ---

    final bool isRTL = isCheckRtl(context);
    final hasWarranty = transactions.salesDetails!.any((e) => e.warrantyInfo?.warrantyDuration != null);
    final hasGuarantee = transactions.salesDetails!.any((e) => e.warrantyInfo?.guaranteeDuration != null);
    final bankTransactions =
        transactions.transactions?.where((t) => t.transactionType == 'bank_payment').toList() ?? [];
    final latestBankTransaction = bankTransactions.isNotEmpty ? bankTransactions.last : null;
    final showWarranty = personalInformation.data?.showWarranty == 1 &&
        (personalInformation.data?.warrantyVoidLabel != null || personalInformation.data?.warrantyVoid != null);

    // --- Build PDF Document ---

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.zero,
        crossAxisAlignment: pw.CrossAxisAlignment.start,

        // ------------- HEADER -------------
        header: (pw.Context context) {
          return pw.Directionality(
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20.0),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Company Logo
                      pw.Container(
                        height: 54.12,
                        width: 200,
                        child: universalImage(imageData, w: 200, h: 54.12),
                      ),
                      // Company Contact Details
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
                          if (personalInformation.data?.meta?.showVat == 1 && personalInformation.data?.vatNo != null)
                            localizedText(
                              '${personalInformation.data?.vatName ?? _lang.vat}: ${personalInformation.data?.vatNo ?? ''}',
                              alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                            ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16.0),

                  // Invoice Title Badge
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(20),
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: localizedText(_lang.INVOICE, size: 18, bold: true),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Customer & Invoice Metadata Row
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Customer Details Column
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 60.0,
                                child: localizedText(_lang.customer,
                                    alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 100.0,
                                child: localizedText(transactions.party?.name ?? '',
                                    alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 60.0,
                                child: localizedText(_lang.address,
                                    alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 150.0,
                                child: localizedText(transactions.party?.address ?? 'N/A',
                                    alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 60.0,
                                child: localizedText(_lang.mobile,
                                    alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 100.0,
                                child: localizedText(transactions.party?.phone ?? 'N/A',
                                    alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                              ),
                            ],
                          ),
                          if (personalInformation.data?.showNote == 1)
                            pw.Row(
                              children: [
                                pw.SizedBox(
                                  width: 60.0,
                                  child: localizedText(_lang.remark,
                                      alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                                ),
                                pw.SizedBox(
                                  width: 10.0,
                                  child: pw.Text(':',
                                      style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                                ),
                                pw.SizedBox(
                                  width: 100.0,
                                  child: localizedText(transactions.meta?.note ?? 'N/A',
                                      alignment: isRTL ? pw.TextAlign.end : pw.TextAlign.start),
                                ),
                              ],
                            ),
                        ],
                      ),

                      // Invoice Details Column
                      pw.Column(
                        children: [
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: localizedText(_lang.invoiceNumber, alignment: pw.TextAlign.start),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 75.0,
                                child: localizedText('#${transactions.invoiceNumber}', alignment: pw.TextAlign.start),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: localizedText(_lang.date, alignment: pw.TextAlign.start),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 75.0,
                                child: localizedText(
                                    DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.saleDate ?? ''))),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: localizedText(_lang.time),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 75.0,
                                child:
                                    localizedText(DateFormat('hh:mm a').format(DateTime.parse(transactions.saleDate!))),
                              ),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.SizedBox(
                                width: 100.0,
                                child: localizedText(_lang.sellsBy),
                              ),
                              pw.SizedBox(
                                width: 10.0,
                                child: pw.Text(':',
                                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black)),
                              ),
                              pw.SizedBox(
                                width: 75.0,
                                child: localizedText(
                                  transactions.user?.role == "shop-owner" ? _lang.admin : transactions.user?.name ?? '',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },

        // ------------- FOOTER -------------
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(10.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Customer Signature Line
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                      padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                      child: pw.Column(
                        children: [
                          pw.Container(width: 120.0, height: 2.0, color: PdfColors.black),
                          pw.SizedBox(height: 4.0),
                          localizedText(_lang.customerSignature),
                        ],
                      ),
                    ),
                    // Authorized Signature Line
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                      padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                      child: pw.Column(
                        children: [
                          pw.Container(width: 120.0, height: 2.0, color: PdfColors.black),
                          pw.SizedBox(height: 4.0),
                          localizedText(_lang.authorizedSignature),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Warranty Disclaimers
              if (showWarranty)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black),
                    ),
                    child: pw.Row(
                      children: [
                        if (personalInformation.data?.warrantyVoidLabel != null)
                          localizedText('${personalInformation.data!.warrantyVoidLabel!}- ', bold: true),
                        if (personalInformation.data?.warrantyVoid != null)
                          localizedText(personalInformation.data!.warrantyVoid!, bold: true),
                      ],
                    ),
                  ),
                ),
              pw.SizedBox(height: 10),
              // Developed By Credits
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                child: pw.Center(
                  child: localizedText(
                    '${personalInformation.data?.developByLevel ?? ''} ${personalInformation.data?.developBy ?? ''}',
                  ),
                ),
              ),
            ],
          );
        },

        // ------------- MAIN BODY -------------
        build: (pw.Context context) => <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: pw.Column(
              children: [
                // --- Products Table ---
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
                    1: pw.FlexColumnWidth(hasGuarantee && !hasWarranty ? 6 : 3),
                    2: pw.FlexColumnWidth(hasGuarantee && !hasWarranty ? 0 : 2),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                    5: const pw.FlexColumnWidth(2),
                  }, isRTL: isRTL),
                  children: [
                    // Table Header Row
                    RtlTableHelper.createRow(
                      isRTL: isRTL,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(_lang.sl,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL), bold: true),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(_lang.item,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL), bold: true),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(_lang.quantity,
                              bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL)),
                        ),
                        if (hasWarranty)
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(_lang.warranty,
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL), bold: true),
                          ),
                        if (hasGuarantee)
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(_lang.guarantee,
                                bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL)),
                          ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(_lang.unitPrice,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL), bold: true),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(_lang.discount,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL), bold: true),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText('Price (Exc.)',
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL), bold: true),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: localizedText(_lang.totalPrice,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL), bold: true),
                        ),
                      ],
                    ),

                    // Table Data Rows
                    for (int i = 0; i < transactions.salesDetails!.length; i++)
                      RtlTableHelper.createRow(
                        isRTL: isRTL,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text('${i + 1}',
                                textAlign: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Column(
                              crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                              children: [
                                localizedText(
                                  productName(detailsId: transactions.salesDetails![i].id ?? 0),
                                  alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                ),
                                // Serial Numbers Display
                                if (transactions.salesDetails![i].serialNumbers != null &&
                                    transactions.salesDetails![i].serialNumbers!.isNotEmpty)
                                  localizedText(
                                    '${_lang.serial}: ${transactions.salesDetails![i].serialNumbers!.join(", ")}',
                                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                  ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              formatPointNumber(
                                PDFCommonFunctions().getProductQuantity(
                                  detailsId: transactions.salesDetails![i].id ?? 0,
                                  transactions: transactions,
                                ),
                              ),
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                            ),
                          ),
                          if (hasWarranty)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: localizedText(
                                '${transactions.salesDetails![i].warrantyInfo?.warrantyDuration ?? ''} ${transactions.salesDetails![i].warrantyInfo?.warrantyUnit ?? ''}',
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                              ),
                            ),
                          if (hasGuarantee)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8.0),
                              child: localizedText(
                                '${transactions.salesDetails![i].warrantyInfo?.guaranteeDuration ?? ''} ${transactions.salesDetails![i].warrantyInfo?.guaranteeUnit ?? ''}',
                                alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                              ),
                            ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              formatPointNumber(transactions.salesDetails!.elementAt(i).price ?? 0),
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              formatPointNumber(transactions.salesDetails!.elementAt(i).discount ?? 0),
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              formatPointNumber(transactions.salesDetails!.elementAt(i).priceWithoutTax ??
                                  transactions.salesDetails!.elementAt(i).price ??
                                  0),
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              formatPointNumber(
                                ((transactions.salesDetails![i].price ?? 0) *
                                        (PDFCommonFunctions().getProductQuantity(
                                          detailsId: transactions.salesDetails![i].id ?? 0,
                                          transactions: transactions,
                                        ))) -
                                    ((transactions.salesDetails![i].discount ?? 0) *
                                        (PDFCommonFunctions().getProductQuantity(
                                          detailsId: transactions.salesDetails![i].id ?? 0,
                                          transactions: transactions,
                                        ))),
                              ),
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // --- Payment Info & Amount Calculations Row ---
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left Column: Payment information (Visible ONLY when there are NO returns)
                    if (transactions.salesReturns != null || transactions.salesReturns!.isNotEmpty) pw.SizedBox(),
                    if (transactions.salesReturns == null || transactions.salesReturns!.isEmpty)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 22),
                            // Amount written in words
                            pw.SizedBox(
                              width: 350,
                              child: localizedText(
                                locale == 'ar'
                                    ? numberToArabicWords(transactions.totalAmount?.toInt() ?? 0)
                                    : PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0),
                                bold: true,
                              ),
                            ),
                            pw.SizedBox(height: 18),
                            // Payment Methods Display
                            pw.Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                localizedText('${_lang.paidVia} :', bold: true),
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
                                  return localizedText(text, bold: true);
                                }),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            // Invoice Notes
                            if ((!personalInformation.data!.invoiceNote.isEmptyOrNull ||
                                    !personalInformation.data!.invoiceNoteLevel.isEmptyOrNull) &&
                                personalInformation.data!.showNote == 1)
                              pw.Row(
                                children: [
                                  localizedText('${personalInformation.data?.invoiceNoteLevel ?? ''}: ', bold: true),
                                  localizedText(personalInformation.data?.invoiceNote ?? ''),
                                ],
                              ),
                            pw.SizedBox(height: 12),

                            // Bank Details Box
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
                                      child: localizedText(_lang.bankDetails, bold: true),
                                    ),
                                    pw.Divider(color: PdfColors.black, height: 1),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: pw.Column(
                                        children: [
                                          pw.Row(
                                            children: [
                                              pw.Expanded(child: localizedText(_lang.name)),
                                              pw.Expanded(
                                                  child: localizedText(
                                                      ': ${latestBankTransaction.paymentType?.name ?? ''}')),
                                            ],
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(child: localizedText(_lang.accountNumber)),
                                              pw.Expanded(
                                                  child: localizedText(
                                                      ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.accountNumber ?? ''}')),
                                            ],
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(child: localizedText(_lang.ifscCode)),
                                              pw.Expanded(
                                                  child: localizedText(
                                                      ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.ifscCode ?? ''}')),
                                            ],
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Row(
                                            children: [
                                              pw.Expanded(child: localizedText(_lang.holderName)),
                                              pw.Expanded(
                                                  child: localizedText(
                                                      ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.holderName ?? ''}')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            pw.SizedBox(height: 12),
                            // Gratitude message
                            if (latestBankTransaction != null &&
                                !personalInformation.data!.gratitudeMessage.isEmptyOrNull)
                              pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.only(bottom: 8.0),
                                child: pw.Center(
                                  child: pw.Text(personalInformation.data!.gratitudeMessage ?? ''),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Right Column: Summary Calculations (ALWAYS visible)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(height: 10.0),
                        localizedText("${_lang.subTotal}: ${formatPointNumber(getTotalForOldInvoice())}", bold: true),
                        pw.SizedBox(height: 5.0),
                        localizedText(
                            "${personalInformation.data?.vatName ?? _lang.vat}: ${formatPointNumber(getTotalForOldInvoiceVat() + (transactions.vatAmount ?? 0.00))}",
                            bold: true),
                        pw.SizedBox(height: 5.0),
                        localizedText(
                            "${_lang.shippingCharge}: ${formatPointNumber((transactions.shippingCharge ?? 0))}",
                            bold: true),
                        pw.SizedBox(height: 5.0),
                        pw.Container(
                          width: 100,
                          padding: const pw.EdgeInsets.only(bottom: 5),
                          alignment: pw.AlignmentDirectional.centerEnd,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
                          ),
                          child: localizedText(
                              "${_lang.discount}: ${formatPointNumber((transactions.discountAmount ?? 0) + returnedDiscountAmount())}",
                              bold: true),
                        ),
                        pw.SizedBox(height: 5.0),

                        // Rounding Display
                        if (transactions.roundingAmount != 0)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              localizedText(
                                  "${_lang.amount}: ${formatPointNumber((transactions.actualTotalAmount ?? 0))}",
                                  bold: true),
                              pw.SizedBox(height: 5.0),
                              localizedText(
                                  "${_lang.rounding}: ${!(transactions.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber((transactions.roundingAmount ?? 0))}",
                                  bold: true),
                              pw.SizedBox(height: 5.0),
                            ],
                          ),

                        localizedText(
                            "${_lang.totalAmount}: ${formatPointNumber((transactions.totalAmount ?? 0) + getTotalReturndAmount())}",
                            bold: true),

                        // Payment breakdown summary for non-returned invoices
                        if (transactions.salesReturns == null || transactions.salesReturns!.isEmpty)
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                      "${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}",
                                      bold: true),
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                      "${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}",
                                      bold: true),
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                    (transactions.dueAmount ?? 0) > 0
                                        ? "${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}"
                                        : (transactions.changeAmount ?? 0) > 0
                                            ? "${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}"
                                            : '',
                                    bold: true,
                                  ),
                                  pw.SizedBox(height: 10.0),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),

                // --- Returns Section ---
                if (transactions.salesReturns != null && transactions.salesReturns!.isNotEmpty)
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 20),
                      // Returns Table
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
                          // Returns Header
                          RtlTableHelper.createRow(
                            isRTL: isRTL,
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: localizedText(_lang.sl,
                                    bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: localizedText(_lang.date,
                                    bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: localizedText(_lang.returnedItem,
                                    bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.left, isRTL)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: localizedText(_lang.quantity,
                                    bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: localizedText(_lang.totalReturned,
                                    bold: true, alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.end, isRTL)),
                              ),
                            ],
                          ),
                          // Returns Data Rows
                          for (int i = 0; i < (transactions.salesReturns?.length ?? 0); i++)
                            for (int j = 0; j < (transactions.salesReturns?[i].salesReturnDetails?.length ?? 0); j++)
                              RtlTableHelper.createRow(
                                isRTL: isRTL,
                                decoration: (transactions.salesReturns?.length ?? 0) > 0 && i % 2 == 0
                                    ? const pw.BoxDecoration(color: PdfColors.white)
                                    : const pw.BoxDecoration(color: PdfColors.blue50),
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8.0),
                                    child: localizedText(
                                      '${(i * (transactions.salesReturns?[i].salesReturnDetails?.length ?? 0)) + j + 1}',
                                      alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8.0),
                                    child: localizedText(
                                      DateFormat.yMMMd()
                                          .format(DateTime.parse(transactions.salesReturns?[i].returnDate ?? '0')),
                                      alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8.0),
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        localizedText(
                                          productName(
                                              detailsId:
                                                  transactions.salesReturns?[i].salesReturnDetails?[j].saleDetailId ??
                                                      0),
                                          alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                        ),
                                        if (transactions.salesReturns![i].salesReturnDetails![j].serialNumbers !=
                                                null &&
                                            transactions
                                                .salesReturns![i].salesReturnDetails![j].serialNumbers!.isNotEmpty)
                                          localizedText(
                                            '${_lang.serial}: ${transactions.salesReturns![i].salesReturnDetails![j].serialNumbers!.join(", ")}',
                                            alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                                          ),
                                      ],
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8.0),
                                    child: localizedText(
                                      formatPointNumber(
                                          transactions.salesReturns?[i].salesReturnDetails?[j].returnQty ?? 0),
                                      alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.center, isRTL),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8.0),
                                    child: localizedText(
                                      formatPointNumber(
                                          transactions.salesReturns?[i].salesReturnDetails?[j].returnAmount ?? 0),
                                      alignment: pw.TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),

                      // Payment information BELOW returns table (Displayed ONLY when there ARE returns)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Left Column: Returned Invoice Payment Info
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.SizedBox(height: 22),
                                pw.SizedBox(
                                  width: 350,
                                  child: localizedText(
                                    locale == 'ar'
                                        ? numberToArabicWords(transactions.totalAmount?.toInt() ?? 0)
                                        : PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0),
                                    bold: true,
                                  ),
                                ),
                                pw.SizedBox(height: 18),
                                pw.Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    localizedText('${_lang.paidVia} :', bold: true),
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
                                      return localizedText(text, bold: true);
                                    }),
                                  ],
                                ),
                                pw.SizedBox(height: 12),
                                if ((!personalInformation.data!.invoiceNote.isEmptyOrNull ||
                                        !personalInformation.data!.invoiceNoteLevel.isEmptyOrNull) &&
                                    personalInformation.data!.showNote == 1)
                                  pw.Row(
                                    children: [
                                      localizedText('${personalInformation.data?.invoiceNoteLevel ?? ''}: ',
                                          bold: true),
                                      localizedText(personalInformation.data?.invoiceNote ?? ''),
                                    ],
                                  ),
                                pw.SizedBox(height: 12),

                                // Bank Details Box (If applicable)
                                if (transactions.transactions != null &&
                                    transactions.transactions!.isNotEmpty &&
                                    transactions.transactions!.any((t) => t.transactionType == 'bank_payment'))
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
                                          child: localizedText(_lang.bankDetails),
                                        ),
                                        pw.Divider(color: PdfColors.black, height: 1),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: pw.Column(
                                            children: [
                                              pw.Row(
                                                children: [
                                                  pw.Expanded(child: localizedText(_lang.name)),
                                                  pw.Expanded(
                                                      child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.bankName ?? ''}')),
                                                ],
                                              ),
                                              pw.Row(
                                                children: [
                                                  pw.Expanded(child: localizedText(_lang.accountNumber)),
                                                  pw.Expanded(
                                                      child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.accountNumber ?? ''}')),
                                                ],
                                              ),
                                              pw.Row(
                                                children: [
                                                  pw.Expanded(child: localizedText(_lang.ifscCode)),
                                                  pw.Expanded(
                                                      child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.ifscCode ?? ''}')),
                                                ],
                                              ),
                                              pw.Row(
                                                children: [
                                                  pw.Expanded(child: localizedText(_lang.holderName)),
                                                  pw.Expanded(
                                                      child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.holderName ?? ''}')),
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

                          // Right Column: Return Calculations
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.SizedBox(height: 10.0),
                              pw.Row(
                                children: [
                                  localizedText('${_lang.totalReturnAmount}: ', bold: true),
                                  localizedText(formatPointNumber(getTotalReturndAmount())),
                                ],
                              ),
                              pw.SizedBox(height: 5.0),
                              localizedText(
                                  "${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}",
                                  bold: true),
                              pw.SizedBox(height: 5.0),
                              localizedText(
                                  "${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}",
                                  bold: true),
                              pw.SizedBox(height: 5.0),
                              localizedText(
                                (transactions.dueAmount ?? 0) > 0
                                    ? "${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}"
                                    : (transactions.changeAmount ?? 0) > 0
                                        ? "${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}"
                                        : '',
                                bold: true,
                              ),
                              pw.SizedBox(height: 10.0),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                // --- Final Invoice Gratitude ---
                pw.SizedBox(height: 20.0),
                if (personalInformation.data?.showGratitudeMsg == 1 &&
                    !personalInformation.data!.gratitudeMessage.isEmptyOrNull)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.only(bottom: 8.0),
                    child: pw.Center(
                      child: pw.Text(personalInformation.data!.gratitudeMessage ?? ''),
                    ),
                  ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ],
            ),
          ),
        ],
      ),
    );

    // Render Preview or Save/Share based on parameters
    if (showPreview == true) {
      await Printing.layoutPdf(
        name: personalInformation.data?.companyName ?? '',
        usePrinterSettings: true,
        dynamicLayout: true,
        forceCustomPrintPaper: true,
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } else {
      await PDFCommonFunctions.savePdfAndShowPdf(
        context: context,
        shopName: personalInformation.data?.companyName ?? '',
        invoice: transactions.invoiceNumber ?? '',
        doc: doc,
        isShare: share,
        download: download,
      );
    }
  }
}

// --- Small PDF Table Helper Widgets ---

pw.Widget headerCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    ),
  );
}

pw.Widget cell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 10),
    ),
  );
}

/// ----------------------------------------------------------------------------
/// Excel Generator for Sales Invoices
/// ----------------------------------------------------------------------------
class SalesInvoiceExcel {
  /// Generates and exports a Sale Invoice in Excel (.xlsx) format.
  static Future<void> generateSaleDocument(
    SalesTransactionModel transactions,
    BusinessInformationModel personalInformation,
    BuildContext context, {
    bool? share,
    bool? download,
  }) async {
    final _lang = l.S.of(context);
    final hasWarranty = transactions.salesDetails!.any((e) => e.warrantyInfo?.warrantyDuration != null);
    final hasGuarantee = transactions.salesDetails!.any((e) => e.warrantyInfo?.guaranteeDuration != null);

    // --- Helper Functions for Calculations ---

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num productPrice({required num detailsId}) {
      return transactions.salesDetails!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    num returnedDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.salesReturns?.isNotEmpty ?? false) {
        for (var returns in transactions.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturnDiscount += ((productPrice(detailsId: details.saleDetailId ?? 0) * (details.returnQty ?? 0)) -
                  ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    /// Calculates subtotal excluding discounts per item.
    /// Note: An older standard implementation is kept commented out for reference.
    // num getTotalForOldInvoice() {
    //    num total = 0;
    //    for (var element in transactions.salesDetails!) {
    //      total += (element.price ?? 0) * PDFCommonFunctions().getProductQuantity(detailsId: element.id ?? 0, transactions: transactions);
    //    }
    //    return total;
    // }
    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in transactions.salesDetails!) {
        final qty = PDFCommonFunctions().getProductQuantity(detailsId: element.id ?? 0, transactions: transactions);
        total += ((element.price ?? 0) * qty) - ((element.discount ?? 0) * qty);
      }
      return total;
    }

    String productName({required num detailsId}) {
      return transactions.salesDetails?[transactions.salesDetails!.indexWhere((element) => element.id == detailsId)]
              .product?.productName ??
          '';
    }

    // --- Excel Creation ---

    final excel = Excel.createExcel();
    final sheet = excel['Sales Invoice'];

    // 1. Company Information Block
    if (personalInformation.data?.meta?.showCompanyName == 1) {
      sheet.appendRow([TextCellValue('Company: ${personalInformation.data?.companyName ?? ''}')]);
    }
    if (personalInformation.data?.meta?.showPhoneNumber == 1) {
      sheet.appendRow([TextCellValue('Mobile: ${personalInformation.data?.phoneNumber ?? ''}')]);
    }
    sheet.appendRow([TextCellValue('Invoice: #${transactions.invoiceNumber}')]);
    sheet.appendRow(
        [TextCellValue('Date: ${DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.saleDate ?? ''))}')]);
    sheet.appendRow([]);

    // 2. Customer Information Block
    sheet.appendRow([TextCellValue('Bill To: ${transactions.party?.name ?? ''}')]);
    sheet.appendRow(
        [TextCellValue('Mobile: ${transactions.party?.phone ?? (transactions.meta?.customerPhone ?? _lang.guest)}')]);
    sheet.appendRow([]);

    // 3. Products Table Headers
    sheet.appendRow([
      TextCellValue(_lang.sl),
      TextCellValue(_lang.item),
      if (hasWarranty) TextCellValue('Warranty'),
      if (hasGuarantee) TextCellValue('Guaranty'),
      TextCellValue(_lang.quantity),
      TextCellValue(_lang.unitPrice),
      TextCellValue(_lang.discount),
      TextCellValue(_lang.totalPrice),
    ]);

    // 4. Products Data Rows
    for (int i = 0; i < transactions.salesDetails!.length; i++) {
      String pName = transactions.salesDetails![i].product?.productName ?? '';

      // Append serial numbers to product name
      if (transactions.salesDetails![i].serialNumbers != null &&
          transactions.salesDetails![i].serialNumbers!.isNotEmpty) {
        pName += '\nSerial: ${transactions.salesDetails![i].serialNumbers!.join(", ")}';
      }

      final qty = PDFCommonFunctions()
          .getProductQuantity(detailsId: transactions.salesDetails![i].id ?? 0, transactions: transactions);
      final price = transactions.salesDetails![i].price ?? 0;
      final discount = transactions.salesDetails![i].discount ?? 0;
      final totalPrice = (price * qty) - (discount * qty);

      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(pName),
        if (hasWarranty)
          TextCellValue(
              '${transactions.salesDetails![i].warrantyInfo?.warrantyDuration ?? ''} ${transactions.salesDetails![i].warrantyInfo?.warrantyUnit ?? ''}'),
        if (hasGuarantee)
          TextCellValue(
              '${transactions.salesDetails![i].warrantyInfo?.guaranteeDuration ?? ''} ${transactions.salesDetails![i].warrantyInfo?.guaranteeUnit ?? ''}'),
        TextCellValue(formatPointNumber(qty)),
        TextCellValue(formatPointNumber(price)),
        TextCellValue(formatPointNumber(discount)),
        TextCellValue(formatPointNumber(totalPrice)),
      ]);
    }

    sheet.appendRow([]);

    // 5. Amount Summaries
    sheet.appendRow([
      TextCellValue('${_lang.subTotal}:'),
      TextCellValue(formatPointNumber(getTotalForOldInvoice())),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.discount}:'),
      TextCellValue(formatPointNumber((transactions.discountAmount ?? 0) + returnedDiscountAmount())),
    ]);
    sheet.appendRow([
      TextCellValue('${transactions.vat?.name ?? _lang.vat}:'),
      TextCellValue(formatPointNumber(transactions.vatAmount ?? 0.00)),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.shippingCharge}:'),
      TextCellValue(formatPointNumber((transactions.shippingCharge ?? 0))),
    ]);

    if (transactions.roundingAmount != 0) {
      sheet.appendRow([
        TextCellValue('${_lang.amount}:'),
        TextCellValue(formatPointNumber((transactions.actualTotalAmount ?? 0))),
      ]);
      sheet.appendRow([
        TextCellValue('${_lang.rounding}:'),
        TextCellValue(
            '${!(transactions.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber((transactions.roundingAmount ?? 0))}'),
      ]);
    }

    sheet.appendRow([
      TextCellValue('${_lang.totalAmount}:'),
      TextCellValue(formatPointNumber((transactions.totalAmount ?? 0) + getTotalReturndAmount())),
    ]);
    sheet.appendRow([]);

    // 6. Returns Data (If Any)
    if (transactions.salesReturns != null && transactions.salesReturns!.isNotEmpty) {
      sheet.appendRow([
        TextCellValue(_lang.sl),
        TextCellValue(_lang.date),
        TextCellValue(_lang.returnedItem),
        TextCellValue(_lang.quantity),
        TextCellValue(_lang.totalReturned),
      ]);

      int returnIndex = 1;
      for (int i = 0; i < transactions.salesReturns!.length; i++) {
        for (int j = 0; j < (transactions.salesReturns![i].salesReturnDetails?.length ?? 0); j++) {
          sheet.appendRow([
            TextCellValue('${returnIndex++}'),
            TextCellValue(DateFormat.yMMMd().format(DateTime.parse(transactions.salesReturns![i].returnDate ?? '0'))),
            TextCellValue(
                productName(detailsId: transactions.salesReturns![i].salesReturnDetails?[j].saleDetailId ?? 0)),
            TextCellValue(formatPointNumber(transactions.salesReturns![i].salesReturnDetails?[j].returnQty ?? 0)),
            TextCellValue(formatPointNumber(transactions.salesReturns![i].salesReturnDetails?[j].returnAmount ?? 0)),
          ]);
        }
      }

      sheet.appendRow([
        TextCellValue('${_lang.totalReturnAmount}:'),
        TextCellValue(formatPointNumber(getTotalReturndAmount())),
      ]);
      sheet.appendRow([]);
    }

    // 7. Payment Information
    sheet.appendRow([
      TextCellValue('${_lang.paidVia}: ${transactions.paymentType?.name ?? 'N/A'}'),
    ]);
    sheet.appendRow([
      TextCellValue('${_lang.payableAmount}: ${formatPointNumber(transactions.totalAmount ?? 0)}'),
    ]);
    sheet.appendRow([
      TextCellValue(
          '${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.dueAmount ?? 0)) + (transactions.changeAmount ?? 0))}'),
    ]);

    if ((transactions.dueAmount ?? 0) > 0) {
      sheet.appendRow([
        TextCellValue('${_lang.due}: ${formatPointNumber(transactions.dueAmount ?? 0)}'),
      ]);
    } else if ((transactions.changeAmount ?? 0) > 0) {
      sheet.appendRow([
        TextCellValue('${_lang.changeAmount}: ${formatPointNumber(transactions.changeAmount ?? 0)}'),
      ]);
    }

    sheet.appendRow([
      TextCellValue('${_lang.amountsInWord}: ${PDFCommonFunctions().numberToWords(transactions.totalAmount ?? 0)}'),
    ]);

    if (transactions.meta?.note?.isNotEmpty ?? false) {
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('${_lang.note}: ${(transactions.meta?.note ?? '')}'),
      ]);
    }

    // --- File Saving & Action Execution ---

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Sales_Invoice_${transactions.invoiceNumber}.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    // Open file locally
    await OpenFile.open(filePath);

    // Optionally trigger OS share sheet
    if (share == true) {
      await FilePicker.platform.saveFile(
        fileName: 'Sales_Invoice_${transactions.invoiceNumber}.xlsx',
      );
    }
  }
}
