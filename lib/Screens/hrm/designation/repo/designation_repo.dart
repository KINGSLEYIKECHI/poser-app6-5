// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/hrm/designation/Model/designation_list_model.dart';
import 'package:mobile_pos/Screens/hrm/designation/provider/designation_list_provider.dart';
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';

class DesignationRepo {
  Future<DesignationListModel> fetchAllDesignation() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/designations');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);

      return DesignationListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch Designation list');
    }
  }

  /// Create Designation
  Future<void> createDesignation({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String status,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/designations');
    final body = jsonEncode({
      'name': name,
      'status': status == 'Active' ? '1' : "0",
      'description': description,
    });

    try {
      CustomHttpClient client = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      final response = await client.post(
        url: uri,
        addContentTypeInHeader: true,
        body: body,
      );

      final data = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        ref.refresh(designationListProvider);
        Navigator.pop(context);
        EasyLoading.showSuccess('Designation Created Successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${data['message']}')));
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Update Designation
  Future<void> updateDesignation({
    required WidgetRef ref,
    required BuildContext context,
    required String id,
    required String name,
    required String status,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/designations/$id');
    final body = jsonEncode({
      '_method': 'put',
      'name': name,
      'status': status == 'Active' ? '1' : "0",
      'description': description,
    });

    try {
      CustomHttpClient client = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      final response = await client.post(
        url: uri,
        addContentTypeInHeader: true,
        body: body,
      );

      final data = jsonDecode(response.body);
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        ref.refresh(designationListProvider);
        Navigator.pop(context);
        EasyLoading.showSuccess('Designation Updated Successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${data['message']}')));
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  ///________Delete_Designations______________________________________________________
  Future<bool> deleteDesignation({required String id, required BuildContext context, required WidgetRef ref}) async {
    try {
      final url = Uri.parse('${APIConfig.url}/designations/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting Designations: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error during delete operation: $error');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
