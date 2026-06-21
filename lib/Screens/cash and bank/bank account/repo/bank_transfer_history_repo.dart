// File: bank_transaction_history_repo.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// --- Local Imports ---
import '../../../../Const/api_config.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../model/bank_transfer_history_model.dart';

class BankTransactionHistoryRepo {
  static const String _endpoint = '/bank-transactions';

  // NOTE: This API must accept bankId and optional filters (like time range)
  Future<TransactionHistoryListModel> fetchHistory({
    required num bankId,
    String? timeFilter, // e.g., 'Today', 'Current Year'
    String? transactionTypeFilter,
  }) async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

    // Construct query parameters
    final Map<String, dynamic> queryParams = {
      'bank_id': bankId.toString(),
      // Add other filters as API requires (e.g., 'filter_time': timeFilter)
    };

    final uri = Uri.parse('${APIConfig.url}$_endpoint').replace(queryParameters: queryParams);

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return TransactionHistoryListModel.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch transaction history. Status: ${response.statusCode}');
    }
  }

  // NOTE: You would add methods here for deleting and updating individual transactions
  // if required by the action menu.

  // --- Deletion Placeholder ---
  Future<void> deleteTransaction(num transactionId, BuildContext context, WidgetRef ref) async {
    // ... Implementation using CustomHttpClient().delete() ...
    // ref.invalidate(bankTransactionHistoryProvider(bankId));
  }
}
