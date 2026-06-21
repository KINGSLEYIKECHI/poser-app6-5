import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../../../Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';
import '../../../../currency.dart';
import '../../../Home/home.dart';
import '../../Sign Up/verify_email.dart';
import '../../profile_setup_screen.dart';

class LogInRepo {
  Future<bool> logIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final url = Uri.parse('${APIConfig.url}/sign-in');

    final body = {
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
      print('Signin ${response.statusCode}');
      print('Signin ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));

        bool isSetupDone = responseData['data']['is_setup'];
        try {
          await CurrencyMethods().saveCurrencyDataInLocalDatabase(
              selectedCurrencySymbol: responseData['data']['currency']['symbol'],
              selectedCurrencyName: responseData['data']['currency']['name']);
        } catch (error) {
          print(error);
        }
        if (!isSetupDone) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileSetup()),
            (_) => false,
          );
        } else {
          await saveUserData(
            token: responseData['data']['token'],
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (_) => false,
          );
        }

        return true;
      } else if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmail(
              email: email,
              isFormForgotPass: false,
            ),
          ),
        );

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error: Please try again')));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error: Please try again')));
    }

    return false;
  }
}
