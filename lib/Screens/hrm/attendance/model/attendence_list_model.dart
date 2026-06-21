// File: attendance_model.dart

class AttendanceListModel {
  AttendanceListModel({
    this.message,
    this.data,
  });

  AttendanceListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(AttendanceData.fromJson(v));
      });
    }
  }
  String? message;
  List<AttendanceData>? data;
}

class AttendanceData {
  AttendanceData({
    this.id,
    this.businessId,
    this.branchId,
    this.employeeId,
    this.shiftId,
    this.timeIn,
    this.timeOut,
    this.date,
    this.duration,
    this.month,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.employee,
    this.shift,
  });

  AttendanceData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    branchId = json['branch_id'];
    employeeId = json['employee_id'];
    shiftId = json['shift_id'];
    timeIn = json['time_in'];
    timeOut = json['time_out'];
    date = json['date'];
    duration = json['duration'];
    month = json['month'];
    note = json['note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    employee = json['employee'] != null ? Employee.fromJson(json['employee']) : null;
    shift = json['shift'] != null ? Shift.fromJson(json['shift']) : null;
  }
  num? id;
  num? businessId;
  dynamic branchId;
  num? employeeId;
  num? shiftId;
  String? timeIn;
  String? timeOut;
  String? date;
  String? duration;
  String? month;
  String? note;
  String? createdAt;
  String? updatedAt;
  Employee? employee;
  Shift? shift;
}

class Employee {
  Employee({this.id, this.name});
  Employee.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;
}

class Shift {
  Shift({this.id, this.name});
  Shift.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;
}

// Assume EmployeeData model exists elsewhere for provider list consumption
class EmployeeData {
  num? id;
  String? name;
  EmployeeData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
}

// Assume ShiftData model exists elsewhere for provider list consumption
class ShiftData {
  num? id;
  String? name;
  ShiftData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
}
