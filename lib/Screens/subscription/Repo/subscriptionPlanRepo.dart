// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/profile_provider.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../Model/subscription_plan_model.dart';

class SubscriptionPlanRepo {
  final http.Client _client = http.Client();

  /// Fetch all subscription plans (New Model)
  Future<List<SubscriptionPlanModelNew>> fetchAllPlans() async {
    final uri = Uri.parse('${APIConfig.url}/plans');
    final clientGet = CustomHttpClientGet(client: _client);

    try {
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body) as Map<String, dynamic>;
        final planList = parsedData['data'] as List<dynamic>;

        return planList.map((plan) => SubscriptionPlanModelNew.fromJson(plan)).toList();
      } else {
        log('Error: Failed to fetch plans. Status Code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Exception in fetchAllPlans: $e');
      throw Exception('Failed to fetch Plans: $e');
    }
  }

  /// Subscribe to a Plan (Logic only, returns Success/Fail)
  // Future<bool> subscribePlan({
  //   required WidgetRef ref,
  //   required int planId,
  //   required String paymentMethod,
  // }) async {
  //   final uri = Uri.parse('${APIConfig.url}/subscribes');

  //   try {
  //     final token = await getAuthToken();
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         "Accept": 'application/json',
  //         'Authorization': token,
  //       },
  //       body: {
  //         'plan_id': planId.toString(),
  //         'subscriptionMethod': paymentMethod,
  //       },
  //     );

  //     final parsedData = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       // Refresh providers to update UI
  //       ref.refresh(businessInfoProvider);
  //       ref.refresh(getExpireDateProvider(ref));
  //       return true;
  //     } else {
  //       log('Subscription failed: ${parsedData['message']}');
  //       return false;
  //     }
  //   } catch (error) {
  //     log('Exception in subscribePlan: $error');
  //     return false;
  //   }
  // }
}
