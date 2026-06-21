import 'package:flutter/material.dart';

bool isCheckRtl(BuildContext context) {
  final locale = Localizations.localeOf(context);
  const rtlLanguages = [
    'ar', // Arabic
    'fa', // Persian (Farsi)
    'ur', // Urdu
    'he', // Hebrew
    'ps', // Pashto
  ];

  return rtlLanguages.contains(locale.languageCode);
}
