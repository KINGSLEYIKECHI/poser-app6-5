class PartyLedgerModel {
  int? id;
  String? platform;
  // num? amount;
  num? creditAmount;
  num? debitAmount;
  String? date;
  num? balance;
  String? invoiceNumber;
  SaleModel? sale;
  PurchaseModel? purchase;
  DueModelLeger? dueCollect;

  PartyLedgerModel({
    this.id,
    this.platform,
    this.creditAmount,
    this.debitAmount,
    this.date,
    this.balance,
    this.invoiceNumber,
    this.sale,
    this.purchase,
    this.dueCollect,
  });

  // factory PartyLedgerModel.fromJson(Map<String, dynamic> json) {
  //   // Helper to extract invoice number from nested objects
  //   String? getInvoice(Map<String, dynamic> json) {
  //     if (json['sale'] != null) return json['sale']['invoiceNumber'];
  //     if (json['purchase'] != null) return json['purchase']['invoiceNumber'];
  //     if (json['due_collect'] != null) return json['due_collect']['invoiceNumber'];
  //     return null;
  //   }
  //
  //   return PartyLedgerModel(
  //     id: json['id'],
  //     platform: json['platform'],
  //     debitAmount: num.tryParse(json['debit_amount'].toString()),
  //     creditAmount: num.tryParse(json['credit_amount'].toString()),
  //     date: json['date'],
  //     balance: num.tryParse(json['balance'].toString()),
  //     sale: json['sale'] != null ? SaleModel.fromJson(json['sale']) : null,
  //     purchase: json['purchase'] != null ? PurchaseModel.fromJson(json['purchase']) : null,
  //     dueCollect: json['due_collect'] != null ? DueModelLeger.fromJson(json['due_collect']) : null,
  //     invoiceNumber: getInvoice(json),
  //   );
  // }

  factory PartyLedgerModel.fromJson(Map<String, dynamic> json) {
    return PartyLedgerModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      platform: json['platform'],
      debitAmount: num.tryParse(json['debit_amount']?.toString() ?? ''),
      creditAmount: num.tryParse(json['credit_amount']?.toString() ?? ''),
      date: json['date']?.toString(),
      balance: num.tryParse(json['balance']?.toString() ?? ''),
      invoiceNumber: json['invoice_no']?.toString() ?? '',
    );
  }
}

//SalePartyLegerModel
class SaleModel {
  int? id;
  String? invoiceNumber;
  int? partyId;

  SaleModel({this.id, this.invoiceNumber, this.partyId});

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      partyId: json['party_id'],
    );
  }
}

//SalePartyLegerModel
class PurchaseModel {
  int? id;
  String? invoiceNumber;
  int? partyId;

  PurchaseModel({this.id, this.invoiceNumber, this.partyId});

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      partyId: json['party_id'],
    );
  }
}

//SalePartyLegerModel
class DueModelLeger {
  int? id;
  String? invoiceNumber;
  int? partyId;

  DueModelLeger({this.id, this.invoiceNumber, this.partyId});

  factory DueModelLeger.fromJson(Map<String, dynamic> json) {
    return DueModelLeger(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      partyId: json['party_id'],
    );
  }
}

// Helper class to return data + pagination info
class PartyLedgerResponse {
  final List<PartyLedgerModel> data;
  final int lastPage;
  final int currentPage;

  PartyLedgerResponse({required this.data, required this.lastPage, required this.currentPage});
}
