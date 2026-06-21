// File: rack_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart'; // YOUR CUSTOM HTTP CLIENT
import '../../../../http_client/customer_http_client_get.dart';
import '../model/product_racks_model.dart';
import '../provider/product_recks_provider.dart';

class RackRepo {
  static const String _endpoint = '/racks';

  ///---------------- FETCH ALL RACKS (GET) ----------------///
  Future<RackListModel> fetchAllRacks() async {
    // This remains unchanged, using CustomHttpClientGet
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return RackListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch rack list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE RACK (POST - USING UPLOAD FILE FOR FORM-DATA) ----------------///
  Future<void> createRack({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required List<num> shelfIds,
    required String status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    // Prepare fields for MultipartRequest
    final Map<String, String> fields = {
      'name': name,
      'status': status,
    };

    // Add shelf_id[] as multiple fields (Multipart Request handles array fields easily)
    for (int i = 0; i < shelfIds.length; i++) {
      fields['shelf_id[$i]'] = shelfIds[i].toString();
      // NOTE: Using 'shelf_id[i]' indexing is a common way to ensure PHP/Laravel
      // recognizes the array input in form-data.
    }

    // Initialize CustomHttpClient
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Creating Rack...');

      // Use uploadFile method for form-data submission (even without a file)
      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        fields: fields,
        // NOTE: Replace 'rack_create_permit' with your actual Permit.value
        permission: 'rack_create_permit',
      );

      // Convert StreamedResponse to standard Response for easy parsing
      var response = await http.Response.fromStream(streamedResponse);

      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.invalidate(rackListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Rack created successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Creation failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      // Catching the "Permission denied" exception thrown by CustomHttpClient
      if (error.toString().contains("Permission denied")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied to create rack.'), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    }
  }

  ///---------------- UPDATE RACK (POST with _method=put - USING UPLOAD FILE) ----------------///
  Future<void> updateRack({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
    required List<num> shelfIds,
    required String status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final Map<String, String> fields = {
      '_method': 'put', // Simulate PUT
      'name': name,
      'status': status,
    };

    // Add shelf_id[]
    for (int i = 0; i < shelfIds.length; i++) {
      fields['shelf_id[$i]'] = shelfIds[i].toString();
    }

    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    try {
      EasyLoading.show(status: 'Updating Rack...');

      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        fields: fields,
        // NOTE: Replace 'rack_update_permit' with your actual Permit.value
        permission: 'rack_update_permit',
      );

      var response = await http.Response.fromStream(streamedResponse);
      final parsedData = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        ref.invalidate(rackListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Rack updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      if (error.toString().contains("Permission denied")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied to update rack.'), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    }
  }

  ///---------------- DELETE RACK (DELETE - USING CustomHttpClient) ----------------///
  Future<bool> deleteRack({
    required num id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final url = Uri.parse('${APIConfig.url}$_endpoint/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());

    try {
      EasyLoading.show(status: 'Deleting...');

      // Use the standard delete method
      final response = await customHttpClient.delete(
        url: url,
        // NOTE: Replace 'rack_delete_permit' with your actual Permit.value
        permission: 'rack_delete_permit',
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.invalidate(rackListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rack deleted successfully')),
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
      if (error.toString().contains("Permission denied")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission denied to delete rack.'), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during deletion: $error')),
        );
      }
      return false;
    }
  }
}
