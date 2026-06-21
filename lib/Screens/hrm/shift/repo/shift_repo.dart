// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/hrm/shift/Model/shift_list_model.dart';
import 'package:mobile_pos/Screens/hrm/shift/provider/shift_list_provider.dart';
import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';
import 'package:intl/intl.dart';

class ShiftRepo {
  String convertTo24HourFormat(String time12h) {
    // Example input: "8:00 PM"
    final dateTime = DateFormat('h:mm a', 'en_US').parse(time12h);
    return DateFormat('HH:mm', 'en_US').format(dateTime); // Output: "20:00"
  }

  /// Fetch all shifts
  Future<ShiftListModel> fetchAllShifts() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/shifts');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return ShiftListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch Shift list');
    }
  }

  /// Create new shift (form-data format)
  Future<void> createShift({
    required WidgetRef ref,
    required BuildContext context,
    required String shiftName,
    required String breakStatus,
    required String startTime,
    required String endTime,
    required String status,
    String? breakStartTime,
    String? breakEndTime,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/shifts');

    // Build form-data map (Postman style)
    final Map<String, String> body = {
      'name': shiftName,
      'start_time': convertTo24HourFormat(startTime),
      'status': status,
      'end_time': convertTo24HourFormat(endTime),
      'break_status': breakStatus.toLowerCase(), // yes/no
      if (breakStartTime != null && breakStartTime.isNotEmpty)
        'start_break_time': breakStatus.toLowerCase() == 'no' ? '' : convertTo24HourFormat(breakStartTime),
      if (breakEndTime != null && breakEndTime.isNotEmpty)
        'end_break_time': breakStatus.toLowerCase() == 'no' ? '' : convertTo24HourFormat(breakEndTime),
    };

    try {
      EasyLoading.show(status: 'Saving...');
      CustomHttpClient client = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      print("POST Data For: $body");

      final response = await client.post(
        url: uri,
        body: body, // form-data
        addContentTypeInHeader: false, // important for form-data
      );

      EasyLoading.dismiss();

      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift created successfully!')),
        );
        ref.refresh(shiftListProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create shift: ${parsed['message']}')),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Update existing shift (form-data format)
  Future<void> updateShift({
    required WidgetRef ref,
    required BuildContext context,
    required int id,
    required String shiftName,
    required String breakStatus,
    required String startTime,
    required String endTime,
    required String status,
    String? breakStartTime,
    String? breakEndTime,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/shifts/$id');

    final Map<String, String> body = {
      "_method": 'put',
      'name': shiftName,
      'status': status,
      'start_time': convertTo24HourFormat(startTime),
      'end_time': convertTo24HourFormat(endTime),
      'break_status': breakStatus.toLowerCase(),
      if (breakStartTime != null && breakStartTime.isNotEmpty)
        'start_break_time': breakStatus.toLowerCase() == 'no' ? '' : convertTo24HourFormat(breakStartTime),
      if (breakEndTime != null && breakEndTime.isNotEmpty)
        'end_break_time': breakStatus.toLowerCase() == 'no' ? '' : convertTo24HourFormat(breakEndTime),
    };

    try {
      EasyLoading.show(status: 'Updating...');
      CustomHttpClient client = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      final response = await client.post(
        url: uri,
        body: body,
        addContentTypeInHeader: false, // still form-data
      );

      EasyLoading.dismiss();

      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift updated successfully!')),
        );
        ref.refresh(shiftListProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update shift: ${parsed['message']}')),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Delete shift
  Future<bool> deleteShift({
    required WidgetRef ref,
    required BuildContext context,
    required int id,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/shifts/$id');

    try {
      EasyLoading.show(status: 'Deleting...');
      CustomHttpClient client = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      final response = await client.delete(url: uri);

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete shift: ${response.body}')),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    return false;
  }
}
