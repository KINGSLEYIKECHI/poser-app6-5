class TransferDetailsModel {
  String? message;
  TransferData? data;

  TransferDetailsModel({this.message, this.data});

  TransferDetailsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? TransferData.fromJson(json['data']) : null;
  }
}

class TransferData {
  int? id;
  int? businessId;
  int? userId;
  int? fromBranchId;
  int? fromWarehouseId;
  int? toBranchId;
  int? toWarehouseId;
  String? transferDate;
  String? invoiceNo;
  String? note;
  num? shippingCharge;
  num? subTotal;
  num? totalDiscount;
  num? totalTax;
  num? grandTotal;
  String? status;
  TransferParty? fromBranch;
  TransferParty? toBranch;
  TransferWarehouse? fromWarehouse;
  TransferWarehouse? toWarehouse;
  List<TransferProduct>? transferProducts;

  TransferData({
    this.id,
    this.businessId,
    this.userId,
    this.fromBranchId,
    this.fromWarehouseId,
    this.toBranchId,
    this.toWarehouseId,
    this.transferDate,
    this.invoiceNo,
    this.note,
    this.shippingCharge,
    this.subTotal,
    this.totalDiscount,
    this.totalTax,
    this.grandTotal,
    this.status,
    this.fromBranch,
    this.toBranch,
    this.fromWarehouse,
    this.toWarehouse,
    this.transferProducts,
  });

  TransferData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessId = json['business_id'];
    userId = json['user_id'];
    fromBranchId = json['from_branch_id'];
    fromWarehouseId = json['from_warehouse_id'];
    toBranchId = json['to_branch_id'];
    toWarehouseId = json['to_warehouse_id'];
    transferDate = json['transfer_date'];
    invoiceNo = json['invoice_no'];
    note = json['note'];
    shippingCharge = json['shipping_charge'];
    subTotal = json['sub_total'];
    totalDiscount = json['total_discount'];
    totalTax = json['total_tax'];
    grandTotal = json['grand_total'];
    status = json['status'];
    fromBranch = json['from_branch'] != null ? TransferParty.fromJson(json['from_branch']) : null;
    toBranch = json['to_branch'] != null ? TransferParty.fromJson(json['to_branch']) : null;
    fromWarehouse = json['from_warehouse'] != null ? TransferWarehouse.fromJson(json['from_warehouse']) : null;
    toWarehouse = json['to_warehouse'] != null ? TransferWarehouse.fromJson(json['to_warehouse']) : null;
    if (json['transfer_products'] != null) {
      transferProducts = <TransferProduct>[];
      json['transfer_products'].forEach((v) {
        transferProducts!.add(TransferProduct.fromJson(v));
      });
    }
  }
}

class TransferParty {
  int? id;
  String? name;
  String? phone;
  String? address;

  TransferParty({this.id, this.name, this.phone, this.address});

  TransferParty.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
  }
}

class TransferWarehouse {
  int? id;
  String? name;
  String? phone;
  String? address;

  TransferWarehouse({this.id, this.name, this.phone, this.address});

  TransferWarehouse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
  }
}

class TransferProduct {
  int? id;
  int? transferId;
  int? stockId; // [CRITICAL] Added for Edit functionality
  int? productId;
  num? quantity;
  num? unitPrice;
  num? discount;
  num? tax;
  List<String>? serialNumbers; // [ADDED] For Serial Items
  ProductInfo? product;

  TransferProduct({
    this.id,
    this.transferId,
    this.stockId,
    this.productId,
    this.quantity,
    this.unitPrice,
    this.discount,
    this.tax,
    this.serialNumbers,
    this.product,
  });

  TransferProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transferId = json['transfer_id'];
    stockId = json['stock_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    discount = json['discount'];
    tax = json['tax'];

    // Parse Serial Numbers safely
    if (json['serial_numbers'] != null) {
      serialNumbers = List<String>.from(json['serial_numbers']);
    } else {
      serialNumbers = [];
    }

    product = json['product'] != null ? ProductInfo.fromJson(json['product']) : null;
  }
}

class ProductInfo {
  int? id;
  String? productName;

  ProductInfo({this.id, this.productName});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['productName'];
  }
}
