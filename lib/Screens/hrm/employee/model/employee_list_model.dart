class EmployeeListModel {
  EmployeeListModel({
    this.message,
    this.employees,
  });

  EmployeeListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      employees = [];
      json['data'].forEach((v) {
        employees?.add(EmployeeData.fromJson(v));
      });
    }
  }
  String? message;
  List<EmployeeData>? employees;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (employees != null) {
      map['data'] = employees?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class EmployeeData {
  EmployeeData({
    this.id,
    this.name,
    this.businessId,
    this.branchId,
    this.designationId,
    this.departmentId,
    this.shiftId,
    this.amount,
    this.image,
    this.phone,
    this.email,
    this.gender,
    this.country,
    this.birthDate,
    this.joinDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.department,
    this.designation,
    this.shift,
    this.branch,
  });

  EmployeeData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    businessId = json['business_id'];
    branchId = json['branch_id'];
    designationId = json['designation_id'];
    departmentId = json['department_id'];
    shiftId = json['shift_id'];
    amount = json['amount'];
    image = json['image'];
    phone = json['phone'];
    email = json['email'];
    gender = json['gender'];
    country = json['country'];
    birthDate = json['birth_date'];
    joinDate = json['join_date'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    department = json['department'] != null ? Department.fromJson(json['department']) : null;
    designation = json['designation'] != null ? Designation.fromJson(json['designation']) : null;
    shift = json['shift'] != null ? Shift.fromJson(json['shift']) : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
  }
  num? id;
  String? name;
  num? businessId;
  num? branchId;
  num? designationId;
  num? departmentId;
  num? shiftId;
  num? amount;
  dynamic image;
  String? phone;
  String? email;
  String? gender;
  String? country;
  String? birthDate;
  String? joinDate;
  String? status;
  String? createdAt;
  String? updatedAt;
  Department? department;
  Designation? designation;
  Shift? shift;
  Branch? branch;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['business_id'] = businessId;
    map['branch_id'] = branchId;
    map['designation_id'] = designationId;
    map['department_id'] = departmentId;
    map['shift_id'] = shiftId;
    map['amount'] = amount;
    map['image'] = image;
    map['phone'] = phone;
    map['email'] = email;
    map['gender'] = gender;
    map['country'] = country;
    map['birth_date'] = birthDate;
    map['join_date'] = joinDate;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (department != null) {
      map['department'] = department?.toJson();
    }
    if (designation != null) {
      map['designation'] = designation?.toJson();
    }
    if (shift != null) {
      map['shift'] = shift?.toJson();
    }
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

class Shift {
  Shift({
    this.id,
    this.name,
  });

  Shift.fromJson(dynamic json) {
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

class Designation {
  Designation({
    this.id,
    this.name,
  });

  Designation.fromJson(dynamic json) {
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
