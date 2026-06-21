// ignore_for_file: unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Screens/Due%20Calculation/Model/guest_due_model.dart';

import '../../../Const/api_config.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../../Customers/Provider/customer_provider.dart';
import '../Model/due_collection_invoice_model.dart';
import '../Model/due_collection_model.dart';
import '../Providers/due_provider.dart';

class DueRepo {
  Future<List<DueCollection>> fetchDueCollectionList({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    final client = CustomHttpClientGet(client: http.Client());

    // Manually build query string to preserve order
    final List<String> queryList = [];

    if (type != null && type.isNotEmpty) {
      queryList.add('duration=$type');
    }

    if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
      queryList.add('from_date=$fromDate');
      queryList.add('to_date=$toDate');
    }

    final String queryString = queryList.join('&');
    final Uri uri = Uri.parse('${APIConfig.url}/dues${queryString.isNotEmpty ? '?$queryString' : ''}');

    print('Print Due List URI: $uri');

    final response = await client.get(url: uri);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      final list = parsed['data'] as List<dynamic>;
      return list.map((json) => DueCollection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Due List. Status code: ${response.statusCode}');
    }
  }

  Future<DueCollectionInvoice> fetchDueInvoiceList({required int id}) async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/invoices?party_id=$id');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return DueCollectionInvoice.fromJson(parsedData['data']);
    } else {
      throw Exception('Failed to fetch Sales List');
    }
  }

  Future<DueCollection?> dueCollect({
    required WidgetRef ref,
    required BuildContext context,
    required num partyId,
    required String? invoiceNumber,
    required String paymentDate,
    required List<Map<String, dynamic>> payments,
    required num payDueAmount,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/dues');
    final requestBody = jsonEncode({
      'party_id': partyId,
      'invoiceNumber': invoiceNumber,
      'paymentDate': paymentDate,
      'payments': payments,
      'payDueAmount': payDueAmount,
    });

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(
          url: uri,
          headers: {
            "Accept": 'application/json',
            'Authorization': await getAuthToken(),
            'Content-Type': 'application/json'
          },
          body: requestBody);
      final parsedData = jsonDecode(responseData.body);
      print("Print Due data: $parsedData");

      if (responseData.statusCode == 200) {
        EasyLoading.showSuccess('Collected successful!');

        ref.refresh(partiesProvider);

        ref.refresh(purchaseTransactionProvider);
        ref.refresh(salesTransactionProvider);
        ref.refresh(businessInfoProvider);
        ref.refresh(getExpireDateProvider(ref));

        // ref.refresh(dueInvoiceListProvider(partyId.round()));
        ref.refresh(dueCollectionListProvider);
        ref.refresh(summaryInfoProvider);

        return DueCollection.fromJson(parsedData['data']);
        // Navigator.pop(context);
        // return PurchaseTransaction.fromJson(parsedData);
      } else {
        EasyLoading.dismiss().then(
          (value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Due creation failed: ${parsedData['message']}'))),
        );
        return null;
      }
    } catch (error) {
      EasyLoading.dismiss().then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error'))),
      );
      return null;
    }
  }

  Future<List<GuestDueModel>> fetchGuestDueList() async {
    final client = CustomHttpClientGet(client: http.Client());

    final Uri uri = Uri.parse('${APIConfig.url}/invoice-wise-dues');

    final response = await client.get(url: uri);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      final list = parsed['data'] as List<dynamic>;
      return list.map((json) => GuestDueModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Guest Due List. Status code: ${response.statusCode}');
    }
  }

  Future<DueCollection?> guestDueCollect({
    required WidgetRef ref,
    required BuildContext context,
    required String? invoiceNumber,
    required String paymentDate,
    required List<Map<String, dynamic>> payments,
    required num payDueAmount,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/collect-invoice-due');
    final requestBody = jsonEncode({
      'invoiceNumber': invoiceNumber,
      'paymentDate': paymentDate,
      'payments': payments,
      'payDueAmount': payDueAmount,
    });

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
      var responseData = await customHttpClient.post(url: uri, body: requestBody, addContentTypeInHeader: true);
      final parsedData = jsonDecode(responseData.body);
      print("Print Guest Due data: $parsedData");

      if (responseData.statusCode == 200) {
        EasyLoading.showSuccess('Collected successful!');

        // Refresh providers to update lists
        ref.refresh(salesTransactionProvider);
        ref.refresh(businessInfoProvider);
        ref.refresh(guestDueListProvider); // Refresh Guest Due List
        ref.refresh(summaryInfoProvider);

        return DueCollection.fromJson(parsedData['data']);
      } else {
        EasyLoading.dismiss().then(
          (value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Due collection failed: ${parsedData['message']}'))),
        );
        return null;
      }
    } catch (error) {
      EasyLoading.dismiss().then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $error'))),
      );
      return null;
    }
  }
}
