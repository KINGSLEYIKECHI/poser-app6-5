import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Project Imports
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Provider/customer_provider.dart';
import '../../../Const/api_config.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../constant.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../service/check_user_role_permission_provider.dart';

class InvoiceReturnRepo {
  /// ------------------------------------------------------------
  /// Method: createSalesReturn
  /// ------------------------------------------------------------
  Future<bool?> createSalesReturn({
    required WidgetRef ref,
    required BuildContext context,
    required ReturnDataModel salesReturn,
  }) async {
    return _submitReturnRequest(
      ref: ref,
      context: context,
      urlPath: '/sales-return',
      body: salesReturn.toJson(purchase: false),
      permission: Permit.saleReturnsCreate.value,
      successMessage: 'Sales Return Added successfully!',
      onSuccessRefresh: () {
        ref.refresh(salesTransactionProvider);
      },
    );
  }

  /// ------------------------------------------------------------
  /// Method: createPurchaseReturn
  /// ------------------------------------------------------------
  Future<bool?> createPurchaseReturn({
    required WidgetRef ref,
    required BuildContext context,
    required ReturnDataModel returnData,
  }) async {
    return _submitReturnRequest(
      ref: ref,
      context: context,
      urlPath: '/purchases-return',
      body: returnData.toJson(purchase: true),
      permission: Permit.purchaseReturnsCreate.value,
      successMessage: 'Purchase Return Added successfully!',
      onSuccessRefresh: () {
        ref.refresh(purchaseTransactionProvider);
      },
    );
  }

  /// ------------------------------------------------------------
  /// Private Method: _submitReturnRequest
  /// ------------------------------------------------------------
  Future<bool?> _submitReturnRequest({
    required WidgetRef ref,
    required BuildContext context,
    required String urlPath,
    required Map<String, dynamic> body,
    required String permission,
    required String successMessage,
    required VoidCallback onSuccessRefresh,
  }) async {
    final uri = Uri.parse('${APIConfig.url}$urlPath');

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

      print("POS Return Request Body: ${jsonEncode(body)}");

      // Perform the POST request
      var response = await customHttpClient.post(
        url: uri,
        addContentTypeInHeader: true,
        body: jsonEncode(body),
        permission: permission,
      );

      final parsedData = jsonDecode(response.body);

      print("POS Return Response Body: $parsedData");

      if (response.statusCode == 200) {
        EasyLoading.showSuccess(successMessage);
        ref.refresh(summaryInfoProvider);
        ref.refresh(partiesProvider);
        ref.refresh(productProvider);
        onSuccessRefresh();
        return true;
      } else {
        _showError(context, parsedData['message'] ?? 'Something went wrong');
        return null;
      }
    } catch (error) {
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      _showError(context, errorMessage);
      return null;
    }
  }

  void _showError(BuildContext context, String message) {
    EasyLoading.dismiss();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kMainColor),
    );
  }
}

/// ============================================================================
/// Model: ReturnDataModel (UPDATED)
/// ============================================================================

// 1. Individual Product Model
class ReturnProductModel {
  final num detailId; // This is purchase_detail_id or sale_detail_id
  final num returnQty;
  final List<String>? serialNumbers;

  ReturnProductModel({
    required this.detailId,
    required this.returnQty,
    this.serialNumbers,
  });

  Map<String, dynamic> toJson({required bool purchase}) {
    return {
      // Key changes based on purchase/sale
      purchase ? "purchase_detail_id" : "sale_detail_id": detailId,
      "return_qty": returnQty,
      if (serialNumbers != null && serialNumbers!.isNotEmpty) "serial_numbers": serialNumbers,
    };
  }
}

// 2. Main Request Model
class ReturnDataModel {
  final String? transactionId; // sale_id or purchase_id
  final List<ReturnProductModel> products;
  List<Map<String, dynamic>> payments;

  ReturnDataModel({
    required this.transactionId,
    required this.products,
    required this.payments,
  });

  Map<String, dynamic> toJson({bool purchase = false}) {
    return {
      purchase ? "purchase_id" : 'sale_id': transactionId,
      "products": products.map((e) => e.toJson(purchase: purchase)).toList(),
      "payments": payments,
    };
  }
}
