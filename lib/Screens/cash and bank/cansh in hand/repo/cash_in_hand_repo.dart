// File: cash_transaction_repo.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/http_client/customer_http_client_get.dart';

// --- Local Imports ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../bank account/provider/bank_account_provider.dart';
import '../model/cash_transaction_list_model.dart';
import '../provider/cash_in_hand_provider.dart';

class CashTransactionRepo {
  static const String _endpoint = '/cashes';

  // --- FETCH Cash Transactions ---
  Future<CashTransactionModel> fetchCashTransactions({
    required String? filter,
  }) async {
    // NOTE: Filter logic (date range) would be implemented here in the real code
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    try {
      CustomHttpClientGet customHttpClient = CustomHttpClientGet(client: http.Client());
      final response = await customHttpClient.get(
        url: uri,
      );

      if (response.statusCode == 200) {
        return CashTransactionModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load cash data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  ///---------------- CREATE CASH TRANSFER (e.g., Cash to Bank) (POST - FORM-DATA) ----------------///
  Future<void> createCashTransfer({
    required WidgetRef ref,
    required BuildContext context,
    required num fromBankId, // Should be 0 for Cash
    required num toBankId, // Destination Bank ID
    required num amount,
    required String date, // YYYY-MM-DD
    required String transactionType, // Should be 'cash_to_bank'
    required String type,
    String? note,
    File? image, // Optional image file
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final Map<String, String> fields = {
      // NOTE: API expects 'from' to be the bank ID or cash identifier, 'to' is the destination
      'transaction_type': transactionType,
      'amount': amount.toString(),
      'date': date,
      'from': 'Cash',
      if (transactionType != 'adjust_cash') 'to': toBankId.toString(),
      'note': note ?? '',
      'type': type,
      // 'platform': 'cash', // Platform should be 'cash' for this endpoint
    };
    print('POSTING DATA: $fields');

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Transferring...');

      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        file: image,
        fileFieldName: 'image',
        fields: fields,
      );

      var response = await http.Response.fromStream(streamedResponse);
      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(cashTransactionHistoryProvider); // Refresh Cash History
        ref.invalidate(bankListProvider); // Refresh Bank List (since a bank balance changed)

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Transfer successful')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- UPDATE CASH TRANSFER (e.g., Cash to Bank) (POST/PUT/PATCH - FORM-DATA) ----------------///
  Future<void> updateCashTransfer({
    required WidgetRef ref,
    required BuildContext context,
    required num transactionId,
    required num fromBankId, // Should be 0 for Cash
    required num toBankId, // Destination Bank ID
    required num amount,
    required String date, // YYYY-MM-DD
    required String transactionType, // Should be 'cash_to_bank'
    required String type,
    String? note,
    File? image, // Optional: New image file to upload
    String? existingImageUrl, // Optional: Used to determine if image was removed
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$transactionId');

    final Map<String, String> fields = {
      'transaction_type': transactionType,
      'amount': amount.toString(),
      'date': date,
      'from': fromBankId.toString(),
      if (transactionType != 'adjust_cash')'to': toBankId.toString(),
      'note': note ?? '',
      'type': type,
      'platform': 'cash',
      '_method': 'PUT',
      'image_removed': (image == null && existingImageUrl == null) ? '1' : '0',
    };

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Updating...');

      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        file: image,
        fileFieldName: 'image',
        fields: fields,
        permission: 'cash_transaction_edit_permit',
      );

      var response = await http.Response.fromStream(streamedResponse);
      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(cashTransactionHistoryProvider); // Refresh Cash History
        ref.invalidate(bankListProvider); // Refresh Bank List

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Update successful')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  // --- DELETE Cash Transaction ---
  Future<bool> deleteCashTransaction({
    required WidgetRef ref,
    required BuildContext context,
    required num transactionId,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$transactionId');

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Deleting...');

      var response = await customHttpClient.delete(
        url: uri,
        permission: 'cash_transaction_delete_permit',
      );

      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 204) {
        ref.invalidate(cashTransactionHistoryProvider); // Refresh the cash history list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Transaction deleted successfully!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
        return false;
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
      return false;
    }
  }
}
