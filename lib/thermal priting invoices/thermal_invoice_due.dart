import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/lalnguage_data.dart';
import 'package:mobile_pos/service/thermal_print/src/templates/_due_collection_invoice_template.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../Const/api_config.dart';
import '../constant.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';

class DueThermalPrinterInvoice {
  ///_________Due________________________
  Future<void> printDueTicket(
      {required PrintDueTransactionModel printDueTransactionModel,
      required String? invoiceSize,
      required BuildContext context}) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      bool defould = (printDueTransactionModel.personalInformationModel.data?.invoiceLanguage == 'english' ||
              printDueTransactionModel.personalInformationModel.data?.invoiceLanguage == null)
          ? true
          : false;
      List<int> bytes = [];
      final is80mm = printDueTransactionModel.personalInformationModel.data?.invoiceSize == '3_inch_80mm' &&
          printDueTransactionModel.personalInformationModel.data?.invoiceSize != null;
      if (defould) {
        bytes = (is80mm)
            ? await getDueTicket80mm(printDueTransactionModel: printDueTransactionModel)
            : await getDueTicket50mm(printDueTransactionModel: printDueTransactionModel);
      } else {
        final bool isRTL = rtlLang.contains(await getLanguageName());
        DueThermalInvoiceTemplate dueThermalInvoiceTemplate = DueThermalInvoiceTemplate(
            context: context, printDueTransactionModel: printDueTransactionModel, is58mm: !is80mm, isRTL: isRTL);
        bytes = await dueThermalInvoiceTemplate.template;
      }
      await PrintBluetoothThermal.writeBytes(bytes);
    } else {}
  }

  Future<List<int>> getDueTicket50mm({required PrintDueTransactionModel printDueTransactionModel}) async {
    final transactions = printDueTransactionModel.dueTransactionModel!.transactions ?? [];

    List<String> paymentLabels = [];

    for (var item in transactions) {
      String label;

      switch (item.transactionType) {
        case 'cash_payment':
          label = 'Cash';
          break;
        case 'cheque_payment':
          label = 'Cheque';
          break;
        case 'wallet_payment':
          label = 'Wallet';
          break;
        default:
          label = item.paymentType?.name ?? 'n/a';
      }

      paymentLabels.add(label);
    }

    final paidViaText = "Paid Via : ${paymentLabels.join(', ')}";

    String printProfiles = printDueTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load(name: printProfiles);
    final generator = Generator(PaperSize.mm58, profile);
    // final ByteData data = await rootBundle.load('images/logo.png');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final Image? imagez = decodeImage(imageBytes);
    // bytes += generator.image(imagez!);
    final _qrlogo =
        await getNetworkImage("${printDueTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    final _logo =
        await getNetworkImage("${printDueTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");

    ///____________Image__________________________________
    if (_logo != null && printDueTransactionModel.personalInformationModel.data?.showThermalInvoiceLogo == 1) {
      final img.Image resized = img.copyResize(
        _logo,
        width: 184,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }
    if (printDueTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }
    if (printDueTransactionModel.dueTransactionModel?.branch?.name != null) {
      bytes += generator.text(printDueTransactionModel.dueTransactionModel?.branch?.name ?? '',
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text(
        'Seller :${printDueTransactionModel.dueTransactionModel?.user?.role == "shop-owner" ? 'Admin' : printDueTransactionModel.dueTransactionModel?.user?.name ?? ''}',
        styles: const PosStyles(align: PosAlign.center));

    if (printDueTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printDueTransactionModel.dueTransactionModel?.branch?.address != null ||
          printDueTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text(
          printDueTransactionModel.dueTransactionModel?.branch?.address ??
              printDueTransactionModel.personalInformationModel.data?.address ??
              '',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
    }

    if (printDueTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
      if (printDueTransactionModel.personalInformationModel.data?.vatNo != null &&
          printDueTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
        bytes += generator.text(
            "${printDueTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No :'}${printDueTransactionModel.personalInformationModel.data?.vatNo ?? ''}",
            styles: const PosStyles(align: PosAlign.center));
      }
    }

    if (printDueTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printDueTransactionModel.dueTransactionModel?.branch?.phone != null ||
          printDueTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(
            printDueTransactionModel.dueTransactionModel?.branch?.phone ??
                printDueTransactionModel.personalInformationModel.data?.phoneNumber ??
                'n/a',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('Receipt',
        styles: const PosStyles(
          underline: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.text(
        'Received From: ${printDueTransactionModel.dueTransactionModel?.party?.name ?? printDueTransactionModel.dueTransactionModel?.sale?.invoiceNumber} ',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Mobile: ${printDueTransactionModel.dueTransactionModel?.party?.phone}',
        styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.text('Received By: ${printDueTransactionModel.dueTransactionModel?.user?.name}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Receipt: ${printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? 'Not Provided'}',
        styles: const PosStyles(align: PosAlign.left));
    if (printDueTransactionModel.dueTransactionModel?.paymentDate != null) {
      DateTime saleDate = DateTime.parse(printDueTransactionModel.dueTransactionModel!.paymentDate!);
      String formattedDate = DateFormat('M/d/yyyy h:mm a').format(saleDate);

      bytes += generator.text(
        'Date: $formattedDate',
        styles: const PosStyles(align: PosAlign.left),
        linesAfter: 1,
      );
    }
    // bytes += generator.hr();
    // bytes += generator.row([
    //   PosColumn(text: 'Invoice', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
    //   PosColumn(text: 'Due', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    // ]);
    // bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Total Due',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel!.totalDue.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Payment Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel!.payDueAmount.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Remaining Due:', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel!.dueAmountAfterPay.toString(),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Payment Type:',
    //       width: 8,
    //       styles: const PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: printDueTransactionModel.dueTransactionModel!.paymentType?.name ?? 'N/A',
    //       width: 4,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       )),
    // ]);

    bytes += generator.text(
      paidViaText,
      styles: const PosStyles(
        align: PosAlign.left,
      ),
      linesAfter: 1,
    );

    // ticket.feed(2);
    if (printDueTransactionModel.personalInformationModel.data?.gratitudeMessage != null &&
        printDueTransactionModel.personalInformationModel.data?.showGratitudeMsg == 1) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printDueTransactionModel.dueTransactionModel!.paymentDate ?? '',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

    if ((printDueTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printDueTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printDueTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printDueTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printDueTransactionModel.personalInformationModel.data?.showInvoiceScannerLogo == 1) {
      if (_qrlogo != null) {
        final img.Image resized = img.copyResize(
          _qrlogo,
          width: 120,
          height: 120,
        );
        final img.Image grayscale = img.grayscale(resized);
        bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
      }
    }

    if (printDueTransactionModel.personalInformationModel.data?.developByLevel != null ||
        printDueTransactionModel.personalInformationModel.data?.developBy != null) {
      bytes += generator.text(
          '${printDueTransactionModel.personalInformationModel.data?.developByLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.data?.developBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getDueTicket80mm({required PrintDueTransactionModel printDueTransactionModel}) async {
    final transactions = printDueTransactionModel.dueTransactionModel!.transactions ?? [];

    List<String> paymentLabels = [];

    for (var item in transactions) {
      String label;

      switch (item.transactionType) {
        case 'cash_payment':
          label = 'Cash';
          break;
        case 'cheque_payment':
          label = 'Cheque';
          break;
        case 'wallet_payment':
          label = 'Wallet';
          break;
        default:
          label = item.paymentType?.name ?? 'n/a';
      }

      paymentLabels.add(label);
    }

    final paidViaText = "Paid Via : ${paymentLabels.join(', ')}";
    List<int> bytes = [];

    final _qrlogo =
        await getNetworkImage("${printDueTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    final _logo =
        await getNetworkImage("${printDueTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");
    String printProfiles = printDueTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    CapabilityProfile profile = await CapabilityProfile.load(name: printProfiles);
    final generator = Generator(PaperSize.mm80, profile);

    ///____________Image__________________________________
    if (_logo != null) {
      final img.Image resized = img.copyResize(
        _logo,
        width: 184,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    ///____________Header_____________________________________
    if (printDueTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }
    if (printDueTransactionModel.dueTransactionModel?.branch?.name != null) {
      bytes += generator.text('Branch: ${printDueTransactionModel.dueTransactionModel?.branch?.name}',
          styles: const PosStyles(align: PosAlign.center));
    }
    if (printDueTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printDueTransactionModel.dueTransactionModel?.branch?.address != null ||
          printDueTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text(
            'Address: ${printDueTransactionModel.dueTransactionModel?.branch?.address ?? printDueTransactionModel.personalInformationModel.data?.address ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printDueTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printDueTransactionModel.dueTransactionModel?.branch?.phone != null ||
          printDueTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(
            'Mobile: ${printDueTransactionModel.dueTransactionModel?.branch?.phone ?? printDueTransactionModel.personalInformationModel.data?.phoneNumber ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printDueTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
      if (printDueTransactionModel.personalInformationModel.data?.vatNo != null &&
          printDueTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
        bytes += generator.text(
            "${printDueTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No'}: ${printDueTransactionModel.personalInformationModel.data?.vatNo}",
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('Receipt',
        styles: const PosStyles(
          bold: true,
          underline: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ///__________Customer_and_time_section_______________________
    bytes += generator.row([
      PosColumn(
          text: 'Receipt: ${printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Date: ${DateFormat.yMd().format(DateTime.parse(printDueTransactionModel.dueTransactionModel?.paymentDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text:
              'Name: ${printDueTransactionModel.dueTransactionModel?.party?.name ?? printDueTransactionModel.dueTransactionModel?.sale?.invoiceNumber ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Time: ${DateFormat.jm().format(DateTime.parse(printDueTransactionModel.dueTransactionModel?.paymentDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Mobile: ${printDueTransactionModel.dueTransactionModel?.party?.phone ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Received By: ${printDueTransactionModel.dueTransactionModel?.user?.role == "shop-owner" ? 'Admin' : printDueTransactionModel.dueTransactionModel!.user?.name}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.emptyLines(1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Invoice', width: 6, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Due', width: 5, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: '1', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: printDueTransactionModel.dueTransactionModel?.invoiceNumber ?? '',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: formatPointNumber(printDueTransactionModel.dueTransactionModel?.totalDue ?? 0, addComma: true),
          width: 5,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Payment Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printDueTransactionModel.dueTransactionModel?.payDueAmount ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Remaining Due:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text:
              formatPointNumber((printDueTransactionModel.dueTransactionModel?.dueAmountAfterPay ?? 0), addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    // bytes += generator.hr();
    bytes += generator.text(
      '-----------------------------',
      styles: const PosStyles(align: PosAlign.right),
    );
    bytes += generator.text(
      paidViaText,
      styles: const PosStyles(
        align: PosAlign.left,
      ),
      linesAfter: 1,
    );

    if (printDueTransactionModel.personalInformationModel.data?.gratitudeMessage != null &&
        printDueTransactionModel.personalInformationModel.data?.showGratitudeMsg == 1) {
      bytes += generator.text(printDueTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
    }
    bytes += generator.text(printDueTransactionModel.dueTransactionModel!.paymentDate ?? '',
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    if ((printDueTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printDueTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printDueTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printDueTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printDueTransactionModel.personalInformationModel.data?.showInvoiceScannerLogo == 1) {
      if (_qrlogo != null) {
        final img.Image resized = img.copyResize(
          _qrlogo,
          width: 120,
          height: 120,
        );
        final img.Image grayscale = img.grayscale(resized);
        bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
      }
    }

    if (printDueTransactionModel.personalInformationModel.data?.developByLevel != null ||
        printDueTransactionModel.personalInformationModel.data?.developBy != null) {
      bytes += generator.text(
          '${printDueTransactionModel.personalInformationModel.data?.developByLevel ?? ''}: ${printDueTransactionModel.personalInformationModel.data?.developBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }
}
