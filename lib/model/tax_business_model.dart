class TaxBusiness {
  final int? id;
  final String? phoneNumber;
  final String? companyName;
  final String? vatName;
  final String? vatNo;
  final String? address;
  final String? email;
  final TaxMeta? meta;
  final int? stateId;
  final StateModel? state;

  TaxBusiness({
    this.id,
    this.phoneNumber,
    this.companyName,
    this.vatName,
    this.vatNo,
    this.address,
    this.email,
    this.meta,
    this.stateId,
    this.state,
  });

  factory TaxBusiness.fromJson(Map<String, dynamic> json) {
    return TaxBusiness(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      companyName: json['companyName'],
      vatName: json['vat_name'],
      vatNo: json['vat_no'],
      address: json['address'],
      email: json['email'],
      meta: json['meta'] != null ? TaxMeta.fromJson(json['meta']) : null,
      stateId: json['state_id'],
      state: json['state'] != null ? StateModel.fromJson(json['state']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "phoneNumber": phoneNumber,
      "companyName": companyName,
      "vat_name": vatName,
      "vat_no": vatNo,
      "address": address,
      "email": email,
      "meta": meta?.toJson(),
      "state_id": stateId,
      "state": state?.toJson(),
    };
  }
}

class TaxMeta {
  final int? showCompanyName;
  final int? showPhoneNumber;
  final int? showAddress;
  final int? showEmail;
  final int? showVat;

  TaxMeta({
    this.showCompanyName,
    this.showPhoneNumber,
    this.showAddress,
    this.showEmail,
    this.showVat,
  });

  factory TaxMeta.fromJson(Map<String, dynamic> json) {
    return TaxMeta(
      showCompanyName: json['show_company_name'],
      showPhoneNumber: json['show_phone_number'],
      showAddress: json['show_address'],
      showEmail: json['show_email'],
      showVat: json['show_vat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "show_company_name": showCompanyName,
      "show_phone_number": showPhoneNumber,
      "show_address": showAddress,
      "show_email": showEmail,
      "show_vat": showVat,
    };
  }
}

class StateModel {
  final int? id;
  final String? name;

  StateModel({
    this.id,
    this.name,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}
