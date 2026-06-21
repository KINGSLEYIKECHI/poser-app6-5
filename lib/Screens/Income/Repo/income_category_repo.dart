//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/Income/Providers/income_category_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../Model/income_category.dart';

class IncomeCategoryRepo {
  Future<List<IncomeCategory>> fetchAllIncomeCategory() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/income-categories');

    try {
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
        final categoryList = parsedData['data'] as List<dynamic>;
        return categoryList.map((category) => IncomeCategory.fromJson(category)).toList();
      } else {
        // Handle specific error cases based on response codes
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (error) {
      // Handle unexpected errors gracefully
      rethrow; // Re-throw to allow further handling upstream
    }
  }

  Future<void> addIncomeCategory({
    required WidgetRef ref,
    required BuildContext context,
    required String categoryName,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/income-categories');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var responseData = await customHttpClient.post(
      url: uri,
      body: {
        'categoryName': categoryName,
      },
    );

    EasyLoading.dismiss();

    try {
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
        var data1 = ref.refresh(incomeCategoryProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      // Handle unexpected errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }
}
