import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Const/api_config.dart';
import '../../http_client/customer_http_client_get.dart';
import '../../model/business_category_model.dart';
import '../constant_functions.dart';

class BusinessCategoryRepository {
  Future<List<BusinessCategory>> getBusinessCategories() async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final response = await clientGet.get(
        url: Uri.parse('${APIConfig.url}${APIConfig.businessCategoriesUrl}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        return data.map((category) => BusinessCategory.fromJson(category)).toList();
      } else {
        throw Exception('Failed to fetch business categories');
      }
    } catch (error) {
      throw Exception('Error fetching business categories: $error');
    }
  }
}
