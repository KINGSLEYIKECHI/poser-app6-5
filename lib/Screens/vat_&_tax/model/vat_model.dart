class VatModel {
  VatModel({
    this.id,
    this.name,
    this.businessId,
    this.rate,
    this.manageState,
    this.subTax,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.innerStateVats,
    this.outerStateVats,
  });

  VatModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    businessId = json['business_id'];
    rate = json['rate'];
    // manage_state কখনো int (0/1) আবার কখনো String ("0"/"1") আসতে পারে, তাই safe parsing
    manageState = int.tryParse(json['manage_state'].toString());

    // Standard Sub Vats (Old logic)
    if (json['sub_vat'] != null) {
      subTax = [];
      json['sub_vat'].forEach((v) {
        subTax?.add(SubVat.fromJson(v));
      });
    }

    // Status parsing
    if (json['status'] is bool) {
      status = json['status'];
    } else {
      status = json['status'] == 1 || json['status'] == '1';
    }

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    // Inner State Vats (New logic)
    if (json['inner_state_vats'] != null) {
      innerStateVats = [];
      json['inner_state_vats'].forEach((v) {
        innerStateVats?.add(StateVat.fromJson(v));
      });
    }

    // Outer State Vats (New logic)
    if (json['outer_state_vats'] != null) {
      outerStateVats = [];
      json['outer_state_vats'].forEach((v) {
        outerStateVats?.add(StateVat.fromJson(v));
      });
    }
  }

  num? id;
  String? name;
  num? businessId;
  num? rate;
  int? manageState; // 0 or 1
  List<SubVat>? subTax;
  bool? status;
  String? createdAt;
  String? updatedAt;
  List<StateVat>? innerStateVats;
  List<StateVat>? outerStateVats;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['business_id'] = businessId;
    map['rate'] = rate;
    map['manage_state'] = manageState;
    if (subTax != null) {
      map['sub_vat'] = subTax?.map((v) => v.toJson()).toList();
    }
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (innerStateVats != null) {
      map['inner_state_vats'] = innerStateVats?.map((v) => v.toJson()).toList();
    }
    if (outerStateVats != null) {
      map['outer_state_vats'] = outerStateVats?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SubVat {
  SubVat({
    this.id,
    this.name,
    this.rate,
  });

  SubVat.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  num? id;
  String? name;
  num? rate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['rate'] = rate;
    return map;
  }
}

class StateVat {
  StateVat({
    this.id,
    this.parentVatId,
    this.childVatId,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  StateVat.fromJson(dynamic json) {
    id = json['id'];
    parentVatId = json['parent_vat_id'];
    childVatId = json['child_vat_id'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  num? parentVatId;
  num? childVatId; // This corresponds to the ID of the simple tax
  String? type; // "inner" or "outer"
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['parent_vat_id'] = parentVatId;
    map['child_vat_id'] = childVatId;
    map['type'] = type;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
