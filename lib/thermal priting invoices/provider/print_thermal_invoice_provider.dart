import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/Model/product_total_stock_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../Screens/Products/Model/product_model.dart';
import '../../Screens/Purchase/Model/purchase_transaction_model.dart' hide Product;
import '../../constant.dart';
import '../../model/sale_transaction_model.dart';
import '../model/print_transaction_model.dart';
import '../thermal_invoice_due.dart';
import '../thermal_invoice_purchase.dart';
import '../thermal_invoice_sales.dart';
import '../thermal_invoice_stock.dart';
import '../thermal_invoice_warehouse_transfer.dart';
import '../thermal_lebels_printing.dart';

/// Global provider for managing thermal printer state and operations.
final thermalPrinterProvider = ChangeNotifierProvider((ref) => ThermalPrinter());

/// A state management class responsible for handling Bluetooth connections
/// and routing print commands to the appropriate invoice templates.
class ThermalPrinter extends ChangeNotifier {
  List<BluetoothInfo> availableBluetoothDevices = [];
  bool isBluetoothConnected = false;

  /// Scans and retrieves a list of paired Bluetooth thermal printers.
  /// Updates the connection status and notifies listeners to rebuild the UI.
  Future<void> getBluetooth() async {
    availableBluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    isBluetoothConnected = await PrintBluetoothThermal.connectionStatus;
    notifyListeners();
  }

  /// Attempts to connect to a specific Bluetooth printer using its MAC address.
  /// Returns [true] if the connection is successful, [false] otherwise.
  Future<bool> setConnect(String mac) async {
    bool status = false;
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result == true) {
      isBluetoothConnected = true;
      status = true;
    }

    notifyListeners();
    return status;
  }

  /// Displays a Cupertino-style dialog listing all paired Bluetooth devices.
  /// Allows the user to select and connect to a specific printer.
  Future<dynamic> listOfBluDialog({required BuildContext context}) async {
    return showCupertinoDialog(
      context: context,
      builder: (_) {
        return WillPopScope(
          // Prevent closing the dialog by swiping or back button
          onWillPop: () async => false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: CupertinoAlertDialog(
              insetAnimationCurve: Curves.bounceInOut,
              title: const Text(
                'Connect Your Device',
                textAlign: TextAlign.start,
              ),
              content: SizedBox(
                // Dynamically adjust height based on the number of devices
                height: availableBluetoothDevices.isNotEmpty ? (availableBluetoothDevices.length * 80).toDouble() : 150,
                width: double.maxFinite,
                child: availableBluetoothDevices.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        itemCount: availableBluetoothDevices.length,
                        itemBuilder: (context1, index) {
                          final BluetoothInfo select = availableBluetoothDevices[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            onTap: () async {
                              // Attempt to connect when a device is tapped
                              bool isConnect = await setConnect(select.macAdress);
                              if (isConnect) {
                                finish(context1); // Close dialog on success
                              } else {
                                toast(lang.S.of(context1).tryAgain); // Show error on failure
                              }
                            },
                            title: Text(
                              select.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              lang.S.of(context1).clickToConnect,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          );
                        },
                      )
                    // Fallback UI when no Bluetooth devices are found
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bluetooth_disabled,
                              size: 40,
                              color: kMainColor,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Not available',
                              style: TextStyle(
                                fontSize: 14,
                                color: kGreyTextColor,
                              ),
                            )
                          ],
                        ),
                      ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    lang.S.of(context).cancel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    // Delay slightly for smoother animation closure
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Printing Operations
  // Each method checks for a Bluetooth connection first. If connected, it prints;
  // otherwise, it prompts the user to select a printer via the dialog.
  // ---------------------------------------------------------------------------

  /// Prints a thermal invoice for a sales transaction.
  Future<void> printSalesThermalInvoiceNow({
    required PrintSalesTransactionModel transaction,
    required List<SalesDetails>? productList,
    required BuildContext context,
  }) async {
    await getBluetooth();

    if (isBluetoothConnected) {
      SalesThermalPrinterInvoice().printSalesTicket(
        printTransactionModel: transaction,
        productList: productList,
        context: context,
      );
    } else {
      listOfBluDialog(context: context);
    }
  }

  /// Prints a thermal invoice for a purchase transaction.
  Future<void> printPurchaseThermalInvoiceNow({
    required PrintPurchaseTransactionModel transaction,
    required List<PurchaseDetails>? productList,
    required BuildContext context,
    required String? invoiceSize,
  }) async {
    await getBluetooth();

    if (isBluetoothConnected) {
      PurchaseThermalPrinterInvoice().printPurchaseThermalInvoice(
        printTransactionModel: transaction,
        productList: productList,
        context: context,
      );
    } else {
      listOfBluDialog(context: context);
    }
  }

  /// Prints a thermal invoice for due payments.
  Future<void> printDueThermalInvoiceNow({
    required PrintDueTransactionModel transaction,
    required String? invoiceSize,
    required BuildContext context,
  }) async {
    await getBluetooth();

    if (isBluetoothConnected) {
      DueThermalPrinterInvoice().printDueTicket(
        printDueTransactionModel: transaction,
        invoiceSize: invoiceSize,
        context: context,
      );
    } else {
      listOfBluDialog(context: context);
    }
  }

  /// Prints a thermal invoice for warehouse transfers.
  Future<void> printWhTransferThermalInvoice({
    required PrintWhTransferTransactionModel transaction,
    required String? invoiceSize,
    required BuildContext context,
  }) async {
    await getBluetooth();

    if (isBluetoothConnected) {
      WhTransferThermalPrinterInvoice().printWhTransferTicket(
        printWhTransferModel: transaction,
        invoiceSize: invoiceSize,
        context: context,
      );
    } else {
      listOfBluDialog(context: context);
    }
  }

  /// Prints a comprehensive stock inventory invoice.
  Future<void> printStockInvoiceNow({
    required List<Product> products,
    required BusinessInformationModel businessInformationModel,
    required BuildContext context,
    required ProductListResponse totalStock,
  }) async {
    await getBluetooth();

    if (isBluetoothConnected) {
      StockThermalPrinterInvoice().printStockTicket(
        businessInformationModel: businessInformationModel,
        productList: products,
        stock: totalStock,
      );
    } else {
      listOfBluDialog(context: context);
    }
  }

  /// Prints thermal labels for a specific list of products.
  Future<void> printLabelsNow({
    required List<Product> products,
    required BuildContext context,
  }) async {
    await getBluetooth();

    if (isBluetoothConnected) {
      SalesThermalLabels().printLabels(productList: products);
    } else {
      listOfBluDialog(context: context);
    }
  }
}
