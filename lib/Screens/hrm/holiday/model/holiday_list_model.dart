class HolidayListModel {
  HolidayListModel({
    this.message,
    this.data,
  });

  HolidayListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(HolidayData.fromJson(v));
      });
    }
  }
  String? message;
  List<HolidayData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class HolidayData {
  HolidayData({
    this.id,
    this.businessId,
    this.branchId,
    this.name,
    this.startDate,
    this.endDate,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.branch,
  });

  HolidayData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    branchId = json['branch_id'];
    name = json['name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
  }
  num? id;
  num? businessId;
  num? branchId;
  String? name;
  String? startDate;
  String? endDate;
  String? description;
  String? createdAt;
  String? updatedAt;
  Branch? branch;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['branch_id'] = branchId;
    map['name'] = name;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    map['description'] = description;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (branch != null) {
      map['branch'] = branch?.toJson();
    }
    return map;
  }
}

class Branch {
  Branch({
    this.id,
    this.name,
  });

  Branch.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}
