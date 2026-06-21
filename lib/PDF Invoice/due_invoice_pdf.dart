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

import '../Screens/Due Calculation/Model/due_collection_model.dart';
import '../model/business_info_model.dart';
import 'arabic_fonts.dart';
import 'check_rtl.dart';

import 'pdf_common_functions.dart';

class DueInvoicePDF {
  static Future<void> generateDueDocument(
    DueCollection transactions,
    BusinessInformationModel personalInformation,
    BuildContext context, {
    bool? isShare,
    bool? download,
    bool? showPreview,
  }) async {
    final pw.Document doc = pw.Document();
    final _lang = l.S.of(context);
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
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
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
                            pw.SizedBox(
                              width: 250,
                              child: localizedText(
                                '${_lang.address} :${personalInformation.data?.address ?? ''}',
                                alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                              ),
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
                          if (personalInformation.data?.meta?.showVat == 1)
                            if (personalInformation.data?.vatNo != null && personalInformation.data?.meta?.showVat == 1)
                              localizedText(
                                '${personalInformation.data?.vatName ?? _lang.vatNumber}: ${personalInformation.data?.vatNo ?? ''}',
                                alignment: isRTL ? pw.TextAlign.start : pw.TextAlign.end,
                              ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16.0),
                  pw.Center(
                    child: pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(20),
                        border: pw.Border.all(color: PdfColors.black),
                      ),
                      child: localizedText(
                        _lang.moneyReceipt,
                        bold: true,
                        size: 18,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                localizedText(
                                  '${_lang.invoice}:',
                                  bold: true,
                                ),
                                pw.SizedBox(width: 4),
                                localizedText(
                                  transactions.invoiceNumber ?? '',
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              children: [
                                localizedText(
                                  '${transactions.party?.type?.trim().toLowerCase() == 'supplier' ? _lang.purchase : _lang.sale} ${_lang.invoice}:',
                                  bold: true,
                                ),
                                pw.SizedBox(width: 4),
                                localizedText(
                                  transactions.purchase?.invoiceNumber ?? transactions.sale?.invoiceNumber ?? '',
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              children: [
                                localizedText(
                                  '${_lang.billTo}:',
                                  bold: true,
                                ),
                                pw.SizedBox(width: 4),
                                localizedText(
                                  transactions.party?.name ?? _lang.guest,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                localizedText(
                                  '${_lang.date}:',
                                  bold: true,
                                  alignment: pw.TextAlign.start,
                                ),
                                pw.SizedBox(width: 4),
                                localizedText(
                                  transactions.paymentDate?.isNotEmpty == true
                                      ? DateFormat('d MMM, yyyy').format(DateTime.parse(transactions.paymentDate!))
                                      : '',
                                  alignment: pw.TextAlign.start,
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                localizedText(
                                  '${_lang.time}:',
                                  bold: true,
                                  alignment: pw.TextAlign.start,
                                ),
                                pw.SizedBox(width: 4),
                                localizedText(
                                  transactions.paymentDate?.isNotEmpty == true
                                      ? DateFormat('hh:mm a').format(DateTime.parse(transactions.paymentDate!))
                                      : '',
                                  alignment: pw.TextAlign.start,
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                localizedText(
                                  '${_lang.collectedBy}:',
                                  bold: true,
                                  alignment: pw.TextAlign.start,
                                ),
                                pw.SizedBox(width: 4),
                                localizedText(
                                  transactions.user?.role == "shop-owner" ? _lang.admin : transactions.user?.name ?? '',
                                  alignment: pw.TextAlign.start,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Directionality(
              textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Column(children: [
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
                      child: isRTL
                          ? pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if (personalInformation.data?.warrantyVoid != null)
                                  localizedText(
                                    personalInformation.data!.warrantyVoid!,
                                  ),
                                if (personalInformation.data?.warrantyVoidLabel != null)
                                  localizedText(
                                    '${personalInformation.data!.warrantyVoidLabel!}-',
                                    bold: true,
                                  ),
                              ],
                            )
                          : pw.Row(children: [
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
              ]));
        },
        build: (pw.Context context) => <pw.Widget>[
          pw.Directionality(
            textDirection: isRTL ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: pw.Column(
                children: [
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(3),
                      2: const pw.FlexColumnWidth(3),
                      3: const pw.FlexColumnWidth(3),
                    },
                    border: pw.TableBorder(
                      horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      verticalInside: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      left: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      right: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      top: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                      bottom: pw.BorderSide(color: PdfColor.fromInt(0xffD9D9D9)),
                    ),
                    children: [
                      pw.TableRow(
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
                              _lang.totalDue,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.paymentsAmount,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: localizedText(
                              _lang.remainingDue,
                              bold: true,
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              '1',
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              "${transactions.totalDue ?? 0}",
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              "${((transactions.totalDue ?? 0) - (transactions.dueAmountAfterPay ?? 0))}",
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: localizedText(
                              "${transactions.dueAmountAfterPay ?? 0}",
                              alignment: RtlTableHelper.adjustAlignment(pw.TextAlign.start, isRTL),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(height: 10),
                            pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(1),
                                1: const pw.FlexColumnWidth(3),
                              },
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        '',
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: pw.Container(),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        _lang.paidBy,
                                        bold: true,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: pw.Wrap(
                                        spacing: 4,
                                        children: [
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

                                            final isLast = index == (transactions.transactions?.length ?? 1) - 1;
                                            final text = isLast ? label : '$label,';

                                            return localizedText(
                                              text,
                                              bold: true,
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 12),
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
                                                ),
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
                                                child: localizedText(
                                                  _lang.accountNumber,
                                                ),
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
                                                child: localizedText(
                                                  _lang.ifscCode,
                                                ),
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
                                                child: localizedText(
                                                  _lang.holderName,
                                                ),
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
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: isRTL ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end,
                          children: [
                            pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(2),
                                1: const pw.FlexColumnWidth(0.5),
                                2: const pw.FlexColumnWidth(2),
                              },
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        _lang.payableAmount,
                                        alignment: pw.TextAlign.end,
                                        bold: true,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        ':',
                                        alignment: pw.TextAlign.end,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        '${transactions.totalDue ?? 0}',
                                        alignment: pw.TextAlign.end,
                                        bold: true,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        _lang.receivedAmount,
                                        alignment: pw.TextAlign.end,
                                        bold: true,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        ':',
                                        alignment: pw.TextAlign.end,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        '${((transactions.totalDue ?? 0) - (transactions.dueAmountAfterPay ?? 0))}',
                                        alignment: pw.TextAlign.end,
                                        bold: true,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        _lang.dueAmount,
                                        alignment: pw.TextAlign.end,
                                        bold: true,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        ':',
                                        alignment: pw.TextAlign.end,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                      child: localizedText(
                                        '${transactions.dueAmountAfterPay ?? 0}',
                                        alignment: pw.TextAlign.end,
                                        bold: true,
                                      ),
                                    ),
                                  ],
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
                  pw.Padding(padding: const pw.EdgeInsets.all(10)),
                ],
              ),
            ),
          )
        ],
      ),
    );

    EasyLoading.showSuccess(_lang.pdfGenerateSuccessfully);

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
        isShare: isShare,
        download: download,
      );
    }
  }
}
