import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../core/constant_variables/local_data_saving_keys.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../Model/user_role_model_new.dart';

class UserRoleRepo {
  Future<List<UserRoleListModelNew>> fetchAllUsers() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/users');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> parsedData = jsonDecode(response.body);

      final List<dynamic> userList = parsedData['data'] ?? [];
      return userList.map((user) => UserRoleListModelNew.fromJson(user)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<void> addUser({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    String? branchId,
    required Map<String, Map<String, String>> visibility,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/users');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), ref: ref, context: context);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.fields.addAll({
      "name": name,
      "email": email,
      "password": password,
    });
    if (branchId != null) {
      request.fields['branch_id'] = branchId;
    }
    visibility.forEach((key, perm) {
      perm.forEach((action, value) {
        if (value != null) {
          request.fields['visibility[$key][$action]'] = value;
        }
      });
    });

    final response = await customHttpClient.uploadFile(
      url: uri,
      fields: request.fields,
    );

    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);
    print(response.statusCode);
    print(parsedData);
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successful!')));
    } else {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User  creation failed: ${parsedData['message']}')));
    }
  }

  Future<void> updateUser({
    required WidgetRef ref,
    required BuildContext context,
    required String name,
    required String email,
    String? password,
    String? branchId,
    required String userId,
    required Map<String, Map<String, String>> visibility,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/users/$userId');
    CustomHttpClient customHttpClient = CustomHttpClient(
      client: http.Client(),
      ref: ref,
      context: context,
    );

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.fields.addAll({
      "name": name,
      "email": email,
      "_method": 'put',
    });
    if (branchId != null) {
      request.fields['branch_id'] = branchId;
    }
    if (password != null) {
      request.fields['password'] = password;
    }

    // Add visibility fields
    visibility.forEach((key, perm) {
      perm.forEach((action, value) {
        if (value != null) {
          request.fields['visibility[$key][$action]'] = value;
        }
      });
    });

    final response = await customHttpClient.uploadFile(
      url: uri,
      fields: request.fields,
    );

    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);

    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User update failed: ${parsedData['message']}')),
      );
    }
  }

  Future<bool> deleteUser({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    EasyLoading.show(status: 'Processing');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(LocalDataBaseSavingKey.tokenKey) ?? '';
    final url = Uri.parse('${APIConfig.url}/users/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      var response = await customHttpClient.delete(
        url: url,
        headers: headers,
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
}
