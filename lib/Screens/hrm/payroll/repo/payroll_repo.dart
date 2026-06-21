// File: payroll_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Const/api_config.dart';
import '../../../../../http_client/custome_http_client.dart';
import '../../../../../http_client/customer_http_client_get.dart';
import '../Model/payroll_lsit_model.dart';
import '../provider/payroll_provider.dart';

class PayrollRepo {
  static const String _endpoint = '/payrolls';

  ///---------------- FETCH ALL PAYROLLS (GET) ----------------///
  Future<PayrollListModel> fetchAllPayrolls() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return PayrollListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch payroll list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE PAYROLL (POST) ----------------///
  Future<void> createPayroll({
    required WidgetRef ref,
    required BuildContext context,
    required num employeeId,
    required String month,
    required String date, // YYYY-MM-DD
    required String amount,
    required String paymentYear,
    required List<Map<String, dynamic>> payments,
    String? note,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final requestBody = jsonEncode({
      'employee_id': employeeId,
      'payments': payments,
      'month': month.toLowerCase(),
      'date': date,
      'amount': amount,
      'payemnt_year': paymentYear,
      'note': note,
    });

    try {
      EasyLoading.show(status: 'Creating Payroll...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        addContentTypeInHeader: true,
        url: uri,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.invalidate(payrollListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Payroll created successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Creation failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- UPDATE PAYROLL (POST with _method=put) ----------------///
  Future<void> updatePayroll({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required num employeeId,
    required String month,
    required String date,
    required String amount,
    required String paymentYear,
    required List<Map<String, dynamic>> payments,
    String? note,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final requestBody = jsonEncode({
      '_method': 'put',
      'employee_id': employeeId,
      'payments': payments,
      'month': month.toLowerCase(),
      'date': date,
      'amount': amount,
      'payemnt_year': paymentYear,
      'note': note,
    });

    try {
      EasyLoading.show(status: 'Updating Payroll...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();
      print('Payroll Update POST:-------> ${requestBody}');
      print('Payroll Update:-------> ${parsedData}');

      if (responseData.statusCode == 200) {
        ref.invalidate(payrollListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Payroll updated successfully')),
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

  ///---------------- DELETE PAYROLL ----------------///
  Future<bool> deletePayroll({
    required num id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      final url = Uri.parse('${APIConfig.url}$_endpoint/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.invalidate(payrollListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payroll deleted successfully')),
        );
        return true;
      } else {
        final parsedData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
        return false;
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during deletion: $error')),
      );
      return false;
    }
  }
}
