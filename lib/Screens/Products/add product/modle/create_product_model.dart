import 'dart:io';

// Enum for clearer logic in UI
enum ProductType { single, variant, combo }

// --- 1. Combo Product Model ---
class ComboProductModel {
  ComboProductModel({
    this.stockId,
    this.quantity,
    this.purchasePrice,
  });

  String? stockId;
  String? quantity;
  String? purchasePrice;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'stock_id': stockId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
    };
    return data;
  }
}

// --- 2. Stock Data Model (Existing) ---
class StockDataModel {
  StockDataModel({
    this.stockId,
    this.batchNo,
    this.warehouseId,
    this.productStock,
    this.exclusivePrice,
    this.inclusivePrice,
    this.profitPercent,
    this.productSalePrice,
    this.productWholeSalePrice,
    this.productDealerPrice,
    this.mfgDate,
    this.expireDate,
    this.serialNumbers,
    this.variantName,
    this.variationData,
    this.subStock,
  });

  String? stockId;
  String? batchNo;
  String? warehouseId;
  String? productStock;
  String? exclusivePrice;
  String? inclusivePrice;
  String? profitPercent;
  String? productSalePrice;
  String? productWholeSalePrice;
  String? productDealerPrice;
  String? mfgDate;
  String? expireDate;
  List<dynamic>? serialNumbers;
  bool? subStock;
  String? variantName;
  List<Map<String, dynamic>>? variationData;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'stock_id': stockId,
      'batch_no': batchNo,
      'warehouse_id': warehouseId,
      'productStock': productStock,
      'exclusive_price': exclusivePrice,
      'inclusive_price': inclusivePrice,
      'profit_percent': profitPercent == 'Infinity' ? '0' : profitPercent,
      'productSalePrice': productSalePrice,
      'productWholeSalePrice': productWholeSalePrice,
      'productDealerPrice': productDealerPrice,
      'mfg_date': mfgDate,
      'expire_date': expireDate,
      'serial_numbers': serialNumbers,
      'variant_name': variantName,
      'variation_data': variationData,
    };
    data.removeWhere((key, value) => value == null || value.toString().isEmpty || value == 'null');
    return data;
  }
}

// --- 3. Main Create Product Model ---
class CreateProductModel {
  CreateProductModel({
    this.productId,
    this.name,
    this.categoryId,
    this.brandId,
    this.productCode,
    this.modelId,
    this.rackId,
    this.shelfId,
    this.alertQty,
    this.unitId,
    this.vatId,
    this.hasSerial,
    this.vatType,
    this.vatAmount,
    this.image,
    this.productType,
    this.stocks,
    this.comboProducts,
    this.variationIds,
    this.warrantyDuration,
    this.warrantyPeriod,
    this.guaranteeDuration,
    this.guaranteePeriod,
    this.productManufacturer,
    this.productDiscount,
    this.comboProfitPercent,
    this.comboProductSalePrice,
  });

  String? productId;
  String? name;
  String? categoryId;
  String? brandId;
  String? productCode;
  String? modelId;
  String? rackId;
  String? shelfId;
  String? alertQty;
  String? hasSerial;
  String? unitId;
  String? vatId;
  String? vatType;
  String? vatAmount;
  File? image;
  String? productType;
  String? comboProfitPercent;
  String? comboProductSalePrice;

  // Lists
  List<StockDataModel>? stocks;
  List<ComboProductModel>? comboProducts;
  List<String?>? variationIds;

  String? productManufacturer;
  String? productDiscount;

  String? warrantyDuration;
  String? warrantyPeriod;
  String? guaranteeDuration;
  String? guaranteePeriod;
}
