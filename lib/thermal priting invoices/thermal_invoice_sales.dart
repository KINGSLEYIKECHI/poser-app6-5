import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:mobile_pos/Const/lalnguage_data.dart';
import 'package:mobile_pos/service/thermal_print/src/templates/_sale_invoice_template.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../Screens/Products/add product/modle/create_product_model.dart';
import '../constant.dart';
import '../model/sale_transaction_model.dart';
import 'model/print_transaction_model.dart';
import 'network_image.dart';

class SalesThermalPrinterInvoice {
  ///________Sales____________________

  Future<void> printSalesTicket(
      {required PrintSalesTransactionModel printTransactionModel,
      required List<SalesDetails>? productList,
      required BuildContext context}) async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    bool defould = (printTransactionModel.personalInformationModel.data?.invoiceLanguage == 'english' ||
            printTransactionModel.personalInformationModel.data?.invoiceLanguage == null)
        ? true
        : false;
    if (isConnected == true) {
      List<int> bytes = [];
      final is80mm = printTransactionModel.personalInformationModel.data?.invoiceSize == '3_inch_80mm' &&
          printTransactionModel.personalInformationModel.data?.invoiceSize != null;

      if (defould) {
        bytes = is80mm
            ? await getSalesTicket80mm(printTransactionModel: printTransactionModel, productList: productList)
            : await getSalesTicket58mm(printTransactionModel: printTransactionModel, productList: productList);
      } else {
        final bool isRTL = rtlLang.contains(await getLanguageName());

        SaleThermalInvoiceTemplate template = SaleThermalInvoiceTemplate(
            context: context,
            business: printTransactionModel.personalInformationModel,
            is58mm: !is80mm,
            isRTL: isRTL,
            saleInvoice: printTransactionModel.transitionModel!);
        bytes = await template.template;
      }

      if (printTransactionModel.transitionModel?.salesDetails?.isNotEmpty ?? false) {
        await PrintBluetoothThermal.writeBytes(bytes);
        EasyLoading.showSuccess('Successfully Printed');
      } else {
        toast('No Product Found');
      }
    } else {
      EasyLoading.showError('Unable to connect with printer');
    }
  }

  Future<List<int>> getSalesTicket58mm(
      {required PrintSalesTransactionModel printTransactionModel, required List<SalesDetails>? productList}) async {
    List<DateTime> returnedDates = [];
    String productName({required num detailsId}) {
      final details = productList?[productList.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ""}]' : ''}";
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList!.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              if (details.saleDetailId == detailsId) {
                totalQuantity += details.returnQty ?? 0;
              }
            }
          }
        }
      }

      return totalQuantity;
    }

    num getTotalForOldInvoiceVat() {
      num total = 0;
      for (var element in printTransactionModel.transitionModel!.salesDetails!) {
        total += (((element.price ?? 0) - (element.discount ?? 0)) * getProductQuantity(detailsId: element.id ?? 0)) -
            ((element.priceWithoutTax ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
      }

      return total;
    }

    num getTotalForOldInvoiceWithoutTax() {
      num total = 0;
      for (var element in printTransactionModel.transitionModel!.salesDetails!) {
        total += ((element.priceWithoutTax ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
      }

      return total;
    }

    num getTotalForOldInvoice() {
      num total = 0;
      for (var element in productList!) {
        total += ((element.price ?? 0) * getProductQuantity(detailsId: element.id ?? 0)) -
            ((element.discount ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
      }

      return total;
    }

    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    String getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn.toStringAsFixed(2);
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
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

    //qr code
    final _qrlogo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");

    num getTotalItemDiscount() {
      num totalDiscount = 0;

      final salesDetails = printTransactionModel.transitionModel?.salesDetails ?? [];

      for (var element in salesDetails) {
        totalDiscount += (element.discount ?? 0) * getProductQuantity(detailsId: element.id ?? 0);
      }

      return totalDiscount;
    }

    final transactions = printTransactionModel.transitionModel!.transactions ?? [];

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

    String printProfiles = printTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';
    List<int> bytes = [];
    final _logo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");
    CapabilityProfile profile = await CapabilityProfile.load(name: printProfiles);

    final generator = Generator(PaperSize.mm58, profile);

    ///____________Image__________________________________
    if (_logo != null && printTransactionModel.personalInformationModel.data?.showThermalInvoiceLogo == 1) {
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
    if (_logo != null) bytes += generator.text(' ');
    if (printTransactionModel.transitionModel?.branch?.name != null) {
      bytes += generator.text('Branch: ${printTransactionModel.transitionModel?.branch?.name ?? ''}',
          styles: const PosStyles(align: PosAlign.center));
    }
    bytes += generator.text(
        'Seller :${printTransactionModel.transitionModel?.user?.role == "shop-owner" ? 'Admin' : printTransactionModel.transitionModel!.user?.name}',
        styles: const PosStyles(align: PosAlign.center));
    if (printTransactionModel.transitionModel?.branch?.address != null ||
        printTransactionModel.personalInformationModel.data?.address != null) {
      bytes += generator.text(
          printTransactionModel.transitionModel?.branch?.address ??
              printTransactionModel.personalInformationModel.data?.address ??
              '',
          styles: const PosStyles(align: PosAlign.center));
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
      if (printTransactionModel.transitionModel?.branch?.phone != null ||
          printTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(
            'Tel: ${printTransactionModel.transitionModel?.branch?.phone ?? printTransactionModel.personalInformationModel.data?.phoneNumber ?? ''}',
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

    bytes += generator.text('Name: ${printTransactionModel.transitionModel?.party?.name ?? 'Guest'}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('mobile: ${printTransactionModel.transitionModel?.party?.phone ?? 'Not Provided'}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Invoice: ${printTransactionModel.transitionModel?.invoiceNumber ?? 'Not Provided'}',
        styles: const PosStyles(align: PosAlign.left));
    if (printTransactionModel.transitionModel?.saleDate != null) {
      DateTime saleDate = DateTime.parse(printTransactionModel.transitionModel!.saleDate!);
      String formattedDate = DateFormat('M/d/yyyy h:mm a').format(saleDate);

      bytes += generator.text(
        'Date: $formattedDate',
        styles: const PosStyles(align: PosAlign.left),
        linesAfter: 1,
      );
    }

    bytes += generator.row([
      PosColumn(text: 'Item', width: 4, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Price', width: 3, styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(text: 'Amount', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      final warrantyInfo = printTransactionModel.transitionModel?.salesDetails?[index].warrantyInfo;

      final warranty = (warrantyInfo?.warrantyDuration != null && warrantyInfo?.warrantyUnit != null)
          ? "Warranty : ${warrantyInfo?.warrantyDuration} ${warrantyInfo?.warrantyUnit}"
          : "";

      final guarantee = (warrantyInfo?.guaranteeDuration != null && warrantyInfo?.guaranteeUnit != null)
          ? "Guarantee : ${warrantyInfo?.guaranteeDuration} ${warrantyInfo?.guaranteeUnit}"
          : "";

      final name = "${productList?[index].product?.productName ?? ''}"
          "${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}";

      bytes += generator.row([
        PosColumn(
          text: name,
          width: 4,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: formatPointNumber(getProductQuantity(detailsId: productList?[index].id ?? 0)),
          width: 2,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: '${productList?[index].price}',
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text:
              "${((productList?[index].price ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0)) - ((productList?[index].discount ?? 0) * getProductQuantity(detailsId: productList?[index].id ?? 0))}",
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      if (productList?[index].serialNumbers?.isNotEmpty ?? false) {
        bytes += generator.row([
          PosColumn(
            text: 'SN: ${productList?[index].serialNumbers!.join(", ")}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 3),
          PosColumn(text: "", width: 3),
        ]);
      }
      if (warranty.isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text: '$warranty ',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 3),
          PosColumn(text: "", width: 3),
        ]);
      }

      if (guarantee.isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text: '$guarantee ',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 3),
          PosColumn(text: "", width: 3),
        ]);
      }
      return bytes;
    });
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Sub-total',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(getTotalForOldInvoiceWithoutTax(), addComma: true),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: printTransactionModel.personalInformationModel.data?.vatName ?? 'VAT',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text:
              '${formatPointNumber(getTotalForOldInvoiceVat() + (printTransactionModel.transitionModel?.vatAmount ?? 0))}',
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
              (printTransactionModel.transitionModel?.discountAmount ?? 0) + getReturndDiscountAmount()),
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
          text: '${printTransactionModel.transitionModel?.shippingCharge ?? 0}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    if (printTransactionModel.transitionModel?.roundingAmount != 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Total',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: (formatPointNumber(printTransactionModel.transitionModel?.actualTotalAmount ?? 0)),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Rounding',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text:
                ("${!(printTransactionModel.transitionModel?.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber(printTransactionModel.transitionModel?.roundingAmount ?? 0)}"),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    ///_____Return_table_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.transitionModel?.salesReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) => element.isAtSameMomentAs(DateTime.tryParse(
                printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ??
            DateTime.now()))) {
          bytes += generator.row([
            PosColumn(
                text:
                    'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 7,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?.length ?? 0, (index) {
          returnedDates.add(DateTime.tryParse(
                  printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ??
              DateTime.now());
          final product = printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?[index];
          bytes += generator.row([
            PosColumn(
                text: productName(detailsId: product?.saleDetailId ?? 0),
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
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
      bytes += generator.row([
        PosColumn(
            text: 'Returned Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: getTotalReturndAmount(),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    bytes += generator.row([
      PosColumn(text: 'Total Payable', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: printTransactionModel.transitionModel?.totalAmount.toString() ?? '',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Paid Amount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: formatPointNumber(((printTransactionModel.transitionModel?.totalAmount ?? 0) -
                  (printTransactionModel.transitionModel?.dueAmount ?? 0)) +
              (printTransactionModel.transitionModel?.changeAmount ?? 0)),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if ((printTransactionModel.transitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Due Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.dueAmount ?? 0),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    if ((printTransactionModel.transitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.changeAmount ?? 0),
            width: 4,
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
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
    }
    bytes += generator.text(printTransactionModel.transitionModel?.saleDate ?? '',
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    if ((printTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }

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

  Future<List<int>> getSalesTicket80mm(
      {required PrintSalesTransactionModel printTransactionModel, required List<SalesDetails>? productList}) async {
    List<DateTime> returnedDates = [];
    String productName({required num detailsId}) {
      final details = productList?[productList.indexWhere((element) => element.id == detailsId)];
      return "${details?.product?.productName}${details?.product?.productType == ProductType.variant.name ? ' [${details?.stock?.batchNo ?? ""}]' : ''}";
    }

    num getProductQuantity({required num detailsId}) {
      num totalQuantity = productList!.where((element) => element.id == detailsId).first.quantities ?? 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              if (details.saleDetailId == detailsId) {
                totalQuantity += details.returnQty ?? 0;
              }
            }
          }
        }
      }

      return totalQuantity;
    }

    final transactions = printTransactionModel.transitionModel!.transactions ?? [];

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

    num getTotalForOldInvoiceWithoutTax() {
      num total = 0;
      for (var element in printTransactionModel.transitionModel!.salesDetails!) {
        total += ((element.priceWithoutTax ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
      }

      return total;
    }

    num productPrice({required num detailsId}) {
      return productList!.where((element) => element.id == detailsId).first.price ?? 0;
    }

    num getTotalReturndAmount() {
      num totalReturn = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
          if (returns.salesReturnDetails?.isNotEmpty ?? false) {
            for (var details in returns.salesReturnDetails!) {
              totalReturn += details.returnAmount ?? 0;
            }
          }
        }
      }
      return totalReturn;
    }

    num getReturndDiscountAmount() {
      num totalReturnDiscount = 0;
      if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
        for (var returns in printTransactionModel.transitionModel!.salesReturns!) {
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

    num getTotalForOldInvoiceVat() {
      num total = 0;
      for (var element in printTransactionModel.transitionModel!.salesDetails!) {
        total += (((element.price ?? 0) - (element.discount ?? 0)) * getProductQuantity(detailsId: element.id ?? 0)) -
            ((element.priceWithoutTax ?? 0) * getProductQuantity(detailsId: element.id ?? 0));
      }

      return total;
    }

    List<int> bytes = [];
    final _logo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.thermalInvoiceLogo}");

    //qr code
    final _qrlogo = await getNetworkImage("${printTransactionModel.personalInformationModel.data?.invoiceScannerLogo}");
    String printProfiles = printTransactionModel.personalInformationModel.data?.profilePrinter ?? 'default';

    CapabilityProfile profile = await CapabilityProfile.load(name: printProfiles);

    final generator = Generator(PaperSize.mm80, profile);

    // Check if Product Wise Discount is allowed
    final bool allowDiscount = printTransactionModel.personalInformationModel.data?.allowProductDiscount == 1;

    ///____________Image__________________________________
    if (printTransactionModel.personalInformationModel.data?.showThermalInvoiceLogo == 1) {
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
    if (printTransactionModel.personalInformationModel.data?.meta?.showCompanyName == 1) {
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.companyName ?? '',
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1);
    }
    if (printTransactionModel.transitionModel?.branch?.name != null) {
      bytes += generator.text('Branch: ${printTransactionModel.transitionModel?.branch?.name ?? ''}',
          styles: const PosStyles(align: PosAlign.center));
    }
    if (printTransactionModel.personalInformationModel.data?.meta?.showAddress == 1) {
      if (printTransactionModel.transitionModel?.branch?.address != null ||
          printTransactionModel.personalInformationModel.data?.address != null) {
        bytes += generator.text(
            'Address: ${printTransactionModel.transitionModel?.branch?.address ?? printTransactionModel.personalInformationModel.data?.address ?? ''}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }
    if (printTransactionModel.personalInformationModel.data?.meta?.showPhoneNumber == 1) {
      if (printTransactionModel.transitionModel?.branch?.phone != null ||
          printTransactionModel.personalInformationModel.data?.phoneNumber != null) {
        bytes += generator.text(
            'Mobile: ${printTransactionModel.transitionModel?.branch?.phone ?? printTransactionModel.personalInformationModel.data?.phoneNumber ?? ''}',
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

    ///__________Customer_and_time_section_______________________
    bytes += generator.row([
      PosColumn(
          text: 'Invoice: ${printTransactionModel.transitionModel?.invoiceNumber ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Date: ${DateFormat.yMd().format(DateTime.parse(printTransactionModel.transitionModel?.saleDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Name: ${printTransactionModel.transitionModel?.party?.name ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Time: ${DateFormat.jm().format(DateTime.parse(printTransactionModel.transitionModel?.saleDate ?? DateTime.now().toString()))}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Mobile: ${printTransactionModel.transitionModel?.party?.phone ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left)),
      PosColumn(
          text:
              'Sales By: ${printTransactionModel.transitionModel?.user?.role == "shop-owner" ? 'Admin' : printTransactionModel.transitionModel!.user?.name}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.emptyLines(1);

    ///____________Products_Section_________________________________
    bytes += generator.hr();
    if (allowDiscount) {
      bytes += generator.row([
        PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(text: 'Item', width: 4, styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(text: 'Qty', width: 1, styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(text: 'Dis.', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(text: 'Amount', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
    } else {
      bytes += generator.row([
        PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(text: 'Item', width: 5, styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(text: 'Amount', width: 2, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
    }
    bytes += generator.hr();

    List.generate(productList?.length ?? 1, (index) {
      final warrantyInfo = printTransactionModel.transitionModel?.salesDetails?[index].warrantyInfo;

      final warranty = (warrantyInfo?.warrantyDuration != null && warrantyInfo?.warrantyUnit != null)
          ? "Warranty : ${warrantyInfo?.warrantyDuration} ${warrantyInfo?.warrantyUnit}"
          : "";

      final guarantee = (warrantyInfo?.guaranteeDuration != null && warrantyInfo?.guaranteeUnit != null)
          ? "Guarantee : ${warrantyInfo?.guaranteeDuration} ${warrantyInfo?.guaranteeUnit}"
          : "";

      final name = "${productList?[index].product?.productName ?? ''}"
          "${productList?[index].product?.productType == ProductType.variant.name ? ' [${productList?[index].stock?.batchNo ?? ''}]' : ''}";

      final qty = getProductQuantity(detailsId: productList?[index].id ?? 0);
      final price = productList?[index].price ?? 0;
      final discount = productList?[index].discount ?? 0;

      // If discount is allowed, subtract from the amount column
      final amount = allowDiscount ? ((price * qty) - (discount * qty)) : (price * qty);

      if (allowDiscount) {
        bytes += generator.row([
          PosColumn(text: '${index + 1}', width: 1, styles: const PosStyles(align: PosAlign.left)),
          PosColumn(text: name, width: 4, styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: formatPointNumber(qty, addComma: true), width: 1, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(
              text: formatPointNumber(price, addComma: true),
              width: 2,
              styles: const PosStyles(align: PosAlign.center)),
          PosColumn(
              text: formatPointNumber(discount, addComma: true),
              width: 2,
              styles: const PosStyles(align: PosAlign.center)),
          PosColumn(
              text: formatPointNumber(amount, addComma: true),
              width: 2,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      } else {
        bytes += generator.row([
          PosColumn(text: '${index + 1}', width: 1, styles: const PosStyles(align: PosAlign.left)),
          PosColumn(text: name, width: 5, styles: const PosStyles(align: PosAlign.left)),
          PosColumn(
              text: formatPointNumber(qty, addComma: true), width: 2, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(
              text: formatPointNumber(price, addComma: true),
              width: 2,
              styles: const PosStyles(align: PosAlign.center)),
          PosColumn(
              text: formatPointNumber(amount, addComma: true),
              width: 2,
              styles: const PosStyles(align: PosAlign.right)),
        ]);
      }

      if (productList?[index].serialNumbers?.isNotEmpty ?? false) {
        bytes += generator.row([
          PosColumn(text: "", width: 1),
          PosColumn(
            text: 'SN: ${productList?[index].serialNumbers!.join(", ")}',
            width: allowDiscount ? 4 : 5,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(text: "", width: allowDiscount ? 1 : 2),
          PosColumn(text: "", width: 2),
          if (allowDiscount) PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 2),
        ]);
      }
      if (guarantee.isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text: '$guarantee ',
            width: allowDiscount ? 5 : 6, // Spans SL + Item columns
            styles: const PosStyles(
              align: PosAlign.left,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(text: "", width: allowDiscount ? 1 : 2),
          PosColumn(text: "", width: 2),
          if (allowDiscount) PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 2),
        ]);
      }

      if (warranty.isNotEmpty) {
        bytes += generator.row([
          PosColumn(
            text: '$warranty ',
            width: allowDiscount ? 5 : 6, // Spans SL + Item columns
            styles: const PosStyles(
              align: PosAlign.left,
              fontType: PosFontType.fontB,
            ),
          ),
          PosColumn(text: "", width: allowDiscount ? 1 : 2),
          PosColumn(text: "", width: 2),
          if (allowDiscount) PosColumn(text: "", width: 2),
          PosColumn(text: "", width: 2),
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
          text: formatPointNumber(getTotalForOldInvoiceWithoutTax(), addComma: true),
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
          text: formatPointNumber(getTotalForOldInvoiceVat() + (printTransactionModel.transitionModel?.vatAmount ?? 0),
              addComma: true),
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
              (printTransactionModel.transitionModel?.discountAmount ?? 0) + getReturndDiscountAmount(),
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
          text: formatPointNumber(printTransactionModel.transitionModel?.shippingCharge ?? 0, addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);

    if (printTransactionModel.transitionModel?.roundingAmount != 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Total:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: (formatPointNumber(printTransactionModel.transitionModel?.actualTotalAmount ?? 0, addComma: true)),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
      bytes += generator.row([
        PosColumn(
            text: 'Rounding:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text:
                ("${!(printTransactionModel.transitionModel?.roundingAmount?.isNegative ?? true) ? '+' : ''}${formatPointNumber(printTransactionModel.transitionModel?.roundingAmount ?? 0, addComma: true)}"),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }

    ///_____Return_table_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
      List.generate(printTransactionModel.transitionModel?.salesReturns?.length ?? 0, (i) {
        bytes += generator.hr();
        if (!returnedDates.any((element) => element.isAtSameMomentAs(DateTime.tryParse(
                printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ??
            DateTime.now()))) {
          bytes += generator.row([
            PosColumn(text: 'SL', width: 1, styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(
                text:
                    'Return-${DateFormat.yMd().format(DateTime.parse(printTransactionModel.transitionModel?.salesReturns?[i].returnDate ?? DateTime.now().toString()))}',
                width: 6,
                styles: const PosStyles(align: PosAlign.left, bold: true)),
            PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
            PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
          ]);
          bytes += generator.hr();
        }

        List.generate(printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?.length ?? 0, (index) {
          returnedDates.add(DateTime.tryParse(
                  printTransactionModel.transitionModel?.salesReturns?[i].returnDate?.substring(0, 10) ?? '') ??
              DateTime.now());
          final product = printTransactionModel.transitionModel?.salesReturns?[i].salesReturnDetails?[index];
          bytes += generator.row([
            PosColumn(
                text: '${index + 1}',
                width: 1,
                styles: const PosStyles(
                  align: PosAlign.left,
                )),
            PosColumn(
                text: productName(detailsId: product?.saleDetailId ?? 0),
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
                text: 'SN: ${product?.serialNumbers!.join(", ")}',
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

    ///_____Total Returned Amount_______________________________
    if (printTransactionModel.transitionModel?.salesReturns?.isNotEmpty ?? false) {
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
          text: formatPointNumber(printTransactionModel.transitionModel?.totalAmount ?? 0, addComma: true),
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
              ((printTransactionModel.transitionModel?.totalAmount ?? 0) -
                      (printTransactionModel.transitionModel?.dueAmount ?? 0)) +
                  (printTransactionModel.transitionModel?.changeAmount ?? 0),
              addComma: true),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if ((printTransactionModel.transitionModel?.dueAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Due Amount:',
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.dueAmount ?? 0, addComma: true),
            width: 3,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    }
    if ((printTransactionModel.transitionModel?.changeAmount ?? 0) > 0) {
      bytes += generator.row([
        PosColumn(
            text: 'Change Amount:',
            width: 9,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
        PosColumn(
            text: formatPointNumber(printTransactionModel.transitionModel?.changeAmount ?? 0, addComma: true),
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
      bytes += generator.text(printTransactionModel.personalInformationModel.data?.gratitudeMessage ?? '',
          styles: const PosStyles(align: PosAlign.center, bold: true));
    }
    bytes += generator.text(printTransactionModel.transitionModel?.saleDate ?? '',
        styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    if ((printTransactionModel.personalInformationModel.data?.invoiceNoteLevel != null ||
            printTransactionModel.personalInformationModel.data?.invoiceNote != null) &&
        printTransactionModel.personalInformationModel.data?.showNote == 1) {
      bytes += generator.text(
        '${printTransactionModel.personalInformationModel.data?.invoiceNoteLevel ?? ''}: ${printTransactionModel.personalInformationModel.data?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1,
      );
    }

    ///____________qr logo__________________________________
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
