import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mobile_pos/constant.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget universalImage(dynamic data, {double? w, double? h}) {
  try {
    // Case 1: Uint8List → PNG/JPG
    if (data is Uint8List) {
      return pw.Image(
        pw.MemoryImage(data),
        width: w,
        height: h,
        fit: pw.BoxFit.cover,
      );
    }

    // Case 2: SVG string
    if (data is String && data.trim().startsWith("<svg")) {
      return pw.SvgImage(
        svg: data,
        width: w,
        height: h,
        fit: pw.BoxFit.cover,
      );
    }

    // Case 3: Base64 Image String (data:image/png;base64,...)
    if (data is String && data.contains("base64")) {
      try {
        final base64Str = data.split(',').last;
        final bytes = base64Decode(base64Str);

        return pw.Image(
          pw.MemoryImage(bytes),
          width: w,
          height: h,
          fit: pw.BoxFit.cover,
        );
      } catch (e) {
        // base64 decode failed
        return pw.Container(width: w, height: h);
      }
    }

    // Case 4: Unknown String → DO NOT convert to image
    if (data is String) {
      return pw.Container(
        alignment: pw.Alignment.center,
        width: w,
        height: h,
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          color: PdfColors.grey200,
        ),
        child: pw.Text(
          "No Image",
          textAlign: pw.TextAlign.center,
        ),
      );
    }

    // Unknown type
    return pw.Container(width: w, height: h);
  } catch (e) {
    return pw.Container(
      alignment: pw.Alignment.center,
      width: w,
      height: h,
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        color: PdfColors.grey200,
      ),
      child: pw.Text(
        "Invalid Image",
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
