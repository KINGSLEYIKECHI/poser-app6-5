import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../../bank account/provider/bank_account_provider.dart';
import '../model/cheques_list_model.dart';

final chequeListProvider = FutureProvider.autoDispose<ChequeTransactionModel>((ref) async {
  final repo = ChequeRepository();
  return repo.fetchChequeList(filter: 'Current Year');
});

class ChequeRepository {
  static const String _endpoint = '/cheques';

  // --- 1. FETCH LIST ---
  Future<ChequeTransactionModel> fetchChequeList({
    required String? filter,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    try {
      CustomHttpClientGet customHttpClientGet = CustomHttpClientGet(client: http.Client());
      final response = await customHttpClientGet.get(
        url: uri,
      );

      if (response.statusCode == 200) {
        return ChequeTransactionModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load cheques: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // --- 2. DEPOSIT Cheque (POST /api/v1/cheques) ---
  Future<void> depositCheque({
    required WidgetRef ref,
    required BuildContext context,
    required num chequeTransactionId,
    required dynamic paymentDestination,
    required String transferDate,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final Map<String, dynamic> fields = {
      'transaction_id': chequeTransactionId.toString(),
      'payment_type': paymentDestination.toString(),
      'date': transferDate,
      'note': description,
    };

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Depositing Cheque...');

      var response = await customHttpClient.post(
        url: uri,
        body: fields,
        permission: 'cheque_deposit_permit',
      );

      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(chequeListProvider);
        ref.invalidate(bankListProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Cheque Deposited Successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deposit Failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  // --- 3. RE-OPEN Cheque (POST /api/v1/cheque-reopen/{transaction_id}) ---
  Future<void> reOpenCheque({
    required WidgetRef ref,
    required BuildContext context,
    required num chequeTransactionId,
  }) async {
    // API Call: POST /cheque-reopen/{id}
    final uri = Uri.parse('${APIConfig.url}/cheque-reopen/$chequeTransactionId');

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Re-opening Cheque...');

      // Sending Empty body as the ID is in the URL
      var response = await customHttpClient.post(
        url: uri,
        body: {},
      );

      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success: Refresh Lists and Close Dialog
        ref.invalidate(chequeListProvider);
        ref.invalidate(bankListProvider);

        Navigator.pop(context); // Close the confirmation dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Cheque Re-opened Successfully!')),
        );
      } else {
        // API Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }
}
