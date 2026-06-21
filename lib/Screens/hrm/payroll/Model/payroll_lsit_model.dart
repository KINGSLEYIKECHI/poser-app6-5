// File: payroll_list_model.dart

import '../../../../widgets/multipal payment mathods/model/payment_transaction_model.dart';

class PayrollListModel {
  PayrollListModel({
    this.message,
    this.data,
  });

  PayrollListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(PayrollData.fromJson(v));
      });
    }
  }
  String? message;
  List<PayrollData>? data;
}

class PayrollData {
  PayrollData({
    this.id,
    this.businessId,
    this.branchId,
    this.employeeId,
    this.paymentTypeId,
    this.month,
    this.puid,
    this.date,
    this.amount,
    this.payemntYear,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.employee,
    this.transactions,
    this.branch,
  });

  PayrollData.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    branchId = json['branch_id'];
    employeeId = json['employee_id'];
    paymentTypeId = json['payment_type_id'];
    month = json['month'];
    puid = json['puid'];
    date = json['date'];
    amount = json['amount'];
    payemntYear = json['payemnt_year'];
    note = json['note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    employee = json['employee'] != null ? Employee.fromJson(json['employee']) : null;
    if (json['transactions'] != null) {
      transactions = [];
      json['transactions'].forEach((v) {
        transactions?.add(PaymentsTransaction.fromJson(v));
      });
    }
    branch = json['branch'];
  }
  num? id;
  num? businessId;
  dynamic branchId;
  num? employeeId;
  num? paymentTypeId;
  String? month;
  String? puid;
  String? date;
  num? amount;
  String? payemntYear;
  String? note;
  String? createdAt;
  String? updatedAt;
  Employee? employee;
  List<PaymentsTransaction>? transactions;
  dynamic branch;
}


// Reusing Employee model from previous section (assuming it's available)
class Employee {
  Employee({this.id, this.name});
  Employee.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;
}

// Placeholder for list consumption
class PaymentTypeData extends PaymentType {
  PaymentTypeData.fromJson(dynamic json) : super.fromJson(json);
}
