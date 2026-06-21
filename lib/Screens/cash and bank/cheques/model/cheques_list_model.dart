import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20account/model/bank_account_list_model.dart';

import '../../../../model/business_info_model.dart';

class ChequeTransactionModel {
  final String? message;
  final List<ChequeTransactionData>? data;

  ChequeTransactionModel({this.message, this.data});

  factory ChequeTransactionModel.fromJson(Map<String, dynamic> json) {
    return ChequeTransactionModel(
      message: json['message'],
      data: (json['data'] as List<dynamic>?)?.map((e) => ChequeTransactionData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ChequeTransactionData {
  final int? id;
  final String? platform;
  final String? transactionType;
  final String? type; // 'credit'
  final num? amount;
  final String? date;
  final num? referenceId;
  final String? invoiceNo;
  final String? image;
  final String? note;
  final ChequeMeta? meta;
  final User? user; // Received From
  BankData? paymentType;

  ChequeTransactionData({
    this.id,
    this.platform,
    this.transactionType,
    this.type,
    this.amount,
    this.date,
    this.referenceId,
    this.invoiceNo,
    this.image,
    this.note,
    this.meta,
    this.user,
    this.paymentType,
  });

  factory ChequeTransactionData.fromJson(Map<String, dynamic> json) {
    return ChequeTransactionData(
      id: json['id'],
      platform: json['platform'],
      transactionType: json['transaction_type'],
      type: json['type'],
      amount: json['amount'],
      date: json['date'],
      referenceId: json['reference_id'],
      invoiceNo: json['invoice_no'],
      image: json['image'],
      note: json['note'],
      meta: json['meta'] != null ? ChequeMeta.fromJson(json['meta']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      paymentType: json['payment_type'] != null ? BankData.fromJson(json['payment_type']) : null,
    );
  }
}

class ChequeMeta {
  final String? chequeNumber;
  final String? status; // 'open'

  ChequeMeta({this.chequeNumber, this.status});

  factory ChequeMeta.fromJson(Map<String, dynamic> json) {
    return ChequeMeta(
      chequeNumber: json['cheque_number'],
      status: json['status'],
    );
  }
}

// User model is assumed to be shared from bank_transfer_history_model.dart
