// File: leave_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Const/api_config.dart';
import '../../../../../http_client/custome_http_client.dart';
import '../../../../../http_client/customer_http_client_get.dart';
import '../model/leave_list_model.dart';
import '../provider/leave_list_provider.dart';

class LeaveRepo {
  // Base endpoint for leave requests from Postman screenshots
  static const String _endpoint = '/leaves';

  ///---------------- FETCH ALL LEAVE REQUESTS (GET) ----------------///
  Future<LeaveListModel> fetchAllLeaveRequests() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return LeaveListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch leave requests list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE LEAVE REQUEST (POST) ----------------///
  Future<void> createLeaveRequest({
    required WidgetRef ref,
    required BuildContext context,
    required num employeeId,
    required num leaveTypeId,
    required String startDate,
    required String endDate,
    required dynamic leaveDuration,
    required String month,
    required String description,
    required String status, // e.g., 'pending'
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final requestBody = jsonEncode({
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'leave_duration': leaveDuration,
      'month': month,
      'description': description,
      'status': status,
    });

    try {
      EasyLoading.show(status: 'Submitting Leave Request...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.refresh(leaveRequestListProvider); // Assuming you'll define this provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Leave Request created successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- UPDATE LEAVE REQUEST (POST with _method=put) ----------------///
  Future<void> updateLeaveRequest({
    required WidgetRef ref,
    required BuildContext context,
    required num id, // Leave Request ID from Postman URL
    required num employeeId,
    required num leaveTypeId,
    required String startDate,
    required String endDate,
    required dynamic leaveDuration,
    required String month,
    required String description,
    required String status, // e.g., 'approved'
  }) async {
    // Postman URL: {{url}}/api/v1/leaves/2
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final requestBody = jsonEncode({
      '_method': 'put', // Required for sending PUT data via POST
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'leave_duration': leaveDuration,
      'month': month,
      'description': description,
      'status': status,
    });

    try {
      EasyLoading.show(status: 'Updating Request...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      // Sending as POST request based on the Postman screenshot
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.refresh(leaveRequestListProvider); // Assuming you'll define this provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Leave Request updated successfully')),
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

  ///---------------- DELETE LEAVE REQUEST (DELETE) ----------------///
  Future<bool> deleteLeaveRequest({
    required num id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      // URL: {{url}}/api/v1/leaves/{id}
      final url = Uri.parse('${APIConfig.url}$_endpoint/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.refresh(leaveRequestListProvider); // Assuming you'll define this provider
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave Request deleted successfully')),
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
