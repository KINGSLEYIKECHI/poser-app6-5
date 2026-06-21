import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/warehouse/model/warehouse_by_branch_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/create_warehouse_data_model.dart';
import 'package:mobile_pos/http_client/custome_http_client.dart';
import '../../../Const/api_config.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../warehouse_model/warehouse_list_model.dart';

class WarehouseRepo {
  // Fetch Warehouse List
  Future<WarehouseListModel> fetchWareHouseList() async {
    final url = Uri.parse('${APIConfig.url}/warehouses');
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

    try {
      final response = await clientGet.get(url: url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return WarehouseListModel.fromJson(jsonData);
      } else {
        final data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to fetch warehouse');
        throw Exception(data['message'] ?? 'Failed to fetch warehouse');
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
      rethrow;
    }
  }

  // Fetch Warehouse By Branch
  Future<List<WarehouseByBranchData>> fetchWarehouseByBranch(String branchId) async {
    final url = Uri.parse('${APIConfig.url}/warehouses-by-branch/$branchId');
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

    try {
      final response = await clientGet.get(url: url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = WarehouseByBranchModel.fromJson(jsonData);
        return model.data ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Create Warehouse
  Future<bool> createWareHouse(
      {required CreateWareHouseModel data, required WidgetRef ref, required BuildContext context}) async {
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    EasyLoading.show(status: 'Creating Warehouse...');
    final url = Uri.parse('${APIConfig.url}/warehouses');

    try {
      final response = await client.post(
        url: url,
        body: data.toJson(),
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData['message'] ?? 'Failed to create');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  // Update Warehouse
  Future<bool> updateWareHouse(
      {required CreateWareHouseModel data, required WidgetRef ref, required BuildContext context}) async {
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    EasyLoading.show(status: 'Updating Warehouse...');
    final url = Uri.parse('${APIConfig.url}/warehouses/${data.warehouseId}');

    final body = data.toJson();
    body['_method'] = 'put';

    try {
      final response = await client.post(
        url: url,
        body: body,
      );

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData['message'] ?? 'Failed to update');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  // Delete Warehouse
  Future<bool> deleteWarehouse({required String id, required WidgetRef ref, required BuildContext context}) async {
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    EasyLoading.show(status: 'Deleting...');
    final url = Uri.parse('${APIConfig.url}/warehouses/$id');

    try {
      final response = await client.delete(url: url);
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        EasyLoading.showError(responseData['message'] ?? 'Failed to delete');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }
}
