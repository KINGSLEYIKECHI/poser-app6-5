import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/Authentication/Repo/logout_repo.dart';

import '../Repository/constant_functions.dart';

class CustomHttpClientGet {
  final http.Client client;

  CustomHttpClientGet({
    required this.client,
  });

  Future<http.Response> get({
    required Uri url,
    Map<String, String>? headers,
    bool? addContentTypeInHeader,
  }) async {
    final http.Response response = await client.get(
      url,
      headers: headers ??
          {
            'Accept': 'application/json',
            'Authorization': await getAuthToken(),
            if (addContentTypeInHeader ?? false) 'Content-Type': 'application/json',
          },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      EasyLoading.showError('Session expired. Please login again!');
      LogOutRepo().signOutApi();
      // Return a safe JSON response to prevent jsonDecode format exception
      return http.Response(jsonEncode({'error': 'Unauthorized or Session Expired'}), response.statusCode);
    }

    return response;
  }
}
