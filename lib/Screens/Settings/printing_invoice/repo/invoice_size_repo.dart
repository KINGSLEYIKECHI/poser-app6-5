import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/http_client/custome_http_client.dart';
import 'package:http/http.dart' as http;
import '../../../../Const/api_config.dart';

class InvoiceSizeRepo {
  Future<bool> invoiceSizeChange({required String? invoiceSize, required WidgetRef ref, required BuildContext context}) async {
    EasyLoading.show();
    CustomHttpClient client = CustomHttpClient(client: http.Client(), ref: ref, context: context);
    final url = Uri.parse('${APIConfig.url}/invoice-settings/update');
    try {
      final response = await client.post(url: url, body: {'invoice_size': invoiceSize});

      final massage = json.decode(response.body)['message'];
      if (response.statusCode == 200) {
        EasyLoading.showSuccess(massage);
        return true;
      }
      EasyLoading.showError(massage);
      return false;
    } catch (e) {
      EasyLoading.showError(e.toString());
      return false;
    }
  }
}
