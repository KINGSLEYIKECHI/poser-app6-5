import 'dart:convert' show json;

import 'package:flutter/services.dart';

class PrinterProfile {
  const PrinterProfile({required this.name});
  final String name;

  factory PrinterProfile.tryFromName(String? name) {
    return PrinterProfile(name: name ?? 'default');
  }

  static PrinterProfile get fallback {
    return PrinterProfile(name: 'default');
  }

  static Future<List<PrinterProfile>> loadProfiles() async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/esc_pos_utils_plus/resources/capabilities.json',
      );
      final decodedJson = json.decode(jsonString);

      if (decodedJson['profiles'] is! Map<String, dynamic>) {
        throw FormatException('Invalid profiles format in JSON');
      }

      final profilesMap = decodedJson['profiles'] as Map<String, dynamic>;
      return profilesMap.keys.map((key) => PrinterProfile(name: key)).toList();
    } catch (e) {
      throw Exception('Failed to load printer profiles: $e');
    }
  }

  @override
  bool operator ==(Object other) {
    return other is PrinterProfile && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
