// purchase_return_model.dart

class TaxPurchaseReturnModel {
  final int id;
  final int businessId;
  final int? branchId;
  final int purchaseId;
  final String invoiceNo;
  final String returnDate;
  final String createdAt;
  final String updatedAt;
  final Purchase? purchase;
  final List<TaxPurchaseReturnDetail> details;
  final List<Transaction>? transactions; // Nullable because it's missing in the 2nd item

  TaxPurchaseReturnModel({
    required this.id,
    required this.businessId,
    this.branchId,
    required this.purchaseId,
    required this.invoiceNo,
    required this.returnDate,
    required this.createdAt,
    required this.updatedAt,
    this.purchase,
    required this.details,
    this.transactions,
  });

  factory TaxPurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    return TaxPurchaseReturnModel(
      id: json['id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      branchId: json['branch_id'],
      purchaseId: json['purchase_id'] ?? 0,
      invoiceNo: json['invoice_no'] ?? '',
      returnDate: json['return_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      purchase: json['purchase'] != null ? Purchase.fromJson(json['purchase']) : null,
      details: (json['details'] as List<dynamic>?)?.map((e) => TaxPurchaseReturnDetail.fromJson(e)).toList() ?? [],
      transactions: (json['transactions'] as List<dynamic>?)?.map((e) => Transaction.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'branch_id': branchId,
      'purchase_id': purchaseId,
      'invoice_no': invoiceNo,
      'return_date': returnDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'purchase': purchase?.toJson(),
      'details': details.map((e) => e.toJson()).toList(),
      'transactions': transactions?.map((e) => e.toJson()).toList(),
    };
  }
}

class Purchase {
  final int id;
  final int partyId;
  final bool isPaid;
  final double totalAmount;
  final double dueAmount;
  final double paidAmount;
  final String invoiceNumber;
  final Party? party;

  Purchase({
    required this.id,
    required this.partyId,
    required this.isPaid,
    required this.totalAmount,
    required this.dueAmount,
    required this.paidAmount,
    required this.invoiceNumber,
    this.party,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? 0,
      partyId: json['party_id'] ?? 0,
      isPaid: json['isPaid'] ?? false,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      dueAmount: (json['dueAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      invoiceNumber: json['invoiceNumber'] ?? '',
      party: json['party'] != null ? Party.fromJson(json['party']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'party_id': partyId,
      'isPaid': isPaid,
      'totalAmount': totalAmount,
      'dueAmount': dueAmount,
      'paidAmount': paidAmount,
      'invoiceNumber': invoiceNumber,
      'party': party?.toJson(),
    };
  }
}

class Party {
  final int id;
  final String name;
  final String? email;

  Party({
    required this.id,
    required this.name,
    this.email,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class TaxPurchaseReturnDetail {
  final int id;
  final int businessId;
  final int purchaseReturnId;
  final int purchaseDetailId;
  final double returnAmount;
  final int returnQty;
  final List<dynamic>? serialNumbers;
  final PurchaseDetail? purchaseDetail;

  TaxPurchaseReturnDetail({
    required this.id,
    required this.businessId,
    required this.purchaseReturnId,
    required this.purchaseDetailId,
    required this.returnAmount,
    required this.returnQty,
    this.serialNumbers,
    this.purchaseDetail,
  });

  factory TaxPurchaseReturnDetail.fromJson(Map<String, dynamic> json) {
    return TaxPurchaseReturnDetail(
      id: json['id'] ?? 0,
      businessId: json['business_id'] ?? 0,
      purchaseReturnId: json['purchase_return_id'] ?? 0,
      purchaseDetailId: json['purchase_detail_id'] ?? 0,
      returnAmount: (json['return_amount'] ?? 0).toDouble(),
      returnQty: json['return_qty'] ?? 0,
      serialNumbers: json['serial_numbers'],
      purchaseDetail: json['purchase_detail'] != null ? PurchaseDetail.fromJson(json['purchase_detail']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'purchase_return_id': purchaseReturnId,
      'purchase_detail_id': purchaseDetailId,
      'return_amount': returnAmount,
      'return_qty': returnQty,
      'serial_numbers': serialNumbers,
      'purchase_detail': purchaseDetail?.toJson(),
    };
  }
}

class PurchaseDetail {
  final int id;
  final int purchaseId;
  final int productId;
  final double priceWithoutTax;
  final double productDealerPrice;
  final double productPurchasePrice;
  final double productSalePrice;
  final double productWholeSalePrice;
  final int quantities;
  final String? mfgDate;
  final double profitPercent;
  final String? expireDate;
  final int stockId;
  final List<dynamic>? serialNumbers;
  final Product? product;
  final Stock? stock;

  PurchaseDetail({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.priceWithoutTax,
    required this.productDealerPrice,
    required this.productPurchasePrice,
    required this.productSalePrice,
    required this.productWholeSalePrice,
    required this.quantities,
    this.mfgDate,
    required this.profitPercent,
    this.expireDate,
    required this.stockId,
    this.serialNumbers,
    this.product,
    this.stock,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      id: json['id'] ?? 0,
      purchaseId: json['purchase_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      priceWithoutTax: (json['price_without_tax'] ?? 0).toDouble(),
      productDealerPrice: (json['productDealerPrice'] ?? 0).toDouble(),
      productPurchasePrice: (json['productPurchasePrice'] ?? 0).toDouble(),
      productSalePrice: (json['productSalePrice'] ?? 0).toDouble(),
      productWholeSalePrice: (json['productWholeSalePrice'] ?? 0).toDouble(),
      quantities: json['quantities'] ?? 0,
      mfgDate: json['mfg_date'],
      profitPercent: (json['profit_percent'] ?? 0).toDouble(),
      expireDate: json['expire_date'],
      stockId: json['stock_id'] ?? 0,
      serialNumbers: json['serial_numbers'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      stock: json['stock'] != null ? Stock.fromJson(json['stock']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'price_without_tax': priceWithoutTax,
      'productDealerPrice': productDealerPrice,
      'productPurchasePrice': productPurchasePrice,
      'productSalePrice': productSalePrice,
      'productWholeSalePrice': productWholeSalePrice,
      'quantities': quantities,
      'mfg_date': mfgDate,
      'profit_percent': profitPercent,
      'expire_date': expireDate,
      'stock_id': stockId,
      'serial_numbers': serialNumbers,
      'product': product?.toJson(),
      'stock': stock?.toJson(),
    };
  }
}

class Product {
  final int id;
  final String productName;
  final int hasSerial; // Kept as int based on JSON (0), can be converted to bool if needed

  Product({
    required this.id,
    required this.productName,
    required this.hasSerial,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      hasSerial: json['has_serial'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'has_serial': hasSerial,
    };
  }
}

class Stock {
  final int id;
  final String batchNo;

  Stock({
    required this.id,
    required this.batchNo,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] ?? 0,
      batchNo: json['batch_no'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_no': batchNo,
    };
  }
}

class Transaction {
  final int id;
  final String platform;
  final String transactionType;
  final String type;
  final double amount;
  final String date;
  final int businessId;
  final int? branchId;
  final int? paymentTypeId;
  final int userId;
  final String? fromBank;
  final String? toBank;
  final int referenceId;
  final String invoiceNo;
  final String? image;
  final String? note;
  final String? meta;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.platform,
    required this.transactionType,
    required this.type,
    required this.amount,
    required this.date,
    required this.businessId,
    this.branchId,
    this.paymentTypeId,
    required this.userId,
    this.fromBank,
    this.toBank,
    required this.referenceId,
    required this.invoiceNo,
    this.image,
    this.note,
    this.meta,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      platform: json['platform'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      businessId: json['business_id'] ?? 0,
      branchId: json['branch_id'],
      paymentTypeId: json['payment_type_id'],
      userId: json['user_id'] ?? 0,
      fromBank: json['from_bank'],
      toBank: json['to_bank'],
      referenceId: json['reference_id'] ?? 0,
      invoiceNo: json['invoice_no'] ?? '',
      image: json['image'],
      note: json['note'],
      meta: json['meta'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'transaction_type': transactionType,
      'type': type,
      'amount': amount,
      'date': date,
      'business_id': businessId,
      'branch_id': branchId,
      'payment_type_id': paymentTypeId,
      'user_id': userId,
      'from_bank': fromBank,
      'to_bank': toBank,
      'reference_id': referenceId,
      'invoice_no': invoiceNo,
      'image': image,
      'note': note,
      'meta': meta,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
