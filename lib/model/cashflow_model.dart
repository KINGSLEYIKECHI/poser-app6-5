class CashflowModel {
  final num? cashIn;
  final num? cashOut;
  final num? runningCash;
  final num? initialRunningCash;
  final List<CashflowData>? data;

  CashflowModel({
    this.cashIn,
    this.cashOut,
    this.runningCash,
    this.initialRunningCash,
    this.data,
  });

  factory CashflowModel.fromJson(Map<String, dynamic> json) {
    return CashflowModel(
      cashIn: json["cash_in"],
      cashOut: json["cash_out"],
      runningCash: json["running_cash"],
      initialRunningCash: json["initial_running_cash"],
      data: json["data"] == null ? [] : List<CashflowData>.from(json["data"]!.map((x) => CashflowData.fromJson(x))),
    );
  }
}

class CashflowData {
  final int? id;
  final String? platform;
  final String? transactionType;
  final String? type;
  final num? amount;
  final DateTime? date;
  final String? invoiceNo;
  final String? paymentType;
  final String? partyName;

  CashflowData({
    this.id,
    this.platform,
    this.transactionType,
    this.type,
    this.amount,
    this.date,
    this.invoiceNo,
    this.paymentType,
    this.partyName,
  });

  factory CashflowData.fromJson(Map<String, dynamic> json) {
    final _partyKey = (json["sale"]?["party"]) ?? (json["purchase"]?["party"]) ?? (json["due_collect"]?["party"]);

    return CashflowData(
      id: json["id"],
      platform: json["platform"],
      transactionType: json["transaction_type"],
      type: json["type"],
      amount: json["amount"],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      invoiceNo: json["invoice_no"],
      paymentType: json["payment_type"]?["name"],
      partyName: _partyKey?["name"],
    );
  }
}
