import 'package:flutter/material.dart';

import '_base_widget.dart';

class ThermerText extends ThermerWidget {
  ThermerText(
    this.data, {
    this.direction,
    this.style = const TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w500),
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.fallbackFonts,
  });

  final String data;

  final TextDirection? direction;

  final TextStyle? style;

  final TextAlign textAlign;

  final int? maxLines;

  final List<String>? fallbackFonts;
}
