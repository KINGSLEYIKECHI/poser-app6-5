class PaymentsTransaction {
  num? id;
  String? platform;
  String? transactionType;
  num? amount;
  String? date;
  String? invoiceNo;
  num? referenceId;
  num? paymentTypeId;
  TransactionMeta? meta;
  PaymentType? paymentType;

  PaymentsTransaction({
    this.id,
    this.platform,
    this.transactionType,
    this.amount,
    this.date,
    this.invoiceNo,
    this.referenceId,
    this.paymentTypeId,
    this.meta,
    this.paymentType,
  });

  PaymentsTransaction.fromJson(dynamic json) {
    id = json['id'];
    platform = json['platform'];
    transactionType = json['transaction_type'];
    amount = num.tryParse(json['amount'].toString());
    date = json['date'];
    invoiceNo = json['invoice_no'];
    referenceId = json['reference_id'];
    paymentTypeId = json['payment_type_id'];
    meta = json['meta'] != null ? TransactionMeta.fromJson(json['meta']) : null;
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
  }
}

class TransactionMeta {
  String? chequeNumber;
  String? status;

  TransactionMeta({this.chequeNumber, this.status});

  TransactionMeta.fromJson(dynamic json) {
    chequeNumber = json['cheque_number'];
    status = json['status'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['cheque_number'] = chequeNumber;
    data['status'] = status;
    return data;
  }
}

class PaymentType {
  PaymentType({
    this.id,
    this.name,
    this.paymentTypeMeta,
  });

  PaymentType.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    paymentTypeMeta = json['meta'] != null ? PaymentTypeMeta.fromJson(json['meta']) : null;
  }
  num? id;
  String? name;
  PaymentTypeMeta? paymentTypeMeta;
}

class PaymentTypeMeta {
  PaymentTypeMeta({
    this.accountNumber,
    this.ifscCode,
    this.holderName,
    this.bankName,
    this.upiId,
  });

  PaymentTypeMeta.fromJson(dynamic json) {
    accountNumber = json['account_number'];
    ifscCode = json['routing_number']; // proper IFSC code
    holderName = json['account_holder'];
    bankName = json['bank_name'];
    upiId = json['upi_id'];
  }

  String? accountNumber;
  String? ifscCode;
  String? holderName;
  String? bankName;
  String? upiId;
}
