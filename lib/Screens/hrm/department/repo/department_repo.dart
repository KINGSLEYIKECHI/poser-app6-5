import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/hrm/department/model/department_list_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../provider/department_list_provider.dart';

class DepartmentRepo {
  Future<DepartmentListModel> fetchAllDepartments() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/departments');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);

      return DepartmentListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch Department list');
    }
  }

  ///---------------- CREATE DEPARTMENT ----------------///
  Future<void> createDepartment({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String description,
    required String status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/departments');

    final requestBody = jsonEncode({
      'name': name,
      'description': description,
      'status': status,
    });

    try {
      EasyLoading.show(status: 'Creating...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.refresh(departmentListProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Department created')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department creation failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- UPDATE DEPARTMENT ----------------///
  Future<void> updateDepartment({
    required WidgetRef ref,
    required BuildContext context,
    required int id,
    required String name,
    required String description,
    required String status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/departments/$id');

    final requestBody = jsonEncode({
      '_method': 'put',
      'name': name,
      'description': description,
      'status': status,
    });

    try {
      EasyLoading.show(status: 'Updating...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.refresh(departmentListProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Department updated')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department update failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<bool> deleteDepartment({required String id, required BuildContext context, required WidgetRef ref}) async {
    try {
      final url = Uri.parse('${APIConfig.url}/departments/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting Department: ${response.statusCode} - ${response.body}');
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
