// --- Nested Helper Models ---

import 'package:mobile_pos/Screens/product%20racks/model/product_racks_model.dart';
import 'package:mobile_pos/Screens/shelfs/model/shelf_list_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/warehouse_list_model.dart';

class Vat {
  final int? id;
  final num? rate; // Changed to num

  Vat({
    this.id,
    this.rate,
  });

  factory Vat.fromJson(Map<String, dynamic> json) {
    return Vat(
      id: json['id'],
      rate: json['rate'],
    );
  }
}

class Unit {
  final int? id;
  final String? unitName;

  Unit({
    this.id,
    this.unitName,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      unitName: json['unitName'],
    );
  }
}

class Brand {
  final int? id;
  final String? brandName;

  Brand({
    this.id,
    this.brandName,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      brandName: json['brandName'],
    );
  }
}

class Category {
  final int? id;
  final String? categoryName;

  Category({
    this.id,
    this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json['categoryName'],
    );
  }
}

class ProductModel {
  final int? id;
  final String? name;

  ProductModel({
    this.id,
    this.name,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class WarrantyGuaranteeInfo {
  final String? warrantyDuration;
  final String? warrantyUnit;
  final String? guaranteeDuration;
  final String? guaranteeUnit;

  WarrantyGuaranteeInfo({
    this.warrantyDuration,
    this.warrantyUnit,
    this.guaranteeDuration,
    this.guaranteeUnit,
  });

  factory WarrantyGuaranteeInfo.fromJson(Map<String, dynamic> json) {
    return WarrantyGuaranteeInfo(
      warrantyDuration: json['warranty_duration'],
      warrantyUnit: json['warranty_unit'],
      guaranteeDuration: json['guarantee_duration'],
      guaranteeUnit: json['guarantee_unit'],
    );
  }
}

/// Represents a specific stock/batch of a product, potentially with variants.
class Stock {
  final int? id;
  final int? businessId;
  final int? branchId;
  final int? warehouseId;
  final int? productId;
  final String? batchNo;
  final num? productStock; // Changed to num
  final num? productPurchasePrice;
  final num? exclusivePrice;
  final num? profitPercent; // Changed to num
  final num? productSalePrice;
  final num? productWholeSalePrice;
  final num? productDealerPrice;
  final List<dynamic>? serialNumbers;
  // Variation data is an array of maps
  final List<Map<String, dynamic>>? variationData;
  final String? variantName;
  final String? mfgDate;
  final String? expireDate;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final Product? product;
  final WarehouseData? warehouse;
  final num? hasSerial;

  Stock({
    this.id,
    this.businessId,
    this.branchId,
    this.warehouseId,
    this.productId,
    this.batchNo,
    this.productStock,
    this.productPurchasePrice,
    this.profitPercent,
    this.productSalePrice,
    this.productWholeSalePrice,
    this.productDealerPrice,
    this.serialNumbers,
    this.variationData,
    this.variantName,
    this.mfgDate,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.product,
    this.warehouse,
    this.hasSerial,
    this.exclusivePrice,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      businessId: json['business_id'],
      branchId: json['branch_id'],
      warehouseId: json['warehouse_id'],
      productId: json['product_id'],
      batchNo: json['batch_no'],
      productStock: json['productStock'],
      exclusivePrice: json['exclusive_price'],
      productPurchasePrice: json['productPurchasePrice'],
      profitPercent: json['profit_percent'],
      productSalePrice: json['productSalePrice'],
      productWholeSalePrice: json['productWholeSalePrice'],
      productDealerPrice: json['productDealerPrice'],
      serialNumbers: json['serial_numbers'],
      variationData: (json['variation_data'] as List?)?.cast<Map<String, dynamic>>(),
      variantName: json['variant_name'],
      mfgDate: json['mfg_date'],
      expireDate: json['expire_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      warehouse: json['warehouse'] != null ? WarehouseData.fromJson(json['warehouse']) : null,
      hasSerial: json['has_serial'],
    );
  }
}

/// Represents a component product within a 'combo' product.
class ComboProductComponent {
  final int? id;
  final int? productId;
  final int? stockId;
  final num? purchasePrice;
  final num? quantity; // Changed to num
  final Stock? stock;

  ComboProductComponent({
    this.id,
    this.productId,
    this.stockId,
    this.purchasePrice,
    this.quantity,
    this.stock,
  });

  factory ComboProductComponent.fromJson(Map<String, dynamic> json) {
    return ComboProductComponent(
      id: json['id'],
      productId: json['product_id'],
      stockId: json['stock_id'],
      purchasePrice: json['purchase_price'],
      quantity: json['quantity'],
      stock: json['stock'] != null ? Stock.fromJson(json['stock']) : null,
    );
  }
}

// --- Main Product Model ---

/// Represents a single product entity.
class Product {
  final int? id;
  final String? productName;
  final int? businessId;
  final int? rackId;
  final int? shelfId;
  final int? unitId;
  final int? brandId;
  final int? categoryId;
  final String? productCode;
  final WarrantyGuaranteeInfo? warrantyGuaranteeInfo;
  // variation_ids is a List<String> or null
  final List<String>? variationIds;
  final String? productPicture;
  final String? productType;
  final num? productDealerPrice;
  final num? totalLossProfit;
  final num? productPurchasePrice;
  final num? totalSaleAmount;
  final num? productSalePrice;
  final num? saleCount;
  final num? purchaseCount;
  final num? productWholeSalePrice;
  final num? productStock; // Changed to num
  final String? expireDate;
  final num? alertQty; // Changed to num
  final num? profitPercent; // Changed to num
  final num? vatAmount;
  final String? vatType;
  final int? hasSerial;
  final String? size;
  final String? type;
  final String? color;
  final String? weight;
  final String? capacity;
  final String? productManufacturer;
  final dynamic meta; // Use 'dynamic' for unstructured JSON
  final String? createdAt;
  final String? updatedAt;
  final int? vatId;
  final int? modelId;
  final int? warehouseId;
  final num? stocksSumProductStock; // Changed to num

  // Relationships (Nested Objects/Lists)
  final Unit? unit;
  final Vat? vat;
  final Brand? brand;
  final Category? category;
  final ProductModel? productModel;
  final List<Stock>? stocks;
  final RackData? rack;
  final ShelfData? shelf;
  final List<ComboProductComponent>? comboProducts;

  Product({
    this.id,
    this.productName,
    this.businessId,
    this.rackId,
    this.shelfId,
    this.unitId,
    this.brandId,
    this.categoryId,
    this.productCode,
    this.totalLossProfit,
    this.warrantyGuaranteeInfo,
    this.variationIds,
    this.productPicture,
    this.productType,
    this.hasSerial,
    this.productDealerPrice,
    this.saleCount,
    this.purchaseCount,
    this.productPurchasePrice,
    this.productSalePrice,
    this.productWholeSalePrice,
    this.totalSaleAmount,
    this.productStock,
    this.expireDate,
    this.alertQty,
    this.profitPercent,
    this.vatAmount,
    this.vatType,
    this.size,
    this.type,
    this.color,
    this.weight,
    this.capacity,
    this.productManufacturer,
    this.meta,
    this.createdAt,
    this.updatedAt,
    this.vatId,
    this.modelId,
    this.warehouseId,
    this.stocksSumProductStock,
    this.unit,
    this.vat,
    this.brand,
    this.category,
    this.productModel,
    this.stocks,
    this.comboProducts,
    this.rack,
    this.shelf,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper function to safely map lists, returning null if the source is null
    List<T>? _mapList<T>(List? list, T Function(Map<String, dynamic>) fromJson) {
      return list?.map((i) => fromJson(i as Map<String, dynamic>)).toList();
    }

    return Product(
      id: json['id'],
      productName: json['productName'],
      businessId: json['business_id'],
      rackId: json['rack_id'],
      shelfId: json['shelf_id'],
      unitId: json['unit_id'],
      brandId: json['brand_id'],
      hasSerial: json['has_serial'],
      categoryId: json['category_id'],
      productCode: json['productCode'],
      warrantyGuaranteeInfo: json['warranty_guarantee_info'] != null
          ? WarrantyGuaranteeInfo.fromJson(json['warranty_guarantee_info'])
          : null,
      variationIds: (json['variation_ids'] as List?)?.cast<String>(),
      productPicture: json['productPicture'],
      totalLossProfit: json['total_profit_loss'],
      productType: json['product_type'],
      productDealerPrice: json['productDealerPrice'],
      totalSaleAmount: json['total_sale_amount'],
      saleCount: json['sale_details_sum_quantities'],
      purchaseCount: json['purchase_details_sum_quantities'],
      productPurchasePrice: json['productPurchasePrice'],
      productSalePrice: json['productSalePrice'],
      productWholeSalePrice: json['productWholeSalePrice'],
      productStock: json['productStock'],
      expireDate: json['expire_date'],
      alertQty: json['alert_qty'],
      profitPercent: json['profit_percent'],
      vatAmount: json['vat_amount'],
      vatType: json['vat_type'],
      size: json['size'],
      type: json['type'],
      color: json['color'],
      weight: json['weight'],
      capacity: json['capacity'],
      productManufacturer: json['productManufacturer'],
      meta: json['meta'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      vatId: json['vat_id'],
      modelId: json['model_id'],
      warehouseId: json['warehouse_id'],
      stocksSumProductStock: json['stocks_sum_product_stock'],

      // Nested Relationships
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      shelf: json['shelf'] != null ? ShelfData.fromJson(json['shelf']) : null,
      rack: json['rack'] != null ? RackData.fromJson(json['rack']) : null,
      vat: json['vat'] != null ? Vat.fromJson(json['vat']) : null,
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      productModel: json['product_model'] != null ? ProductModel.fromJson(json['product_model']) : null,

      // Lists of Nested Objects
      stocks: _mapList<Stock>(json['stocks'] as List?, Stock.fromJson),
      comboProducts: _mapList<ComboProductComponent>(
        json['combo_products'] as List?,
        ComboProductComponent.fromJson,
      ),
    );
  }
}
