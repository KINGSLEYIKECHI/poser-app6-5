import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/due_collection_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/business_info_model.dart';
import '../../model/sale_transaction_model.dart';
import 'due_status.dart';

Future<void> generateDueReportExcel(
  BuildContext context,
  List<DueCollection>? data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  EasyLoading.show(status: 'Generating Excel');

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];

    // ---- DATE RANGE ----
    String fromStr = fromDate != null ? DateFormat('dd-MM-yyyy').format(fromDate) : '';
    String toStr = toDate != null ? DateFormat('dd-MM-yyyy').format(toDate!) : '';

    // ---- TOTAL CALCULATION ----
    double total = 0;
    double totalPaid = 0;
    double totalDue = 0;

    if (data != null) {
      for (var item in data) {
        total += item.totalDue ?? 0;
        totalPaid += item.payDueAmount ?? 0;
        totalDue += item.dueAmountAfterPay ?? 0;
      }
    }

    // ----------------------------- //
    //           HEADER ROWS         //
    // ----------------------------- //

    // Row 1: Company Name
    sheet.appendRow([TextCellValue(business?.data?.companyName ?? '')]);

    // Row 2: Report Title
    sheet.appendRow([TextCellValue('Due Report')]);

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
      TextCellValue('Name'),
      TextCellValue('Status'),
      TextCellValue('Total'),
      TextCellValue('Paid'),
      TextCellValue('Due'),
    ]);

    // Apply bold header style
    for (int i = 0; i < 7; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerStartRow)).cellStyle;
    }

    // Row 6: Space before data
    sheet.appendRow([]);

    // ----------------------------- //
    //         TABLE DATA ROWS       //
    // ----------------------------- //

    if (data != null) {
      for (var item in data) {
        final status = getDueStatus(item);
        sheet.appendRow([
          TextCellValue(item.invoiceNumber ?? 'n/a'),
          TextCellValue(DateFormat('dd-MM-yyyy').format(DateTime.parse(item.paymentDate.toString()))),
          TextCellValue(item.party?.name ?? item.sale?.invoiceNumber ?? 'n/a'),
          TextCellValue(status),
          TextCellValue((item.totalDue ?? 0).toStringAsFixed(2)),
          TextCellValue((item.payDueAmount ?? 0).toStringAsFixed(2)),
          TextCellValue((item.dueAmountAfterPay ?? 0).toStringAsFixed(2)),
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
    ]);

    // Apply bold style
    for (int i = 0; i < 7; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: totalRowIndex)).cellStyle;
    }

    // ----------------------------- //
    //         SAVE FILE             //
    // ----------------------------- //
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${business?.data?.companyName ?? "Company"}_Due_Report.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    EasyLoading.showSuccess('Report Generated');
    await OpenFile.open(filePath);
  } catch (e) {
    EasyLoading.showError('Error: $e');
    debugPrint('Excel Generation Error: $e');
  }
}
