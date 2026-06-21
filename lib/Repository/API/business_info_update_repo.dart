import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/Const/api_config.dart';
import '../../http_client/custome_http_client.dart';
import '../../widgets/printer_profile/printer_profile.dart';
import '../constant_functions.dart';

class BusinessUpdateRepository {
  Future<bool> updateProfile({
    required String id,
    String? name,
    required String categoryId,
    required BuildContext context,
    required WidgetRef ref,
    String? phone,
    String? address,
    String? email,
    String? vatNumber,
    String? vatTitle,
    String? invoiceNoteLevel,
    String? invoiceNote,
    String? gratitudeMessage,
    String? warrantyLabelVoid,
    String? warrantyVoid,
    String? saleRoundingOption,
    String? invoiceSize,
    PrinterProfile? profilePrinter,
    String? invoiceLanguage,
    Map<String, int>? invoiceVisibilityMeta,
    File? image,
    File? invoiceLogo,
    File? a4InvoiceLogo,
    File? thermalInvoiceLogo,
    File? invoiceScannerLogo,
    String? countryId,
    String? stateId,
    int? allowProductDiscount,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/business/$id');

    final customHttpClient = CustomHttpClient(
      client: http.Client(),
      context: context,
      ref: ref,
    );

    /// ---------- BASE FIELDS ----------
    final fields = <String, String>{
      '_method': 'PUT',
      'business_category_id': categoryId,
      'companyName': name ?? '',
      'phoneNumber': phone ?? '',
      'address': address ?? '',
      'email': email ?? '',
      'vat_no': vatNumber ?? '',
      'vat_name': vatTitle ?? '',
      'note_label': invoiceNoteLevel ?? '',
      'note': invoiceNote ?? '',
      'warranty_void_label': warrantyLabelVoid ?? '',
      'warranty_void': warrantyVoid ?? '',
      'gratitude_message': gratitudeMessage ?? '',
      'sale_rounding_option': saleRoundingOption ?? 'none',
      'invoice_size': invoiceSize ?? '2_inch_58mm',
      'profile_printer': profilePrinter?.name ?? 'default', // ✅ FIXED
      'invoice_language': invoiceLanguage ?? 'english',
    };

    /// ---------- META FIELDS (numeric 0/1) ----------
    fields['show_company_name'] = (invoiceVisibilityMeta?['show_company_name'] ?? 1).toString();
    fields['show_phone_number'] = (invoiceVisibilityMeta?['show_phone_number'] ?? 1).toString();
    fields['show_address'] = (invoiceVisibilityMeta?['show_address'] ?? 1).toString();
    fields['show_email'] = (invoiceVisibilityMeta?['show_email'] ?? 1).toString();
    fields['show_vat'] = (invoiceVisibilityMeta?['show_vat'] ?? 1).toString();

    /// ---------- ROOT FIELDS (numeric 0/1) ----------
    fields['show_note'] = (invoiceVisibilityMeta?['show_note'] ?? 1).toString();
    fields['show_gratitude_msg'] = (invoiceVisibilityMeta?['show_gratitude_msg'] ?? 1).toString();
    fields['show_invoice_scanner_logo'] = (invoiceVisibilityMeta?['show_invoice_scanner_logo'] ?? 1).toString();
    fields['show_a4_invoice_logo'] = (invoiceVisibilityMeta?['show_a4_invoice_logo'] ?? 1).toString();
    fields['show_thermal_invoice_logo'] = (invoiceVisibilityMeta?['show_thermal_invoice_logo'] ?? 1).toString();
    fields['show_warranty'] = (invoiceVisibilityMeta?['show_warranty'] ?? 1).toString();
    fields['allow_product_discount'] = (allowProductDiscount ?? 1).toString();

    if (countryId != null) fields['country_id'] = countryId;
    if (stateId != null) fields['state_id'] = stateId;

    /// ---------- FILES ----------
    final files = <String, File>{};
    if (image != null) files['pictureUrl'] = image;
    if (invoiceLogo != null) files['invoice_logo'] = invoiceLogo;
    if (a4InvoiceLogo != null) files['a4_invoice_logo'] = a4InvoiceLogo;
    if (thermalInvoiceLogo != null) files['thermal_invoice_logo'] = thermalInvoiceLogo;
    if (invoiceScannerLogo != null) files['invoice_scanner_logo'] = invoiceScannerLogo;

    try {
      final response = await customHttpClient.uploadMultipleFiles(
        url: uri,
        fields: fields,
        files: files,
      );

      final body = await response.stream.bytesToString();
      final decoded = json.decode(body);

      if (response.statusCode == 200) {
        EasyLoading.showSuccess(decoded['message'] ?? 'Updated successfully');
        return true;
      } else {
        EasyLoading.showError(decoded['message'] ?? 'Update failed. Status: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Error updating profile: $e');
      print('Stack trace: $stackTrace');
      EasyLoading.showError('Update failed: $e');
      return false;
    }
  }

  Future<bool> updateSalesSettings({
    required String id,
    required BuildContext context,
    required WidgetRef ref,
    String? saleRoundingOption,
    int? allowGuestDueSale,
  }) async {
    final uri = Uri.parse('${APIConfig.url}/business/$id');
    CustomHttpClient customHttpClient = CustomHttpClient(client: http.Client(), context: context, ref: ref);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = await getAuthToken();

    request.fields['_method'] = 'put';
    if (saleRoundingOption != null) request.fields['sale_rounding_option'] = saleRoundingOption;
    if (allowGuestDueSale != null) request.fields['allow_due_sale'] = allowGuestDueSale.toString();
    final response = await customHttpClient.uploadFile(
      url: uri,
      fields: request.fields,
    );
    var da = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      EasyLoading.showSuccess(json.decode(da)['message']);
      return true; // Update successful
    } else {
      EasyLoading.showError(json.decode(da)['message']);
      return false;
    }
  }
}
