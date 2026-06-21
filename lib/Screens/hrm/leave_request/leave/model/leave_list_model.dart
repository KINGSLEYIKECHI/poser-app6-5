class LeaveListModel {
  LeaveListModel({
    this.message,
    this.data,
  });

  LeaveListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(LeaveRequestData.fromJson(v));
      });
    }
  }
  String? message;
  List<LeaveRequestData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class LeaveRequestData {
  LeaveRequestData({
    this.id,
    this.businessId,
    this.branchId,
    this.employeeId,
    this.leaveTypeId,
    this.departmentId,
    this.startDate,
    this.endDate,
    this.leaveDuration,
    this.month,
    this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.employee,
    this.branch,
    this.leaveType,
    this.department,
  });

  LeaveRequestData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    branchId = json['branch_id'];
    employeeId = json['employee_id'];
    leaveTypeId = json['leave_type_id'];
    departmentId = json['department_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaveDuration = json['leave_duration'];
    month = json['month'];
    status = json['status'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    employee = json['employee'] != null ? Employee.fromJson(json['employee']) : null;
    branch = json['branch'];
    leaveType = json['leave_type'] != null ? LeaveType.fromJson(json['leave_type']) : null;
    department = json['department'] != null ? Department.fromJson(json['department']) : null;
  }
  num? id;
  num? businessId;
  dynamic branchId;
  num? employeeId;
  num? leaveTypeId;
  num? departmentId;
  String? startDate;
  String? endDate;
  num? leaveDuration;
  String? month;
  String? status;
  String? description;
  String? createdAt;
  String? updatedAt;
  Employee? employee;
  dynamic branch;
  LeaveType? leaveType;
  Department? department;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['branch_id'] = branchId;
    map['employee_id'] = employeeId;
    map['leave_type_id'] = leaveTypeId;
    map['department_id'] = departmentId;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    map['leave_duration'] = leaveDuration;
    map['month'] = month;
    map['status'] = status;
    map['description'] = description;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (employee != null) {
      map['employee'] = employee?.toJson();
    }
    map['branch'] = branch;
    if (leaveType != null) {
      map['leave_type'] = leaveType?.toJson();
    }
    if (department != null) {
      map['department'] = department?.toJson();
    }
    return map;
  }
}

class Department {
  Department({
    this.id,
    this.name,
  });

  Department.fromJson(dynamic json) {
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

class LeaveType {
  LeaveType({
    this.id,
    this.name,
  });

  LeaveType.fromJson(dynamic json) {
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

class Employee {
  Employee({
    this.id,
    this.name,
  });

  Employee.fromJson(dynamic json) {
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
