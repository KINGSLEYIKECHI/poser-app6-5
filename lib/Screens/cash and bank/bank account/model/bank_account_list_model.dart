// File: bank_account_model.dart

class BankListModel {
  BankListModel({this.message, this.data});

  BankListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(BankData.fromJson(v));
      });
    }
  }
  String? message;
  List<BankData>? data;
}

class BankData {
  BankData({
    this.id,
    this.name, // Account Display Name
    this.meta,
    this.showInInvoice,
    this.openingDate,
    this.openingBalance,
    this.balance,
    this.status,
  });

  BankData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    meta = json['meta'] != null ? BankMeta.fromJson(json['meta']) : null;
    showInInvoice = json['show_in_invoice'];
    openingDate = json['opening_date'];
    openingBalance = json['opening_balance'];
    balance = json['balance'];
    status = json['status'];
  }
  num? id;
  String? name;
  BankMeta? meta;
  num? showInInvoice;
  String? openingDate;
  num? openingBalance;
  num? balance;
  num? status;
}

class BankMeta {
  BankMeta({
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.bankName,
    this.accountHolder,
  });

  BankMeta.fromJson(dynamic json) {
    accountNumber = json['account_number'];
    ifscCode = json['ifsc_code'];
    upiId = json['upi_id'];
    bankName = json['bank_name'];
    accountHolder = json['account_holder'];
  }
  String? accountNumber;
  String? ifscCode;
  String? upiId;
  String? bankName;
  String? accountHolder;

  // Helper method to convert back to API format (meta fields are sent as separate inputs)
  Map<String, dynamic> toApiMetaJson() {
    return {
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
      'bank_name': bankName,
      'account_holder': accountHolder,
    };
  }
}
