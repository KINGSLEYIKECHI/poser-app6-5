// File: leave_type_model.dart

class LeaveTypeListModel {
  LeaveTypeListModel({
    this.message,
    this.data,
  });

  LeaveTypeListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(LeaveTypeData.fromJson(v));
      });
    }
  }
  String? message;
  List<LeaveTypeData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LeaveTypeData {
  LeaveTypeData({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  LeaveTypeData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    name = json['name'];
    description = json['description'];
    // Assuming status 1 means 'Active' and 0 means 'Inactive' in the UI
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? businessId;
  String? name;
  String? description;
  num? status; // status is a number (1 or 0)
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
