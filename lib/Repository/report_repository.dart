// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_pos/Const/api_config.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_pos/model/due_model.dart';
// import 'package:mobile_pos/model/purchase_model.dart';
// import 'package:mobile_pos/model/sale_model.dart';
//
// import '../constant_functions.dart';
//
// class ReportRepository {
//   //---------sales report repo---------------
//   Future<SaleModel> sale({String? type}) async {
//     final headers = {
//       'Accept': 'application/json',
//       'Authorization': await getAuthToken(),
//     };
//     Uri uri;
//
//     if (type!.startsWith("custom_date")) {
//       final uriParams = Uri.splitQueryString(type.replaceFirst('custom_date', ''));
//       final fromDate = uriParams['from_date'];
//       final toDate = uriParams['to_date'];
//       uri = Uri.parse('${APIConfig.url}/sales?duration=custom_date&from_date=$fromDate&to_date=$toDate');
//     } else {
//       uri = Uri.parse('${APIConfig.url}/sales?duration=$type');
//     }
//     final response = await http.get(uri, headers: headers);
//     if (response.statusCode == 200) {
//       final parsedData = jsonDecode(response.body);
//       return SaleModel.fromJson(parsedData);
//     } else {
//       throw Exception('Failed to fetch Sales List');
//     }
//   }
//
//   //----------purchase report repo----------------
//   Future<PurchaseModel> purchase({String? type}) async {
//     final headers = {
//       'Accept': 'application/json',
//       'Authorization': await getAuthToken(),
//     };
//     Uri uri;
//
//     if (type!.startsWith("custom_date")) {
//       final uriParams = Uri.splitQueryString(type.replaceFirst('custom_date', ''));
//       final fromDate = uriParams['from_date'];
//       final toDate = uriParams['to_date'];
//       uri = Uri.parse('${APIConfig.url}/purchase?duration=custom_date&from_date=$fromDate&to_date=$toDate');
//     } else {
//       uri = Uri.parse('${APIConfig.url}/purchase?duration=$type');
//     }
//     final response = await http.get(uri, headers: headers);
//     print('-------${response.statusCode}------');
//     if (response.statusCode == 200) {
//       final parsedData = jsonDecode(response.body);
//       return PurchaseModel.fromJson(parsedData);
//     } else {
//       throw Exception('Failed to fetch Sales List');
//     }
//   }
//
//   //---------- report repo----------------
//   Future<DueModel> due({String? type}) async {
//     final headers = {
//       'Accept': 'application/json',
//       'Authorization': await getAuthToken(),
//     };
//     Uri uri;
//
//     if (type!.startsWith("custom_date")) {
//       final uriParams = Uri.splitQueryString(type.replaceFirst('custom_date', ''));
//       final fromDate = uriParams['from_date'];
//       final toDate = uriParams['to_date'];
//       uri = Uri.parse('${APIConfig.url}/dues?duration=custom_date&from_date=$fromDate&to_date=$toDate');
//     } else {
//       uri = Uri.parse('${APIConfig.url}/dues?duration=$type');
//       print('------$uri------------------');
//     }
//     final response = await http.get(uri, headers: headers);
//     print('-------${response.statusCode}------');
//     if (response.statusCode == 200) {
//       final parsedData = jsonDecode(response.body);
//       return DueModel.fromJson(parsedData);
//     } else {
//       throw Exception('Failed to fetch Sales List');
//     }
//   }
// }
//
// final reportRepo = ReportRepository();
// final saleReportProvider = FutureProvider.family.autoDispose<SaleModel, String>((ref, type) => reportRepo.sale(type: type));
// final purchaseReportProvider = FutureProvider.family.autoDispose<PurchaseModel, String>((ref, type) => reportRepo.purchase(type: type));
// final dueReportProvider = FutureProvider.family.autoDispose<DueModel, String>((ref, type) => reportRepo.due(type: type));
