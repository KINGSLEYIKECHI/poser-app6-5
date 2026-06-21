import 'package:mobile_pos/Screens/Due%20Calculation/Model/due_collection_model.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';
import 'package:mobile_pos/widgets/multipal%20payment%20mathods/model/payment_transaction_model.dart';

class TransactionModel {
  TransactionModel({
    this.message,
    this.totalAmount,
    this.moneyIn,
    this.moneyOut,
    this.data,
  });

  String? message;
  num? totalAmount;
  num? moneyIn;
  num? moneyOut;
  List<TransactionModelData>? data;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      message: json['message'],
      totalAmount: json['total_amount'],
      moneyIn: json['money_in'],
      moneyOut: json['money_out'],
      data: json['data'] != null
          ? List<TransactionModelData>.from(
              json['data'].map((v) => TransactionModelData.fromJson(v)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total_amount': totalAmount,
      'money_in': moneyIn,
      'money_out': moneyOut,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionModelData {
  TransactionModelData({
    this.id,
    this.platform,
    this.transactionType,
    this.type,
    this.amount,
    this.totalAmount,
    this.date,
    this.businessId,
    this.branchId,
    this.paymentTypeId,
    this.userId,
    this.fromBank,
    this.toBank,
    this.referenceId,
    this.invoiceNo,
    this.image,
    this.note,
    this.meta,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.party,
    this.paymentType,
    this.sale,
    this.purchase,
    this.dueCollect,
  });

  num? id;
  String? platform;
  String? transactionType;
  String? type;
  num? amount;
  num? totalAmount;
  String? date;
  num? businessId;
  num? branchId;
  num? paymentTypeId;
  num? userId;
  String? fromBank;
  int? toBank;
  num? referenceId;
  String? invoiceNo;
  String? image;
  String? note;
  Meta? meta;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  Party? party;
  PaymentsTransaction? paymentType;
  SalesTransactionModel? sale;
  PurchaseTransaction? purchase;
  DueCollection? dueCollect;

  factory TransactionModelData.fromJson(Map<String, dynamic> json) {
    final _partyKey = json['sale']?['party'] ?? json['purchase']?['party'] ?? json['due_collect']?['party'];

    return TransactionModelData(
      id: json['id'],
      platform: json['platform'],
      transactionType: json['transaction_type'],
      type: json['type'],
      amount: json['amount'],
      totalAmount: json['total_amount'],
      date: json['date'],
      businessId: json['business_id'],
      branchId: json['branch_id'],
      paymentTypeId: json['payment_type_id'],
      userId: json['user_id'],
      fromBank: json['from_bank']?.toString(),
      toBank: json['to_bank'],
      referenceId: json['reference_id'],
      invoiceNo: json['invoice_no'],
      image: json['image'],
      note: json['note'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      party: _partyKey != null ? Party.fromJson(_partyKey) : null,
      paymentType: json['payment_type'] != null ? PaymentsTransaction.fromJson(json['payment_type']) : null,
      sale: json['sale'] != null ? SalesTransactionModel.fromJson(json['sale']) : null,
      purchase: json['purchase'] != null ? PurchaseTransaction.fromJson(json['purchase']) : null,
      dueCollect: json['due_collect'] != null ? DueCollection.fromJson(json['due_collect']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'transaction_type': transactionType,
      'type': type,
      'amount': amount,
      'total_amount': totalAmount,
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
      'meta': meta?.toJson(),
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'payment_type': paymentType,
      'sale': sale,
      'purchase': purchase,
      'due_collect': dueCollect,
    };
  }
}
