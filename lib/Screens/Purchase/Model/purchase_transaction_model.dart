import '../../../model/tax_business_model.dart';
import '../../../widgets/multipal payment mathods/model/payment_transaction_model.dart';

class PurchaseTransaction {
  PurchaseTransaction({
    this.id,
    this.partyId,
    this.businessId,
    this.userId,
    this.discountAmount,
    this.discountPercent,
    this.discountType,
    this.shippingCharge,
    this.dueAmount,
    this.paidAmount,
    this.changeAmount,
    this.totalAmount,
    this.invoiceNumber,
    this.isPaid,
    this.paymentTypeId,
    this.paymentType,
    this.purchaseDate,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.party,
    this.details,
    this.purchaseReturns,
    this.transactions, // New Field
    this.vatAmount,
    this.vatId,
    this.vatPercent,
    this.vat,
    this.business,
    this.branch,
  });

  PurchaseTransaction.fromJson(dynamic json) {
    id = json['id'];
    partyId = json['party_id'];
    businessId = json['business_id'];
    userId = json['user_id'];
    discountAmount = json['discountAmount'];
    discountPercent = json['discount_percent'];
    shippingCharge = json['shipping_charge'];
    discountType = json['discount_type'];
    dueAmount = json['dueAmount'];
    changeAmount = json['change_amount'];
    vatAmount = json['vat_amount'];
    vatPercent = json['vat_percent'];
    vatId = json['vat_id'];
    paidAmount = json['paidAmount'];
    totalAmount = json['totalAmount'];
    invoiceNumber = json['invoiceNumber'];
    isPaid = json['isPaid'];
    paymentTypeId = int.tryParse(json["payment_type_id"].toString());
    business = json['business'] != null ? TaxBusiness.fromJson(json['business']) : null;

    vat = json['vat'] != null ? PurchaseVat.fromJson(json['vat']) : null;
    purchaseDate = json['purchaseDate'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    party = json['party'] != null ? Party.fromJson(json['party']) : null;

    if (json['details'] != null) {
      details = [];
      json['details'].forEach((v) {
        details?.add(PurchaseDetails.fromJson(v));
      });
    }

    if (json['purchase_returns'] != null) {
      purchaseReturns = [];
      json['purchase_returns'].forEach((v) {
        purchaseReturns?.add(PurchaseReturn.fromJson(v));
      });
    }

    // New List from JSON
    if (json['transactions'] != null) {
      transactions = [];
      json['transactions'].forEach((v) {
        transactions?.add(PaymentsTransaction.fromJson(v));
      });
    }
  }

  num? id;
  num? partyId;
  num? businessId;
  num? userId;
  num? discountAmount;
  num? discountPercent;
  num? shippingCharge;
  String? discountType;
  num? dueAmount;
  num? paidAmount;
  num? changeAmount;
  num? vatAmount;
  num? vatPercent;
  num? vatId;
  num? totalAmount;
  String? invoiceNumber;
  bool? isPaid;
  int? paymentTypeId;
  PaymentType? paymentType;
  Branch? branch;
  String? purchaseDate;
  String? createdAt;
  String? updatedAt;
  User? user;
  Party? party;
  List<PurchaseDetails>? details;
  TaxBusiness? business;
  List<PurchaseReturn>? purchaseReturns;
  List<PaymentsTransaction>? transactions; // Added
  PurchaseVat? vat;
}

class PurchaseDetails {
  PurchaseDetails({
    this.id,
    this.purchaseId,
    this.productId,
    this.productPurchasePrice,
    this.quantities,
    this.productWholeSalePrice,
    this.productSalePrice,
    this.productDealerPrice,
    this.productStock,
    this.profitPercent,
    this.mfgDate,
    this.expireDate,
    this.stockId,
    this.product,
    this.stock,
    this.serialNumbers,
    this.priceWithoutTax,
  });

  PurchaseDetails.fromJson(dynamic json) {
    id = json['id'];
    purchaseId = json['purchase_id'];
    productId = json['product_id'];
    productPurchasePrice = json['productPurchasePrice'];
    quantities = json['quantities'];
    productDealerPrice = json['productDealerPrice'];
    priceWithoutTax = json['price_without_tax'];
    productSalePrice = json['productSalePrice'];
    productStock = json['productStock'];
    profitPercent = json['profit_percent'];
    mfgDate = json['mfg_date'];
    expireDate = json['expire_date'];
    stockId = json['stock_id']; // Added
    productWholeSalePrice = json['productWholeSalePrice'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    stock = json['stock'] != null ? PurchaseStock.fromJson(json['stock']) : null;
    serialNumbers = json['serial_numbers'];
  }

  num? id;
  num? purchaseId;
  num? productId;
  num? productPurchasePrice;
  num? quantities;
  num? productDealerPrice;
  num? productSalePrice;
  num? productWholeSalePrice;
  num? productStock;
  num? profitPercent;

  num? stockId; // Added
  PurchaseStock? stock;
  String? mfgDate;
  String? expireDate;
  Product? product;
  num? priceWithoutTax;
  List<dynamic>? serialNumbers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['purchase_id'] = purchaseId;
    map['product_id'] = productId;
    map['productPurchasePrice'] = productPurchasePrice;
    map['quantities'] = quantities;
    map['stock_id'] = stockId;
    if (product != null) {
      map['product'] = product?.toJson();
    }
    return map;
  }
}

class Product {
  Product({
    this.id,
    this.productName,
    this.categoryId,
    this.category,
    this.productType,
    this.hasSerial,
    this.vatAmount,
    this.vatType,
    this.vat,
  });

  Product.fromJson(dynamic json) {
    id = json['id'];
    productName = json['productName'];
    productType = json['product_type'];
    categoryId = json['category_id'];
    vatAmount = json['vat_amount'];
    hasSerial = json['has_serial'];
    vatType = json['vat_type'];

    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    vat = json['vat'] != null ? PurchaseProductVat.fromJson(json['vat']) : null;
  }

  num? id;
  String? productName;
  String? productType;
  String? vatType;
  num? categoryId;
  num? vatAmount;
  num? hasSerial;

  Category? category;
  PurchaseProductVat? vat;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['productName'] = productName;
    map['category_id'] = categoryId;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    return map;
  }
}

class Category {
  Category({
    this.id,
    this.categoryName,
  });

  Category.fromJson(dynamic json) {
    id = json['id'];
    categoryName = json['categoryName'];
  }

  num? id;
  String? categoryName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['categoryName'] = categoryName;
    return map;
  }
}

class PurchaseStock {
  PurchaseStock({
    this.id,
    this.batchNo,
    this.variantName,
    this.warehouseId,
  });

  PurchaseStock.fromJson(dynamic json) {
    id = json['id'];
    batchNo = json['batch_no'];
    variantName = json['variant_name']; // Added
    warehouseId = json['warehouse_id']; // Added
  }

  num? id;
  String? batchNo;
  String? variantName; // Added
  num? warehouseId; // Added
}

class Party {
  Party({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.type,
    this.address,
  });

  Party.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    type = json['type']; // Added based on JSON
    address = json['address']; // Added based on JSON
  }

  num? id;
  String? name;
  String? email;
  String? address;
  String? phone;
  String? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['address'] = address;
    map['phone'] = phone;
    map['type'] = type;
    return map;
  }
}

class User {
  User({
    this.id,
    this.name,
    this.role,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    role = json['role'];
  }

  num? id;
  String? name;
  String? role;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['role'] = role;
    return map;
  }
}

class Branch {
  Branch({
    this.id,
    this.name,
    this.phone,
    this.address,
  });

  Branch.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
  }

  num? id;
  String? name;
  String? phone;
  String? address;
}

class PurchaseReturn {
  PurchaseReturn({
    this.id,
    this.businessId,
    this.purchaseId,
    this.invoiceNo,
    this.returnDate,
    this.createdAt,
    this.updatedAt,
    this.purchaseReturnDetails,
  });

  PurchaseReturn.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    purchaseId = json['purchase_id'];
    invoiceNo = json['invoice_no'];
    returnDate = json['return_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['details'] != null) {
      purchaseReturnDetails = [];
      json['details'].forEach((v) {
        purchaseReturnDetails?.add(PurchaseReturnDetails.fromJson(v));
      });
    }
  }

  num? id;
  num? businessId;
  num? purchaseId;
  String? invoiceNo;
  String? returnDate;
  String? createdAt;
  String? updatedAt;
  List<PurchaseReturnDetails>? purchaseReturnDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['purchase_id'] = purchaseId;
    map['invoice_no'] = invoiceNo;
    map['return_date'] = returnDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (purchaseReturnDetails != null) {
      map['details'] = purchaseReturnDetails?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PurchaseReturnDetails {
  PurchaseReturnDetails({
    this.id,
    this.businessId,
    this.purchaseReturnId,
    this.purchaseDetailId,
    this.returnAmount,
    this.returnQty,
  });

  PurchaseReturnDetails.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    purchaseReturnId = json['purchase_return_id'];
    purchaseDetailId = json['purchase_detail_id'];
    returnAmount = json['return_amount'];
    returnQty = json['return_qty'];
    serialNumbers = json['serial_numbers'];
  }

  num? id;
  num? businessId;
  num? purchaseReturnId;
  num? purchaseDetailId;
  num? returnAmount;
  num? returnQty;
  List<dynamic>? serialNumbers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['purchase_return_id'] = purchaseReturnId;
    map['purchase_detail_id'] = purchaseDetailId;
    map['return_amount'] = returnAmount;
    map['return_qty'] = returnQty;
    map['serial_numbers'] = serialNumbers;
    return map;
  }
}

class PurchaseVat {
  PurchaseVat({
    this.id,
    this.name,
    this.rate,
  });

  PurchaseVat.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  num? id;
  String? name;
  num? rate;
}

class PaymentType {
  PaymentType({
    this.id,
    this.name,
  });

  PaymentType.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  num? id;
  String? name;
}

class PurchaseProductVat {
  PurchaseProductVat({
    this.id,
    this.name,
    this.rate,
  });

  PurchaseProductVat.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  num? id;
  num? rate;
  String? name;
}
