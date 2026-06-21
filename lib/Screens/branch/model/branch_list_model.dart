class BranchListModel {
  BranchListModel({
    this.message,
    this.data,
  });

  BranchListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(BranchData.fromJson(v));
      });
    }
  }
  String? message;
  List<BranchData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class BranchData {
  BranchData({
    this.id,
    this.businessId,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.description,
    this.status,
    this.isMain,
    this.branchOpeningBalance,
    this.branchRemainingBalance,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  BranchData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    description = json['description'];
    status = json['status'];
    isMain = json['is_main'];
    branchOpeningBalance = json['branchOpeningBalance'];
    branchRemainingBalance = json['branchRemainingBalance'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? businessId;
  String? name;
  String? phone;
  String? email;
  String? address;
  String? description;
  num? status;
  num? isMain;
  num? branchOpeningBalance;
  num? branchRemainingBalance;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['name'] = name;
    map['phone'] = phone;
    map['email'] = email;
    map['address'] = address;
    map['description'] = description;
    map['status'] = status;
    map['is_main'] = isMain;
    map['branchOpeningBalance'] = branchOpeningBalance;
    map['branchRemainingBalance'] = branchRemainingBalance;
    map['deleted_at'] = deletedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
