import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/business_info_model.dart';
import '../../model/sale_transaction_model.dart';

Future<void> generatePurchaseReturnReportExcel(
  BuildContext context,
  List<PurchaseTransaction>? data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  EasyLoading.show(status: 'Generating Excel');

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Purchase Return Report'];

    // ---- DATE RANGE ----
    String fromStr = fromDate != null ? DateFormat('dd-MM-yyyy').format(fromDate) : '';
    String toStr = toDate != null ? DateFormat('dd-MM-yyyy').format(toDate) : '';

    // ---- TOTAL CALCULATION ----
    double total = 0;
    double totalPaid = 0;
    double totalDue = 0;
    num totalReturnedAmount = 0;

    if (data != null) {
      for (var item in data) {
        total += item.totalAmount ?? 0;
        totalPaid += item.paidAmount ?? 0;
        totalDue += item.dueAmount ?? 0;
      }
    }

    double getReturnedAmountForItem(item) {
      double returned = 0;

      for (var purchaseReturn in item.purchaseReturns ?? []) {
        for (var details in purchaseReturn.purchaseReturnDetails ?? []) {
          returned += details.returnAmount ?? 0;
        }
      }

      return returned;
    }

    if (data != null) {
      for (var item in data) {
        for (var purchaseReturn in item.purchaseReturns ?? []) {
          for (var details in purchaseReturn.purchaseReturnDetails ?? []) {
            totalReturnedAmount += details.returnAmount ?? 0;
          }
        }
      }
    }

    // ----------------------------- //
    //           HEADER ROWS         //
    // ----------------------------- //

    // Row 1: Company Name
    sheet.appendRow([TextCellValue(business?.data?.companyName ?? '')]);

    // Row 2: Report Title
    sheet.appendRow([TextCellValue('Purchase Returned Report')]);

    // Row 3: Duration
    sheet.appendRow([
      TextCellValue('Duration: $fromStr to $toStr'),
    ]);

    // Row 4: Empty Space
    sheet.appendRow([]);

    // Row 5: Table Headers
    final headerStartRow = sheet.maxRows;
    sheet.appendRow([
      TextCellValue('Reference'),
      TextCellValue('Date'),
      TextCellValue('Supplier'),
      TextCellValue('Status'),
      TextCellValue('Total'),
      TextCellValue('Paid'),
      TextCellValue('Due'),
      TextCellValue('Return Amount'),
    ]);

    // Apply bold header style
    for (int i = 0; i < 8; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerStartRow)).cellStyle;
    }

    // Row 6: Space before data
    sheet.appendRow([]);

    // ----------------------------- //
    //         TABLE DATA ROWS       //
    // ----------------------------- //

    if (data != null) {
      for (var item in data) {
        double returnedAmount = getReturnedAmountForItem(item);

        sheet.appendRow([
          TextCellValue(item.invoiceNumber ?? 'n/a'),
          TextCellValue(DateFormat('dd-MM-yyyy').format(DateTime.parse(item.purchaseDate.toString()))),
          TextCellValue(item.party?.name ?? 'n/a'),
          TextCellValue(item.isPaid == true ? 'Paid' : 'Unpaid'),
          TextCellValue((item.totalAmount ?? 0).toStringAsFixed(2)),
          TextCellValue((item.paidAmount ?? 0).toStringAsFixed(2)),
          TextCellValue((item.dueAmount ?? 0).toStringAsFixed(2)),
          TextCellValue(returnedAmount.toStringAsFixed(2)),
        ]);
      }
    }

    // ----------------------------- //
    //         TOTAL ROW             //
    // ----------------------------- //
    final totalRowIndex = sheet.maxRows;

    sheet.appendRow([
      TextCellValue('Total'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(total.toStringAsFixed(2)),
      TextCellValue(totalPaid.toStringAsFixed(2)),
      TextCellValue(totalDue.toStringAsFixed(2)),
      TextCellValue(totalReturnedAmount.toStringAsFixed(2)),
    ]);

    // Apply bold style
    for (int i = 0; i < 8; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: totalRowIndex)).cellStyle;
    }

    // ----------------------------- //
    //         SAVE FILE             //
    // ----------------------------- //
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${business?.data?.companyName ?? "Company"}_purchase_return_report.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    EasyLoading.showSuccess('Report Generated');
    await OpenFile.open(filePath);
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('Excel Generation Error: $e');
  }
}
