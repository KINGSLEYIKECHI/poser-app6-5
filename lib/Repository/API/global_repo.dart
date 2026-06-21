import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Const/api_config.dart';
import '../../http_client/customer_http_client_get.dart';
import '../../model/country_state_model.dart';

class GlobalRepository {
  // Fetch All Countries
  Future<List<CountryModel>> getCountries() async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      // URL adjust kore niben
      final response = await clientGet.get(
        url: Uri.parse('${APIConfig.url}/countries?no_paginate=true'),
      );

      if (response.statusCode == 200) {
        // JSON structure: root -> data -> data -> List
        final data = jsonDecode(response.body)['data']['data'] as List;
        return data.map((e) => CountryModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch countries');
      }
    } catch (error) {
      throw Exception('Error fetching countries: $error');
    }
  }

  // Fetch States by Country ID
  // Note: API te jodi query param hisebe country_id pass kora lage
  Future<List<StateModel>> getStates({required int countryId}) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      // URL adjust kore niben, example: /states?country_id=12
      final response = await clientGet.get(
        url: Uri.parse('${APIConfig.url}/states?country_id=$countryId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['data'] as List;
        return data.map((e) => StateModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch states');
      }
    } catch (error) {
      throw Exception('Error fetching states: $error');
    }
  }
}
