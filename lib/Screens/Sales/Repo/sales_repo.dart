import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/constant.dart';
import '../../../Const/api_config.dart';
import '../../../model/purchase_tax_model.dart';
import '../../../model/sale_tax_model.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../Repository/constant_functions.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../../../model/balance_sheet_model.dart' as bs;
import '../../../model/bill_wise_loss_profit_report_model.dart' as bwlprm;
import '../../../model/cashflow_model.dart' as cf;
import '../../../model/loss_profit_model.dart' as lpmodel;
import '../../../model/product_history_model.dart' as phlm;
import '../../../model/sale_transaction_model.dart';
import '../../../model/subscription_report_model.dart' as srm;
import '../../../model/tax_report_model.dart' as trm;
import '../../Customers/Provider/customer_provider.dart';

class SaleRepo {
  Future<List<SalesTransactionModel>> fetchSalesList({
    bool? salesReturn,
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    final client = CustomHttpClientGet(client: http.Client());

    // Manually build query string to preserve order
    final List<String> queryList = [];

    if (salesReturn != null && salesReturn) {
      queryList.add('returned-sales=true');
    }

    if (type != null && type.isNotEmpty) {
      queryList.add('duration=$type');
    }

    if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
      queryList.add('from_date=$fromDate');
      queryList.add('to_date=$toDate');
    }

    final String queryString = queryList.join('&');
    final Uri uri = Uri.parse('${APIConfig.url}/sales${queryString.isNotEmpty ? '?$queryString' : ''}');

    print(uri);

    final response = await client.get(url: uri);

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      final list = parsed['data'] as List<dynamic>;
      return list.map((json) => SalesTransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Sales List. Status code: ${response.statusCode}');
    }
  }

  Future<SalesTransactionModel?> getSingleSale(int id) async {
    final uri = Uri.parse('${APIConfig.url}/sales/$id');
    // final uri = Uri.parse('${APIConfig.url}/sale-taxes/$id');

    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final response = await clientGet.get(url: uri);

      print("Fetch Single Single Status: ${response.statusCode}");
      print("Fetch Single Single Body: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return SalesTransactionModel.fromJson(parsed['data']);
      } else {
        throw Exception("Failed to fetch sale details");
      }
    } catch (e) {
      throw Exception("Error fetching sale: $e");
    }
  }

  ///--------------tax sale transaction model-------------------
  Future<TaxSaleData?> getTaxSale(int id) async {
    final uri = Uri.parse('${APIConfig.url}/sale-taxes/$id');

    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final taxSaleResponse = TaxSaleResponse.fromJson(parsed);
        print('------parsing data--${taxSaleResponse.data?.salesReturns}---------------');
        return taxSaleResponse.data;
      } else {
        throw Exception("Failed to fetch sale tax");
      }
    } catch (e) {
      throw Exception("Error fetching sale: $e");
    }
  }

  ///--------------tax purhase transaction model-------------------
  Future<TaxPurchaseData?> getTaxPurchase(int id) async {
    final uri = Uri.parse('${APIConfig.url}/purchase-taxes/$id');

    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final taxSaleResponse = PurchaseTaxResponse.fromJson(parsed);
        return taxSaleResponse.data;
      } else {
        throw Exception("Failed to fetch purchase tex tax");
      }
    } catch (e) {
      throw Exception("Error fetching sale: $e");
    }
  }

  /// Create Sale
  Future<SalesTransactionModel?> createSale({
    required WidgetRef ref,
    required BuildContext context,
    required num? partyId,
    required String? customerPhone,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num unRoundedTotalAmount,
    required num totalAmount,
    required num roundingAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num? vatId,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required String roundedOption,
    required List<CartSaleProducts> products,
    required String discountType,
    required num shippingCharge,
    String? note,
    File? image,
  }) async {
    // 1. Prepare Fields
    final fields = _buildCommonFields(
      purchaseDate: purchaseDate,
      discountAmount: discountAmount,
      discountPercent: discountPercent,
      totalAmount: totalAmount,
      dueAmount: dueAmount,
      vatAmount: vatAmount,
      vatPercent: vatPercent,
      changeAmount: changeAmount,
      isPaid: isPaid,
      paymentType: paymentType,
      discountType: discountType,
      shippingCharge: shippingCharge,
      roundedOption: roundedOption,
      roundingAmount: roundingAmount,
      unRoundedTotalAmount: unRoundedTotalAmount,
      products: products,
      note: note,
      partyId: partyId,
      vatId: vatId,
    );

    if (customerPhone != null) fields['customer_phone'] = customerPhone;

    // 2. Submit Request
    final response = await _submitRequest(
      ref: ref,
      context: context,
      url: '${APIConfig.url}/sales',
      method: 'POST',
      fields: fields,
      image: image,
    );
    print('Sales Request status code: ${response?.statusCode}');
    print('Sales Response Data: ${response?.body}');

    // 3. Handle Success
    if (response != null && response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      _refreshProviders(ref);
      return SalesTransactionModel.fromJson(parsedData['data']);
    } else if (response != null) {
      _handleError(context, response);
    }
    return null;
  }

  /// Update Sale
  Future<void> updateSale({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
    required num? partyId,
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num unRoundedTotalAmount,
    required num totalAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num? vatId,
    required num changeAmount,
    required num roundingAmount,
    required bool isPaid,
    required String paymentType,
    required String roundedOption,
    required List<CartSaleProducts> products,
    required String discountType,
    required num shippingCharge,
    String? note,
    File? image,
  }) async {
    // 1. Prepare Fields
    final fields = _buildCommonFields(
      purchaseDate: purchaseDate,
      discountAmount: discountAmount,
      discountPercent: discountPercent,
      totalAmount: totalAmount,
      dueAmount: dueAmount,
      vatAmount: vatAmount,
      vatPercent: vatPercent,
      changeAmount: changeAmount,
      isPaid: isPaid,
      paymentType: paymentType,
      discountType: discountType,
      shippingCharge: shippingCharge,
      roundedOption: roundedOption,
      roundingAmount: roundingAmount,
      unRoundedTotalAmount: unRoundedTotalAmount,
      products: products,
      note: note,
      partyId: partyId,
      vatId: vatId,
    );

    // Add Method Override for Update
    fields['_method'] = 'put';

    // 2. Submit Request
    final response = await _submitRequest(
      ref: ref,
      context: context,
      url: '${APIConfig.url}/sales/$id',
      method: 'POST', // Multipart uses POST with _method field for PUT behavior usually
      fields: fields,
      image: image,
    );

    // 3. Handle Success
    if (response != null && response.statusCode == 200) {
      EasyLoading.showSuccess('Updated successful!');
      _refreshProviders(ref);
      Navigator.pop(context);
    } else if (response != null) {
      _handleError(context, response);
    }
  }

  // ------------------------------------------
  // Private Helper Methods (The Simplification)
  // ------------------------------------------

  Map<String, String> _buildCommonFields({
    required String purchaseDate,
    required num discountAmount,
    required num discountPercent,
    required num totalAmount,
    required num dueAmount,
    required num vatAmount,
    required num vatPercent,
    required num changeAmount,
    required bool isPaid,
    required String paymentType,
    required String discountType,
    required num shippingCharge,
    required String roundedOption,
    required num roundingAmount,
    required num unRoundedTotalAmount,
    required List<CartSaleProducts> products,
    String? note,
    num? partyId,
    num? vatId,
  }) {
    final Map<String, String> fields = {
      'saleDate': purchaseDate,
      'discountAmount': discountAmount.toString(),
      'discount_percent': discountPercent.toString(),
      'totalAmount': totalAmount.toString(),
      'dueAmount': dueAmount.toString(),
      'paidAmount': (totalAmount - dueAmount).toString(),
      'change_amount': changeAmount.toString(),
      'vat_amount': vatAmount.toString(),
      'vat_percent': vatPercent.toString(),
      'isPaid': isPaid.toString(),
      'payments': paymentType,
      'discount_type': discountType,
      'shipping_charge': shippingCharge.toString(),
      'rounding_option': roundedOption,
      'rounding_amount': roundingAmount.toStringAsFixed(2),
      'actual_total_amount': unRoundedTotalAmount.toString(),
      'note': note ?? '',
      'products': jsonEncode(products.map((e) => e.toJson()).toList()),
    };

    if (partyId != null) fields['party_id'] = partyId.toString();
    if (vatId != null) fields['vat_id'] = vatId.toString();

    return fields;
  }

  Future<http.Response?> _submitRequest({
    required WidgetRef ref,
    required BuildContext context,
    required String url,
    required String method,
    required Map<String, String> fields,
    File? image,
  }) async {
    final uri = Uri.parse(url);
    try {
      var request = http.MultipartRequest(method, uri);

      // Add Headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': await getAuthToken(),
        'Content-Type': 'multipart/form-data',
      });

      // Add Fields
      request.fields.addAll(fields);

      // Add Image
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      CustomHttpClient customHttpClient = CustomHttpClient(
        client: http.Client(),
        ref: ref,
        context: context,
      );

      var streamedResponse = await customHttpClient.uploadFile(
        url: uri,
        file: image,
        fileFieldName: 'image',
        fields: request.fields,
        contentType: 'multipart/form-data',
      );
      print('POST Sales Data ------------------->\n${request.fields}');

      return await http.Response.fromStream(streamedResponse);
    } catch (error) {
      EasyLoading.dismiss();
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: kMainColor),
      );
      return null;
    }
  }

  void _refreshProviders(WidgetRef ref) {
    ref.refresh(productProvider);
    ref.refresh(partiesProvider);
    ref.refresh(salesTransactionProvider);
    ref.refresh(businessInfoProvider);
    ref.refresh(getExpireDateProvider(ref));
    ref.refresh(summaryInfoProvider);
  }

  void _handleError(BuildContext context, http.Response response) {
    EasyLoading.dismiss();
    try {
      final parsedData = jsonDecode(response.body);
      print('reponse :${parsedData}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: ${parsedData['message'] ?? response.reasonPhrase}')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: ${response.statusCode}')),
      );
    }
  }

  Future<lpmodel.LossProfitModel> getLossProfit({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri = Uri.parse('${APIConfig.url}/reports/loss-profit${queryString.isNotEmpty ? '?$queryString' : ''}');

      final response = await clientGet.get(url: uri);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed == null) {
          throw Exception("Response is null");
        }
        if (parsed['data'] == null) {
          return lpmodel.LossProfitModel.fromJson(parsed);
        }

        return lpmodel.LossProfitModel.fromJson(parsed['data']);
      } else {
        throw Exception("Failed to fetch loss profit: ${response.statusCode} - ${response.body}");
      }
    } catch (e, stack) {
      throw Exception("Error fetching loss profit: $e");
    }
  }

  Future<cf.CashflowModel> getCashflow({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri = Uri.parse('${APIConfig.url}/reports/cashflow${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return cf.CashflowModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch sale details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching sale: $e");
    }
  }

  Future<bs.BalanceSheetModel> getBalanceSheet({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri =
          Uri.parse('${APIConfig.url}/reports/balance-sheet${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return bs.BalanceSheetModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch balance sheet details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching balance sheet: $e");
    }
  }

  Future<List<srm.SubscriptionReportModel>> getSubscriptionReport({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri =
          Uri.parse('${APIConfig.url}/reports/subscription${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return [...?parsed?["data"].map<srm.SubscriptionReportModel>((x) => srm.SubscriptionReportModel.fromJson(x))];
      } else {
        throw Exception("Failed to fetch subscription report details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching subscription report: $e");
    }
  }

  Future<trm.TaxReportModel> getTaxReport({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri = Uri.parse('${APIConfig.url}/reports/tax${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return trm.TaxReportModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch tax report details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching tax report: $e");
    }
  }

  Future<bwlprm.BillWiseLossProfitReportModel> getBillWiseLossProfitReport({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri =
          Uri.parse('${APIConfig.url}/reports/bill-wise-profit${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return bwlprm.BillWiseLossProfitReportModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch tax report details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching tax report: $e");
    }
  }

  Future<phlm.ProductHistoryListModel> getProductSaleHistoryReport({
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri =
          Uri.parse('${APIConfig.url}/reports/product-sale-history${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return phlm.ProductHistoryListModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch tax report details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching tax report: $e");
    }
  }

  Future<phlm.ProductHistoryDetailsModel> getProductSaleHistoryReportDetails({
    required int productId,
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri = Uri.parse(
          '${APIConfig.url}/reports/product-sale-history/$productId${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return phlm.ProductHistoryDetailsModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch tax report details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching tax report: $e");
    }
  }

  Future<phlm.ProductHistoryDetailsModel> getProductPurchaseHistoryReportDetails({
    required int productId,
    String? type,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
      final List<String> queryList = [];

      if (type != null && type.isNotEmpty) {
        queryList.add('duration=$type');
      }

      if (type == 'custom_date' && fromDate != null && toDate != null && fromDate.isNotEmpty && toDate.isNotEmpty) {
        queryList.add('from_date=$fromDate');
        queryList.add('to_date=$toDate');
      }

      final String queryString = queryList.join('&');
      final Uri uri = Uri.parse(
          '${APIConfig.url}/reports/product-purchase-history/$productId${queryString.isNotEmpty ? '?$queryString' : ''}');
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return phlm.ProductHistoryDetailsModel.fromJson(parsed);
      } else {
        throw Exception("Failed to fetch tax report details: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching tax report: $e");
    }
  }

  /// Delete Sale
  Future<bool> deleteSale({
    required WidgetRef ref,
    required BuildContext context,
    required num id,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/sales/$id');

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(
        client: http.Client(),
        ref: ref,
        context: context,
      );

      final response = await customHttpClient.delete(
        url: uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': await getAuthToken(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        EasyLoading.showSuccess('Sale deleted successfully!');
        _refreshProviders(ref);
        return true;
      } else {
        _handleError(context, response);
        return false;
      }
    } catch (error) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error'), backgroundColor: kMainColor),
      );
      return false;
    }
  }
}

class CartSaleProducts {
  final num stockId;
  final num productId;
  final num? price;
  final num? discount;
  final String productName;
  final num? quantities;
  final List<dynamic>? serialNumber;

  CartSaleProducts({
    required this.productName,
    required this.stockId,
    this.discount,
    required this.productId,
    required this.price,
    required this.quantities,
    this.serialNumber,
  });

  Map<String, dynamic> toJson() => {
        'stock_id': stockId,
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantities': quantities,
        'discount': discount,
        'serial_numbers': serialNumber,
      };
}
