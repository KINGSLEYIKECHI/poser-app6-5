import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Required for SocketException

import 'package:http/http.dart' as http;
// import '../../../constant.dart'; // Keep your constant import

class PurchaseModel {
  final String validProductCode = '53621221';
  final String apiToken = 'orZoxiU81Ok7kxsE0FvfraaO0vDW5tiz';

  // Added 'purchaseCode' as a parameter to the function
  Future<bool> isActiveBuyer(String purchaseCode) async {
    // 1. Validation: Check if the purchase code is empty
    if (purchaseCode.isEmpty) {
      print('Error: Purchase code is empty');
      return false;
    }

    try {
      final uri = Uri.parse('https://api.envato.com/v3/market/author/sale?code=$purchaseCode');

      // 2. Set a timeout to prevent the app from hanging (e.g., 10 seconds)
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $apiToken'},
      ).timeout(const Duration(seconds: 10));

      print('Response Body: ${response.body}');

      // 3. Check HTTP Status Code
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);

          // 4. Null Safety: Check if 'item' and 'id' exist in the response
          if (data['item'] != null && data['item']['id'] != null) {
            final purchasedProductCode = data['item']['id'];

            print('Purchased Product ID: $purchasedProductCode');

            // 5. Verify if the purchased product matches your product code
            if (purchasedProductCode.toString() == validProductCode) {
              return true; // Verification Successful
            } else {
              print('Error: Product code does not match.');
            }
          } else {
            print('Error: Invalid JSON structure or missing item ID.');
          }
        } catch (e) {
          print('Error parsing JSON: $e');
        }
      }
      // Handle specific HTTP errors
      else if (response.statusCode == 404) {
        print('Error: Purchase code not found or invalid (404).');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Error: Unauthorized access. Please check your API Token.');
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } on SocketException {
      // 6. Handle No Internet Connection
      print('Network Error: No internet connection.');
    } on TimeoutException {
      // 7. Handle Request Timeout
      print('Network Error: Connection timed out.');
    } catch (e) {
      // 8. Handle any other unexpected errors
      print('Unexpected Error: $e');
    }

    // Return false if any error occurs
    return false;
  }
}
