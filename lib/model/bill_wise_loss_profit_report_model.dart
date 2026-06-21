class BillWiseLossProfitReportModel {
  final num? totalSaleAmount;
  final num? totalProfit;
  final num? totalLoss;
  final List<TransactionModel>? transactions;

  BillWiseLossProfitReportModel({
    this.totalSaleAmount,
    this.totalProfit,
    this.totalLoss,
    this.transactions,
  });

  factory BillWiseLossProfitReportModel.fromJson(Map<String, dynamic> json) {
    return BillWiseLossProfitReportModel(
      totalSaleAmount: json["total_amount"],
      totalProfit: json['total_bill_profit'],
      totalLoss: json['total_bill_loss'],
      transactions: json['data'] == null
          ? null
          : List<TransactionModel>.from(json['data'].map((x) => TransactionModel.fromJson(x))),
    );
  }
}

class TransactionModel {
  final int? id;
  final String? partyName;
  final String? invoiceNumber;
  final DateTime? transactionDate;
  final num? totalAmount;
  final num? lossProfit;
  final List<TransactionItem>? items;

  bool get isProfit => (lossProfit ?? 0) > 0;

  TransactionModel({
    this.id,
    this.partyName,
    this.invoiceNumber,
    this.transactionDate,
    this.totalAmount,
    this.lossProfit,
    this.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      partyName: json['party']?['name'],
      invoiceNumber: json['invoiceNumber'],
      transactionDate: json["saleDate"] == null ? null : DateTime.parse(json['saleDate']),
      totalAmount: json['totalAmount'],
      lossProfit: json['lossProfit'],
      items: json['details'] == null
          ? null
          : List<TransactionItem>.from(json['details'].map((x) => TransactionItem.fromJson(x))),
    );
  }
}

class TransactionItem {
  final int? id;
  final String? name;
  final int? quantity;
  final num? purchasePrice;
  final num? salesPrice;
  final num? lossProfit;

  bool get isProfit => (lossProfit ?? 0) > 0;

  TransactionItem({
    this.id,
    this.name,
    this.quantity,
    this.purchasePrice,
    this.salesPrice,
    this.lossProfit,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'],
      name: json['product']?['productName'],
      quantity: json['quantities'],
      purchasePrice: json['productPurchasePrice'],
      salesPrice: json['price'],
      lossProfit: json['lossProfit'],
    );
  }
}
