import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/lalnguage_data.dart';
import 'package:mobile_pos/service/thermal_print/src/templates/_purchase_invoice_template.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../Screens/Products/add product/modle/create_product_model.dart';
import '../Screens/Purchase/Model/purchase_transaction_model.dart';
import '../constant.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';

class PurchaseThermalPrinterInvoice {
  ///__________Purchase________________
  Future<void> printPurchaseThermalInvoice(
      {required PrintPurchaseTransactionModel printTransactionModel,
      required List<PurchaseDetails>? productList,
      required BuildContext context}) async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected == true) {
      bool defould = (printTransactionModel.personalInformationModel.data?.invoiceLanguage == 'english' ||
              printTransactionModel.personalInformationModel.data?.invoiceLanguage == null)
          ? true
          : false;
      List<int> bytes = [];
      final is80mm = printTransactionModel.personalInformationModel.data?.invoiceSize == '3_inch_80mm' &&
          printTransactionModel.personalInformationModel.data?.invoiceSize != null;
      if (defould) {
        bytes = (is80mm)
            ? await getPurchaseTicket80mm(printTransactionModel: printTransactionModel, productList: productList)
            : await getPurchaseTicket58mm(printTransactionModel: printTransactionModel, productList: productList);
      } else {
        final bool isRTL = rtlLang.contains(await getLanguageName());
        PurchaseThermalInvoiceTemplate template = PurchaseThermalInvoiceTemplate(
            context: context,
            is58mm: !is80mm,
            printTransactionModel: printTransactionModel,
            productList: productList,
            isRTL: isRTL);
        bytes = await template.template;
      }

      if (printTransactionModel.purchaseTransitionModel?.details?.isNotEmpty ?? false) {
        await PrintBluetoothThermal.writeBytes(bytes);
      } else {
        toast('No Product Found');
      }
      // if (invoiceSize != null && invoiceSize == '3_inch_80mm') {
      //   List<int> bytes = await getPurchaseTicket80mm(printTransactionModel: printTransactionModel, productList: productList);
      //   if (printTransactionModel.purchaseTransitionModel?.details?.isNotEmpty ?? false) {
      //     await PrintBluetoothThermal.writeBytes(bytes);
      //   } else {
      //     toast('No Product Found');
      //   }
      // } else {
      //   List<int> bytes = await getPurchaseTicket58mm(printTransactionModel: printTransactionModel, productList: productList,is80mm: invoiceSize == '3_inch_80mm');
      //   if (printTransactionModel.purchaseTransitionModel?.details?.isNotEmpty ?? false) {
      //     await PrintBluetoothThermal.writeBytes(bytes);
      //   } else {
      //     toast('No Product Found');
      //   }
      // }
    } else {
      EasyLoading.showError('Unable to connect with printer');
    }
  }

  Future<List<int>> getPurchaseTicket58mm(
      {required PrintPurchaseTransactionModel printTransactionModel,
      required List<PurchaseDetails>? productList}) async {
    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
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

    String productName({required num detailsId}) {
      final details = printTransactionModel.purchaseTransitionModel?.details?[
          printTransactionModel.purchaseTransitionModel!.details!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ''}]' : ''}";
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList?.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
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

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in productList ?? []) {
        // Calculate the total for each item without VAT
        num productPrice = element.priceWithoutTax ?? 0;
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);

        total += productPrice * productQuantity;
      }

      return total;
    }

    num getTotalVatAmountForOldInvoice() {
      num total = 0;
      for (var element in productList ?? []) {
        // Calculate the total for each item without VAT
        num productPrice = (element.productPurchasePrice ?? 0) - (element.priceWithoutTax ?? 0);
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);

        total += productPrice * productQuantity;
      }

      return total;
    }

    final transactions = printTransactionModel.purchaseTransitionModel?.transactions ?? [];

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
    String printProfiles = printTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    CapabilityProfile profile = await CapabilityProfile.load(name: printProfiles);
    final generator = Generator(PaperSize.mm58, profile);

    final _logo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");
    //qr code
    final _qrlogo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    ///____________Image__________________________________
    if (_logo != null && printTransactionModel.personalInformationModel.data?.showThermalInvoiceLogo == 1) {
      final img.Image resized = img.copyResize(
        _logo,
        width: 184,
      );
      final img.Image grayscale = img.grayscale(resized);
      bytes += generator.imageRaster(grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    if (printTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }

    if (printTransactionModel.purchaseTransitionModel?.branch?.name != null) {
      bytes += generator.text('Branch: ${printTransactionModel.purchaseTransitionModel?.branch?.name ?? ''}',
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text(
        'Seller :${printTransactionModel.purchaseTransitionModel?.user?.role == "shop-owner" ? "Admin" : printTransactionModel.purchaseTransitionModel?.user?.name}',
        styles: const PosStyles(align: PosAlign.center));

    if (printTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printTransactionModel.purchaseTransitionModel?.branch?.address != null ||
          printTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text(
            printTransactionModel.purchaseTransitionModel?.branch?.address ??
                printTransactionModel.personalInformationModel.data?.address ??
                '',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
      if (printTransactionModel.personalInformationModel.data?.vatNo != null &&
          printTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
        bytes += generator.text(
            "${printTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No :'}${printTransactionModel.personalInformationModel.data?.vatNo ?? ''}",
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printTransactionModel.purchaseTransitionModel?.branch?.phone != null ||
          printTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(
            'Tel: ${printTransactionModel.purchaseTransitionModel?.branch?.phone ?? printTransactionModel.personalInformationModel.data?.phoneNumber ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('INVOICE',
        styles: const PosStyles(
          underline: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.text('Name: ${printTransactionModel.purchaseTransitionModel?.party?.name ?? 'Guest'}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('mobile: ${printTransactionModel.purchaseTransitionModel?.party?.phone ?? 'Not Provided'}',
        styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.text('Purchase By: ${printTransactionModel.purchaseTransitionModel?.user?.name ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(
        'Invoice: ${printTransactionModel.purchaseTransitionModel?.invoiceNumber ?? 'Not Provided'}',
        styles: const PosStyles(align: PosAlign.left));
    if (printTransactionModel.purchaseTransitionModel?.purchaseDate != null) {
      DateTime saleDate = DateTime.parse(printTransactionModel.purchaseTransitionModel!.purchaseDate!);
      String formattedDate = DateFormat('M/d/yyyy h:mm a').format(saleDate);

      bytes += generator.text(
        'Date: $formattedDate',
        styles: const PosStyles(align: PosAlign.left),
        linesAfter: 1,
      );
    }
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Price', width: 3, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      bytes += generator.row([
        PosColumn(
            text:
                "${productList?[index].product?.productName ?? 'Not Defined'}${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}",
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(productList?[index].productPurchasePrice ?? 0) ?? 'Not Defined',
            width: 3,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: formatPointNumber(getProductQuantity(detailsId: productList?[index].id ?? 0)),
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text:
                "${(productList?[index].productPurchasePrice ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0)}",
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      if (productList?[index].serialNumbers?.isNotEmpty ?? false) {
        bytes += generator.row([
          PosColumn(
            text: 'SN: ${productList?[index].serialNumbers?.join(", ")}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(text: "", width: 3),
          PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 3),
        ]);
      }
    });

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Subtotal',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(getTotalForOldInvoice()),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: printTransactionModel.personalInformationModel.data?.vatName ?? 'Vat',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(
              getTotalVatAmountForOldInvoice() + (printTransactionModel.purchaseTransitionModel?.vatAmount ?? 0)),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Shipping Charge',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.shippingCharge ?? 0),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(
              (printTransactionModel.purchaseTransitionModel?.discountAmount ?? 0) + getReturndDiscountAmount()),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Total',
    //       width: 8,
    //       styles: const PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: formatPointNumber((printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0) + getTotalReturndAmount()),
    //       width: 4,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       )),
    // ]);
    List<DateTime> returnedDates = [];

    ///_____Return_table_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.purchaseTransitionModel?.purchaseReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) => element.isAtSameMomentAs(DateTime.tryParse(
                printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ??
                    '') ??
            DateTime.now()))) {
          bytes += generator.row([
            PosColumn(
                text:
                    'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 7,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(
            printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?.length ?? 0,
            (index) {
          returnedDates.add(DateTime.tryParse(
                  printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ??
                      '') ??
              DateTime.now());
          final product =
              printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?[index];
          bytes += generator.row([
            PosColumn(
                text: productName(detailsId: product?.purchaseDetailId ?? 0),
                width: 7,
                styles: const PosStyles(align: PosAlign.left)),
            PosColumn(
                text: product?.returnQty.toString() ?? 'Not Defined',
                width: 2,
                styles: const PosStyles(align: PosAlign.center)),
            PosColumn(
                text: "${(product?.returnAmount ?? 0)}", width: 3, styles: const PosStyles(align: PosAlign.right)),
          ]);
          if (product?.serialNumbers?.isNotEmpty ?? false) {
            bytes += generator.row([
              PosColumn(
                text: 'SN: ${product?.serialNumbers?.join(", ")}',
                width: 7,
                styles: const PosStyles(
                  align: PosAlign.left,
                ),
              ),
              PosColumn(text: "", width: 2),
              PosColumn(text: "", width: 3),
            ]);
          }
          return bytes;
        });
        //
      });
    }
    bytes += generator.hr();

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      bytes += generator.row([
        PosColumn(
            text: 'Returned Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: '${getTotalReturndAmount()}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    bytes += generator.row([
      PosColumn(text: 'Total Payable', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Paid Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(((printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0) -
                  (printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0)) +
              (printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0)),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if ((printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Due Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    if ((printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    // bytes += generator.row([
    //   PosColumn(
    //       text: 'Payment Type:',
    //       width: 8,
    //       styles: const PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: printTransactionModel.purchaseTransitionModel?.paymentType?.name ?? 'N/A',
    //       width: 4,
    //       styles: const PosStyles(
    //         align: PosAlign.right,
    //       )),
    // ]);

    bytes += generator.hr();
    bytes += generator.text(
      paidViaText,
      styles: const PosStyles(
        align: PosAlign.left,
      ),
      linesAfter: 1,
    );

    // ticket.feed(2);
    if (printTransactionModel.personalInformationModel.data?.gratitudeMessage != null &&
        printTransactionModel.personalInformationModel.data?.showGratitudeMsg == 1) {
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
    }
    bytes += generator.text(printTransactionModel.purchaseTransitionModel!.purchaseDate ?? '',
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    if ((printTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
          '${printTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
          styles: const PosStyles(align: PosAlign.left, bold: false),
          linesAfter: 1);
    }
    // if (printTransactionModel.personalInformationModel.data?.developByLink != null) {
    //   bytes += generator.qrcode(
    //     printTransactionModel.personalInformationModel.data?.developByLink ?? '',
    //   );
    //   bytes += generator.emptyLines(1);
    // }
    if (printTransactionModel.personalInformationModel.data?.showInvoiceScannerLogo == 1) {
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
    if (printTransactionModel.personalInformationModel.data?.developByLevel != null ||
        printTransactionModel.personalInformationModel.data?.developBy != null) {
      bytes += generator.text(
          '${printTransactionModel.personalInformationModel.data?.developByLevel ?? 'Developed By'}: ${printTransactionModel.personalInformationModel.data?.developBy ?? companyName}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> getPurchaseTicket80mm(
      {required PrintPurchaseTransactionModel printTransactionModel,
      required List<PurchaseDetails>? productList}) async {
    List<DateTime> returnedDates = [];
    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.productPurchasePrice ?? 0;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
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

    String productName({required num detailsId}) {
      final details = printTransactionModel.purchaseTransitionModel?.details?[
          printTransactionModel.purchaseTransitionModel!.details!.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ''}]' : ''}";
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
          if (returns.purchaseReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.purchaseReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList?.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.purchaseTransitionModel!.purchaseReturns!) {
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

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in productList ?? []) {
        num productPrice = element.priceWithoutTax ?? 0;
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);
        total += productPrice * productQuantity;
      }
      return total;
    }

    num getTotalVatAmountForOldInvoice() {
      num total = 0;
      for (var element in productList ?? []) {
        num productPrice = (element.productPurchasePrice ?? 0) - (element.priceWithoutTax ?? 0);
        num productQuantity = getProductQuantity(detailsId: element.id ?? 0);
        total += productPrice * productQuantity;
      }
      return total;
    }

    final transactions = printTransactionModel.purchaseTransitionModel?.transactions ?? [];

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

    //qr code
    final _qrlogo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    final _logo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");
    String printProfiles = printTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
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
    if (printTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }
    if (printTransactionModel.purchaseTransitionModel?.branch?.name != null) {
      bytes += generator.text('Branch: ${printTransactionModel.purchaseTransitionModel?.branch?.name}',
          styles: const PosStyles(align: PosAlign.center));
    }
    if (printTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printTransactionModel.purchaseTransitionModel?.branch?.address != null ||
          printTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text(
            'Address: ${printTransactionModel.purchaseTransitionModel?.branch?.address ?? printTransactionModel.personalInformationModel.data?.address ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }

    if (printTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printTransactionModel.purchaseTransitionModel?.branch?.phone != null ||
          printTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(
            'Mobile: ${printTransactionModel.purchaseTransitionModel?.branch?.phone ?? printTransactionModel.personalInformationModel.data?.phoneNumber ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
      if (printTransactionModel.personalInformationModel.data?.vatNo != null &&
          printTransactionModel.personalInformationModel.data?.meta?.showVat == 1) {
        bytes += generator.text(
            "${printTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No'}: ${printTransactionModel.personalInformationModel.data?.vatNo}",
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    bytes += generator.emptyLines(1);
    bytes += generator.text('INVOICE',
        styles: const PosStyles(
          bold: true,
          underline: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    if (printTransactionModel.personalInformationModel.data?.vatNo != null) {
      bytes += generator.text(
          "${printTransactionModel.personalInformationModel.data?.vatName ?? 'VAT No :'}${printTransactionModel.personalInformationModel.data?.vatNo}",
          styles: const PosStyles(align: PosAlign.center));
    }

    ///__________Customer_and_time_section_______________________
    bytes += generator.row([
      PosColumn(
          text: 'Invoice: ${printTransactionModel.purchaseTransitionModel?.invoiceNumber ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Date: ${DateFormat.yMd().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Name: ${printTransactionModel.purchaseTransitionModel?.party?.name ?? 'Guest'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Time: ${DateFormat.jm().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Mobile: ${printTransactionModel.purchaseTransitionModel?.party?.phone ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Purchase By: ${printTransactionModel.purchaseTransitionModel?.user?.role == "shop-owner" ? 'Admin' : printTransactionModel.purchaseTransitionModel!.user?.name}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.emptyLines(1);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Item', width: 5, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Total', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();

    List.generate(productList?.length ?? 1, (index) {
      bytes += generator.row([
        PosColumn(
            text: '${index + 1}',
            width: 1,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text:
                "${productList?[index].product?.productName ?? ''}${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}",
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(getProductQuantity(detailsId: productList?[index].id ?? 0), addComma: true),
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: formatPointNumber(productList?[index].productPurchasePrice ?? 0, addComma: true),
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text: formatPointNumber(
                (productList?[index].productPurchasePrice ?? 0) *
                    getProductQuantity(detailsId: productList?[index].id ?? 0),
                addComma: true),
            width: 2,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      if (productList?[index].serialNumbers?.isNotEmpty ?? false) {
        bytes += generator.row([
          PosColumn(text: "", width: 1),
          PosColumn(
            text: 'SN: ${productList?[index].serialNumbers?.join(", ")}',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 2),
        ]);
      }
      return bytes;
    });

    // for (var item in productList ?? []) {
    //   final qty = getProductQuantity(detailsId: item.id ?? 0);
    //   final price = item.productPurchasePrice ?? 0;
    //   bytes += generator.row([
    //     PosColumn(text: item.product?.productName ?? '', width: 5),
    //     PosColumn(text: formatPointNumber(price), width: 2, styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(text: formatPointNumber(qty), width: 2, styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(text: formatPointNumber(price * qty), width: 3, styles: const PosStyles(align: PosAlign.right)),
    //   ]);
    // }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Sub-total:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(getTotalForOldInvoice(), addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: '${printTransactionModel.personalInformationModel.data?.vatName ?? 'VAT'}:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(
              getTotalVatAmountForOldInvoice() + (printTransactionModel.purchaseTransitionModel?.vatAmount ?? 0),
              addComma: true),
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
          text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.shippingCharge ?? 0, addComma: true),
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
          text: formatPointNumber(
              (printTransactionModel.purchaseTransitionModel?.discountAmount ?? 0) + getReturndDiscountAmount(),
              addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    ///_____Return_table_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.purchaseTransitionModel?.purchaseReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) => element.isAtSameMomentAs(DateTime.tryParse(
                printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ??
                    '') ??
            DateTime.now()))) {
          bytes += generator.row([
            PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(
                text:
                    'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 6,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(
            printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?.length ?? 0,
            (index) {
          returnedDates.add(DateTime.tryParse(
                  printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].returnDate?.substring(0, 10) ??
                      '') ??
              DateTime.now());
          final product =
              printTransactionModel.purchaseTransitionModel?.purchaseReturns?[i].purchaseReturnDetails?[index];
          bytes += generator.row([
            PosColumn(
                text: '${index + 1}',
                width: 1,
                styles: const PosStyles(
                  align: PosAlign.left,
                )),
            PosColumn(
                text: productName(detailsId: product?.purchaseDetailId ?? 0),
                width: 6,
                styles: const PosStyles(align: PosAlign.left)),
            PosColumn(
                text: product?.returnQty.toString() ?? 'Not Defined',
                width: 2,
                styles: const PosStyles(align: PosAlign.center)),
            PosColumn(
                text: formatPointNumber(product?.returnAmount ?? 0, addComma: true),
                width: 3,
                styles: const PosStyles(align: PosAlign.right)),
          ]);
          if (product?.serialNumbers?.isNotEmpty ?? false) {
            bytes += generator.row([
              PosColumn(text: "", width: 1),
              PosColumn(
                text: 'SN: ${product?.serialNumbers?.join(", ")}',
                width: 6,
                styles: const PosStyles(
                  align: PosAlign.left,
                ),
              ),
              PosColumn(text: "", width: 2),
              PosColumn(text: "", width: 3),
            ]);
          }
          return bytes;
        });
        //
      });
    }

    final returnedAmount = getTotalReturndAmount();

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.purchaseTransitionModel?.purchaseReturns?.isNotEmpty ?? false) {
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
            text: 'Returned Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(getTotalReturndAmount(), addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    } else {
      bytes += generator.text('                    ----------------------------');
    }

    bytes += generator.row([
      PosColumn(text: 'Total Payable:', width: 9, styles: const PosStyles(align: PosAlign.right, bold: true)),
      PosColumn(
          text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Paid Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
      PosColumn(
          text: formatPointNumber(
              ((printTransactionModel.purchaseTransitionModel?.totalAmount ?? 0) -
                      (printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0)) +
                  (printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0),
              addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    if ((printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Due Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.dueAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    if ((printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.purchaseTransitionModel?.changeAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.text(
      paidViaText,
      styles: const PosStyles(
        align: PosAlign.left,
      ),
      linesAfter: 1,
    );
    if (printTransactionModel.personalInformationModel.data?.gratitudeMessage != null &&
        printTransactionModel.personalInformationModel.data?.showGratitudeMsg == 1) {
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.gratitudeMessage ?? 'gra',
          styles: const PosStyles(align: PosAlign.center, bold: true));
    }
    if (printTransactionModel.purchaseTransitionModel?.purchaseDate != null) {
      DateTime saleDate = DateTime.parse(printTransactionModel.purchaseTransitionModel!.purchaseDate!);
      String formattedDate = DateFormat('M/d/yyyy h:mm a').format(saleDate);

      bytes += generator.text(formattedDate, styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }
    // bytes += generator.text(printTransactionModel.purchaseTransitionModel!.purchaseDate ?? '', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    if ((printTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }
    // if (printTransactionModel.personalInformationModel.data?.developByLink != null) {
    //   bytes += generator.qrcode(
    //     printTransactionModel.personalInformationModel.data?.developByLink ?? '',
    //   );
    //   bytes += generator.emptyLines(1);
    // }
    if (printTransactionModel.personalInformationModel.data?.showInvoiceScannerLogo == 1) {
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
    if (printTransactionModel.personalInformationModel.data?.developByLevel != null ||
        printTransactionModel.personalInformationModel.data?.developBy != null) {
      bytes += generator.text(
          '${printTransactionModel.personalInformationModel.data?.developByLevel ?? ''}: ${printTransactionModel.personalInformationModel.data?.developBy ?? ''}',
          styles: const PosStyles(align: PosAlign.center),
          linesAfter: 1);
    }
    bytes += generator.cut();
    return bytes;
  }
}
