import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_pos/Screens/hrm/holiday/model/holiday_list_model.dart';
import 'package:mobile_pos/Screens/hrm/holiday/provider/holidays_list_provider.dart';

import '../../../../Const/api_config.dart';
import '../../../../http_client/custome_http_client.dart';
import '../../../../http_client/customer_http_client_get.dart';

class HolidayRepo {
  ///---------------- FETCH HOLIDAYS ----------------///
  Future<HolidayListModel> fetchAllHolidays() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/holidays');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return HolidayListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch Holidays list');
    }
  }

  ///---------------- CREATE HOLIDAY ----------------///
  Future<void> createHolidays({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/holidays'); // Modified endpoint

    final requestBody = jsonEncode({
      'name': name,
      'start_date': startDate, // Field names match the model/API
      'end_date': endDate, // Field names match the model/API
      'description': description,
    });

    try {
      EasyLoading.show(status: 'Creating Holiday...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.refresh(holidayListProvider); // Refresh the list after creation

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Holiday created successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Holiday creation failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- UPDATE HOLIDAY ----------------///
  Future<void> updateHolidays({
    // Renamed function
    required WidgetRef ref,
    required BuildContext context,
    required int id,
    required String name,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/holidays/$id'); // Modified endpoint

    final requestBody = jsonEncode({
      '_method': 'put', // Required for PUT/PATCH via POST on some APIs
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
    });

    try {
      EasyLoading.show(status: 'Updating Holiday...');
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      var responseData = await customHttpClient.post(
        // Assuming the PUT is sent via POST with '_method': 'put'
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);
      EasyLoading.dismiss();

      if (responseData.statusCode == 200) {
        ref.refresh(holidayListProvider); // Refresh the list after update

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(parsedData['message'] ?? 'Holiday updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Holiday update failed: ${parsedData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  ///---------------- DELETE HOLIDAY ----------------///
  Future<bool> deleteHolidays({
    // Renamed function
    required num id, // Changed to num to match model's id type
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      final url = Uri.parse('${APIConfig.url}/holidays/$id'); // Modified endpoint
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.refresh(holidayListProvider); // Refresh the list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Holiday deleted successfully')),
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
