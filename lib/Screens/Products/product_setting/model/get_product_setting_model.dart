class GetProductSettingModel {
  GetProductSettingModel({
    this.message,
    this.data,
  });

  GetProductSettingModel.fromJson(dynamic json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    // this.id,
    // this.businessId,
    this.modules,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(dynamic json) {
    // id = json['id'];
    // businessId = json['business_id'];
    modules = json['modules'] != null ? Modules.fromJson(json['modules']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  // num? id;
  // num? businessId;
  Modules? modules;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    // map['id'] = id;
    // map['business_id'] = businessId;
    if (modules != null) {
      map['modules'] = modules?.toJson();
    }
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class Modules {
  Modules({
    this.showProductName,
    this.variantName,
    this.showProductCode,
    this.showProductStock,
    this.showProductSalePrice,
    this.showProductDealerPrice,
    this.showProductWholesalePrice,
    this.showProductUnit,
    this.showProductBrand,
    this.showProductCategory,
    this.showProductManufacturer,
    this.showProductImage,
    this.showExpireDate,
    this.showAlertQty,
    this.showVatId,
    this.showVatType,
    this.showExclusivePrice,
    this.showInclusivePrice,
    this.showProfitPercent,
    this.showWarehouse,
    this.showBatchNo,
    this.showMfgDate,
    this.showModelNo,
    this.defaultSalePrice,
    this.defaultWholesalePrice,
    this.defaultDealerPrice,
    this.showProductTypeSingle,
    this.showProductTypeVariant,
    this.showAction,
    this.defaultExpiredDate,
    this.defaultMfgDate,
    this.expireDateType,
    this.mfgDateType,
    this.showProductBatchNo,
    this.showProductExpireDate,
    // --- NEW FIELDS ---
    this.showProductTypeCombo,
    this.showRack,
    this.showShelf,
    this.showGuaranty,
    this.showWarranty,
    this.showSerial,
    // ------------------
  });

  Modules.fromJson(dynamic json) {
    showProductName = json['show_product_name'];
    variantName = json['variant_name'];
    showProductCode = json['show_product_code'];
    showProductStock = json['show_product_stock'];
    showProductSalePrice = json['show_product_sale_price'];
    showProductDealerPrice = json['show_product_dealer_price'];
    showProductWholesalePrice = json['show_product_wholesale_price'];
    showProductUnit = json['show_product_unit'];
    showProductBrand = json['show_product_brand'];
    showProductCategory = json['show_product_category'];
    showProductManufacturer = json['show_product_manufacturer'];
    showProductImage = json['show_product_image'];
    showExpireDate = json['show_expire_date'];
    showAlertQty = json['show_alert_qty'];
    showVatId = json['show_vat_id'];
    showVatType = json['show_vat_type'];
    showWarehouse = json['show_warehouse'];
    showExclusivePrice = json['show_exclusive_price'];
    showInclusivePrice = json['show_inclusive_price'];
    showProfitPercent = json['show_profit_percent'];
    showBatchNo = json['show_batch_no'];
    showMfgDate = json['show_mfg_date'];
    showModelNo = json['show_model_no'];
    defaultSalePrice = json['default_sale_price'];
    defaultWholesalePrice = json['default_wholesale_price'];
    defaultDealerPrice = json['default_dealer_price'];
    showProductTypeSingle = json['show_product_type_single'];
    showProductTypeVariant = json['show_product_type_variant'];
    showAction = json['show_action'];
    defaultExpiredDate = json['default_expired_date'];
    defaultMfgDate = json['default_mfg_date'];
    expireDateType = json['expire_date_type'];
    mfgDateType = json['mfg_date_type'];
    showProductBatchNo = json['show_product_batch_no'];
    showProductExpireDate = json['show_product_expire_date'];
    // --- NEW FIELDS ---
    showProductTypeCombo = json['show_product_type_combo'] ?? '1';
    showRack = json['show_rack'] ?? '1';
    showShelf = json['show_shelf'] ?? '1';
    showGuaranty = json['show_guarantee'] ?? '1';
    showWarranty = json['show_warranty'] ?? '1';
    showSerial = json['show_serial'] ?? '1';
    // ------------------
  }
  String? showProductName;
  String? showProductCode;
  String? showProductStock;
  String? showProductSalePrice;
  String? showProductDealerPrice;
  String? showProductWholesalePrice;
  String? showProductUnit;
  String? showProductBrand;
  String? showProductCategory;
  String? showProductManufacturer;
  String? showProductImage;
  String? showExpireDate;
  String? showAlertQty;
  String? showVatId;
  String? showVatType;
  String? showExclusivePrice;
  String? showInclusivePrice;
  String? showProfitPercent;
  String? showBatchNo;
  String? variantName;
  String? showMfgDate;
  String? showModelNo;
  String? defaultSalePrice;
  String? defaultWholesalePrice;
  String? defaultDealerPrice;
  String? showProductTypeSingle;
  String? showProductTypeVariant;
  String? showAction;
  String? defaultExpiredDate;
  String? defaultMfgDate;
  String? expireDateType;
  String? mfgDateType;
  String? showProductBatchNo;
  String? showProductExpireDate;
  // --- NEW FIELDS ---
  String? showWarehouse;
  String? showProductTypeCombo;
  String? showRack;
  String? showShelf;
  String? showGuaranty;
  String? showWarranty;
  String? showSerial;

  // ------------------

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['show_product_name'] = showProductName;
    map['variant_name'] = variantName;
    map['show_product_code'] = showProductCode;
    map['show_product_stock'] = showProductStock;
    map['show_product_sale_price'] = showProductSalePrice;
    map['show_product_dealer_price'] = showProductDealerPrice;
    map['show_product_wholesale_price'] = showProductWholesalePrice;
    map['show_product_unit'] = showProductUnit;
    map['show_product_brand'] = showProductBrand;
    map['show_product_category'] = showProductCategory;
    map['show_product_manufacturer'] = showProductManufacturer;
    map['show_product_image'] = showProductImage;
    map['show_expire_date'] = showExpireDate;
    map['show_alert_qty'] = showAlertQty;
    map['show_vat_id'] = showVatId;
    map['show_warehouse'] = showWarehouse;
    map['show_vat_type'] = showVatType;
    map['show_exclusive_price'] = showExclusivePrice;
    map['show_inclusive_price'] = showInclusivePrice;
    map['show_profit_percent'] = showProfitPercent;
    map['show_batch_no'] = showBatchNo;
    map['show_mfg_date'] = showMfgDate;
    map['show_model_no'] = showModelNo;
    map['default_sale_price'] = defaultSalePrice;
    map['default_wholesale_price'] = defaultWholesalePrice;
    map['default_dealer_price'] = defaultDealerPrice;
    map['show_product_type_single'] = showProductTypeSingle;
    map['show_product_type_variant'] = showProductTypeVariant;
    map['show_action'] = showAction;
    map['default_expired_date'] = defaultExpiredDate;
    map['default_mfg_date'] = defaultMfgDate;
    map['expire_date_type'] = expireDateType;
    map['mfg_date_type'] = mfgDateType;
    map['show_product_batch_no'] = showProductBatchNo;
    map['show_product_expire_date'] = showProductExpireDate;
    // --- NEW FIELDS ---
    map['show_product_type_combo'] = showProductTypeCombo;
    map['show_rack'] = showRack;
    map['show_shelf'] = showShelf;
    map['show_guarantee'] = showGuaranty;
    map['show_warranty'] = showWarranty;
    map['show_serial'] = showSerial;
    // ------------------
    return map;
  }
}
