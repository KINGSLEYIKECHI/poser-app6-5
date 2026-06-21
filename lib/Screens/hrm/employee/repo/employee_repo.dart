import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/hrm/employee/model/employee_list_model.dart';
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/emplpyee_list_provider.dart';

class EmployeeRepo {
  Future<EmployeeListModel> fetchAllEmployee() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/employees');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);

      return EmployeeListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch Employee list');
    }
  }

  Future<void> saveEmployee({
    required WidgetRef ref,
    required BuildContext context,
    required Map<String, String> formData,
    required bool isEdit,
    required File? image,
    String? employeeId,
  }) async {
    final url = isEdit ? Uri.parse('${APIConfig.url}/employees/$employeeId') : Uri.parse('${APIConfig.url}/employees');

    try {
      EasyLoading.show(status: isEdit ? 'Updating...' : 'Saving...');

      final client = http.Client();

      // We assume CustomHttpClient handles form-data and authorization.
      CustomHttpClient customClient = CustomHttpClient(client: client, context: context, ref: ref);

      // We need to use post for both create and update (with _method: put)
      final response = await customClient.uploadFile(
        url: url,
        fields: formData, // Passing the map directly for form-data
        file: image,
        fileFieldName: 'image',
      );

      EasyLoading.dismiss();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh the main employee list provider after successful operation
        ref.invalidate(employeeListProvider);
        Navigator.pop(context);
        EasyLoading.showSuccess(isEdit ? 'Employee Updated Successfully' : 'Employee Saved Successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${data['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  ///________Delete_Employee______________________________________________________
  Future<bool> deleteEmployee({required String id, required BuildContext context, required WidgetRef ref}) async {
    try {
      final url = Uri.parse('${APIConfig.url}/employees/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting Employee: ${response.statusCode} - ${response.body}');
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
