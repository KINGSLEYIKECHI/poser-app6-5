// File: bank_transaction_repo.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../bank account/provider/bank_account_provider.dart';
import '../../bank account/provider/bank_transfers_history_provider.dart';
// Note: We don't need a specific provider for transactions list update right now.

class BankTransactionRepo {
  static const String _endpoint = '/bank-transactions';

  ///---------------- CREATE BANK TO BANK TRANSFER (POST - FORM-DATA) ----------------///
  Future<void> createBankTransfer({
    required WidgetRef ref,
    required BuildContext context,
    required num fromBankId,
    num? toBankId,
    required num amount,
    required String date, // YYYY-MM-DD
    required String transactionType,
    required String type,
    String? note,
    File? image, // Optional image file
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    // Prepare fields for MultipartRequest
    final Map<String, String> fields = {
      'transaction_type': transactionType,
      'amount': amount.toString(),
      'date': date,
      'from': fromBankId.toString(),
      'to': toBankId.toString(),
      'note': note ?? '',
      'type': type,
    };

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      print(fields);
      EasyLoading.show(status: 'Transferring...');

      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        file: image,
        fileFieldName: 'image',
        fields: fields,
        permission: 'bank_transaction_create_permit',
      );

      var response = await http.Response.fromStream(streamedResponse);
      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(bankListProvider); // Invalidate bank list to update balances
        ref.invalidate(bankTransactionHistoryProvider); // Invalidate history
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

  ///---------------- UPDATE BANK TO BANK TRANSFER/ADJUSTMENT (PUT/PATCH - FORM-DATA) ----------------///
  Future<void> updateBankTransfer({
    required WidgetRef ref,
    required BuildContext context,
    required num transactionId, // New: ID of the transaction being updated
    required num fromBankId,
    num? toBankId,
    required num amount,
    required String date, // YYYY-MM-DD
    required String transactionType,
    required String type,
    String? note,
    File? image, // Optional: New image file to upload
    String? existingImageUrl, // Optional: Used to determine if image was removed
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$transactionId');

    // Prepare fields for MultipartRequest
    final Map<String, String> fields = {
      'transaction_type': transactionType,
      'amount': amount.toString(),
      'date': date,
      'from': fromBankId.toString(),
      'to': toBankId.toString(),
      'note': note ?? '',
      'type': type,
      '_method': 'PUT', // Important: Tells backend this is a PUT/PATCH request

      'image_removed': (image == null && existingImageUrl == null) ? '1' : '0',
    };

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      print(fields);
      EasyLoading.show(status: 'Updating...');

      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        file: image, // Will upload new image if present
        fileFieldName: 'image',
        fields: fields,
        permission: 'bank_transaction_edit_permit', // Assuming a different permission for editing
      );

      var response = await http.Response.fromStream(streamedResponse);
      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(bankListProvider); // Invalidate bank list to update balances
        ref.invalidate(bankTransactionHistoryProvider); // Invalidate history

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

  ///---------------- DELETE BANK TRANSACTION (DELETE) ----------------///
  Future<bool> deleteBankTransaction({
    required WidgetRef ref,
    required BuildContext context,
    required num transactionId,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$transactionId');

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Deleting...');

      // Assuming your CustomHttpClient has a standard method for DELETE requests
      // If not, you'll need to use http.delete(uri, headers: customHttpClient.headers) directly.
      var response = await customHttpClient.delete(
        url: uri,
        permission: 'bank_transaction_delete_permit', // Assuming required permission
      );

      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 204) {
        ref.invalidate(bankListProvider); // Refresh bank balances
        ref.invalidate(bankTransactionHistoryProvider); // Refresh history list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Transaction deleted successfully!')),
        );
        // Do NOT pop here; let the calling widget handle navigation (e.g., pop from the list view)
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
