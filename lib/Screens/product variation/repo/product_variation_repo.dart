// File: variation_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../model/product_variation_model.dart';
import '../provider/product_variation_provider.dart';

class VariationRepo {
  static const String _endpoint = '/variations';

  ///---------------- FETCH ALL VARIATIONS (GET) ----------------///
  Future<VariationListModel> fetchAllVariations() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return VariationListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch variation list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE VARIATION (POST) ----------------///
  Future<void> createVariation({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String values, // Comma separated string of values
    required String status, // "1" or "0"
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final requestBody = jsonEncode({
      'name': name,
      'values': values,
      'status': status,
    });

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Creating Variation...');
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.invalidate(variationListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Variation created successfully')),
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

  ///---------------- UPDATE VARIATION (PUT) ----------------///
  Future<void> updateVariation({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
    required String values,
    required String status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final requestBody = jsonEncode({
      '_method': 'put', // Use POST method with _method=put
      'name': name,
      'values': values,
      'status': status,
    });

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Updating Variation...');
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.invalidate(variationListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Variation updated successfully')),
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

  ///---------------- DELETE VARIATION ----------------///
  Future<bool> deleteVariation({
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
        ref.invalidate(variationListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Variation deleted successfully')),
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
