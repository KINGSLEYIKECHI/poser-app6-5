import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../Const/api_config.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../../../widgets/multipal payment mathods/multi_payment_widget.dart';
import '../Model/income_modle.dart';

class IncomeRepo {
  Future<List<Income>> fetchAllIncome({
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

    final Uri uri = Uri.parse('${APIConfig.url}/incomes').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('Request URI: $uri');

    final response = await client.get(url: uri);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      final list = parsed['data'] as List<dynamic>;
      return list.map((json) => Income.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Due List. Status code: ${response.statusCode}');
    }
  }

  Future<void> createIncome({
    required WidgetRef ref,
    required BuildContext context,
    required num amount,
    required num incomeCategoryId,
    required String incomeFor, // Renamed from expanseFor
    required String referenceNo,
    required String incomeDate, // Renamed from expenseDate
    required String note,
    required List<PaymentEntry> payments, // <<< Updated parameter
  }) async {
    final uri = Uri.parse('${APIConfig.url}/incomes');

    // Build the request body as a Map<String, String> for form-data
    Map<String, String> requestBody = {
      'amount': amount.toString(),
      'income_category_id': incomeCategoryId.toString(),
      'incomeFor': incomeFor,
      'referenceNo': referenceNo,
      'incomeDate': incomeDate,
      'note': note,
    };

    // Add payments in the format: payments[index][key]
    for (int i = 0; i < payments.length; i++) {
      final payment = payments[i];
      final paymentAmount = num.tryParse(payment.amountController.text) ?? 0;

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

      var responseData = await customHttpClient.post(
        url: uri,
        body: requestBody, // Send the Map directly
        // Set to false to send as x-www-form-urlencoded
        addContentTypeInHeader: false,
      );

      final parsedData = jsonDecode(responseData.body);

      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        // Refresh income-related providers

        Navigator.pop(context, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(parsedData['message'] ?? 'Income created successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Income creation failed: ${parsedData['message']}')));
        return;
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }
}
