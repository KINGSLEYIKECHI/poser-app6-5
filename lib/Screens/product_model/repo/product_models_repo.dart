import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../model/product_models_model.dart';
import '../add_products_models.dart';

class ProductModelsRepo {
  // Create Model
  Future<bool> createModels({required CreateModelsModel data}) async {
    EasyLoading.show(status: 'Creating Models...');
    final url = Uri.parse('${APIConfig.url}/product-models');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    request.fields['name'] = data.name.toString();
    request.fields['status'] = data.status.toString();
    try {
      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();
      print('Model create ${response.statusCode}');
      print('Model create ${data.status}');

      if (response.statusCode == 200) {
        return true;
      } else {
        var data = jsonDecode(responseData.body);
        EasyLoading.showError(data['message'] ?? 'Failed to create Model');
        print('Error: ${data['message']}');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      print('Error: ${e.toString()}');
      return false;
    }
  }

  // models List
  Future<ProductModelsModel> fetchModelsList() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('${APIConfig.url}/product-models');
    try {
      var response = await clientGet.get(url: url);
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return ProductModelsModel.fromJson(jsonData);
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to fetch models');
        throw Exception(data['message'] ?? 'Failed to fetch models');
      }
    } catch (e) {
      // Hide loading indicator and show error
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update Model
  Future<bool> updateModels({required CreateModelsModel data}) async {
    EasyLoading.show(status: 'Updating Model...');
    final url = Uri.parse('${APIConfig.url}/product-models/${data.modelId}');

    // Create a multipart request
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });
    request.fields['name'] = data.name.toString();
    request.fields['status'] = data.status.toString();
    request.fields['_method'] = 'put';
    try {
      var response = await request.send();

      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        var data = jsonDecode(responseData.body);
        EasyLoading.showError(data['message'] ?? 'Failed to update');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  // delete warehouse
  Future<bool> deleteModel({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    final url = Uri.parse('${APIConfig.url}/product-models/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      var response = await http.delete(
        url,
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
