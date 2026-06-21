// File: attendance_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../model/attendence_list_model.dart';
import '../provider/attendence_provider.dart';

class AttendanceRepo {
  static const String _endpoint = '/attendances'; // Assuming a suitable endpoint

  ///---------------- FETCH ALL ATTENDANCE (GET) ----------------///
  Future<AttendanceListModel> fetchAllAttendance() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return AttendanceListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch attendance list. Status: ${response.statusCode}');
    }
  }

  ///---------------- CREATE ATTENDANCE (POST) ----------------///
  Future<void> createAttendance({
    required WidgetRef ref,
    required BuildContext context,
    required num employeeId,
    required num shiftId,
    required String timeIn, // HH:MM:SS format
    required String timeOut, // HH:MM:SS format
    required String date, // YYYY-MM-DD format
    // required String month,
    String? note,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint');

    final requestBody = jsonEncode({
      'employee_id': employeeId,
      'shift_id': shiftId,
      'time_in': timeIn,
      'time_out': timeOut,
      'date': date,
      // 'month': month,
      'note': note,
    });

    try {
      EasyLoading.show(status: 'Recording Attendance...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        ref.invalidate(attendanceListProvider); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Attendance recorded successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- UPDATE ATTENDANCE (PUT) ----------------///
  Future<void> updateAttendance({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required num employeeId,
    required num shiftId,
    required String timeIn,
    required String timeOut,
    required String date,
    // required String month,
    String? note,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$_endpoint/$id');

    final requestBody = jsonEncode({
      '_method': 'put',
      'employee_id': employeeId,
      'shift_id': shiftId,
      'time_in': timeIn,
      'time_out': timeOut,
      'date': date,
      // 'month': month,
      'note': note,
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
        ref.invalidate(attendanceListProvider); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Attendance updated successfully')),
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

  ///---------------- DELETE ATTENDANCE ----------------///
  Future<bool> deleteAttendance({
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
        ref.invalidate(attendanceListProvider); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance deleted successfully')),
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
