//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Expense/Providers/all_expanse_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../../../widgets/multipal payment mathods/multi_payment_widget.dart';
import '../Model/expense_modle.dart';
import '../add_erxpense.dart';

class ExpenseRepo {
  Future<List<Expense>> fetchAllIExpense({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    final client = CustomHttpClientGet(client: http.Client());

    final Map<String, String> queryParams = {};

    if (type != null && type.isNotEmpty) {
      queryParams['duration'] = type;
    }

    if (type == 'custom_date') {
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['to_date'] = toDate;
      }
    }

    final Uri uri = Uri.parse('${APIConfig.url}/expenses').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('Request URI: $uri');

    final response = await client.get(url: uri);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      final list = parsed['data'] as List<dynamic>;
      return list.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Due List. Status code: ${response.statusCode}');
    }
  }

  // Future<List<Expense>> fetchExpense() async {
  //   CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
  //   final uri = Uri.parse('${APIConfig.url}/expenses');
  //
  //   final response = await clientGet.get(url: uri);
  //
  //   if (response.statusCode == 200) {
  //     final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
  //
  //     final partyList = parsedData['data'] as List<dynamic>;
  //     return partyList.map((category) => Expense.fromJson(category)).toList();
  //     // Parse into Party objects
  //   } else {
  //     throw Exception('Failed to fetch expense list');
  //   }
  // }

  Future<void> createExpense({
    required WidgetRef ref,
    required BuildContext context,
    required num amount,
    required num expenseCategoryId,
    required String expanseFor,
    required String referenceNo,
    required String expenseDate,
    required String note,
    required List<PaymentEntry> payments, // <<< Updated parameter
  }) async {
    final uri = Uri.parse('${APIConfig.url}/expenses');

    // Build the request body as a Map<String, String> for form-data
    // This will be sent as 'application/x-www-form-urlencoded'
    Map<String, String> requestBody = {
      'amount': amount.toString(),
      'expense_category_id': expenseCategoryId.toString(),
      'expanseFor': expanseFor,
      'referenceNo': referenceNo,
      'expenseDate': expenseDate,
      'note': note,
    };

    // Add payments in the format: payments[index][key]
    for (int i = 0; i < payments.length; i++) {
      final payment = payments[i];
      final paymentAmount = num.tryParse(payment.amountController.text) ?? 0;

      // Only add valid payments
      if (payment.type != null && paymentAmount > 0) {
        requestBody['payments[$i][type]'] = payment.type!;
        requestBody['payments[$i][amount]'] = paymentAmount.toString();

        if (payment.type == 'cheque' && payment.chequeNumberController.text.isNotEmpty) {
          requestBody['payments[$i][cheque_number]'] = payment.chequeNumberController.text;
        }
      }
    }

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      print('POST DATA OF EXPENSE: $requestBody');

      var responseData = await customHttpClient.post(
        url: uri,
        body: requestBody,
        addContentTypeInHeader: false,
      );

      final parsedData = jsonDecode(responseData.body);

      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(parsedData['message'] ?? 'Expense created successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Expense creation failed: ${parsedData['message']}')));
        return;
      }
    } catch (error) {
      EasyLoading.dismiss();
      // Handle unexpected errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
      // return null;
    }
  }
}
