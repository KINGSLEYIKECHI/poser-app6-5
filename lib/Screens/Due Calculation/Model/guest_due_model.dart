class GuestDueModel {
  num? id;
  num? businessId;
  num? branchId;
  num? userId;
  num? dueAmount;
  num? paidAmount;
  num? totalAmount;
  String? invoiceNumber;
  String? saleDate;

  GuestDueModel({
    this.id,
    this.businessId,
    this.branchId,
    this.userId,
    this.dueAmount,
    this.paidAmount,
    this.totalAmount,
    this.invoiceNumber,
    this.saleDate,
  });

  GuestDueModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessId = json['business_id'];
    branchId = json['branch_id'];
    userId = json['user_id'];
    dueAmount = json['dueAmount'];
    paidAmount = json['paidAmount'];
    totalAmount = json['totalAmount'];
    invoiceNumber = json['invoiceNumber'];
    saleDate = json['saleDate'];
  }
}
