import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../../../Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';
import '../../../../currency.dart';

class SignUpRepo {
  Future<dynamic> signUp({required String name, required String email, required String password, required BuildContext context}) async {
    final url = Uri.parse('${APIConfig.url}/sign-up');

    final body = {
      'name': name,
      'email': email,
      'password': password,
    };
    final headers = {
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = jsonDecode(response.body);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));

        final token = responseData['token'];
        if (token != null) {
          await saveUserData(token: token);
          return responseData['token'];
        }

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error: Please try again')));
    } finally {}

    return false;
  }

  Future<bool> verifyOTP({required String email, required String otp, required BuildContext context}) async {
    final url = Uri.parse('${APIConfig.url}/submit-otp');

    final body = {
      'email': email,
      'otp': otp,
    };
    final headers = {
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = jsonDecode(response.body);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));

        String? token = responseData['token'];
        if (responseData['currency'] != null) {
          await CurrencyMethods()
              .saveCurrencyDataInLocalDatabase(selectedCurrencySymbol: responseData['currency']['symbol'], selectedCurrencyName: responseData['currency']['name']);
        }
        if (token != null) {
          await saveUserData(token: responseData['token']);
        }

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['error'])));
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server error: Please try again')));
    }

    return false;
  }

  Future<bool> resendOTP({required String email, required BuildContext context}) async {
    final url = Uri.parse('${APIConfig.url}/resend-otp');

    final body = {
      'email': email,
    };
    final headers = {
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      final responseData = jsonDecode(response.body);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['error'])));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error: Please try again')));
    } finally {}

    return false;
  }
}
