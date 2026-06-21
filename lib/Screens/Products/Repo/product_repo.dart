//ignore_for_file: file_names, unused_element, unused_local_variable
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Products/Model/product_total_stock_model.dart';
import 'package:mobile_pos/service/check_user_role_permission_provider.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../Const/api_config.dart';
import '../../../Repository/constant_functions.dart';
import '../../../constant.dart';
import '../../../core/constant_variables/local_data_saving_keys.dart';
import '../../../http_client/custome_http_client.dart';
import '../../../http_client/customer_http_client_get.dart';
import '../../Purchase/Repo/purchase_repo.dart';
import '../Model/product_model.dart';
import '../add product/modle/create_product_model.dart';

class ProductRepo {
  // ==============================================================================
  // NEW CREATE PRODUCT FUNCTION
  // ==============================================================================
  Future<bool> createProduct(
      {required CreateProductModel data, required BuildContext context, required WidgetRef ref}) async {
    return _submitProductData(data: data, isUpdate: false, context: context, ref: ref);
  }

  // ==============================================================================
  // NEW UPDATE PRODUCT FUNCTION
  // ==============================================================================
  Future<bool> updateProduct(
      {required CreateProductModel data, required BuildContext context, required WidgetRef ref}) async {
    return _submitProductData(data: data, isUpdate: true, context: context, ref: ref);
  }

  /// Shared Logic for Create and Update to avoid code duplication
  Future<bool> _submitProductData(
      {required CreateProductModel data,
      required bool isUpdate,
      required BuildContext context,
      required WidgetRef ref}) async {
    EasyLoading.show(status: isUpdate ? 'Updating Product...' : 'Creating Product...');

    final url = Uri.parse(isUpdate ? '${APIConfig.url}/products/${data.productId}' : '${APIConfig.url}/products');

    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    // Helper to safely add simple string fields
    void addField(String key, dynamic value) {
      if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
        request.fields[key] = value.toString();
      }
    }

    // --- 1. Standard Fields ---
    if (isUpdate) addField('_method', 'put');

    addField('productName', data.name);
    addField('category_id', data.categoryId);
    addField('unit_id', data.unitId);
    addField('productCode', data.productCode);
    addField('brand_id', data.brandId);
    addField('model_id', data.modelId);
    addField('rack_id', data.rackId);
    addField('shelf_id', data.shelfId);
    addField('alert_qty', data.alertQty);
    addField('has_serial', data.hasSerial);

    addField('product_type', data.productType); // single, variant, combo
    addField('vat_type', data.vatType);
    addField('vat_id', data.vatId);
    // Optional: vat_amount if backend calculates it or needs it
    if (data.vatAmount != null) addField('vat_amount', data.vatAmount);

    // Extra info
    addField('productManufacturer', data.productManufacturer);
    addField('productDiscount', data.productDiscount);

    // --- 2. Complex Fields (JSON Encoded) ---

    // A. STOCKS
    // This handles Single (1 item in list) and Variant (multiple items in list)
    if (data.stocks != null && data.stocks!.isNotEmpty) {
      // Convert list of StockDataModel to List of Maps
      List<Map<String, dynamic>> stockListJson = data.stocks!.map((stock) => stock.toJson()).toList();
      // Encode to JSON String
      request.fields['stocks'] = jsonEncode(stockListJson);
    }

    // B. VARIATION IDs (Only for variant type)
    if (data.productType?.toLowerCase() == 'variant' && (data.variationIds?.isNotEmpty ?? false)) {
      request.fields['variation_ids'] = jsonEncode(data.variationIds);
    }

    // C. COMBO PRODUCTS (Only for combo type)
    if (data.productType?.toLowerCase() == 'combo' && (data.comboProducts?.isNotEmpty ?? false)) {
      request.fields['combo_products'] = jsonEncode(data.comboProducts);
      addField('profit_percent', data.comboProfitPercent);
      addField('productSalePrice', data.comboProductSalePrice);
    }

    // D. WARRANTY & GUARANTEE
    Map<String, String> warrantyInfo = {};
    if (data.warrantyDuration != null && data.warrantyDuration!.isNotEmpty) {
      warrantyInfo['warranty_duration'] = data.warrantyDuration!;
      warrantyInfo['warranty_unit'] = data.warrantyPeriod ?? 'days';
    }
    if (data.guaranteeDuration != null && data.guaranteeDuration!.isNotEmpty) {
      warrantyInfo['guarantee_duration'] = data.guaranteeDuration!;
      warrantyInfo['guarantee_unit'] = data.guaranteePeriod ?? 'days';
    }

    if (warrantyInfo.isNotEmpty) {
      request.fields['warranty_guarantee_info'] = jsonEncode(warrantyInfo);
    }

    // --- 3. File Upload ---
    if (data.image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'productPicture',
        data.image!.path,
        filename: data.image!.path.split('/').last,
      ));
    }

    // --- Debugging Logs ---
    print('URL: $url');
    print('--- Fields ---');

    request.fields.forEach((key, value) {
      print('$key: $value');
    });
    print('--- Fields ---');
    print(request.fields);

    // --- 4. Execute ---
    try {
      // var response = await request.send();
      CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), ref: ref, context: context);
      print('Product image: ${data.image?.path}');
      final response = await customHttpClient.uploadFile(
        url: url,
        file: data.image,
        fileFieldName: 'productPicture',
        fields: request.fields,
      );
      var responseData = await http.Response.fromStream(response);

      EasyLoading.dismiss();
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${responseData.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showSuccess(body['message'] ?? (isUpdate ? 'Updated successfully!' : 'Created successfully!'));
          return true;
        } catch (e) {
          // If JSON parsing fails but status is 200
          EasyLoading.showSuccess(isUpdate ? 'Product updated!' : 'Product created!');
          return true;
        }
      } else {
        try {
          var body = jsonDecode(responseData.body);
          EasyLoading.showError(body['message'] ?? 'Failed to process product');
        } catch (e) {
          EasyLoading.showError('Failed with status: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Network Error: ${e.toString()}');
      print(e.toString());
      return false;
    }
  }

  Future<String?> generateProductCode() async {
    final uri = Uri.parse('${APIConfig.url}/product/generate-code');
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

    try {
      final response = await clientGet.get(url: uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'].toString();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> fetchAllProducts() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/products');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body) as Map<String, dynamic>;

      final partyList = parsedData['data'] as List<dynamic>;
      return partyList.map((category) => Product.fromJson(category)).toList();
      // Parse into Party objects
    } else {
      throw Exception('Failed to fetch Products');
    }
  }

  Future<ProductListResponse> fetchProducts() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final uri = Uri.parse('${APIConfig.url}/products');

    final response = await clientGet.get(url: uri);

    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      return ProductListResponse.fromJson(parsedData);
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  // Fetch Product Details
  Future<Product> fetchProductDetails({required String productID}) async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());

    final url = Uri.parse('${APIConfig.url}/products/$productID');

    try {
      var response = await clientGet.get(url: url);
      EasyLoading.dismiss();
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return Product.fromJson(jsonData['data']);
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to fetch details');
        throw Exception(data['message'] ?? 'Failed to fetch details');
      }
    } catch (e) {
      // Hide loading indicator and show error
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> deleteProduct({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final String apiUrl = '${APIConfig.url}/products/$id';

    try {
      CustomHttpClient customHttpClient = CustomHttpClient(
        ref: ref,
        context: context,
        client: http.Client(),
      );

      final response = await customHttpClient.delete(
        url: Uri.parse(apiUrl),
        permission: Permit.productsDelete.value,
      );

      EasyLoading.dismiss();

      // 👇 Print full response info
      print('Delete Product Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('Headers: ${response.headers}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );

        ref.refresh(productProvider);
      } else {
        final parsedData = jsonDecode(response.body);
        final errorMessage = parsedData['error'].toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: kMainColor,
          ),
        );
      }
    } catch (e) {
      print('rrrr');
      EasyLoading.dismiss();
      print('Exception during product delete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> addStock({
    required String id,
    required String qty,
    required List<dynamic> serialNumbers,
    required String productId,
    required BuildContext context, // Added context
    required WidgetRef ref, // Added ref
  }) async {
    final url = Uri.parse('${APIConfig.url}/stocks');

    try {
      // Initialize CustomHttpClient
      CustomHttpClient customHttpClient = CustomHttpClient(
        client: http.Client(),
        context: context,
        ref: ref,
      );

      final requestBody = jsonEncode({
        "product_id": productId,
        "stock_id": id,
        "productStock": qty,
        "serial_numbers": serialNumbers,
      });

      // Use customHttpClient.post instead of http.post
      final response = await customHttpClient.post(
        url: url,
        addContentTypeInHeader: true,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Unknown error');
        return false;
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateVariation({
    required String stockId,
    required CartProductModelPurchase data,
    required BuildContext context, // Added context
    required WidgetRef ref, // Added ref
  }) async {
    EasyLoading.show(status: 'Updating Product...');

    // Note: Ensure data.variantName contains the correct ID or Slug required by your API
    final url = Uri.parse('${APIConfig.url}/stocks/$stockId');
    print(url);

    try {
      // Initialize CustomHttpClient
      CustomHttpClient customHttpClient = CustomHttpClient(
        client: http.Client(),
        context: context,
        ref: ref,
      );

      // Create Body Map
      final Map<String, dynamic> requestBody = {
        '_method': 'put', // Method spoofing for Laravel/PHP backends
        'batch_no': data.batchNumber,
        'product_id': data.productId,
        'productStock': data.quantities,
        'productPurchasePrice': data.productPurchasePrice,
        'profit_percent': data.profitPercent,
        'productSalePrice': data.productSalePrice,
        'productWholeSalePrice': data.productWholeSalePrice,
        'productDealerPrice': data.productDealerPrice,
        'mfg_date': data.mfgDate,
        'expire_date': data.expireDate,
        "warehouse_id": data.warehouseId,
        // If you need to update serials, verify if 'serialNumbers' key is required
        if (data.serialNumber?.isNotEmpty ?? false) 'serial_numbers': data.serialNumber,
      };

      // Optional: Remove null/empty values to mimic previous logic
      requestBody.removeWhere((key, value) => value == null || value.toString() == 'null');

      print('--- Request Body ---');
      print(jsonEncode(requestBody));

      // Perform Normal JSON POST
      final response = await customHttpClient.post(
        addContentTypeInHeader: true,
        url: url,
        body: jsonEncode(requestBody),
      );

      EasyLoading.dismiss();

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var body = jsonDecode(response.body);
          EasyLoading.showSuccess(body['message'] ?? 'Product updated successfully!');
          return true;
        } catch (e) {
          EasyLoading.showSuccess('Product updated successfully!');
          return true;
        }
      } else {
        try {
          var body = jsonDecode(response.body);
          EasyLoading.showError(body['message'] ?? 'Failed to update product');
        } catch (e) {
          EasyLoading.showError('Failed to update product. Status: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Network Error: ${e.toString()}');
      print('Network Error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteStock({required String id}) async {
    EasyLoading.show(status: 'Processing');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(LocalDataBaseSavingKey.tokenKey) ?? '';
    final url = Uri.parse('${APIConfig.url}/stocks/$id');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      var response = await http.delete(
        url,
        headers: headers,
      );
      EasyLoading.dismiss();
      print(response.statusCode);
      if (response.statusCode == 200) {
        return true;
      } else {
        var data = jsonDecode(response.body);
        EasyLoading.showError(data['message'] ?? 'Failed to delete');
        print(data['message']);
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      print(e.toString());
      return false;
    }
  }

  Future<PaginatedProductListModel> getPaginatedProducts({
    int page = 1,
    PaginatedProductListFilter filter = const PaginatedProductListFilter(),
  }) async {
    try {
      final clientGet = CustomHttpClientGet(client: http.Client());
      final _queryParams = {'page': page.toString(), ...filter.toJson()};

      final _uri = Uri.parse('${APIConfig.url}/get-paginated-products').replace(queryParameters: _queryParams);

      final _response = await clientGet.get(url: _uri);

      if (_response.statusCode != 200) {
        throw Exception("Failed to get products data from API");
      }

      return PaginatedProductListModel.fromJson(jsonDecode(_response.body), Product.fromJson);
    } catch (e) {
      rethrow;
    }
  }
}
