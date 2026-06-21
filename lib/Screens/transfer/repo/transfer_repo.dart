import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_cart_data_model.dart';
import 'package:mobile_pos/Screens/transfer/model/transfer_details_model.dart';
import 'package:mobile_pos/Screens/transfer/provider/transfer_provider.dart';
import 'package:mobile_pos/Screens/transfer/model/transfar_list_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
import 'package:mobile_pos/http_client/custome_http_client.dart';
import 'package:mobile_pos/http_client/customer_http_client_get.dart';

class TransferRepo {
  // Fetch Transfer List
  Future<TransferListModel> fetchTransferList() async {
    final url = Uri.parse('${APIConfig.url}/transfers');
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    try {
      final response = await clientGet.get(url: url);
      if (response.statusCode == 200) {
        return TransferListModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch transfers');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete Transfer
  Future<bool> deleteTransfer({required String id, required WidgetRef ref, required BuildContext context}) async {
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    EasyLoading.show(status: 'Deleting Transfer...');
    final url = Uri.parse('${APIConfig.url}/transfers/$id');
    try {
      final response = await client.delete(url: url);
      EasyLoading.dismiss();
      return response.statusCode == 200;
    } catch (e) {
      EasyLoading.dismiss();
      return false;
    }
  }

  // Create Transfer (Updated with Serial Support)
  Future<bool> createTransfer({
    required String date,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? fromBranchId,
    String? toBranchId,
    required String status,
    required String shippingCharge,
    required String note,
    required List<TransferCartItem> items,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    EasyLoading.show(status: 'Creating Transfer...');
    final url = Uri.parse('${APIConfig.url}/transfers');

    try {
      // Mapping Items to JSON structure
      List<Map<String, dynamic>> productList = items.map((e) {
        return {
          'stock_id': e.stockId,
          'quantity': e.quantity,
          'unit_price': e.purchasePrice,
          'tax': 0,
          'discount': 0,
          'serial_numbers': e.serialNumber ?? [], // [ADDED] Serial List
        };
      }).toList();

      final body = jsonEncode({
        'transfer_date': date,
        'from_branch_id': fromBranchId,
        'to_branch_id': toBranchId,
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'status': status.toLowerCase(),
        'note': note.isEmpty ? null : note,
        'shipping_charge': num.tryParse(shippingCharge) ?? 0,
        'products': productList,
      });

      print('Transfer Body: $body');

      final response = await client.post(
        url: url,
        body: body,
        addContentTypeInHeader: true,
      );

      print('Transfer Body: $body');
      print('Transfer Response: ${response.body}');

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.refresh(productProvider);
        ref.refresh(fetchTransferListProvider);
        return true;
      } else {
        final data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to create transfer');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

// Update Transfer
  Future<bool> updateTransfer({
    required String id,
    required String date,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? fromBranchId,
    String? toBranchId,
    required String status,
    required String shippingCharge,
    required String note,
    required List<TransferCartItem> items,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    EasyLoading.show(status: 'Updating Transfer...');
    final url = Uri.parse('${APIConfig.url}/transfers/$id'); // PUT/PATCH usually uses ID

    try {
      List<Map<String, dynamic>> productList = items.map((e) {
        return {
          'stock_id': e.stockId,
          'quantity': e.quantity,
          'unit_price': e.purchasePrice,
          'tax': 0,
          'discount': 0,
          'serial_numbers': e.serialNumber ?? [],
        };
      }).toList();

      final body = jsonEncode({
        'transfer_date': date,
        'from_branch_id': fromBranchId,
        'to_branch_id': toBranchId,
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'status': status.toLowerCase(),
        'note': note.isEmpty ? null : note,
        'shipping_charge': num.tryParse(shippingCharge) ?? 0,
        'products': productList,
        '_method': 'PUT'
      });

      // Assuming your API uses PUT for updates
      final response = await client.post(
        url: url,
        body: body,
        addContentTypeInHeader: true,
      );

      EasyLoading.dismiss();
      print('Transfer Update Body: $body');
      print('Transfer Update Response: ${response.body}');

      if (response.statusCode == 200) {
        ref.refresh(fetchTransferListProvider);
        ref.refresh(productProvider);
        return true;
      } else {
        final data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to update transfer');
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  // Fetch Transfer Details
  Future<TransferDetailsModel> fetchTransferDetails(String id) async {
    final url = Uri.parse('${APIConfig.url}/transfers/$id');
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

    try {
      final response = await clientGet.get(url: url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TransferDetailsModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load transfer details');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
