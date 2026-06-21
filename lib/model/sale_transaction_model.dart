import 'package:mobile_pos/model/tax_business_model.dart';

import '../widgets/multipal payment mathods/model/payment_transaction_model.dart';

class SaleModel {
  SaleModel(this.message, this.totalAmount, this.totalReturnedAmount);
  SaleModel.fromJson(dynamic json) {
    message = json['message'];
    totalAmount = json['total_amount'];
    totalReturnedAmount = json['total_return_amount'];
    data = json['data'] != null ? SalesTransactionModel.fromJson(json['data']) : null;
  }

  String? message;
  num? totalAmount;
  num? totalReturnedAmount;
  SalesTransactionModel? data;
}

class SalesTransactionModel {
  SalesTransactionModel({
    this.id,
    this.businessId,
    this.partyId,
    this.userId,
    this.discountAmount,
    this.discountPercent,
    this.shippingCharge,
    this.dueAmount,
    this.isPaid,
    this.vatAmount,
    this.vatPercent,
    this.paidAmount,
    this.changeAmount,
    this.totalAmount,
    this.paymentTypeId,
    this.paymentType,
    this.discountType,
    this.invoiceNumber,
    this.saleDate,
    this.createdAt,
    this.updatedAt,
    this.detailsSumLossProfit,
    this.user,
    this.party,
    this.salesDetails,
    this.salesReturns,
    this.transactions, // NEW: List of transactions
    this.meta,
    this.vatId,
    this.vat,
    this.image,
    this.roundingAmount,
    this.actualTotalAmount,
    this.roundingOption,
    this.branch,
    this.business,
  });

  SalesTransactionModel.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    partyId = num.tryParse(json['party_id'].toString()) ?? 0;
    userId = json['user_id'];
    discountAmount = json['discountAmount'];
    discountPercent = num.tryParse(json['discount_percent'].toString()) ?? 0;
    shippingCharge = num.tryParse(json['shipping_charge'].toString()) ?? 0;
    dueAmount = json['dueAmount'];
    isPaid = json['isPaid'];
    vatAmount = json['vat_amount'];
    vatPercent = json['vat_percent'];
    vatId = json['vat_id'];
    paidAmount = json['paidAmount'];
    changeAmount = json['change_amount'];
    totalAmount = json['totalAmount'];
    paymentTypeId = int.tryParse(json['payment_type_id'].toString()) ?? 0;
    discountType = json['discount_type'];
    invoiceNumber = json['invoiceNumber'];
    saleDate = json['saleDate'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    roundingOption = json['rounding_option'].toString();
    roundingAmount = num.tryParse(json['rounding_amount'].toString()) ?? 0;
    actualTotalAmount = num.tryParse(json['actual_total_amount'].toString()) ?? 0;
    detailsSumLossProfit = json['lossProfit'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    business = json['business'] != null ? TaxBusiness.fromJson(json['business']) : null;
    vat = json['vat'] != null ? SalesVat.fromJson(json['vat']) : null;
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    party = json['party'] != null ? SalesParty.fromJson(json['party']) : SalesParty(name: 'Guest', type: 'Guest');

    if (json['details'] != null) {
      salesDetails = [];
      json['details'].forEach((v) {
        salesDetails?.add(SalesDetails.fromJson(v));
      });
    }
    if (json['sale_returns'] != null) {
      salesReturns = [];
      json['sale_returns'].forEach((v) {
        salesReturns?.add(SalesReturn.fromJson(v));
      });
    }

    // NEW: Parsing the transactions list
    if (json['transactions'] != null) {
      transactions = [];
      json['transactions'].forEach((v) {
        transactions?.add(PaymentsTransaction.fromJson(v));
      });
    }

    image = json['image'];
  }

  num? id;
  num? businessId;
  num? partyId;
  num? userId;
  num? discountAmount;
  num? discountPercent;
  num? shippingCharge;
  num? dueAmount;
  bool? isPaid;
  num? vatAmount;
  num? vatPercent;
  num? vatId;
  num? paidAmount;
  num? changeAmount;
  num? totalAmount;
  num? roundingAmount;
  num? actualTotalAmount;
  String? roundingOption;
  PaymentType? paymentType;
  Branch? branch;
  int? paymentTypeId;
  String? discountType;
  String? invoiceNumber;
  String? saleDate;
  String? createdAt;
  String? updatedAt;
  num? detailsSumLossProfit;
  User? user;
  SalesParty? party;
  Meta? meta;
  SalesVat? vat;
  TaxBusiness? business;
  List<SalesDetails>? salesDetails;
  List<SalesReturn>? salesReturns;
  List<PaymentsTransaction>? transactions; // NEW Variable

  String? image;
}

class SalesDetails {
  SalesDetails({
    this.id,
    this.saleId,
    this.productId,
    this.price,
    this.discount, // NEW
    this.lossProfit,
    this.quantities,
    this.productPurchasePrice,
    this.mfgDate,
    this.expireDate,
    this.stockId,
    this.serialNumbers,
    this.stock,
    this.warrantyInfo, // NEW
    this.createdAt,
    this.updatedAt,
    this.product,
    this.priceWithoutTax,
  });

  SalesDetails.fromJson(dynamic json) {
    id = json['id'];
    saleId = json['sale_id'];
    productId = json['product_id'];
    price = json['price'];
    priceWithoutTax = json['price_without_tax'];
    discount = json['discount']; // NEW
    lossProfit = json['lossProfit'];
    quantities = json['quantities'];
    productPurchasePrice = json['productPurchasePrice'];
    mfgDate = json['mfg_date'];
    expireDate = json['expire_date'];
    stockId = json['stock_id'];
    serialNumbers = json['serial_numbers'];
    // NEW: Warranty Info parsing
    warrantyInfo = json['warranty_guarantee_info'] != null
        ? WarrantyGuaranteeInfo.fromJson(json['warranty_guarantee_info'])
        : null;

    stock = json['stock'] != null ? SalesStock.fromJson(json['stock']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['product'] != null ? SalesProduct.fromJson(json['product']) : null;
  }

  num? id;
  num? saleId;
  num? productId;
  num? price;
  num? discount; // NEW Variable
  num? lossProfit;
  num? quantities;
  num? productPurchasePrice;
  String? mfgDate;
  String? expireDate;
  num? stockId;
  List<dynamic>? serialNumbers;
  SalesStock? stock;
  WarrantyGuaranteeInfo? warrantyInfo; // NEW Variable
  String? createdAt;
  num? priceWithoutTax;
  String? updatedAt;
  SalesProduct? product;
}

// NEW CLASS: Handles Warranty and Guarantee details
class WarrantyGuaranteeInfo {
  String? warrantyDuration;
  String? warrantyUnit;
  String? guaranteeDuration;
  String? guaranteeUnit;

  WarrantyGuaranteeInfo({
    this.warrantyDuration,
    this.warrantyUnit,
    this.guaranteeDuration,
    this.guaranteeUnit,
  });

  WarrantyGuaranteeInfo.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return;
    }

    warrantyDuration = json['warranty_duration']?.toString();
    warrantyUnit = json['warranty_unit']?.toString();
    guaranteeDuration = json['guarantee_duration']?.toString();
    guaranteeUnit = json['guarantee_unit']?.toString();
  }
}

class SalesProduct {
  SalesProduct({
    this.id,
    this.productName,
    this.categoryId,
    this.category,
    this.productPurchasePrice,
    this.productCode,
    this.productType,
    this.hasSerial,
  });

  SalesProduct.fromJson(dynamic json) {
    id = json['id'];
    productName = json['productName'];
    productCode = json['productCode'];
    categoryId = json['category_id'];
    productType = json['product_type'];
    productPurchasePrice = json['productPurchasePrice'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    hasSerial = json['has_serial'];
  }

  num? id;
  String? productName;
  String? productCode;
  num? categoryId;
  num? productPurchasePrice;
  String? productType;
  Category? category;
  num? hasSerial;

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

class SalesParty {
  SalesParty({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.type,
    this.address,
  });

  SalesParty.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    type = json['type'];
    address = json['address'];
  }

  num? id;
  String? name;
  dynamic email;
  String? phone;
  String? type;
  String? address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['type'] = type;
    map['address'] = address;
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

class Meta {
  Meta({
    this.customerPhone,
    this.note,
  });

  Meta.fromJson(dynamic json) {
    customerPhone = json['customer_phone'];
    note = json['note'];
  }

  String? customerPhone;
  String? note;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customer_phone'] = customerPhone;
    map['note'] = note;
    return map;
  }
}

class SalesReturn {
  SalesReturn({
    this.id,
    this.businessId,
    this.saleId,
    this.invoiceNo,
    this.returnDate,
    this.createdAt,
    this.updatedAt,
    this.salesReturnDetails,
  });

  SalesReturn.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    saleId = json['sale_id'];
    invoiceNo = json['invoice_no'];
    returnDate = json['return_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['details'] != null) {
      salesReturnDetails = [];
      json['details'].forEach((v) {
        salesReturnDetails?.add(SalesReturnDetails.fromJson(v));
      });
    }
  }

  num? id;
  num? businessId;
  num? saleId;
  String? invoiceNo;
  String? returnDate;
  String? createdAt;
  String? updatedAt;
  List<SalesReturnDetails>? salesReturnDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['sale_id'] = saleId;
    map['invoice_no'] = invoiceNo;
    map['return_date'] = returnDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (salesReturnDetails != null) {
      map['details'] = salesReturnDetails?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SalesReturnDetails {
  SalesReturnDetails({
    this.id,
    this.businessId,
    this.saleReturnId,
    this.saleDetailId,
    this.returnAmount,
    this.returnQty,
    this.serialNumbers,
    this.saleDetail,
  });

  SalesReturnDetails.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    saleReturnId = json['sale_return_id'];
    saleDetailId = json['sale_detail_id'];
    returnAmount = json['return_amount'];
    returnQty = json['return_qty'];
    saleDetail = json['sale_detail'] != null ? SaleReturnItemDetail.fromJson(json['sale_detail']) : null;
    serialNumbers = json['serial_numbers'];
  }

  num? id;
  num? businessId;
  num? saleReturnId;
  num? saleDetailId;
  num? returnAmount;
  num? returnQty;
  List<dynamic>? serialNumbers;
  SaleReturnItemDetail? saleDetail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['sale_return_id'] = saleReturnId;
    map['sale_detail_id'] = saleDetailId;
    map['return_amount'] = returnAmount;
    map['return_qty'] = returnQty;
    map['serial_numbers'] = serialNumbers;
    return map;
  }
}

///------------return details sale details-----------------
class SaleReturnItemDetail {
  int? id;
  int? saleId;
  int? productId;
  num? priceWithoutTax;
  num? price;
  num? discount;
  num? lossProfit;
  num? quantities;
  WarrantyGuaranteeInfo? warrantyGuaranteeInfo;
  num? productPurchasePrice;
  String? mfgDate;
  String? expireDate;
  int? stockId;
  dynamic serialNumbers;
  ReturnProduct? product;

  SaleReturnItemDetail({
    this.id,
    this.saleId,
    this.productId,
    this.priceWithoutTax,
    this.price,
    this.discount,
    this.lossProfit,
    this.quantities,
    this.warrantyGuaranteeInfo,
    this.productPurchasePrice,
    this.mfgDate,
    this.expireDate,
    this.stockId,
    this.serialNumbers,
    this.product,
  });

  SaleReturnItemDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    saleId = json['sale_id'];
    productId = json['product_id'];
    priceWithoutTax = json['price_without_tax'];
    price = json['price'];
    discount = json['discount'];
    lossProfit = json['lossProfit'];
    quantities = json['quantities'];
    warrantyGuaranteeInfo = json['warranty_guarantee_info'] != null
        ? WarrantyGuaranteeInfo.fromJson(json['warranty_guarantee_info'])
        : null;
    productPurchasePrice = json['productPurchasePrice'];
    mfgDate = json['mfg_date'];
    expireDate = json['expire_date'];
    stockId = json['stock_id'];
    serialNumbers = json['serial_numbers'];
    product = json['product'] != null ? ReturnProduct.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['id'] = id;
    map['sale_id'] = saleId;
    map['product_id'] = productId;
    map['price_without_tax'] = priceWithoutTax;
    map['price'] = price;
    map['discount'] = discount;
    map['lossProfit'] = lossProfit;
    map['quantities'] = quantities;
    map['productPurchasePrice'] = productPurchasePrice;
    map['mfg_date'] = mfgDate;
    map['expire_date'] = expireDate;
    map['stock_id'] = stockId;
    map['serial_numbers'] = serialNumbers;

    if (product != null) {
      map['product'] = product!.toJson();
    }

    return map;
  }
}

class ReturnProduct {
  int? id;
  String? productName;
  int? hasSerial;

  ReturnProduct({
    this.id,
    this.productName,
    this.hasSerial,
  });

  ReturnProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['productName'];
    hasSerial = json['has_serial'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['id'] = id;
    map['productName'] = productName;
    map['has_serial'] = hasSerial;
    return map;
  }
}

///------------return details sale details-----------------

class SalesVat {
  SalesVat({
    this.id,
    this.name,
    this.rate,
  });

  SalesVat.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  num? id;
  String? name;
  num? rate;
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

class SalesStock {
  SalesStock({
    this.id,
    this.batchNo,
    this.productCurrentStock,
  });

  SalesStock.fromJson(dynamic json) {
    id = json['id'];
    batchNo = json['batch_no'] ?? 'N/A';
    productCurrentStock = json['productStock'];
  }

  num? id;
  String? batchNo;
  num? productCurrentStock;
}
