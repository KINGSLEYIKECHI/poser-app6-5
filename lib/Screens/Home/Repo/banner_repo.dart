import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../Model/banner_model.dart';

class BannerRepo {
  Future<List<Banner>> fetchAllIBanners() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/banners');

    final response = await clientGet.get(url: uri);
    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
      print('Banner Repo: ${parsedData['data']}');

      final partyList = parsedData['data'] as List<dynamic>;
      return partyList.map((user) => Banner.fromJson(user)).toList();
      // Parse into Party objects
    } else {
      throw Exception('Failed to fetch Users');
    }
  }
}
