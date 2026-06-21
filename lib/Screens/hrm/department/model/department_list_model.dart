class DepartmentListModel {
  DepartmentListModel({
    this.message,
    this.data,
  });

  DepartmentListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(DepartmentData.fromJson(v));
      });
    }
  }
  String? message;
  List<DepartmentData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class DepartmentData {
  DepartmentData({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  DepartmentData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? businessId;
  String? name;
  String? description;
  num? status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['name'] = name;
    map['description'] = description;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
