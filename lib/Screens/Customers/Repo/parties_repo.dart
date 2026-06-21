//ignore_for_file: avoid_print,unused_local_variable
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Const/api_config.dart';

import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../Model/parties_model.dart';
import '../Provider/customer_provider.dart';
import '../add_customer.dart';

class PartyRepository {
  Future<List<Party>> fetchAllParties() async {
    final uri = Uri.parse('${APIConfig.url}/parties');
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
      final partyList = parsedData['data'] as List<dynamic>;
      // Parse into Party objects
      return partyList.map((category) => Party.fromJson(category)).toList();
    } else {
      throw Exception('Failed to fetch parties');
    }
  }

  Future<void> addParty({
    required WidgetRef ref,
    required BuildContext context,
    required Customer customer,
  }) async {
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
    final uri = Uri.parse('${APIConfig.url}/parties');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    void addField(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        request.fields[key] = value;
      }
    }

    addField('name', customer.name);
    addField('phone', customer.phone);
    addField('type', customer.customerType);
    addField('email', customer.email);
    // Adding Tax Number
    addField('tax_no', customer.taxNumber);
    addField('address', customer.address);
    addField('opening_balance_type', customer.openingBalanceType);
    addField('opening_balance', customer.openingBalance?.toString());
    addField('credit_limit', customer.creditLimit?.toString());

    // Send billing and shipping address fields directly
    addField('billing_address[address]', customer.billingAddress);
    addField('billing_address[city]', customer.billingCity);
    addField('state_id', customer.billingStateId?.toString());
    addField('billing_address[zip_code]', customer.billingZipcode);
    addField('country_id', customer.billingCountryId?.toString());

    addField('shipping_address[address]', customer.shippingAddress);
    addField('shipping_address[city]', customer.shippingCity);
    addField('shipping_address[state]', customer.shippingState);
    addField('shipping_address[zip_code]', customer.shippingZipcode);
    addField('shipping_address[country]', customer.shippingCountry);

    print('Party Data Fields: ${request.fields}');

    final response = await customHttpClient.uploadFile(
      url: uri,
      fileFieldName: 'image',
      file: customer.image,
      fields: request.fields,
    );

    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);

    print('Party Added Response: $parsedData');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added successfully!')));
      ref.refresh(partiesProvider); // Refresh party list
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Party creation failed: ${parsedData['message']}')),
      );
    }
  }

  Future<void> updateParty({
    required WidgetRef ref,
    required BuildContext context,
    required Customer customer,
  }) async {
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);
    final uri = Uri.parse('${APIConfig.url}/parties/${customer.id}');

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    void addField(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        request.fields[key] = value;
      }
    }

    request.fields['_method'] = 'put';
    addField('name', customer.name);
    addField('phone', customer.phone);
    addField('type', customer.customerType);
    addField('email', customer.email);
    // Adding Tax Number
    addField('tax_no', customer.taxNumber);
    addField('address', customer.address);
    addField('opening_balance_type', customer.openingBalanceType);
    addField('opening_balance', customer.openingBalance?.toString());
    addField('credit_limit', customer.creditLimit?.toString());

    // Send billing and shipping address fields directly
    addField('billing_address[address]', customer.billingAddress);
    addField('billing_address[city]', customer.billingCity);
    addField('state_id', customer.billingStateId?.toString());
    addField('billing_address[zip_code]', customer.billingZipcode);
    addField('country_id', customer.billingCountryId?.toString());

    addField('shipping_address[address]', customer.shippingAddress);
    addField('shipping_address[city]', customer.shippingCity);
    addField('shipping_address[state]', customer.shippingState);
    addField('shipping_address[zip_code]', customer.shippingZipcode);
    addField('shipping_address[country]', customer.shippingCountry);

    if (customer.image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', customer.image!.path));
    }

    final response = await customHttpClient.uploadFile(
      url: uri,
      fileFieldName: 'image',
      file: customer.image,
      fields: request.fields,
    );

    final responseData = await response.stream.bytesToString();
    final parsedData = jsonDecode(responseData);

    print('--- Sending Party Data ---');
    request.fields.forEach((key, value) {
      print('$key: $value');
    });

    if (customer.image != null) {
      print('Image path: ${customer.image!.path}');
    } else {
      print('No image selected');
    }
    print('---------------------------');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated successfully!')));
      ref.refresh(partiesProvider); // Refresh party list
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Party update failed: ${parsedData['message']}')),
      );
    }
  }

  Future<void> deleteParty({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final String apiUrl = '${APIConfig.url}/parties/$id';

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(ref: ref, context: context, client: http.Client());
      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Party deleted successfully')));
        ref.refresh(partiesProvider);
        Navigator.pop(context);
      } else {
        final parsedData = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete party: ${parsedData['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> sendCustomerUdeSms({required num id, required BuildContext context}) async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/parties/$id');

    final response = await clientGet.get(url: uri);
    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonDecode(response.body)['message'])));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${jsonDecode((response.body))['message']}')));
    }
  }

  Future<void> saveAdvanceCollection({
    required WidgetRef ref,
    required BuildContext context,
    required String partyId,
    required String amount,
    required String date,
    required List<Map<String, dynamic>> payments,
    String? note,
  }) async {
    // API Endpoint
    final uri = Uri.parse('${APIConfig.url}/advance-collections');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    // 1. Prepare the Body Map
    Map<String, dynamic> requestBody = {
      'party_id': partyId,
      'amount': amount,
      'date': date,
      'payments': payments,
    };

    if (note != null) {
      requestBody['note'] = note;
    }

    print('--- Sending Advance Collection Data (JSON) ---');
    print(jsonEncode(requestBody));

    try {
      // 2. Send Standard POST Request
      final response = await customHttpClient.post(
        addContentTypeInHeader: true,
        url: uri,
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      print('--- Response Data ---');
      print(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advance Collected Successfully!')),
        );
        ref.refresh(partiesProvider);
        Navigator.pop(context);
      } else {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${responseData['message'] ?? 'Unknown Error'}')),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
