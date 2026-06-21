// File: bank_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../model/bank_account_list_model.dart';
import '../provider/bank_account_provider.dart';

class BankRepo {
  static const String _endpoint = '/banks';

  ///---------------- FETCH ALL BANKS (GET) ----------------///
  Future<BankListModel> fetchAllBanks() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return BankListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch bank list. Status: ${response.statusCode}');
    }
  }

  // Helper to construct API body from core data and meta data
  Map<String, dynamic> _buildBody({
    required String name,
    required num openingBalance,
    required String openingDate,
    required num showInInvoice,
    required BankMeta meta,
    num? branchId,
  }) {
    // NOTE: API requires meta fields to be nested meta[key] in form-data.
    // When sending JSON, we flatten the meta data and prefix it.

    // Convert meta to flat fields with 'meta[key]' prefix
    final metaFields = meta.toApiMetaJson().map((key, value) => MapEntry(key, value));

    return {
      'name': name,
      'branch_id': branchId, // Assuming branchId is managed separately or is nullable
      'opening_balance': openingBalance,
      'opening_date': openingDate, // YYYY-MM-DD format
      'show_in_invoice': showInInvoice,
      ...metaFields // Flattened meta fields
    };
  }

  ///---------------- CREATE BANK (POST) ----------------///
  Future<void> createBank({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required num openingBalance,
    required String openingDate,
    required num showInInvoice,
    required BankMeta meta,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final requestBody = jsonEncode(_buildBody(
      name: name,
      openingBalance: openingBalance,
      openingDate: openingDate,
      showInInvoice: showInInvoice,
      meta: meta,
    ));

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Creating Bank...');
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
        permission: 'bank_create_permit', // Assuming permit exists
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();
      print('Add Bank Response: $parsedData');

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.invalidate(bankListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Bank Account created successfully')),
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

  ///---------------- UPDATE BANK (PUT) ----------------///
  Future<void> updateBank({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
    required num openingBalance,
    required String openingDate,
    required num showInInvoice,
    required BankMeta meta,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final baseBody = _buildBody(
      name: name,
      openingBalance: openingBalance,
      openingDate: openingDate,
      showInInvoice: showInInvoice,
      meta: meta,
    );
    // Add PUT method override
    baseBody['_method'] = 'put';

    final requestBody = jsonEncode(baseBody);

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Updating Bank...');
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
        permission: 'bank_update_permit', // Assuming permit exists
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.invalidate(bankListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Bank Account updated successfully')),
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

  ///---------------- DELETE BANK ----------------///
  Future<bool> deleteBank({
    required num id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      final url = Uri.parse('${APIConfig.url}$_endpoint/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: url,
        permission: 'bank_delete_permit', // Assuming permit exists
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.invalidate(bankListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank Account deleted successfully')),
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
