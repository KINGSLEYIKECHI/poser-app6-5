import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/model/purchase_tax_return_model.dart';

///--------vat item data-------------
class PurchaseTaxResponse {
  bool? success;
  TaxPurchaseData? data;

  PurchaseTaxResponse({this.success, this.data});

  PurchaseTaxResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TaxPurchaseData.fromJson(json['data']) : null;
  }
}

class TaxPurchaseData {
  num? totalAmount;
  num? totalReturnedAmount;
  PurchaseTransaction? purchase;
  List<TaxListData>? taxItems;
  List<TaxPurchaseReturnModel>? purchaseReturn;

  TaxPurchaseData({
    this.totalAmount,
    this.totalReturnedAmount,
    this.purchase,
    this.taxItems,
    this.purchaseReturn,
  });

  TaxPurchaseData.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'];
    totalReturnedAmount = json['total_return_amount'];

    purchase = json['purchase'] != null ? PurchaseTransaction.fromJson(json['purchase']) : null;

    if (json['purchase_returns'] != null) {
      purchaseReturn = [];
      json['purchase_returns'].forEach((v) {
        purchaseReturn?.add(TaxPurchaseReturnModel.fromJson(v));
      });
    }

    if (json['tax_items'] != null) {
      taxItems = (json['tax_items'] as List).map((e) => TaxListData.fromJson(e)).toList();
    } else {
      taxItems = [];
    }
  }
}

class TaxListData {
  num? vatId;
  num? vatRate;
  num? vatAmount;
  VatData? vatData;

  TaxListData({
    this.vatId,
    this.vatRate,
    this.vatAmount,
    this.vatData,
  });

  TaxListData.fromJson(Map<String, dynamic> json) {
    vatId = json['vat_id'];
    vatRate = json['vat_rate'];
    vatAmount = json['vat_amount'];
    vatData = json['vat'] != null ? VatData.fromJson(json['vat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};

    map['vat_id'] = vatId;
    map['vat_rate'] = vatRate;
    map['vat_amount'] = vatAmount;

    if (vatData != null) {
      map['vat'] = vatData!.toJson();
    }

    return map;
  }
}

///------------vat data--------------
class VatData {
  num? id;
  String? vatName;

  VatData({
    this.id,
    this.vatName,
  });

  VatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vatName = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};

    map['id'] = id;
    map['name'] = vatName;

    return map;
  }
}
