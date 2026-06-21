import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../../../Const/api_config.dart';
import '../../../../Repository/constant_functions.dart';
import '../../../../http_client/customer_http_client_get.dart';
import '../model/get_product_setting_model.dart';
import '../model/product_setting_model.dart';

class ProductSettingRepo {
  // Add or update setting
  Future<bool> updateProductSetting({required UpdateProductSettingModel data}) async {
    EasyLoading.show(status: 'Updating');

    // final prefs = await SharedPreferences.getInstance(); // Removed if unused

    final url = Uri.parse('${APIConfig.url}/product-settings');

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': await getAuthToken(),
    });

    request.fields['show_product_name'] = '1';
    request.fields['show_product_code'] = data.productCode.toString();
    request.fields['show_product_stock'] = data.productStock.toString();
    request.fields['show_product_sale_price'] = data.salePrice.toString();
    request.fields['show_product_dealer_price'] = data.dealerPrice.toString();
    request.fields['show_product_wholesale_price'] = data.wholesalePrice.toString();
    request.fields['show_product_unit'] = data.unit.toString();
    request.fields['show_product_brand'] = data.brand.toString();
    request.fields['show_product_category'] = data.category.toString();
    request.fields['show_product_manufacturer'] = data.manufacturer.toString();
    request.fields['show_product_image'] = data.image.toString();
    request.fields['show_expire_date'] = data.showExpireDate.toString();
    request.fields['show_alert_qty'] = data.alertQty.toString();
    request.fields['show_vat_id'] = data.vatId.toString();
    request.fields['show_vat_type'] = data.vatType.toString();
    request.fields['show_exclusive_price'] = data.exclusivePrice.toString();
    request.fields['show_inclusive_price'] = data.inclusivePrice.toString();
    request.fields['show_profit_percent'] = data.profitPercent.toString();
    request.fields['show_batch_no'] = data.batchNo.toString();
    request.fields['show_mfg_date'] = data.showManufactureDate.toString();
    request.fields['show_model_no'] = data.model.toString();
    request.fields['show_product_type_single'] = data.showSingle.toString();
    request.fields['show_product_type_variant'] = data.showVariant.toString();
    request.fields['show_action'] = data.showAction.toString();
    request.fields['default_expired_date'] = data.defaultExpireDate.toString();
    request.fields['default_mfg_date'] = data.defaultManufactureDate.toString();
    request.fields['expire_date_type'] = data.expireDateType.toString();
    request.fields['mfg_date_type'] = data.manufactureDateType.toString();
    request.fields['show_product_type_combo'] = data.showProductTypeCombo.toString();
    request.fields['show_warehouse'] = data.showWarehouse.toString();
    request.fields['show_rack'] = data.showRack.toString();
    request.fields['show_shelf'] = data.showShelf.toString();
    request.fields['show_guarantee'] = data.showGuaranty.toString();
    request.fields['show_warranty'] = data.showWarranty.toString();
    request.fields['show_serial'] = data.showSerial.toString();

    try {
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      EasyLoading.dismiss();

      print(response.statusCode);
      print(responseData.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        // Safely decode JSON to prevent crashes if server returns HTML
        try {
          var dataDecode = jsonDecode(responseData.body);
          String errorMessage = dataDecode['message'] ?? 'Failed to update';

          // Check for specific demo account restriction
          if (errorMessage.toLowerCase().contains('demo account')) {
            EasyLoading.showInfo(errorMessage, duration: const Duration(seconds: 4));
          } else {
            EasyLoading.showError(errorMessage);
          }
        } catch (e) {
          // Fallback if response body is not a valid JSON
          EasyLoading.showError('Failed to update. Status Code: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: ${e.toString()}');
      return false;
    }
  }

  // Fetch product settings
  Future<GetProductSettingModel> fetchProductSetting() async {
    CustomHttpClientGet clientGet = CustomHttpClientGet(client: http.Client());
    final url = Uri.parse('${APIConfig.url}/product-settings');

    try {
      var response = await clientGet.get(url: url);
      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return GetProductSettingModel.fromJson(jsonData);
      } else {
        String finalErrorMessage = 'Failed to fetch Setting';

        // Safely decode JSON to prevent crashes
        try {
          var dataDecode = jsonDecode(response.body);
          finalErrorMessage = dataDecode['message'] ?? finalErrorMessage;

          // Check for specific demo account restriction
          if (finalErrorMessage.toLowerCase().contains('demo account')) {
            EasyLoading.showInfo(finalErrorMessage, duration: const Duration(seconds: 4));
          } else {
            EasyLoading.showError(finalErrorMessage);
          }
        } catch (e) {
          // Fallback if response body is not a valid JSON
          EasyLoading.showError('Failed to fetch. Status Code: ${response.statusCode}');
        }

        throw Exception(finalErrorMessage);
      }
    } catch (e) {
      EasyLoading.dismiss();
      // Avoid showing duplicate error messages if already shown above
      if (!e.toString().contains('demo account')) {
        EasyLoading.showError('Error: ${e.toString()}');
      }
      throw Exception('Error: ${e.toString()}');
    }
  }
}
