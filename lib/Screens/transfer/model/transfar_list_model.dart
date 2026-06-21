class TransferListModel {
  final String? message;
  final List<TransferListData>? data;

  TransferListModel({this.message, this.data});

  factory TransferListModel.fromJson(Map<String, dynamic> json) {
    return TransferListModel(
      message: json['message'],
      data: json['data'] != null ? (json['data'] as List).map((i) => TransferListData.fromJson(i)).toList() : null,
    );
  }
}

class TransferListData {
  final int? id;
  final String? transferDate;
  final String? invoiceNo;
  final String? status;
  final String? fromBranch;
  final String? toBranch;
  final String? fromWarehouse;
  final String? toWarehouse;
  final int? qty;
  final num? stockValue;

  TransferListData({
    this.id,
    this.transferDate,
    this.invoiceNo,
    this.status,
    this.fromBranch,
    this.toBranch,
    this.fromWarehouse,
    this.toWarehouse,
    this.qty,
    this.stockValue,
  });

  factory TransferListData.fromJson(Map<String, dynamic> json) {
    return TransferListData(
      id: json['id'],
      transferDate: json['transfer_date'],
      invoiceNo: json['invoice_no'],
      status: json['status'],
      fromBranch: json['from_branch'],
      toBranch: json['to_branch'],
      fromWarehouse: json['from_warehouse'],
      toWarehouse: json['to_warehouse'],
      qty: json['qty'],
      stockValue: json['stock_value'],
    );
  }
}
