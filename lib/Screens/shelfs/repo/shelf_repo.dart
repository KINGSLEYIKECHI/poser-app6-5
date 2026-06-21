// File: shelf_repo.dart (FINAL CODE WITHOUT DESCRIPTION)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports (Ensure these paths are correct for your project) ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../model/shelf_list_model.dart';
import '../provider/shelf_provider.dart';


class ShelfRepo {

  static const String _endpoint = '/shelfs';


  ///---------------- FETCH ALL SHELVES (GET) ----------------///
  Future<ShelfListModel> fetchAllShelves() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return ShelfListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch shelf list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE SHELF (POST) ----------------///
  Future<void> createShelf({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    // Description removed from parameters
    required String status, // "1" or "0"
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final requestBody = jsonEncode({
      'name': name,
      'status': status,
    });

    try {
      EasyLoading.show(status: 'Creating Shelf...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.invalidate(shelfListProvider); // Refresh list on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Shelf created successfully')),
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

  ///---------------- UPDATE SHELF (PUT) ----------------///
  Future<void> updateShelf({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
    required String status, // "1" or "0"
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final requestBody = jsonEncode({
      '_method': 'put', // Use POST method with _method=put
      'name': name,
      'status': status,
    });

    try {
      EasyLoading.show(status: 'Updating Shelf...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.invalidate(shelfListProvider); // Refresh list on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Shelf updated successfully')),
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

  ///---------------- DELETE SHELF (DELETE) ----------------///
  Future<bool> deleteShelf({
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
        ref.invalidate(shelfListProvider); // Refresh list on success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shelf deleted successfully')),
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