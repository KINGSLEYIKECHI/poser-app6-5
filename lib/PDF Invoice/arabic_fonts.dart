import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;

String reshapeArabicOnly(String text) {
  return ArabicReshaper().reshape(text);
}

String fixArabic(String text) {
  final reshaped = ArabicReshaper().reshape(text);

  final visualList = bidi.logicalToVisual(reshaped);

  final visualString = String.fromCharCodes(visualList);

  return visualString;
}
