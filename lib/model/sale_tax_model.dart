import '../Screens/Customers/Model/parties_model.dart';
import 'sale_transaction_model.dart';

///--------vat item data-------------
class TaxSaleResponse {
  bool? success;
  TaxSaleData? data;

  TaxSaleResponse({this.success, this.data});

  TaxSaleResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TaxSaleData.fromJson(json['data']) : null;
  }
}

class TaxSaleData {
  num? totalAmount;
  num? totalReturnedAmount;
  SalesTransactionModel? sale;
  List<TaxListData>? taxItems;
  List<TaxSaleReturn>? salesReturns; // Maps from JSON: sale_returns

  TaxSaleData({
    this.totalAmount,
    this.totalReturnedAmount,
    this.sale,
    this.taxItems,
    this.salesReturns,
  });

  TaxSaleData.fromJson(Map<String, dynamic> json) {
    totalAmount = json['total_amount'] ?? json['totalAmount'];
    totalReturnedAmount = json['total_return_amount'] ?? json['totalReturnedAmount'];

    sale = json['sale'] != null ? SalesTransactionModel.fromJson(json['sale']) : null;

    // FIXED: Handle snake_case 'sale_returns' from API
    if (json['sale_returns'] != null) {
      salesReturns = [];
      for (var v in json['sale_returns']) {
        salesReturns?.add(TaxSaleReturn.fromJson(v));
      }
    } else if (json['salesReturns'] != null) {
      // Fallback for camelCase
      salesReturns = [];
      for (var v in json['salesReturns']) {
        salesReturns?.add(TaxSaleReturn.fromJson(v));
      }
    }

    // Handle tax_items (snake_case from API)
    if (json['tax_items'] != null) {
      taxItems = (json['tax_items'] as List).map((e) => TaxListData.fromJson(e)).toList();
    } else if (json['taxItems'] != null) {
      taxItems = (json['taxItems'] as List).map((e) => TaxListData.fromJson(e)).toList();
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
    vatId = json['vat_id'] ?? json['vatId'];
    vatRate = (json['vat_rate'] ?? json['vatRate'])?.toDouble();
    vatAmount = (json['vat_amount'] ?? json['vatAmount'])?.toDouble();
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

class VatData {
  num? id;
  String? vatName;

  VatData({this.id, this.vatName});

  VatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vatName = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': vatName};
  }
}

///-------------------sale tax return model------------------
class TaxSaleReturn {
  final int? id;
  final int? businessId;
  final int? branchId;
  final int? saleId;
  final String? invoiceNo;
  final String? returnDate;
  final String? createdAt;
  final String? updatedAt;
  final TaxSale? sale;
  final List<SaleReturnDetail>? details; // JSON key: 'details'
  final List<dynamic>? transactions;

  TaxSaleReturn({
    this.id,
    this.businessId,
    this.branchId,
    this.saleId,
    this.invoiceNo,
    this.returnDate,
    this.createdAt,
    this.updatedAt,
    this.sale,
    this.details,
    this.transactions,
  });

  factory TaxSaleReturn.fromJson(Map<String, dynamic> json) {
    return TaxSaleReturn(
      id: json['id'],
      businessId: json['business_id'] ?? json['businessId'],
      branchId: json['branch_id'] ?? json['branchId'],
      saleId: json['sale_id'] ?? json['saleId'],
      invoiceNo: json['invoice_no'] ?? json['invoiceNo'],
      returnDate: json['return_date'] ?? json['returnDate'],
      createdAt: json['created_at'] ?? json['createdAt'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
      sale: json['sale'] != null ? TaxSale.fromJson(json['sale']) : null,
      // FIXED: JSON uses 'details' not 'salesReturnDetails'
      details: json['details'] != null
          ? (json['details'] as List).map((item) => SaleReturnDetail.fromJson(item)).toList()
          : [],
      transactions: json['transactions'],
    );
  }
}

class SaleReturnDetail {
  final int? id;
  final int? businessId;
  final int? saleReturnId;
  final int? saleDetailId; // JSON: sale_detail_id
  final num? returnAmount;
  final num? returnQty;
  final List<String>? serialNumbers;
  final SaleDetail? saleDetail; // JSON key: 'sale_detail'

  SaleReturnDetail({
    this.id,
    this.businessId,
    this.saleReturnId,
    this.saleDetailId,
    this.returnAmount,
    this.returnQty,
    this.serialNumbers,
    this.saleDetail,
  });

  factory SaleReturnDetail.fromJson(Map<String, dynamic> json) {
    return SaleReturnDetail(
      id: json['id'],
      businessId: json['business_id'] ?? json['businessId'],
      saleReturnId: json['sale_return_id'] ?? json['saleReturnId'],
      // FIXED: Map snake_case to camelCase
      saleDetailId: json['sale_detail_id'] ?? json['saleDetailId'],
      returnAmount: (json['return_amount'] ?? json['returnAmount'])?.toDouble(),
      returnQty: (json['return_qty'] ?? json['returnQty'])?.toDouble(),
      // serialNumbers: (json['serial_numbers'] as List?)?.toList(),
      serialNumbers: json['serial_numbers'] != null ? List<String>.from(json['serial_numbers']) : null,
      // FIXED: Map 'sale_detail' to saleDetail
      saleDetail: json['sale_detail'] != null ? SaleDetail.fromJson(json['sale_detail']) : null,
    );
  }
}

class SaleDetail {
  final int? id;
  final num? price;
  final num? priceWithoutTax;
  final num? discount;
  final num? quantities;
  final int? productId;
  final int? saleId;
  final int? stockId;
  // final String? warrantyGuaranteeInfo;
  final List<String>? serialNumbers;
  final StockData? stock; // JSON: stock
  final ProductData? product; // JSON: product

  SaleDetail({
    this.id,
    this.price,
    this.priceWithoutTax,
    this.discount,
    this.quantities,
    this.productId,
    this.saleId,
    this.stockId,
    // this.warrantyGuaranteeInfo,
    this.serialNumbers,
    this.stock,
    this.product,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      id: json['id'],
      price: json['price']?.toDouble(),
      priceWithoutTax: (json['price_without_tax'] ?? json['priceWithoutTax'])?.toDouble(),
      discount: json['discount']?.toDouble(),
      quantities: json['quantities']?.toDouble(),
      productId: json['product_id'] ?? json['productId'],
      saleId: json['sale_id'] ?? json['saleId'],
      stockId: json['stock_id'] ?? json['stockId'],
      // warrantyGuaranteeInfo: json['warranty_guarantee_info'] ?? json['warrantyGuaranteeInfo'],
      // serialNumbers: (json['serial_numbers'] as List?)?.toList(),
      serialNumbers: json['serial_numbers'] != null ? List<String>.from(json['serial_numbers']) : null,
      // FIXED: Ensure stock is properly mapped
      stock: json['stock'] != null ? StockData.fromJson(json['stock']) : null,
      product: json['product'] != null ? ProductData.fromJson(json['product']) : null,
    );
  }
}

class StockData {
  final int? id;
  final String? batchNo; // JSON: batch_no

  StockData({this.id, this.batchNo});

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      id: json['id'],
      // FIXED: Map batch_no to batchNo
      batchNo: json['batch_no'] ?? json['batchNo'],
    );
  }
}

class ProductData {
  final int? id;
  final String? productName;
  final int? vatId;
  final int? hasSerial;

  ProductData({this.id, this.productName, this.vatId, this.hasSerial});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'],
      productName: json['productName'] ?? json['product_name'],
      vatId: json['vat_id'] ?? json['vatId'],
      hasSerial: json['has_serial'] ?? json['hasSerial'],
    );
  }
}

class TaxSale {
  final int id;
  final int partyId;
  final bool isPaid;
  final double totalAmount;
  final double dueAmount;
  final double paidAmount;
  final String invoiceNumber;
  final Party? party;

  TaxSale({
    required this.id,
    required this.partyId,
    required this.isPaid,
    required this.totalAmount,
    required this.dueAmount,
    required this.paidAmount,
    required this.invoiceNumber,
    this.party,
  });

  factory TaxSale.fromJson(Map<String, dynamic> json) {
    return TaxSale(
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
