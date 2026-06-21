// File: bank_transaction_history_model.dart (Updated to full structure)

class TransactionHistoryListModel {
  TransactionHistoryListModel({this.message, this.data});

  TransactionHistoryListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(TransactionData.fromJson(v));
      });
    }
  }
  String? message;
  List<TransactionData>? data;
}

class TransactionData {
  TransactionData({
    this.id,
    this.platform,
    this.transactionType,
    this.type, // credit / debit / transfer
    this.amount,
    this.date,
    this.fromBankId,
    this.toBankId,
    this.invoiceNo,
    this.image,
    this.note,
    this.user,
    // Add nested bank models if API provides bank objects, otherwise we only use IDs
  });

  TransactionData.fromJson(dynamic json) {
    id = json['id'];
    platform = json['platform'];
    transactionType = json['transaction_type'];
    type = json['type'];
    amount = json['amount'];
    date = json['date'];
    fromBankId = json['from_bank'];
    toBankId = json['to_bank'];
    invoiceNo = json['invoice_no'];
    image = json['image'];
    note = json['note'];
    user = json['user'] != null ? TransactionUser.fromJson(json['user']) : null;
  }
  num? id;
  String? platform;
  String? transactionType;
  String? type;
  num? amount;
  String? date;
  num? fromBankId;
  num? toBankId;
  String? invoiceNo;
  String? image;
  String? note;
  TransactionUser? user;
}

class TransactionUser {
  TransactionUser({this.id, this.name});
  TransactionUser.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;
}