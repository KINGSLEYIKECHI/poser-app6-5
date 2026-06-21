import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../Const/api_config.dart';
import '../http_client/customer_http_client_get.dart';

final socialLoginCheckProvider = FutureProvider.autoDispose<bool>((ref) async {
  CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
  final url = Uri.parse('${APIConfig.url}/module-check?module_name=SocialLoginAddon');
  final headers = {
    "Accept": "application/json",
  };
  final response = await clientGet.get(url: url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['status'];
  } else {
    return false;
  }
});
final invoice80mmAddonCheckProvider = FutureProvider.autoDispose<bool>((ref) async {
  final url = Uri.parse('${APIConfig.url}/module-check?module_name=ThermalPrinterAddon');
  final headers = {
    "Accept": "application/json",
  };
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['status'];
  } else {
    return false;
  }
});
