import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Const/api_config.dart';

class OtpSettingsModel {
  final String otpStatus;
  final String otpExpirationTime;
  final String otpDurationType;

  OtpSettingsModel({
    required this.otpStatus,
    required this.otpExpirationTime,
    required this.otpDurationType,
  });

  factory OtpSettingsModel.fromJson(Map<String, dynamic> json) {
    return OtpSettingsModel(
      otpStatus: json['otp_status'] ?? '',
      otpExpirationTime: json['otp_expiration_time'] ?? '',
      otpDurationType: json['otp_duration_type'] ?? '',
    );
  }
}

class OtpSettingsRepo {
  Future<OtpSettingsModel?> fetchOtpSettings() async {
    try {
      final response = await http.get(
        Uri.parse("${APIConfig.url}/otp-settings"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final data = decoded['data'];
        return OtpSettingsModel.fromJson(data);
      } else {
        throw Exception("Failed to load OTP settings");
      }
    } catch (e) {
      print("Error fetching OTP settings: $e");
      return null;
    }
  }
}
