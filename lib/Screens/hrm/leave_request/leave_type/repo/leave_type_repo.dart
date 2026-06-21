// File: leave_type_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports ---
import '../../../../../Const/api_config.dart';
import '../../../../../http_client/custome_http_client.dart';
import '../../../../../http_client/customer_http_client_get.dart';
import '../model/leave_type_list_model.dart';
import '../provider/leave_type_list_provider.dart';

class LeaveTypeRepo {
  static const String _endpoint = '/leave-types';

  ///---------------- FETCH ALL LEAVE TYPES ----------------///
  Future<LeaveTypeListModel> fetchAllLeaveTypes() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return LeaveTypeListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch leave types list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE LEAVE TYPE ----------------///
  Future<void> createLeaveType({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String description,
    required num status, // 1 for Active, 0 for Inactive
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

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

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.refresh(leaveTypeListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Leave Type created successfully')),
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

  ///---------------- UPDATE LEAVE TYPE ----------------///
  Future<void> updateLeaveType({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String name,
    required String description,
    required num status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

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
        ref.refresh(leaveTypeListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Leave Type updated successfully')),
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

  ///---------------- DELETE LEAVE TYPE ----------------///
  Future<bool> deleteLeaveType({
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
        ref.refresh(leaveTypeListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave Type deleted successfully')),
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
