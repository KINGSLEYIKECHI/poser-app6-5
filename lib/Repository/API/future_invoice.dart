import 'package:http/http.dart' as http;

import '../../Const/api_config.dart';
import '../../http_client/customer_http_client_get.dart';
import '../constant_functions.dart';

class FutureInvoice {
  Future<String> getFutureInvoice({required String tag}) async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    try {
      final response = await clientGet.get(
        url: Uri.parse('${APIConfig.url}/new-invoice?platform=$tag'),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (error) {
      return '';
    }
  }
}
