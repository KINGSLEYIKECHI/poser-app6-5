class ProductHistoryListModel {
  final int? totalPurchaseQuantity;
  final int? totalSaleQuantity;
  final List<ProductHistoryItemModel>? items;

  int get totalRemainingQuantity {
    return items?.fold<int>(0, (p, ev) => p + (ev.remainingQuantity ?? 0)) ?? 0;
  }

  num get totalSalePrice {
    return items?.fold<num>(0, (p, ev) => p + ((ev.salePrice ?? 0) * (ev.saleQuantity ?? 0))) ?? 0;
  }

  num get totalPurchasePrice {
    return items?.fold<num>(0, (p, ev) => p + ((ev.purchasePrice ?? 0) * (ev.purchaseQuantity ?? 0))) ?? 0;
  }

  ProductHistoryListModel({
    this.totalPurchaseQuantity,
    this.totalSaleQuantity,
    this.items,
  });

  factory ProductHistoryListModel.fromJson(Map<String, dynamic> json) {
    return ProductHistoryListModel(
      totalPurchaseQuantity: json['total_purchase_qty'],
      totalSaleQuantity: json['total_sale_qty'],
      items: json['data'] == null
          ? null
          : List<ProductHistoryItemModel>.from(json['data']!.map((x) => ProductHistoryItemModel.fromJson(x))),
    );
  }
}

class ProductHistoryItemModel {
  final int? id;
  final String? name;
  final num? salePrice;
  final num? purchasePrice;
  final int? purchaseQuantity;
  final int? saleQuantity;
  final int? remainingQuantity;

  ProductHistoryItemModel({
    this.id,
    this.name,
    this.salePrice,
    this.purchasePrice,
    this.purchaseQuantity,
    this.saleQuantity,
    this.remainingQuantity,
  });

  factory ProductHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final int _totalPurchaseQuantity = json["purchase_details"] == null
        ? 0
        : (json["purchase_details"] as List<dynamic>).fold<int>(0, (p, ev) => p + (ev["quantities"] as int? ?? 0));

    final int _totalSaleQuantity = json["sale_details"] == null
        ? 0
        : (json["sale_details"] as List<dynamic>).fold<int>(0, (p, ev) => p + (ev["quantities"] as int? ?? 0));

    final _remainingQuantity = switch (json["product_type"]?.trim().toLowerCase()) {
      "combo" => json["combo_products"] == null
          ? 0
          : (json["combo_products"] as List<dynamic>).fold<int>(0, (p, ev) {
              return p + (ev["stock"]?["productStock"] as int? ?? 0);
            }),
      _ => json["stocks"] == null ? null : (json["stocks"] as List<dynamic>).firstOrNull?["productStock"] as int? ?? 0,
    };

    final _salePrice = switch (json["product_type"]?.trim().toLowerCase()) {
      "combo" => json["productSalePrice"] ?? 0,
      _ =>
        json["stocks"] == null ? null : (json["stocks"] as List<dynamic>).firstOrNull?["productSalePrice"] as num? ?? 0,
    };

    final _purchasePrice = switch (json["product_type"]?.trim().toLowerCase()) {
      "combo" => json["combo_products"] == null
          ? 0
          : (json["combo_products"] as List<dynamic>).fold<num>(0, (p, ev) => p + (ev["purchase_price"] as num? ?? 0)),
      _ => json["stocks"] == null
          ? null
          : (json["stocks"] as List<dynamic>).firstOrNull?["productPurchasePrice"] as num? ?? 0,
    };

    return ProductHistoryItemModel(
      id: json['id'],
      name: json['productName'],
      salePrice: _salePrice,
      purchasePrice: _purchasePrice,
      purchaseQuantity: _totalPurchaseQuantity,
      saleQuantity: _totalSaleQuantity,
      remainingQuantity: _remainingQuantity,
    );
  }
}

class ProductHistoryDetailsModel {
  final int? totalQuantities;
  final num? totalSalePrice;
  final num? totalPurchasePrice;
  final String? productName;
  final List<ProductHistoryDetailsItem>? items;

  ProductHistoryDetailsModel({
    this.totalQuantities,
    this.totalSalePrice,
    this.totalPurchasePrice,
    this.productName,
    this.items,
  });

  factory ProductHistoryDetailsModel.fromJson(Map<String, dynamic> j) {
    final _json = j['data'];
    final _detailsKey = _json["sale_details"] ?? _json["purchase_details"];

    return ProductHistoryDetailsModel(
      totalQuantities: j['total_quantities'],
      totalSalePrice: j['total_sale_price'],
      totalPurchasePrice: j['total_purchase_price'],
      productName: _json?["productName"],
      items: _detailsKey == null
          ? null
          : List<ProductHistoryDetailsItem>.from(_detailsKey!.map((x) => ProductHistoryDetailsItem.fromJson(x))),
    );
  }
}

class ProductHistoryDetailsItem {
  final int? id;
  final String? invoiceNo;
  final String? type;
  final DateTime? transactionDate;
  final int? quantities;
  final num? salePrice;
  final num? purchasePrice;

  ProductHistoryDetailsItem({
    this.id,
    this.invoiceNo,
    this.type,
    this.transactionDate,
    this.quantities,
    this.salePrice,
    this.purchasePrice,
  });

  factory ProductHistoryDetailsItem.fromJson(Map<String, dynamic> json) {
    final _invoiceKey = json["sale"]?["invoiceNumber"] ?? json["purchase"]?["invoiceNumber"];
    final _transactionDate = json["sale"]?["saleDate"] ?? json["purchase"]?["purchaseDate"];

    return ProductHistoryDetailsItem(
      id: json['id'],
      invoiceNo: _invoiceKey,
      type: 'Purchase',
      transactionDate: _transactionDate != null ? DateTime.parse(_transactionDate) : null,
      quantities: json['quantities'],
      salePrice: json['price'],
      purchasePrice: json['productPurchasePrice'],
    );
  }
}
