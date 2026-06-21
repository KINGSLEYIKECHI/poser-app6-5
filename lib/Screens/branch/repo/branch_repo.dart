import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/branch/provider/branch_list_provider.dart';
import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../model/branch_list_model.dart';

class BranchRepo {
  Future<BranchListModel> fetchBranchList() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/branches');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);

      return BranchListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch Branch List');
    }
  }
  Future<void> createBranch({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String phone,
    required String email,
    required String address,
    required String branchOpeningBalance,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/branches');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    final requestBody = json.encode({
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "branchOpeningBalance": branchOpeningBalance,
      "description": description,
    });

    try {
      var responseData = await customHttpClient.post(
        url: uri,
        body: requestBody,
        addContentTypeInHeader: true,
      );

      EasyLoading.dismiss();
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branch created successfully!')),
        );
        ref.refresh(branchListProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${parsedData['message']}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> updateBranch({
    required WidgetRef ref,
    required BuildContext context,
    required String id,
    required String name,
    required String phone,
    required String email,
    required String address,
    required String branchOpeningBalance,
    required String description,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/branches/$id');
    CustomHttpClient customHttpClient =
    CustomHttpClient(client: http.Client(), context: context, ref: ref);

    final body = {
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "branchOpeningBalance": branchOpeningBalance,
      "description": description,
      "_method": "put", // Laravel PUT simulation
    };

    try {
      var responseData = await customHttpClient.post(
        url: uri,
        body: body,
        addContentTypeInHeader: false,
      );

      EasyLoading.dismiss();
      final parsedData = jsonDecode(responseData.body);

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branch updated successfully!')),
        );
        ref.refresh(branchListProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${parsedData['message']}')),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  // switch Branch
  Future<bool> switchBranch({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final url = Uri.parse('${APIConfig.url}/switch-branch/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
      'Content-Type': 'application/json',
    };
    try {
      var response = await http.get(
        url,
        headers: headers,
      );
      EasyLoading.dismiss();
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to switch');
        print(data['message']);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteUser({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    EasyLoading.show(status: 'Processing');
    final url = Uri.parse('${APIConfig.url}/branches/$id');
    try {
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      var response = await customHttpClient.delete(
        url: url,
      );
      EasyLoading.dismiss();
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to delete');
        print(data['message']);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      print(e.toString());
      return false;
    }
  }

  // switch Branch
  Future<bool> exitBranch({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final url = Uri.parse('${APIConfig.url}/exit-branch/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
      'Content-Type': 'application/json',
    };
    try {
      var response = await http.get(
        url,
        headers: headers,
      );
      EasyLoading.dismiss();
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to exit');
        print(data['message']);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      print(e.toString());
      return false;
    }
  }
}
