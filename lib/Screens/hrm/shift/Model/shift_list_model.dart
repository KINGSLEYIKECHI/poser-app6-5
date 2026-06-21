class ShiftListModel {
  ShiftListModel({
    this.message,
    this.data,
  });

  ShiftListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ShiftData.fromJson(v));
      });
    }
  }
  String? message;
  List<ShiftData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ShiftData {
  ShiftData({
    this.id,
    this.name,
    this.businessId,
    this.startTime,
    this.endTime,
    this.startBreakTime,
    this.endBreakTime,
    this.breakTime,
    this.breakStatus,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  ShiftData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    businessId = json['business_id'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    startBreakTime = json['start_break_time'];
    endBreakTime = json['end_break_time'];
    breakTime = json['break_time'];
    breakStatus = json['break_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? name;
  num? businessId;
  String? startTime;
  String? endTime;
  String? startBreakTime;
  String? endBreakTime;
  String? breakTime;
  String? breakStatus;
  num? status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['business_id'] = businessId;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['start_break_time'] = startBreakTime;
    map['end_break_time'] = endBreakTime;
    map['break_time'] = breakTime;
    map['break_status'] = breakStatus;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
