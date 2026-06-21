// import 'dart:typed_data' show Uint8List;

// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
// import 'package:image/image.dart' as img;
// import 'package:intl/intl.dart';
// import 'package:mobile_pos/generated/l10n.dart' as lang;
// import 'package:mobile_pos/generated/l10n.dart';
// import 'package:mobile_pos/model/business_info_model.dart';
// import 'package:mobile_pos/model/sale_transaction_model.dart';
// import '../../thermer/thermer.dart' as thermer;

// // part '_purchase_invoice_template.dart';
// part '_sale_invoice_template.dart';
// // part '_kot_ticket_template.dart';
// // part '_due_collection_invoice_template.dart';

// abstract class ThermalInvoiceTemplateBase {
//   ThermalInvoiceTemplateBase(this.ref);
//   final riverpod.Ref ref;

//   thermer.TextDirection get textDirection {
//     final _rtlLang = ['ar', 'ar-bh', 'eg-ar', 'fa', 'prs', 'ps', 'ur'];

//     // if (_rtlLang.contains(ref.read(GlobalContextHolder.localeProvider).languageCode)) {
//     //   return thermer.TextDirection.rtl;
//     // }

//     return thermer.TextDirection.ltr;
//   }

//   Future<List<int>> get template;
//   // Future<img.Image?> getNetworkImage(
//   //   String? url, {
//   //   int width = 100,
//   //   int height = 100,
//   // }) async {
//   //   if (url == null) return null;

//   //   try {
//   //     final _response = await dio.Dio().get<List<int>>(
//   //       url,
//   //       options: dio.Options(responseType: dio.ResponseType.bytes),
//   //     );

//   //     final _image = img.decodeImage(Uint8List.fromList(_response.data!));
//   //     if (_image == null) return null;

//   //     return img.copyResize(
//   //       _image,
//   //       width: width,
//   //       height: height,
//   //       interpolation: img.Interpolation.average,
//   //     );
//   //   } catch (e) {
//   //     return null;
//   //   }
//   // }
// }

// // extension ThermalPrinterPaperSizeExt  {
// //   PaperSize get escPosSize {
// //     return switch (this) {
// //       ThermalPrinterPaperSize.mm582Inch => PaperSize.mm58,
// //       ThermalPrinterPaperSize.mm803Inch => PaperSize.mm80,
// //     };
// //   }
// // }
