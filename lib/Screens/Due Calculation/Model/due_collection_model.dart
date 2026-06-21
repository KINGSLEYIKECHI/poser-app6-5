import '../../../model/sale_transaction_model.dart';
import '../../../widgets/multipal payment mathods/model/payment_transaction_model.dart';
import '../../Customers/Model/parties_model.dart';

class DueCollection {
  DueCollection({
    this.id,
    this.businessId,
    this.partyId,
    this.userId,
    this.saleId,
    this.purchaseId,
    this.totalDue,
    this.dueAmountAfterPay,
    this.payDueAmount,
    this.paymentTypeId,
    this.paymentType,
    this.paymentDate,
    this.invoiceNumber,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.party,
    this.transactions,
    this.branch,
    this.sale,
    this.purchase,
  });

  DueCollection.fromJson(dynamic json) {
    sale = json['sale'] != null ? DueSale.fromJson(json['sale']) : null;
    id = json['id'];
    businessId = json['business_id'];
    partyId = json['party_id'];
    userId = json['user_id'];
    saleId = json['sale_id'];
    purchaseId = json['purchase_id'];
    totalDue = json['totalDue'];
    dueAmountAfterPay = json['dueAmountAfterPay'];
    payDueAmount = json['payDueAmount'];
    paymentTypeId = int.tryParse(json["payment_type_id"].toString());
    // paymentType = json['paymentType'];
    paymentDate = json['paymentDate'];
    purchase = json['purchase'] != null ? DuePurchase.fromJson(json['purchase']) : null;
    invoiceNumber = json['invoiceNumber'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    party = json['party'] != null ? Party.fromJson(json['party']) : null;
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    // NEW: Parsing the transactions list
    if (json['transactions'] != null) {
      transactions = [];
      json['transactions'].forEach((v) {
        transactions?.add(PaymentsTransaction.fromJson(v));
      });
    }
  }

  num? id;
  num? businessId;
  num? partyId;
  num? userId;
  num? saleId;
  num? purchaseId;
  num? totalDue;
  num? dueAmountAfterPay;
  num? payDueAmount;
  int? paymentTypeId;
  PaymentType? paymentType;
  String? invoiceNumber;
  String? paymentDate;
  String? createdAt;
  String? updatedAt;
  User? user;
  Party? party;
  DueSale? sale;
  DuePurchase? purchase;
  Branch? branch;
  List<PaymentsTransaction>? transactions; // NEW Variable

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['party_id'] = partyId;
    map['user_id'] = userId;
    map['sale_id'] = saleId;
    map['purchase_id'] = purchaseId;
    map['totalDue'] = totalDue;
    map['dueAmountAfterPay'] = dueAmountAfterPay;
    map['payDueAmount'] = payDueAmount;
    map['paymentType'] = paymentType;
    map['paymentDate'] = paymentDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (party != null) {
      map['party'] = party?.toJson();
    }
    map['branch'] = branch;
    return map;
  }

  DueCollection copyWith({
    num? id,
    num? businessId,
    num? partyId,
    num? userId,
    num? saleId,
    num? purchaseId,
    num? totalDue,
    num? dueAmountAfterPay,
    num? payDueAmount,
    int? paymentTypeId,
    PaymentType? paymentType,
    String? invoiceNumber,
    String? paymentDate,
    String? createdAt,
    String? updatedAt,
    User? user,
    Party? party,
    DueSale? sale,
    Branch? branch,
    List<PaymentsTransaction>? transactions,
    DuePurchase? purchase,
  }) {
    return DueCollection(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      saleId: saleId ?? this.saleId,
      purchaseId: purchaseId ?? this.purchaseId,
      totalDue: totalDue ?? this.totalDue,
      dueAmountAfterPay: dueAmountAfterPay ?? this.dueAmountAfterPay,
      payDueAmount: payDueAmount ?? this.payDueAmount,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      paymentType: paymentType ?? this.paymentType,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      party: party ?? this.party,
      sale: sale ?? this.sale,
      branch: branch ?? this.branch,
      transactions: transactions ?? this.transactions,
      purchase: purchase ?? this.purchase,
    );
  }
}

class PaymentType {
  int? id;
  String? name;

  PaymentType({required this.id, required this.name});

  // Factory constructor to create an instance from a Map
  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  // Method to convert an instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
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

class DueSale {
  num? id;
  String? invoiceNumber;

  DueSale({this.id, this.invoiceNumber});

  DueSale.fromJson(dynamic json) {
    id = json['id'];
    invoiceNumber = json['invoiceNumber'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['invoiceNumber'] = invoiceNumber;

    return map;
  }
}

class DuePurchase {
  num? id;
  String? invoiceNumber;

  DuePurchase({this.id, this.invoiceNumber});

  DuePurchase.fromJson(dynamic json) {
    id = json['id'];
    invoiceNumber = json['invoiceNumber'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['invoiceNumber'] = invoiceNumber;

    return map;
  }
}
