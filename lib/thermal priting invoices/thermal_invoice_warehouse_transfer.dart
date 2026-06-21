import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/lalnguage_data.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../Const/api_config.dart';
import '../constant.dart';
import '../service/thermal_print/src/templates/_warehouse_invoice_template.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';

class WhTransferThermalPrinterInvoice {
  ///_________Due________________________
  Future<void> printWhTransferTicket(
      {required PrintWhTransferTransactionModel printWhTransferModel,
      required String? invoiceSize,
      required BuildContext context}) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      bool defould = (printWhTransferModel.personalInformationModel.data?.invoiceLanguage == 'english' ||
              printWhTransferModel.personalInformationModel.data?.invoiceLanguage == null)
          ? true
          : false;
      List<int> bytes = [];
      final is80mm = printWhTransferModel.personalInformationModel.data?.invoiceSize == '3_inch_80mm' &&
          printWhTransferModel.personalInformationModel.data?.invoiceSize != null;
      if (defould) {
        bytes = (is80mm)
            ? await getSalesTicket80mm(printWhTransactionModel: printWhTransferModel)
            : await getWhTransferTicket50mm(printWhTransactionModel: printWhTransferModel);
      } else {
        final bool isRTL = rtlLang.contains(await getLanguageName());
        WarehouseThermalInvoiceTemplate whTransferThermalInvoiceTemplate = WarehouseThermalInvoiceTemplate(
            context: context,
            is58mm: !is80mm,
            isRTL: isRTL,
            transferInvoice: printWhTransferModel,
            business: printWhTransferModel.personalInformationModel);
        bytes = await whTransferThermalInvoiceTemplate.template;
      }
      await PrintBluetoothThermal.writeBytes(bytes);
    } else {}
  }

  Future<List<int>> getWhTransferTicket50mm({required PrintWhTransferTransactionModel printWhTransactionModel}) async {
    List<int> bytes = [];
    String _printProfiles = printWhTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    CapabilityProfile profile = await CapabilityProfile.load(name: _printProfiles);
    final generator = Generator(PaperSize.mm58, profile);
    final _qrlogo =
        await getNetworkImage("${printWhTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    final _logo = await getNetworkImage("${printWhTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");

    ///____________Image__________________________________
    if (_logo != null && printWhTransactionModel.personalInformationModel.data?.showThermalInvoiceLogo == 1) {
      final img.Image resized = img.copyResize(
        _logo,
        width: 184,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }
    if (printWhTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printWhTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }

    if (printWhTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printWhTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text(
          printWhTransactionModel.personalInformationModel.data?.address ?? '',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
    }

    if (printWhTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
      if (printWhTransactionModel.personalInformationModel.data?.vatNo != null &&
          printWhTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
        bytes += generator.text(
            "${printWhTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No :'}${printWhTransactionModel.personalInformationModel.data?.vatNo ?? ''}",
            styles: const PosStyles(align: PosAlign.center));
      }
    }

    if (printWhTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printWhTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(printWhTransactionModel.personalInformationModel.data?.phoneNumber ?? 'n/a',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('TRANSFER INVOICE',
        styles: const PosStyles(
          underline: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.text('Invoice: ${printWhTransactionModel.transfer?.data?.invoiceNo ?? ''} ',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Status: ${printWhTransactionModel.transfer?.data?.status ?? ''}',
        styles: const PosStyles(align: PosAlign.left));
    if (printWhTransactionModel.transfer?.data?.transferDate != null) {
      DateTime saleDate = DateTime.parse(printWhTransactionModel.transfer!.data!.transferDate!);
      String formattedDate = DateFormat('M/d/yyyy h:mm a').format(saleDate);

      bytes += generator.text(
        'Date: $formattedDate',
        styles: const PosStyles(align: PosAlign.left),
      );
      //warehouse
      //From warehouse
      bytes += generator.text(
        'From',
        styles: const PosStyles(align: PosAlign.left, bold: true),
      );
      bytes += generator.text(
        'WH: ${printWhTransactionModel.transfer?.data?.fromWarehouse?.name ?? ''}',
        styles: const PosStyles(align: PosAlign.left),
      );
      if (printWhTransactionModel.transfer?.data?.fromWarehouse?.address != null) {
        bytes += generator.text(
          printWhTransactionModel.transfer?.data?.fromWarehouse?.address ?? '',
          styles: const PosStyles(align: PosAlign.left),
        );
      }
      //To warehouse
      bytes += generator.text(
        'To',
        styles: const PosStyles(align: PosAlign.left, bold: true),
      );
      bytes += generator.text(
        'WH: ${printWhTransactionModel.transfer?.data?.toWarehouse?.name ?? ''}',
        styles: const PosStyles(align: PosAlign.left),
      );
      if (printWhTransactionModel.transfer?.data?.toWarehouse?.address != null) {
        bytes += generator.text(
          printWhTransactionModel.transfer?.data?.toWarehouse?.address ?? '',
          styles: const PosStyles(align: PosAlign.left),
        );
      }
    }

    ///__________Customer_and_time_section_______________________
    bytes += generator.emptyLines(1);

    ///____________Products_Section_________________________________
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: 3, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Amount', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(printWhTransactionModel.transfer?.data!.transferProducts?.length ?? 1, (index) {
      final product = printWhTransactionModel.transfer!.data!.transferProducts![index];
      final itemQty = printWhTransactionModel.transfer?.data!.transferProducts?[index].quantity ?? 0;
      final itemPrice = printWhTransactionModel.transfer?.data!.transferProducts?[index].unitPrice ?? 0;
      bytes += generator.row([
        PosColumn(
            text: printWhTransactionModel.transfer?.data!.transferProducts?[index].product?.productName ??
                'SN: ${printWhTransactionModel.transfer?.data!.transferProducts?[index].serialNumbers?[index] ?? ''}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(text: '$itemQty', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '$itemPrice',
            width: 3,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(text: '${itemQty * itemPrice}', width: 3, styles: const PosStyles(align: PosAlign.right)),
      ]);
      // SERIAL NUMBER ROW (UNDER PRODUCT)
      if (product.serialNumbers != null && product.serialNumbers!.isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text: 'SN: ${product.serialNumbers!.join(", ")}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
              fontType: PosFontType.fontA,
            ),
          ),
          PosColumn(text: '', width: 2),
          PosColumn(text: '', width: 3),
          PosColumn(text: '', width: 3),
        ]);
      }
      return bytes;
    });
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Sub-total:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.subTotal ?? 0),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.totalDiscount ?? 0),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Tax:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.totalTax ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Shipping Charge:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.shippingCharge ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total Payable:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.grandTotal ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr(linesAfter: 1);

    // ticket.feed(2);
    if (printWhTransactionModel.personalInformationModel.data?.gratitudeMessage != null &&
        printWhTransactionModel.personalInformationModel.data?.showGratitudeMsg == 1) {
      bytes += generator.text(printWhTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printWhTransactionModel.transfer!.data!.transferDate ?? '',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

    if ((printWhTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printWhTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printWhTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printWhTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printWhTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printWhTransactionModel.personalInformationModel.data?.showInvoiceScannerLogo == 1 && _qrlogo != null) {
      final img.Image resized = img.copyResize(
        _qrlogo,
        width: 120,
        height: 120,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    if (printWhTransactionModel.personalInformationModel.data?.developByLevel != null ||
        printWhTransactionModel.personalInformationModel.data?.developBy != null) {
      bytes += generator.text(
          '${printWhTransactionModel.personalInformationModel.data?.developByLevel ?? ''}: ${printWhTransactionModel.personalInformationModel.data?.developBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getSalesTicket80mm({required PrintWhTransferTransactionModel printWhTransactionModel}) async {
    List<int> bytes = [];
    final _logo = await getNetworkImage("${printWhTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");

    //qr code
    final _qrlogo =
        await getNetworkImage("${printWhTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    String _printProfiles = printWhTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';

    CapabilityProfile profile = await CapabilityProfile.load(name: _printProfiles);

    final generator = Generator(PaperSize.mm80, profile);

    ///____________Image__________________________________
    if (printWhTransactionModel.personalInformationModel.data?.showThermalInvoiceLogo == 1) {
      if (_logo != null) {
        final img.Image resized = img.copyResize(
          _logo,
          width: 184,
        );
        final img.Image grayscale = img.grayscale(resized);
        bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
      }
    }

    ///____________Header_____________________________________
    if (printWhTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printWhTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }

    if (printWhTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printWhTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text('Address: ${printWhTransactionModel.personalInformationModel.data?.address ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printWhTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printWhTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text('Mobile: ${printWhTransactionModel.personalInformationModel.data?.phoneNumber ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printWhTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
      if (printWhTransactionModel.personalInformationModel.data?.vatNo != null &&
          printWhTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
        bytes += generator.text(
            "${printWhTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No'}: ${printWhTransactionModel.personalInformationModel.data?.vatNo}",
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('Transfer Invoice',
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
          text: 'Invoice: ${printWhTransactionModel.transfer?.data?.invoiceNo ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Date: ${DateFormat.yMd().format(DateTime.parse(printWhTransactionModel.transfer?.data?.transferDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Status: ${printWhTransactionModel.transfer?.data?.status ?? ''}',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text:
              'Time: ${DateFormat.jm().format(DateTime.parse(printWhTransactionModel.transfer?.data?.transferDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.emptyLines(1);

    //warehouse
    bytes += generator.row([
      PosColumn(text: 'From', width: 6, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'To', width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'WH: ${printWhTransactionModel.transfer?.data?.fromWarehouse?.name ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text: 'WH: ${printWhTransactionModel.transfer?.data?.toWarehouse?.name ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    if (printWhTransactionModel.transfer?.data?.fromWarehouse?.address != null ||
        printWhTransactionModel.transfer?.data?.toWarehouse?.address != null) {
      bytes += generator.row([
        PosColumn(
            text: printWhTransactionModel.transfer?.data?.fromWarehouse?.address ?? 'n/a',
            width: 6,
            styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
            text: printWhTransactionModel.transfer?.data?.toWarehouse?.address ?? 'n/a',
            width: 6,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.emptyLines(1);

    ///____________Products_Section_________________________________
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Item', width: 5, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Amount', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(printWhTransactionModel.transfer?.data!.transferProducts?.length ?? 1, (index) {
      final product = printWhTransactionModel.transfer!.data!.transferProducts![index];
      final itemQty = printWhTransactionModel.transfer?.data!.transferProducts?[index].quantity ?? 0;
      final itemPrice = printWhTransactionModel.transfer?.data!.transferProducts?[index].unitPrice ?? 0;

      bytes += generator.row([
        PosColumn(
            text: '${index + 1}',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
          text: product.product?.productName ?? '',
          width: 5,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(text: '$itemQty', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: '$itemPrice',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(text: '${itemQty * itemPrice}', width: 2, styles: const PosStyles(align: PosAlign.right)),
      ]);

      // SERIAL NUMBER ROW (UNDER PRODUCT)
      if (product.serialNumbers != null && product.serialNumbers!.isNotEmpty) {
        bytes += generator.row([
          PosColumn(text: '', width: 1), // empty for SL
          PosColumn(
            text: 'SN: ${product.serialNumbers!.join(", ")}',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
              fontType: PosFontType.fontA,
            ),
          ),
          for (int j = 0; j < 3; j++) PosColumn(text: '', width: 2),
        ]);
      }
      return bytes;
    });
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Sub-total:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.subTotal ?? 0),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.totalDiscount ?? 0),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Tax:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.totalTax ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Shipping Charge:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.shippingCharge ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total Payable:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(printWhTransactionModel.transfer?.data?.grandTotal ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    bytes += generator.hr(linesAfter: 1);

    // ticket.feed(2);
    if (printWhTransactionModel.personalInformationModel.data?.gratitudeMessage != null &&
        printWhTransactionModel.personalInformationModel.data?.showGratitudeMsg == 1) {
      bytes += generator.text(printWhTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(printWhTransactionModel.transfer!.data!.transferDate ?? '',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }

    if ((printWhTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printWhTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printWhTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printWhTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printWhTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    if (printWhTransactionModel.personalInformationModel.data?.showInvoiceScannerLogo == 1) {
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

    if (printWhTransactionModel.personalInformationModel.data?.developByLevel != null ||
        printWhTransactionModel.personalInformationModel.data?.developBy != null) {
      bytes += generator.text(
          '${printWhTransactionModel.personalInformationModel.data?.developByLevel ?? ''}: ${printWhTransactionModel.personalInformationModel.data?.developBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }

    bytes += generator.cut();
    return bytes;
  }
}
