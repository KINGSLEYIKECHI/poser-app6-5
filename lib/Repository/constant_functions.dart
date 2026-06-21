import 'package:shared_preferences/shared_preferences.dart';

import '../core/constant_variables/local_data_saving_keys.dart';

Future<String> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();

  print("AUTHToken: Bearer ${prefs.getString(LocalDataBaseSavingKey.tokenKey)}");
  return "Bearer ${prefs.getString(LocalDataBaseSavingKey.tokenKey) ?? ''}";
}

Future<void> saveUserData({required String token}) async {
  print(token);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(LocalDataBaseSavingKey.tokenKey, token);
  await prefs.setBool(LocalDataBaseSavingKey.skipOnBodingKey, true);
}
