import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Const/api_config.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../model/transaction_model.dart';

class TransactionRepo {
  Future<TransactionModel> fetchTransactionList({
    required String duration,
    String? fromDate,
    String? toDate,
    String? platform,
    int? partyId,
  }) async {
    try {
      final client = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      // Add required duration parameter
      queryList.add('duration=$duration');

      // Add date parameters only if duration is custom_date
      if (duration == 'custom_date') {
        if (fromDate != null && fromDate.isNotEmpty) {
          queryList.add('from_date=$fromDate');
        }
        if (toDate != null && toDate.isNotEmpty) {
          queryList.add('to_date=$toDate');
        }
      }

      // Add platform filter if specified and not "all_transaction"
      if (platform != null && platform.isNotEmpty && platform != 'all_transaction') {
        queryList.add('platform=$platform');
      }

      // Add party filter if specified
      if (partyId != null) {
        queryList.add('party_id=$partyId');
      }

      final uri = Uri.parse(
        '${APIConfig.url}/transactions?${queryList.join('&')}',
      );

      print('Fetching transactions from: $uri'); // Debug print

      final response = await client.get(url: uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TransactionModel.fromJson(jsonData);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }
}
