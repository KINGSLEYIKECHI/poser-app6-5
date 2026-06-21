class BusinessInformationModel {
  BusinessInformationModel({
    this.message,
    this.data,
  });

  BusinessInformationModel.fromJson(dynamic json) {
    message = json['message'];
    data = json['data'] != null ? BusinessInfoData.fromJson(json['data']) : null;
  }
  String? message;
  BusinessInfoData? data;
}

class BusinessInfoData {
  BusinessInfoData({
    this.id,
    this.planSubscribeId,
    this.businessCategoryId,
    this.affiliatorId,
    this.companyName,
    this.willExpire,
    this.address,
    this.phoneNumber,
    this.pictureUrl,
    this.subscriptionDate,
    this.remainingShopBalance,
    this.shopOpeningBalance,
    this.vatNo,
    this.vatName,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.enrolledPlan,
    this.user,
    this.businessCurrency,
    this.invoiceLogo,
    this.saleRoundingOption,
    this.invoiceSize,
    this.invoiceNoteLevel,
    this.invoiceNote,
    this.gratitudeMessage,
    this.profilePrinter,
    this.developByLevel,
    this.developBy,
    this.developByLink,
    this.branchCount,
    this.invoiceLanguage,
    this.addons,
    this.invoiceEmail,
    this.showNote,
    this.warrantyVoidLabel,
    this.warrantyVoid,
    this.meta,
    this.showGratitudeMsg,
    this.showInvoiceScannerLogo,
    this.showA4InvoiceLogo,
    this.showThermalInvoiceLogo,
    this.showWarranty,
    this.countryId,
    this.stateId,
    this.country,
    this.state,
    this.allowDueSale,
    this.allowProductDiscount,
  });

  BusinessInfoData.fromJson(dynamic json) {
    id = json['id'];
    planSubscribeId = json['plan_subscribe_id'];
    invoiceEmail = json['email'];
    businessCategoryId = json['business_category_id'];
    affiliatorId = json['affiliator_id'];
    companyName = json['companyName'];
    willExpire = json['will_expire'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    pictureUrl = json['pictureUrl'];
    subscriptionDate = json['subscriptionDate'];
    remainingShopBalance = json['remainingShopBalance'];
    shopOpeningBalance = json['shopOpeningBalance'];
    vatNo = json['vat_no'];
    vatName = json['vat_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    enrolledPlan = json['enrolled_plan'] != null ? EnrolledPlan.fromJson(json['enrolled_plan']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    meta = json['meta'] != null ? BusinessMeta.fromJson(json['meta']) : null;
    businessCurrency = json['business_currency'] != null ? BusinessCurrency.fromJson(json['business_currency']) : null;
    invoiceLogo = json['invoice_logo'];
    thermalInvoiceLogo = json['thermal_invoice_logo'];
    a4InvoiceLogo = json['a4_invoice_logo'];
    invoiceScannerLogo = json['invoice_scanner_logo'];
    saleRoundingOption = json['sale_rounding_option'];
    invoiceSize = json['invoice_size'];
    profilePrinter = json['profile_printer'];
    invoiceNoteLevel = json['note_label'];
    invoiceNote = json['note'];
    gratitudeMessage = json['gratitude_message'];
    warrantyVoidLabel = json['warranty_void_label'];
    warrantyVoid = json['warranty_void'];
    developByLevel = json['develop_by_level'];
    developBy = json['develop_by'];
    developByLink = json['develop_by_link'];
    branchCount = json['branch_count'];
    addons = json['addons'] != null ? Addons.fromJson(json['addons']) : null;
    invoiceLanguage = json['invoice_language'];
    showNote = json['show_note'];
    showGratitudeMsg = json['show_gratitude_msg'];
    showInvoiceScannerLogo = json['show_invoice_scanner_logo'];
    showA4InvoiceLogo = json['show_a4_invoice_logo'];
    showThermalInvoiceLogo = json['show_thermal_invoice_logo'];
    showWarranty = json['show_warranty'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    country = json['country'] != null ? BusinessCountry.fromJson(json['country']) : null;
    state = json['state'] != null ? BusinessState.fromJson(json['state']) : null;
    allowDueSale = json['allow_due_sale'];
    allowProductDiscount = json['allow_product_discount'];
  }
  num? id;
  num? planSubscribeId;
  num? businessCategoryId;
  num? affiliatorId;
  String? companyName;
  String? willExpire;
  String? address;
  String? phoneNumber;
  String? pictureUrl;
  String? subscriptionDate;
  num? remainingShopBalance;
  num? shopOpeningBalance;
  String? vatNo;
  String? vatName;
  String? createdAt;
  String? updatedAt;
  Category? category;
  EnrolledPlan? enrolledPlan;
  User? user;
  BusinessCurrency? businessCurrency;
  String? invoiceLogo;
  String? thermalInvoiceLogo;
  String? a4InvoiceLogo;
  String? invoiceScannerLogo;
  String? saleRoundingOption;
  String? invoiceSize;
  String? profilePrinter;
  String? invoiceLanguage;
  String? invoiceNoteLevel;
  String? invoiceNote;
  String? gratitudeMessage;
  String? warrantyVoidLabel;
  String? warrantyVoid;
  String? developByLevel;
  String? developBy;
  int? showNote;
  int? showGratitudeMsg;
  int? showInvoiceScannerLogo;
  int? showA4InvoiceLogo;
  int? showThermalInvoiceLogo;
  int? showWarranty;
  String? invoiceEmail;
  BusinessMeta? meta;

  String? developByLink;
  num? branchCount;
  Addons? addons;
  num? countryId;
  num? stateId;
  BusinessCountry? country;
  BusinessState? state;
  int? allowDueSale;
  int? allowProductDiscount;
}

class BusinessMeta {
  BusinessMeta(
      {this.showCompanyName, this.showPhoneNumber, this.showAddress, this.showEmail, this.showVat, this.showVatName});

  BusinessMeta.fromJson(dynamic json) {
    showCompanyName = json['show_company_name'];
    showPhoneNumber = json['show_phone_number'];
    showAddress = json['show_address'];
    showEmail = json['show_email'];
    showVat = json['show_vat'];
  }

  num? showCompanyName;
  num? showPhoneNumber;
  num? showAddress;
  num? showEmail;
  num? showVat;
  num? showVatName;
}

class Addons {
  Addons({
    this.affiliateAddon,
    this.multiBranchAddon,
    this.warehouseAddon,
    this.thermalPrinterAddon,
    this.hrmAddon,
    this.domainAddon,
    this.serialCodeAddon,
    this.taxInvoicePdf,
  });

  Addons.fromJson(dynamic json) {
    affiliateAddon = json['AffiliateAddon'] ?? false;
    multiBranchAddon = json['MultiBranchAddon'] ?? false;
    warehouseAddon = json['WarehouseAddon'] ?? false;
    thermalPrinterAddon = json['ThermalPrinterAddon'] ?? false;
    hrmAddon = json['HrmAddon'] ?? false;
    domainAddon = json['CustomDomainAddon'] ?? false;
    serialCodeAddon = json['SerialCodeAddon'] ?? false;
    taxInvoicePdf = json['TaxInvoiceAddon'] ?? false;
  }

  bool? affiliateAddon;
  bool? multiBranchAddon;
  bool? warehouseAddon;
  bool? thermalPrinterAddon;
  bool? hrmAddon;
  bool? domainAddon;
  bool? serialCodeAddon;
  bool? taxInvoicePdf;

  Map<String, dynamic> toJson() {
    return {
      'AffiliateAddon': affiliateAddon ?? false,
      'MultiBranchAddon': multiBranchAddon ?? false,
      'WarehouseAddon': warehouseAddon ?? false,
      'ThermalPrinterAddon': thermalPrinterAddon ?? false,
      'HrmAddon': hrmAddon ?? false,
      'CustomDomainAddon': domainAddon ?? false,
      'SerialCodeAddon': serialCodeAddon ?? false,
      'TaxInvoiceAddon': taxInvoicePdf ?? false,
    };
  }
}

class BusinessCurrency {
  BusinessCurrency({
    this.id,
    this.name,
    this.code,
    this.symbol,
    this.position,
  });

  BusinessCurrency.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    symbol = json['symbol'];
    position = json['position'];
  }
  num? id;
  String? name;
  String? code;
  String? symbol;
  String? position;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['code'] = code;
    map['symbol'] = symbol;
    map['position'] = position;
    return map;
  }
}

class User {
  User({
    this.id,
    this.name,
    this.role,
    required this.visibility,
    this.lang,
    this.email,
    this.visibilityIsNull = false,
    this.activeBranch,
    this.activeBranchId,
    this.branchId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawVisibility = json['visibility'];
    Map<String, Map<String, String>> parsedVisibility = {};
    bool visibilityIsNull = false;

    if (rawVisibility == null) {
      visibilityIsNull = true;
    } else if (rawVisibility is Map<String, dynamic>) {
      parsedVisibility = rawVisibility.map((moduleKey, perms) {
        if (perms is Map<String, dynamic>) {
          return MapEntry(
            moduleKey,
            perms.map((permKey, value) => MapEntry(permKey, value.toString())),
          );
        }
        return MapEntry(moduleKey, <String, String>{});
      });
    }

    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      lang: json['lang'],
      visibility: parsedVisibility,
      visibilityIsNull: visibilityIsNull,
      activeBranch: json['active_branch'] != null ? ActiveBranch.fromJson(json['active_branch']) : null,
      activeBranchId: json['active_branch_id'],
      branchId: json['branch_id'],
    );
  }

  final bool visibilityIsNull; // new field

  /// 🔍 Get all enabled permissions in format: `module.permission`
  List<String> getAllPermissions() {
    if (visibilityIsNull) {
      return [];
    }

    final List<String> permissions = [];
    visibility.forEach((module, perms) {
      perms.forEach((action, value) {
        if (value == "1") {
          permissions.add('$module.$action');
        }
      });
    });
    return permissions;
  }

  num? id;
  String? name;
  String? role;
  final Map<String, Map<String, String>> visibility;
  dynamic lang;
  String? email;
  num? branchId;
  num? activeBranchId;

  ActiveBranch? activeBranch;
}

class ActiveBranch {
  ActiveBranch({
    this.id,
    this.name,
  });

  ActiveBranch.fromJson(dynamic json) {
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

class EnrolledPlan {
  EnrolledPlan({
    this.id,
    this.planId,
    this.businessId,
    this.price,
    this.duration,
    this.allowMultibranch,
    this.plan,
  });

  EnrolledPlan.fromJson(dynamic json) {
    id = json['id'];
    planId = json['plan_id'];
    businessId = json['business_id'];
    price = json['price'];
    duration = json['duration'];
    allowMultibranch = json['allow_multibranch'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
  }
  num? id;
  num? planId;
  num? businessId;
  num? price;
  num? duration;
  num? allowMultibranch;
  Plan? plan;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['plan_id'] = planId;
    map['business_id'] = businessId;
    map['price'] = price;
    map['duration'] = duration;
    map['allow_multibranch'] = allowMultibranch;
    if (plan != null) {
      map['plan'] = plan?.toJson();
    }
    return map;
  }
}

class Plan {
  Plan({
    this.id,
    this.subscriptionName,
  });

  Plan.fromJson(dynamic json) {
    id = json['id'];
    subscriptionName = json['subscriptionName'];
  }
  num? id;
  String? subscriptionName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['subscriptionName'] = subscriptionName;
    return map;
  }
}

class Category {
  Category({
    this.id,
    this.name,
  });

  Category.fromJson(dynamic json) {
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

class BusinessCountry {
  num? id;
  String? name;

  BusinessCountry({this.id, this.name});

  BusinessCountry.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}

// New Class for State Object
class BusinessState {
  num? id;
  String? name;
  num? countryId;

  BusinessState({this.id, this.name, this.countryId});

  BusinessState.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    countryId = json['country_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['country_id'] = countryId;
    return map;
  }
}
