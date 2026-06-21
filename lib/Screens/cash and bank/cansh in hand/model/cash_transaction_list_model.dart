// File: cash_transaction_model.dart

class CashTransactionModel {
  final String? message;
  final List<CashTransactionData>? data;
  final num? totalBalance;

  CashTransactionModel({this.message, this.data, this.totalBalance});

  factory CashTransactionModel.fromJson(Map<String, dynamic> json) {
    return CashTransactionModel(
      message: json['message'],
      data: (json['data'] as List<dynamic>?)?.map((e) => CashTransactionData.fromJson(e as Map<String, dynamic>)).toList(),
      totalBalance: json['total_balance'],
    );
  }
}

class CashTransactionData {
  final int? id;
  final String? platform;
  final String? transactionType;
  final String? type;
  final num? amount;
  final String? date;
  final num? fromBank;
  final num? toBank;
  final String? invoiceNo;
  final String? image;
  final String? note;
  final User? user;

  CashTransactionData({
    this.id,
    this.platform,
    this.transactionType,
    this.type,
    this.amount,
    this.date,
    this.fromBank,
    this.toBank,
    this.invoiceNo,
    this.image,
    this.note,
    this.user,
  });

  factory CashTransactionData.fromJson(Map<String, dynamic> json) {
    return CashTransactionData(
      id: json['id'],
      platform: json['platform'],
      transactionType: json['transaction_type'],
      type: json['type'],
      amount: json['amount'],
      date: json['date'],
      fromBank: json['from_bank'],
      toBank: json['to_bank'],
      invoiceNo: json['invoice_no'],
      image: json['image'],
      note: json['note'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int? id;
  final String? name;

  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
    );
  }
}
