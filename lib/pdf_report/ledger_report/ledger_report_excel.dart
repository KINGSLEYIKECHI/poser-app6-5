import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../Screens/party ledger/model/party_ledger_model.dart';
import '../../model/business_info_model.dart';
import 'generate_pdf_date_range.dart';

Future<void> generateLedgerReportExcel(
  BuildContext context,
  List<PartyLedgerModel>? data,
  BusinessInformationModel business,
  DateTime? fromDate,
  DateTime? toDate,
  String selectedTime,
) async {
  EasyLoading.show(status: 'Generating Excel');

  try {
    if (data == null || data.isEmpty) {
      EasyLoading.showInfo('No transactions available');
      return;
    }

    // Create Excel
    final excel = Excel.createExcel();
    final sheet = excel['Party Ledger'];

    // ---------------------------
    //   CALCULATE TOTALS
    // ---------------------------
    double creditBalance = 0;
    double debitBalance = 0;

    // for (var item in data) {
    //   if (item.type == 'credit') {
    //     creditBalance += item.amount ?? 0;
    //   } else {
    //     debitBalance += item.amount ?? 0;
    //   }
    // }

    for (var item in data) {
      creditBalance += item.creditAmount ?? 0;
    }
    for (var item in data) {
      debitBalance += item.debitAmount ?? 0;
    }

    // ---------------------------
    //   DATE RANGE (same as PDF)
    // ---------------------------
    final pdfRange = getPdfDateRangeForSelectedTime(
      selectedTime,
      fromDate: fromDate,
      toDate: toDate,
    );

    final fromStr = pdfRange['from']!;
    final toStr = pdfRange['to']!;

    // ---------------------------
    //   HEADER SECTION
    // ---------------------------
    sheet.appendRow([
      // TextCellValue(business.data?.companyName ?? ''),
      TextCellValue(appsName),
    ]);

    sheet.appendRow([
      TextCellValue('Party Ledger'),
    ]);

    sheet.appendRow([
      TextCellValue('Duration: $fromStr to $toStr'),
    ]);

    sheet.appendRow([]); // empty space row

    // ---------------------------
    //   TABLE HEADER
    // ---------------------------
    final headerRow = sheet.maxRows;

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Reference No'),
      TextCellValue('Description'),
      TextCellValue('Credit'),
      TextCellValue('Debit'),
      TextCellValue('Balance'),
    ]);

    // Style header row (bold)
    for (int col = 0; col < 6; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: headerRow),
      );
      cell.cellStyle = CellStyle(bold: true);
    }

    sheet.appendRow([]);

    // ---------------------------
    //   TABLE DATA
    // ---------------------------
    for (var item in data) {
      bool isOpening = item.platform == 'opening_balance';

      sheet.appendRow([
        TextCellValue(DateFormat('dd-MM-yyyy').format(DateTime.parse(item.date.toString()))),
        TextCellValue(item.invoiceNumber ?? ''),
        TextCellValue(
          isOpening ? "Opening" : item.platform?.replaceAll('_', ' ') ?? 'Transaction',
        ),
        TextCellValue((item.creditAmount ?? 0).toStringAsFixed(2)),
        TextCellValue((item.debitAmount ?? 0).toStringAsFixed(2)),
        TextCellValue((item.balance ?? 0).toStringAsFixed(2)),
      ]);
    }

    // ---------------------------
    //   TOTAL ROW
    // ---------------------------
    final totalRow = sheet.maxRows;

    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Total'),
      TextCellValue(creditBalance.toStringAsFixed(2)),
      TextCellValue(debitBalance.toStringAsFixed(2)),
      TextCellValue((data.last.balance ?? 0).toStringAsFixed(2)),
    ]);

    // Make TOTAL row bold
    for (int col = 0; col < 6; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: totalRow),
      );
      cell.cellStyle = CellStyle(bold: true);
    }

    // ---------------------------
    //   SAVE FILE
    // ---------------------------
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final filePath = '${dir.path}/${business.data?.companyName ?? "Company"}_Ledger_Report_$timestamp.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    EasyLoading.showSuccess('Excel Generated Successfully!');
    await OpenFile.open(filePath);
  } catch (e) {
    EasyLoading.showError("Error: $e");
    debugPrint("Excel Error: $e");
  }
}

// Future<void> generateLedgerReportExcel(
//   BuildContext context,
//   List<PartyLedgerModel>? data,
//   BusinessInformationModel? business,
//   DateTime? fromDate,
//   DateTime? toDate,
// ) async {
//   EasyLoading.show(status: 'Generating Excel');
//
//   try {
//     if (data == null) {
//       EasyLoading.showError('Invalid data provided');
//       return;
//     }
//
//     // Create Excel file & sheet
//     final excel = Excel.createExcel();
//     final sheet = excel['Party Ledger'];
//
//     double creditBalance = 0;
//     double debitBalance = 0;
//
//     for (var item in data) {
//       if (item.type == 'credit') {
//         creditBalance += item.amount ?? 0;
//       } else {
//         debitBalance += item.amount ?? 0;
//       }
//     }
//
//     // ---------------------------
//     //   HEADER SECTION
//     // ---------------------------
//
//     // Row 1: Company Name
//     sheet.appendRow([
//       TextCellValue(business?.data?.companyName ?? ''),
//     ]);
//
//     // Row 2: Report Title
//     sheet.appendRow([
//       TextCellValue('Party Ledger'),
//     ]);
//
//     // Row 3: Date Range
//     if (fromDate != null && toDate != null) {
//       final String formattedFrom = DateFormat('dd-MM-yyyy').format(fromDate);
//       final String formattedTo = DateFormat('dd-MM-yyyy').format(toDate);
//
//       sheet.appendRow([
//         TextCellValue('Duration: $formattedFrom to $formattedTo'),
//       ]);
//     }
//
//     // Empty row
//     sheet.appendRow([]);
//
//     // ---------------------------
//     //   LEDGER TABLE HEADER
//     // ---------------------------
//     final headerRowIndex = sheet.maxRows;
//
//     sheet.appendRow([
//       TextCellValue('Date'),
//       TextCellValue('Invoice No'),
//       TextCellValue('Details'),
//       TextCellValue('Credit'),
//       TextCellValue('Debit'),
//       TextCellValue('Balance'),
//     ]);
//
//     // Add space row
//     sheet.appendRow([]);
//
//     // Apply bold style on table header
//     for (var i = 0; i < 6; i++) {
//       sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: headerRowIndex)).cellStyle;
//     }
//
//     // ---------------------------
//     //   LEDGER TABLE BODY
//     // ---------------------------
//     for (int i = 0; i < data.length; i++) {
//       final item = data[i];
//       final isOpening = item.platform == 'opening_balance';
//
//       sheet.appendRow([
//         TextCellValue(item.date ?? 'n/a'),
//         TextCellValue(item.invoiceNumber ?? ''),
//         TextCellValue(isOpening ? "Opening" : item.platform?.replaceAll('_', ' ') ?? 'Transaction'),
//         TextCellValue(item.type == 'credit' ? (item.amount ?? 0).toStringAsFixed(2) : '0.00'),
//         TextCellValue(item.type != 'credit' ? (item.amount ?? 0).toStringAsFixed(2) : '0.00'),
//         TextCellValue((item.balance ?? 0).toStringAsFixed(2)),
//       ]);
//     }
//
//     // ---------------------------
//     //   TOTAL ROW
//     // ---------------------------
//     final totalRowIndex = sheet.maxRows;
//
//     sheet.appendRow([
//       TextCellValue(''),
//       TextCellValue(''),
//       TextCellValue('Total'),
//       TextCellValue(creditBalance.toStringAsFixed(2)),
//       TextCellValue(debitBalance.toStringAsFixed(2)),
//       TextCellValue((data.last.balance ?? 0).toStringAsFixed(2)),
//     ]);
//
//     // Make total row bold
//     for (var i = 0; i < 6; i++) {
//       sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: totalRowIndex)).cellStyle;
//     }
//
//     // ---------------------------
//     //   SAVE FILE
//     // ---------------------------
//     final dir = await getApplicationDocumentsDirectory();
//     final filePath = '${dir.path}/${business?.data?.companyName ?? "Company"}_Ledger_Report.xlsx';
//
//     final file = File(filePath);
//     await file.writeAsBytes(excel.encode()!);
//
//     EasyLoading.showSuccess('Ledger Excel Generated!');
//     await OpenFile.open(filePath);
//   } catch (e) {
//     EasyLoading.showError('Error: $e');
//     debugPrint('Ledger Excel Error: $e');
//   }
// }
