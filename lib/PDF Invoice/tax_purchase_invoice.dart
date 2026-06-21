import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_pos/PDF%20Invoice/pdf_text.dart';
import 'package:mobile_pos/PDF%20Invoice/table_rtl_helper.dart';
import 'package:mobile_pos/PDF%20Invoice/universal_image_widget.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/model/purchase_tax_return_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/purchase_tax_model.dart';
import '../Screens/Products/add product/modle/create_product_model.dart';
import '../model/business_info_model.dart';
import 'arabic_fonts.dart';
import 'check_rtl.dart';
import 'convert_number_arabic.dart';
import 'pdf_common_functions.dart';

///-----------tax sale invoice pdf-------------------
class TaxPurchaseInvoicePdf {
  static Future<void> generateSaleDocument(
    TaxPurchaseData transactions,
    BusinessInformationModel personalInformation,
    BuildContext context, {
    bool? share,
    bool? download,
    bool? showPreview,
  }) async {
    final pw.Document doc = pw.Document();
    final _lang = l.S.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // FIXED: Safe null checking for return amounts
    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (transactions.purchaseReturn?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturn!) {
          if (returns.details.isNotEmpty) {
            for (var details in returns.details) {
              totalReturn += details.returnAmount;
            }
          }
        }
      }
      return totalReturn;
    }

    ///-------returned_discount_amount
    num productPrice({required num detailsId}) {
      try {
        final matchingDetail = transactions.purchase?.details?.where((element) => element.id == detailsId).firstOrNull;
        return matchingDetail?.productPurchasePrice ?? 0;
      } catch (e) {
        return 0;
      }
    }

    num returnedDiscountAmount() {
      num totalReturnDiscount = 0;
      if (transactions.purchaseReturn?.isNotEmpty ?? false) {
        for (var returns in transactions.purchaseReturn!) {
          if (returns.details.isNotEmpty) {
            for (var details in returns.details) {
              totalReturnDiscount +=
                  ((productPrice(detailsId: details.id) * (details.returnQty ?? 0)) - ((details.returnAmount ?? 0)));
            }
          }
        }
      }
      return totalReturnDiscount;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      if (transactions.purchase?.details?.isNotEmpty ?? false) {
        for (var element in transactions.purchase!.details!) {
          total += ((element.productPurchasePrice ?? 0) *
                  PDFCommonFunctions()
                      .getPurchaseTaxProductQuantity(detailsId: element.id?.toInt() ?? 0, transactions: transactions) -
              PDFCommonFunctions()
                  .getPurchaseTaxProductQuantity(detailsId: element.id ?? 0, transactions: transactions));
        }
      }
      return total;
    }

    num subtotal = 0;

    for (var item in transactions.purchase?.details ?? []) {
      subtotal += (item.priceWithoutTax ?? 0) * (item.quantities ?? 0);
    }

    num vatAmount = 0;

    for (final TaxListData item in (transactions.taxItems ?? [])) {
      vatAmount += item.vatAmount ?? 0;
    }

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
      return ['ar', 'ur', 'fa', 'he'].contains(localeCode);
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
            fontFallback: [englishFont, banglaFont],
          ),
        );
      }
      if (isRTLLanguage(localeCode)) {
        return pw.Text(
          fixArabic(text),
          textDirection: pw.TextDirection.ltr,
          textAlign: pw.TextAlign.right,
          maxLines: 2,
          overflow: pw.TextOverflow.visible,
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

    final bool isRTL = isCheckRtl(context);

    // FIXED: Safe bank transaction access
    final bankTransactions =
        transactions.purchase?.transactions?.where((t) => t.transactionType == 'bank_payment').toList() ?? [];
    final latestBankTransaction = bankTransactions.isNotEmpty ? bankTransactions.last : null;

    final showWarranty = personalInformation.data?.showWarranty == 1 &&
        (personalInformation.data?.warrantyVoidLabel != null || personalInformation.data?.warrantyVoid != null);

    ///------------Widget-------------------------
    //header widget
    pw.Padding _buildTableCell(String title, String? value) {
      final displayValue = value ?? '';
      return pw.Padding(
        padding: pw.EdgeInsets.all(10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            localizedText(title, bold: true),
            localizedText(displayValue, bold: true),
          ],
        ),
      );
    }

    // Helper function outside widget
    pw.TableRow _buildTableRow(String title1, String value1, String title2, String? dateOrValue2) {
      return pw.TableRow(
        children: [
          _buildTableCell(title1, value1),
          _buildTableCell(title2, dateOrValue2),
        ],
      );
    }

    //---------------table data----------------------
    pw.Padding _headerCell(String text, bool isRTL, {bool center = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: localizedText(
          text,
          alignment: RtlTableHelper.adjustAlignment(center ? pw.TextAlign.center : pw.TextAlign.start, isRTL),
          bold: true,
        ),
      );
    }

    pw.Padding _bodyCell(String text, bool isRTL, {bool center = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: localizedText(
          text,
          alignment: RtlTableHelper.adjustAlignment(center ? pw.TextAlign.center : pw.TextAlign.start, isRTL),
        ),
      );
    }

    pw.Table _taxHeader(String taxName) {
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black),
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: localizedText(taxName, alignment: pw.TextAlign.center, bold: true),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 40,
                    padding: pw.EdgeInsets.all(4),
                    alignment: pw.Alignment.center,
                    child: localizedText(_lang.rates, alignment: pw.TextAlign.center, bold: true),
                  ),
                  pw.Container(
                    width: 40,
                    padding: pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColors.black))),
                    alignment: pw.Alignment.center,
                    child: localizedText(_lang.amount, alignment: pw.TextAlign.center, bold: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    pw.Table _taxCell(String rate, String amount) {
      return pw.Table(
        border: pw.TableBorder(
          top: pw.BorderSide(color: PdfColors.black),
          left: pw.BorderSide(color: PdfColors.black),
          right: pw.BorderSide(color: PdfColors.black),
        ),
        children: [
          pw.TableRow(
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 40,
                    padding: pw.EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    alignment: pw.Alignment.center,
                    child: pw.Text(rate, textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    width: 40,
                    padding: pw.EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                    decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColors.black))),
                    alignment: pw.Alignment.center,
                    child: pw.Text(amount, textAlign: pw.TextAlign.center),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    pw.Column _itemCell(PurchaseDetails detail, bool isRTL) {
      return pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: pw.Column(children: [
                localizedText(
                  "${detail.product?.productName ?? ''}${detail.product?.productType == ProductType.variant.name ? ' [${detail.stock?.batchNo ?? ''}]' : ''}",
                  alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                ),
                // FIXED: Safe serial numbers check
                if (detail.serialNumbers != null && detail.serialNumbers!.isNotEmpty)
                  localizedText(
                    '${_lang.serial}: ${detail.serialNumbers!.join(", ")}',
                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                  ),
              ]))
        ],
      );
    }

    // FIXED: _returnedItemCell method - Changed saleDetail to purchaseDetail
    pw.Column _returnedItemCell(List<TaxPurchaseReturnDetail>? details, bool isRTL) {
      return pw.Column(
        crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          for (var detail in details ?? [])
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: pw.Column(
                crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                children: [
                  localizedText(
                    detail.purchaseDetail?.product?.productName ?? 'N/A',
                    alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                  ),
                  // // // Serial Numbers - safe check for List<String> or String
                  // if (detail.serialNumbers != null)
                  //   localizedText(
                  //     '${_lang.serial}: ${detail.serialNumbers}',
                  //     alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                  //   ),
                  // Serial Numbers
                  detail.serialNumbers != null && detail.serialNumbers!.isNotEmpty
                      ? localizedText(
                          '${_lang.serial}: ${detail.serialNumbers!.join(", ")}',
                          alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                        )
                      : localizedText(''),
                ],
              ),
            ),
        ],
      );
    }

    ///------------Widget-------------------------

    //---------------table data----------------------
    int taxItemsCount = transactions.taxItems?.length ?? 0;

    Map<int, pw.TableColumnWidth> columnWidths = {
      0: const pw.FlexColumnWidth(1), // SL
      1: pw.FlexColumnWidth(taxItemsCount >= 3 ? 2 : 3), // Item Description
      2: const pw.FlexColumnWidth(1), // Quantity
      3: pw.FlexColumnWidth(taxItemsCount >= 3 ? 1 : 2), // Taxable Value
    };

    int startIndex = 4;

// Dynamic tax column width based on number of tax items
    double taxColumnWidth = 2.0;
    if (taxItemsCount >= 3) {
      taxColumnWidth = 1.5; // Reduce width for 4+ tax items
    } else if (taxItemsCount >= 3) {
      taxColumnWidth = 1.8;
    }

    for (int i = 0; i < taxItemsCount; i++) {
      columnWidths[startIndex + i] = pw.FlexColumnWidth(taxColumnWidth);
    }

    double totalColumnWidth = taxItemsCount >= 3 ? 1.5 : 2.0;
    columnWidths[startIndex + taxItemsCount] = pw.FlexColumnWidth(totalColumnWidth);

    ///------for returned table--------------------------------------

    int returnedTaxItemsCount = transactions.taxItems?.length ?? 0;

    Map<int, pw.TableColumnWidth> returnedColumnWidths = {
      0: const pw.FlexColumnWidth(1), // Date
      1: pw.FlexColumnWidth(1), // Item Description
      2: const pw.FlexColumnWidth(1), // Quantity
      3: pw.FlexColumnWidth(returnedTaxItemsCount >= 3 ? 1 : 2), // Taxable Value
    };

    int returnedStartIndex = 4;

// Dynamic tax column width based on number of tax items
    double returnedTaxColumnWidth = 1.5;
    if (returnedTaxItemsCount >= 3) {
      returnedTaxColumnWidth = 1; // Reduce width for 4+ tax items
    } else if (returnedTaxItemsCount >= 3) {
      returnedTaxColumnWidth = 1.3;
    }

    for (int i = 0; i < returnedTaxItemsCount; i++) {
      returnedColumnWidths[returnedStartIndex + i] = pw.FlexColumnWidth(returnedTaxColumnWidth);
    }

    double returnedTotalColumnWidth = returnedTaxItemsCount >= 3 ? 1 : 1.5;
    returnedColumnWidths[returnedStartIndex + returnedTaxItemsCount] = pw.FlexColumnWidth(returnedTotalColumnWidth);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        margin: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (pw.Context context) => <pw.Widget>[
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.black,
              ),
            ),
            child: pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  child: localizedText(_lang.taxInvoice, size: 24, bold: true),
                ),
                pw.Divider(height: 1),

                ///--------header data-------------------
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.symmetric(vertical: pw.BorderSide(color: PdfColors.black)),
                  ),
                  child: pw.Row(
                    children: [
                      // Logo Section
                      pw.Expanded(
                        child: pw.Padding(
                          padding: pw.EdgeInsets.all(20),
                          child: pw.Center(
                            child: pw.SizedBox(
                              height: 54.12,
                              width: 200,
                              child: universalImage(imageData, w: 200, h: 54.12),
                            ),
                          ),
                        ),
                      ),
                      // Table Section
                      pw.Expanded(
                        child: pw.Table(
                          border: pw.TableBorder(
                            horizontalInside: pw.BorderSide(color: PdfColors.black),
                            verticalInside: pw.BorderSide(color: PdfColors.black),
                            left: pw.BorderSide(color: PdfColors.black),
                            right: pw.BorderSide(color: PdfColors.black),
                            top: pw.BorderSide(color: PdfColors.black),
                          ),
                          defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                          children: [
                            _buildTableRow(_lang.invoiceNo, transactions.purchase?.invoiceNumber ?? 'n/a',
                                _lang.invoiceDate, transactions.purchase?.purchaseDate ?? 'n/a'),
                            _buildTableRow(_lang.orderReference, transactions.purchase?.invoiceNumber ?? '',
                                _lang.paymentReference, transactions.purchase?.paymentType?.name ?? 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Divider(height: 1),

                ///------customer data------------------
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // Branch Info
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              localizedText(transactions.purchase?.business?.companyName ?? 'n/a',
                                  size: 16, bold: true),
                              localizedText(transactions.purchase?.business?.address ?? 'n/a'),
                              localizedText('${_lang.state}: ${transactions.purchase?.business?.state?.name ?? 'n/a'}'),
                              localizedText('${_lang.email}: ${transactions.purchase?.business?.email ?? 'n/a'}',
                                  bold: true),
                            ],
                          ),
                        ),
                        // Bill To Info
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              localizedText(_lang.billTo, size: 16, bold: true),
                              localizedText(transactions.purchase?.party?.name ?? 'n/a', bold: true),
                              localizedText(transactions.purchase?.party?.address ?? 'n/a'),
                              localizedText('${_lang.phone}: ${transactions.purchase?.party?.phone ?? 'n/a'}'),
                              localizedText('${_lang.email}: ${transactions.purchase?.party?.email ?? 'n/a'}',
                                  bold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                ///-------product table----------
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  columnWidths: RtlTableHelper.reverseColumnWidths(columnWidths, isRTL: isRTL),
                  children: [
                    // Table Header
                    RtlTableHelper.createRow(
                      isRTL: isRTL,
                      children: [
                        _headerCell(_lang.sl, isRTL, center: true),
                        _headerCell(_lang.itemDescription, isRTL),
                        _headerCell(_lang.qty, isRTL, center: true),
                        _headerCell(_lang.taxableValue, isRTL, center: true),
                        ...(transactions.taxItems?.map((entry) => _taxHeader(entry.vatData?.vatName ?? '')).toList() ??
                            []),
                        _headerCell(_lang.totalPriceIncludeTax, isRTL, center: true),
                      ],
                    ),
                    // Table Rows
                    for (int i = 0; i < (transactions.purchase?.details?.length ?? 0); i++)
                      RtlTableHelper.createRow(
                        isRTL: isRTL,
                        children: [
                          _bodyCell('${i + 1}', isRTL, center: true),
                          _itemCell(
                            transactions.purchase!.details![i],
                            isRTL,
                          ),
                          _bodyCell(
                            formatPointNumber(
                              PDFCommonFunctions().getPurchaseTaxProductQuantity(
                                detailsId: transactions.purchase?.details![i].id ?? 0,
                                transactions: transactions,
                              ),
                            ),
                            isRTL,
                            center: true,
                          ),
                          _bodyCell(
                              '${((transactions.purchase!.details?[i].priceWithoutTax ?? 0) * (transactions.purchase?.details?[i].quantities ?? 0))}',
                              isRTL,
                              center: true),
                          ...?transactions.taxItems?.map((e) => _taxCell('${e.vatRate}%', '${e.vatAmount}')),
                          _bodyCell(
                              '${((transactions.purchase!.details?[i].productPurchasePrice ?? 0) * (transactions.purchase?.details?[i].quantities ?? 0))}',
                              isRTL,
                              center: true),
                        ],
                      ),
                  ],
                ),

                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left column - Payment information (ONLY when NO returns)
                      transactions.purchaseReturn == null || transactions.purchaseReturn!.isEmpty
                          ? pw.Expanded(
                              child: pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 10),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.SizedBox(height: 22),
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
                                      pw.SizedBox(height: 18),
                                      // Paid via
                                      pw.Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          localizedText(
                                            '${_lang.paidVia} :',
                                            bold: true,
                                          ),
                                          ...?transactions.purchase?.transactions?.asMap().entries.map(
                                            (entry) {
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
                                              final isLast =
                                                  index == (transactions.purchase?.transactions?.length ?? 1) - 1;
                                              final text = isLast ? label : '$label,';
                                              return localizedText(text, bold: true);
                                            },
                                          ),
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
                                            localizedText(
                                              personalInformation.data?.invoiceNote ?? '',
                                            ),
                                          ],
                                        ),
                                      pw.SizedBox(height: 12),
                                      // Bank details - FIXED: Safe null checks
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
                                                          child: localizedText(_lang.name),
                                                        ),
                                                        pw.Expanded(
                                                          child: localizedText(
                                                            ': ${latestBankTransaction.paymentType?.name ?? ''}',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.Row(
                                                      children: [
                                                        pw.Expanded(
                                                          child: localizedText(_lang.accountNumber),
                                                        ),
                                                        pw.Expanded(
                                                          child: localizedText(
                                                            ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.accountNumber ?? ''}',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.Row(
                                                      children: [
                                                        pw.Expanded(
                                                          child: localizedText(_lang.ifscCode),
                                                        ),
                                                        pw.Expanded(
                                                          child: localizedText(
                                                            ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.ifscCode ?? ''}',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    pw.SizedBox(height: 4),
                                                    pw.Row(
                                                      children: [
                                                        pw.Expanded(
                                                          child: localizedText(_lang.holderName),
                                                        ),
                                                        pw.Expanded(
                                                          child: localizedText(
                                                            ': ${latestBankTransaction.paymentType?.paymentTypeMeta?.holderName ?? ''}',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      pw.SizedBox(height: 12),
                                      if (latestBankTransaction != null)
                                        if (!personalInformation.data!.gratitudeMessage.isEmptyOrNull)
                                          pw.Container(
                                            width: double.infinity,
                                            padding: const pw.EdgeInsets.only(bottom: 8.0),
                                            child: pw.Center(
                                              child: pw.Text(
                                                personalInformation.data!.gratitudeMessage ?? '',
                                              ),
                                            ),
                                          ),
                                    ],
                                  )),
                            )
                          : pw.Expanded(child: pw.SizedBox()),
                      // Right column - Amount calculation (ALWAYS shows)
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.SizedBox(height: 10.0),
                            localizedText(
                              "${_lang.subTotal}: ${formatPointNumber(subtotal)}",
                              bold: true,
                            ),
                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${_lang.discount}: ${formatPointNumber((transactions.purchase?.discountAmount ?? 0) + returnedDiscountAmount())}",
                              bold: true,
                            ),
                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${transactions.purchase?.vat?.name ?? _lang.vat}: ${formatPointNumber(vatAmount)}",
                              bold: true,
                            ),
                            pw.SizedBox(height: 5.0),
                            localizedText(
                              "${_lang.shippingCharge}: ${formatPointNumber((transactions.purchase?.shippingCharge ?? 0))}",
                              bold: true,
                            ),
                            pw.SizedBox(height: 5.0),
                            // if (transactions.purchase?.roundingAmount != 0)
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                localizedText(
                                  "${_lang.amount}: ${formatPointNumber((transactions.purchase?.totalAmount ?? 0))}",
                                  bold: true,
                                ),
                                pw.SizedBox(height: 5.0),
                                // localizedText(
                                //   "${_lang.rounding}: ${!(transactions.purchase?.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber((transactions.sale?.roundingAmount ?? 0))}",
                                //   bold: true,
                                // ),
                                pw.SizedBox(height: 5.0),
                              ],
                            ),
                            transactions.purchaseReturn!.isNotEmpty
                                ? localizedText('${_lang.totalAmount} ${transactions.purchase?.totalAmount}',
                                    bold: true)
                                : localizedText(
                                    '${_lang.totalAmount}: ${subtotal + vatAmount + (transactions.purchase?.vatAmount ?? 0) - (transactions.purchase?.discountAmount ?? 0) + (transactions.purchase?.shippingCharge ?? 0)}'),
                            if (transactions.purchaseReturn == null || transactions.purchaseReturn!.isEmpty)
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
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
                                        "${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.purchase?.dueAmount ?? 0)) + (transactions.purchase?.changeAmount ?? 0))}",
                                        bold: true,
                                      ),
                                      pw.SizedBox(height: 5.0),
                                      localizedText(
                                        (transactions.purchase?.dueAmount ?? 0) > 0
                                            ? "${_lang.due}: ${formatPointNumber(transactions.purchase?.dueAmount ?? 0)}"
                                            : (transactions.purchase?.changeAmount ?? 0) > 0
                                                ? "${_lang.changeAmount}: ${formatPointNumber(transactions.purchase?.changeAmount ?? 0)}"
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
                      )
                    ],
                  ),
                  // Returns table - Only show if there are returns
                  if (transactions.purchaseReturn != null && transactions.purchaseReturn!.isNotEmpty)
                    pw.Column(
                      children: [
                        pw.SizedBox(height: 20),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.black),
                          columnWidths: RtlTableHelper.reverseColumnWidths(returnedColumnWidths, isRTL: isRTL),
                          children: [
                            // Table Header
                            RtlTableHelper.createRow(
                              isRTL: isRTL,
                              children: [
                                // _headerCell(_lang.sl, isRTL, center: true),
                                _headerCell(_lang.date, isRTL, center: true),
                                _headerCell(_lang.item, isRTL),
                                _headerCell(_lang.qty, isRTL, center: true),
                                _headerCell(_lang.taxableValue, isRTL, center: true),
                                ...(transactions.taxItems
                                        ?.map((entry) => _taxHeader(entry.vatData?.vatName ?? ''))
                                        .toList() ??
                                    []),
                                _headerCell(_lang.includeTaxPrice, isRTL, center: true),
                              ],
                            ),
                            // Table Rows
                            // FIXED: Returns table row generation - Access details correctly
                            for (int i = 0; i < (transactions.purchaseReturn?.length ?? 0); i++)
                              RtlTableHelper.createRow(
                                isRTL: isRTL,
                                children: [
                                  _bodyCell('${transactions.purchaseReturn?[i].returnDate}', isRTL, center: true),
                                  _returnedItemCell(
                                    // FIXED: Use .details instead of .salesReturnDetails
                                    transactions.purchaseReturn![i].details,
                                    isRTL,
                                  ),
                                  _bodyCell(
                                    formatPointNumber(
                                      PDFCommonFunctions().getPurchaseTaxProductQuantity(
                                        detailsId: transactions.purchaseReturn![i].id ?? 0,
                                        transactions: transactions,
                                      ),
                                    ),
                                    isRTL,
                                    center: true,
                                  ),
                                  // FIXED: Safe access to purchaseDetail
                                  _bodyCell(
                                    '${((transactions.purchaseReturn?[i].details.isNotEmpty ?? false) ? (transactions.purchaseReturn![i].details[0].purchaseDetail?.priceWithoutTax ?? 0) : 0) * ((transactions.purchaseReturn?[i].details.isNotEmpty ?? false) ? (transactions.purchaseReturn![i].details[0].purchaseDetail?.quantities ?? 0) : 0)}',
                                    isRTL,
                                    center: true,
                                  ),
                                  ...?transactions.taxItems?.map((e) => _taxCell('${e.vatRate}%', '${e.vatAmount}')),
                                  // FIXED: Safe access to purchaseDetail for total price
                                  _bodyCell(
                                    '${((transactions.purchaseReturn?[i].details.isNotEmpty ?? false) ? (transactions.purchaseReturn![i].details[0].purchaseDetail?.productPurchasePrice ?? 0) : 0) * ((transactions.purchaseReturn?[i].details.isNotEmpty ?? false) ? (transactions.purchaseReturn![i].details[0].purchaseDetail?.quantities ?? 0) : 0)}',
                                    isRTL,
                                    center: true,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
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
                                        localizedText(
                                          '${_lang.paidVia} :',
                                          bold: true,
                                        ),
                                        ...?transactions.purchase?.transactions?.asMap().entries.map(
                                          (entry) {
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
                                            final isLast =
                                                index == (transactions.purchase?.transactions?.length ?? 1) - 1;
                                            final text = isLast ? label : '$label,';
                                            return localizedText(text, bold: true);
                                          },
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 12),
                                    if ((!personalInformation.data!.invoiceNote.isEmptyOrNull ||
                                            !personalInformation.data!.invoiceNoteLevel.isEmptyOrNull) &&
                                        personalInformation.data!.showNote == 1)
                                      pw.Row(
                                        children: [
                                          localizedText(
                                            '${personalInformation.data?.invoiceNoteLevel ?? ''}: ',
                                            bold: true,
                                          ),
                                          localizedText(
                                            personalInformation.data?.invoiceNote ?? '',
                                          ),
                                        ],
                                      ),
                                    pw.SizedBox(height: 12),
                                    // Bank details for returns - FIXED
                                    if (transactions.purchase?.transactions != null &&
                                        transactions.purchase!.transactions!.isNotEmpty &&
                                        transactions.purchase!.transactions!
                                            .any((t) => t.transactionType == 'bank_payment'))
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
                                                        child: localizedText(_lang.name),
                                                      ),
                                                      pw.Expanded(
                                                        child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.bankName ?? ''}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  pw.Row(
                                                    children: [
                                                      pw.Expanded(
                                                        child: localizedText(_lang.accountNumber),
                                                      ),
                                                      pw.Expanded(
                                                        child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.accountNumber ?? ''}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  pw.Row(
                                                    children: [
                                                      pw.Expanded(
                                                        child: localizedText(_lang.ifscCode),
                                                      ),
                                                      pw.Expanded(
                                                        child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.ifscCode ?? ''}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  pw.Row(
                                                    children: [
                                                      pw.Expanded(
                                                        child: localizedText(_lang.holderName),
                                                      ),
                                                      pw.Expanded(
                                                        child: localizedText(
                                                          ': ${latestBankTransaction?.paymentType?.paymentTypeMeta?.holderName ?? ''}',
                                                        ),
                                                      ),
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
                                    bold: true,
                                  ),
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                    "${_lang.receivedAmount}: ${formatPointNumber(((transactions.totalAmount ?? 0) - (transactions.purchase?.dueAmount ?? 0)) + (transactions.purchase?.changeAmount ?? 0))}",
                                    bold: true,
                                  ),
                                  pw.SizedBox(height: 5.0),
                                  localizedText(
                                    (transactions.purchase?.dueAmount ?? 0) > 0
                                        ? "${_lang.due}: ${formatPointNumber(transactions.purchase?.dueAmount ?? 0)}"
                                        : (transactions.purchase?.changeAmount ?? 0) > 0
                                            ? "${_lang.changeAmount}: ${formatPointNumber(transactions.purchase?.changeAmount ?? 0)}"
                                            : '',
                                    bold: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  pw.SizedBox(height: 20.0),
                  if (personalInformation.data?.showGratitudeMsg == 1)
                    if (!personalInformation.data!.gratitudeMessage.isEmptyOrNull)
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.only(bottom: 8.0),
                        child: pw.Center(
                          child: pw.Text(
                            personalInformation.data!.gratitudeMessage ?? '',
                          ),
                        ),
                      ),
                  pw.SizedBox(height: 16),
                  pw.Column(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10.0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                              child: pw.Column(
                                children: [
                                  pw.Container(
                                    width: 120.0,
                                    height: 2.0,
                                    color: PdfColors.black,
                                  ),
                                  pw.SizedBox(height: 4.0),
                                  localizedText(_lang.customerSignature),
                                ],
                              ),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                              padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                              child: pw.Column(
                                children: [
                                  pw.Container(
                                    width: 120.0,
                                    height: 2.0,
                                    color: PdfColors.black,
                                  ),
                                  pw.SizedBox(height: 4.0),
                                  localizedText(_lang.authorizedSignature),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 10),
                        child: pw.Center(
                          child: localizedText(
                            '${personalInformation.data?.developByLevel ?? ''} ${personalInformation.data?.developBy ?? ''}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16)
                ])
              ],
            ),
          )
        ],
      ),
    );

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
        invoice: transactions.purchase?.invoiceNumber ?? '',
        doc: doc,
        isShare: share,
        download: download,
      );
    }
  }
}
