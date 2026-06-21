import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../model/vat_model.dart';
import '../provider/text_repo.dart';

class TaxRepo {
  //________Fetch_All_Taxes___________________________________________
  Future<List<VatModel>> fetchAllTaxes({String? taxType}) async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/vats?type=$taxType');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
      final partyList = parsedData['data'] as List<dynamic>;
      return partyList.map((category) => VatModel.fromJson(category)).toList();
    } else {
      throw Exception('Failed to fetch tax list');
    }
  }

  //________Create_Single_Tax_________________________________________
  Future<void> createSingleTax({
    required WidgetRef ref,
    required BuildContext context,
    required num taxRate,
    required String taxName,
    required bool status,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats');
    final requestBody = jsonEncode({
      'name': taxName,
      'rate': taxRate,
      'status': status ? 1 : 0,
    });

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      final parsedData = jsonDecode(responseData.body);

      EasyLoading.dismiss();
      if (responseData.statusCode == 200) {
        ref.refresh(taxProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tax creation failed: ${parsedData}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  //________Create_Group_Tax (Updated)__________________________________
  Future<void> createGroupTax({
    required WidgetRef ref,
    required BuildContext context,
    required String taxName,
    required bool status,
    // New parameters
    required bool isManageState,
    List<num>? taxIds, // For normal group tax
    List<num>? innerVatIds, // For manage state
    List<num>? outerVatIds, // For manage state
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    // Common fields
    request.fields.addAll({
      'name': taxName,
      'manage_state': isManageState ? '1' : '0',
      'status': status ? '1' : '0',
    });

    if (isManageState) {
      // Logic for Manage State (Inner & Outer)
      if (innerVatIds != null && innerVatIds.isNotEmpty) {
        for (int i = 0; i < innerVatIds.length; i++) {
          request.fields['inner_vat_ids[$i]'] = innerVatIds[i].toString();
        }
      }
      if (outerVatIds != null && outerVatIds.isNotEmpty) {
        for (int i = 0; i < outerVatIds.length; i++) {
          request.fields['outer_vat_ids[$i]'] = outerVatIds[i].toString();
        }
      }
    } else {
      // Old Logic (Standard Sub Taxes)
      if (taxIds != null && taxIds.isNotEmpty) {
        int index = 0;
        for (var element in taxIds) {
          request.fields['vat_ids[$index]'] = element.toString();
          index++;
        }
      }
    }

    try {
      final response = await customHttpClient.uploadFile(
        url: uri,
        fields: request.fields,
      );
      final responseData = await response.stream.bytesToString();
      final parsedData = jsonDecode(responseData);

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.refresh(taxProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Tax creation failed: ${parsedData['message']}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  //________Update_Single_Tax__________________________________________
  Future<void> updateSingleTax({
    required num id,
    required String name,
    required num rate,
    required bool status,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats/$id');
    final requestBody = jsonEncode({
      'rate': rate,
      'name': name,
      'status': status ? 1 : 0,
      '_method': 'put',
    });

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      final response = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        ref.refresh(taxProvider);
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update tax.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      EasyLoading.dismiss();
    }
  }

  //________Update_Group_Tax (Updated)__________________________________
  Future<void> updateGroupTax({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required String taxName,
    required bool status,
    required bool isManageState,
    List<num>? taxIds,
    List<num>? innerVatIds,
    List<num>? outerVatIds,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/vats/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.fields.addAll({
      'name': taxName,
      'status': status ? '1' : "0",
      'manage_state': isManageState ? '1' : '0',
      '_method': 'put',
    });

    if (isManageState) {
      if (innerVatIds != null && innerVatIds.isNotEmpty) {
        for (int i = 0; i < innerVatIds.length; i++) {
          request.fields['inner_vat_ids[$i]'] = innerVatIds[i].toString();
        }
      }
      if (outerVatIds != null && outerVatIds.isNotEmpty) {
        for (int i = 0; i < outerVatIds.length; i++) {
          request.fields['outer_vat_ids[$i]'] = outerVatIds[i].toString();
        }
      }
    } else {
      if (taxIds != null && taxIds.isNotEmpty) {
        int index = 0;
        for (var element in taxIds) {
          request.fields['vat_ids[$index]'] = element.toString();
          index++;
        }
      }
    }

    try {
      final response = await customHttpClient.uploadFile(
        url: uri,
        fields: request.fields,
      );
      final responseData = await response.stream.bytesToString();
      final parsedData = jsonDecode(responseData);

      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ref.refresh(taxProvider);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Tax update failed: ${parsedData['message']}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  //________Delete_Tax______________________________________________________
  Future<bool> deleteTax({required String id, required BuildContext context, required WidgetRef ref}) async {
    try {
      final url = Uri.parse('${APIConfig.url}/vats/$id');
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(url: url);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
