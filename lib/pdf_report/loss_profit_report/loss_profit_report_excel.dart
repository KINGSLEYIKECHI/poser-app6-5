import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/business_info_model.dart';
import '../../model/loss_profit_model.dart' as lpmodel;

Future<void> generateLossProfitReportExcel(
  BuildContext context,
  lpmodel.LossProfitModel data,
  BusinessInformationModel? business,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  EasyLoading.show(status: 'Generating Excel');

  try {
    final excel = Excel.createExcel();
    final sheet = excel['Loss & Profit Report'];

    // ---- DATE RANGE ----
    String fromStr = fromDate != null ? DateFormat('dd-MM-yyyy').format(fromDate) : '';
    String toStr = toDate != null ? DateFormat('dd-MM-yyyy').format(toDate!) : '';

    // ---- TOTAL CALCULATIONS ----
    double totalProfit = 0;
    double totalLoss = 0;
    /*

    if (data != null) {
      for (var item in data) {
        final profit = item.detailsSumLossProfit ?? 0;

        if (profit.isNegative) {
          totalLoss += profit;
        } else {
          totalProfit += profit;
        }
      }
    }

    // ----------------------------- //
    //           HEADER ROWS
    // ----------------------------- //

    // Row 1: Company Name
    sheet.appendRow([TextCellValue(business?.data?.companyName ?? '')]);

    // Row 2: Report Title
    sheet.appendRow([TextCellValue('Loss & Profit Report')]);

    // Row 3: Duration
    sheet.appendRow([
      TextCellValue('Duration: $fromStr to $toStr'),
    ]);

    // Row 4: Empty Space
    sheet.appendRow([]);

    // Row 5: Header Row
    final headerStartRow = sheet.maxRows;

    sheet.appendRow([
      TextCellValue('SL'),
      TextCellValue('Invoice'),
      TextCellValue('Date'),
      TextCellValue('Name'),
      TextCellValue('Status'),
      TextCellValue('Total'),
      TextCellValue('Profit'),
      TextCellValue('Loss'),
    ]);

    // Style header bold (Excel library is limited but kept same structure)
    for (int i = 0; i < 8; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerStartRow)).cellStyle;
    }

    // Space before data
    sheet.appendRow([]);

    // ----------------------------- //
    //             DATA ROWS
    // ----------------------------- //

    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        final item = data[i];

        sheet.appendRow([
          TextCellValue('${i + 1}'),
          TextCellValue(item.invoiceNumber ?? 'n/a'),
          TextCellValue(DateFormat('dd-MM-yyyy').format(DateTime.parse(item.saleDate.toString()))),
          TextCellValue(item.party?.name ?? 'n/a'),
          TextCellValue(item.isPaid == true ? 'Paid' : 'Unpaid'),
          TextCellValue(item.totalAmount.toString()),
          TextCellValue(!item.detailsSumLossProfit!.isNegative ? item.detailsSumLossProfit.toString() : '0'),
          TextCellValue(item.detailsSumLossProfit!.isNegative ? item.detailsSumLossProfit.toString() : '0'),
        ]);
      }
    }

    // ----------------------------- //
    //         TOTAL ROW
    // ----------------------------- //

    final totalRow = sheet.maxRows;

    sheet.appendRow([
      TextCellValue(''),
      TextCellValue('Total'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(totalProfit.toStringAsFixed(2)),
      TextCellValue(totalLoss.toStringAsFixed(2)),
    ]);

    // Style total row
    for (int i = 0; i < 8; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: totalRow)).cellStyle;
    }
    */

    // ----------------------------- //
    //       SAVE FILE & OPEN
    // ----------------------------- //

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${business?.data?.companyName ?? "Company"}_Loss_Profit_Report.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    EasyLoading.showSuccess('Excel Generated');
    await OpenFile.open(filePath);
  } catch (e) {
    EasyLoading.showError('Error: $e');
    print('Excel Generation Error: $e');
  }
}
