// class BusinessInfoModelNew {
//   BusinessInfoModelNew({
//     this.message,
//     this.data,
//   });
//
//   BusinessInfoModelNew.fromJson(dynamic json) {
//     message = json['message'];
//     data = json['data'] != null ? BusinessInfoData.fromJson(json['data']) : null;
//   }
//   String? message;
//   BusinessInfoData? data;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['message'] = message;
//     if (data != null) {
//       map['data'] = data?.toJson();
//     }
//     return map;
//   }
// }
//
// class BusinessInfoData {
//   BusinessInfoData({
//     this.id,
//     this.planSubscribeId,
//     this.businessCategoryId,
//     this.affiliatorId,
//     this.companyName,
//     this.willExpire,
//     this.address,
//     this.phoneNumber,
//     this.pictureUrl,
//     this.subscriptionDate,
//     this.remainingShopBalance,
//     this.shopOpeningBalance,
//     this.vatNo,
//     this.vatName,
//     this.createdAt,
//     this.updatedAt,
//     this.category,
//     this.enrolledPlan,
//     this.user,
//     this.businessCurrency,
//     this.invoiceLogo,
//     this.saleRoundingOption,
//     this.invoiceSize,
//     this.invoiceNoteLevel,
//     this.invoiceNote,
//     this.gratitudeMessage,
//     this.developByLevel,
//     this.developBy,
//     this.developByLink,
//   });
//
//   BusinessInfoData.fromJson(dynamic json) {
//     id = json['id'];
//     planSubscribeId = json['plan_subscribe_id'];
//     businessCategoryId = json['business_category_id'];
//     affiliatorId = json['affiliator_id'];
//     companyName = json['companyName'];
//     willExpire = json['will_expire'];
//     address = json['address'];
//     phoneNumber = json['phoneNumber'];
//     pictureUrl = json['pictureUrl'];
//     subscriptionDate = json['subscriptionDate'];
//     remainingShopBalance = json['remainingShopBalance'];
//     shopOpeningBalance = json['shopOpeningBalance'];
//     vatNo = json['vat_no'];
//     vatName = json['vat_name'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     category = json['category'] != null ? Category.fromJson(json['category']) : null;
//     enrolledPlan = json['enrolled_plan'] != null ? EnrolledPlan.fromJson(json['enrolled_plan']) : null;
//     user = json['user'] != null ? User.fromJson(json['user']) : null;
//     businessCurrency = json['business_currency'] != null ? BusinessCurrency.fromJson(json['business_currency']) : null;
//     invoiceLogo = json['invoice_logo'];
//     saleRoundingOption = json['sale_rounding_option'];
//     invoiceSize = json['invoice_size'];
//     invoiceNoteLevel = json['invoice_note_level'];
//     invoiceNote = json['invoice_note'];
//     gratitudeMessage = json['gratitude_message'];
//     developByLevel = json['develop_by_level'];
//     developBy = json['develop_by'];
//     developByLink = json['develop_by_link'];
//   }
//   num? id;
//   num? planSubscribeId;
//   num? businessCategoryId;
//   num? affiliatorId;
//   String? companyName;
//   String? willExpire;
//   String? address;
//   String? phoneNumber;
//   String? pictureUrl;
//   String? subscriptionDate;
//   num? remainingShopBalance;
//   num? shopOpeningBalance;
//   dynamic vatNo;
//   String? vatName;
//   String? createdAt;
//   String? updatedAt;
//   Category? category;
//   EnrolledPlan? enrolledPlan;
//   User? user;
//   BusinessCurrency? businessCurrency;
//   String? invoiceLogo;
//   String? saleRoundingOption;
//   dynamic invoiceSize;
//   String? invoiceNoteLevel;
//   String? invoiceNote;
//   String? gratitudeMessage;
//   String? developByLevel;
//   String? developBy;
//   String? developByLink;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['plan_subscribe_id'] = planSubscribeId;
//     map['business_category_id'] = businessCategoryId;
//     map['affiliator_id'] = affiliatorId;
//     map['companyName'] = companyName;
//     map['will_expire'] = willExpire;
//     map['address'] = address;
//     map['phoneNumber'] = phoneNumber;
//     map['pictureUrl'] = pictureUrl;
//     map['subscriptionDate'] = subscriptionDate;
//     map['remainingShopBalance'] = remainingShopBalance;
//     map['shopOpeningBalance'] = shopOpeningBalance;
//     map['vat_no'] = vatNo;
//     map['vat_name'] = vatName;
//     map['created_at'] = createdAt;
//     map['updated_at'] = updatedAt;
//     if (category != null) {
//       map['category'] = category?.toJson();
//     }
//     if (enrolledPlan != null) {
//       map['enrolled_plan'] = enrolledPlan?.toJson();
//     }
//     // if (user != null) {
//     //   map['user'] = user?.toJson();
//     // }
//     if (businessCurrency != null) {
//       map['business_currency'] = businessCurrency?.toJson();
//     }
//     map['invoice_logo'] = invoiceLogo;
//     map['sale_rounding_option'] = saleRoundingOption;
//     map['invoice_size'] = invoiceSize;
//     map['invoice_note_level'] = invoiceNoteLevel;
//     map['invoice_note'] = invoiceNote;
//     map['gratitude_message'] = gratitudeMessage;
//     map['develop_by_level'] = developByLevel;
//     map['develop_by'] = developBy;
//     map['develop_by_link'] = developByLink;
//     return map;
//   }
// }
//
// class BusinessCurrency {
//   BusinessCurrency({
//     this.id,
//     this.name,
//     this.code,
//     this.symbol,
//     this.position,
//   });
//
//   BusinessCurrency.fromJson(dynamic json) {
//     id = json['id'];
//     name = json['name'];
//     code = json['code'];
//     symbol = json['symbol'];
//     position = json['position'];
//   }
//   num? id;
//   String? name;
//   String? code;
//   String? symbol;
//   String? position;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['name'] = name;
//     map['code'] = code;
//     map['symbol'] = symbol;
//     map['position'] = position;
//     return map;
//   }
// }
//
// class User {
//   User({
//     this.id,
//     this.name,
//     this.role,
//     required this.visibility,
//     this.lang,
//     this.email,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     final rawVisibility = json['visibility'];
//     Map<String, Map<String, String>> parsedVisibility = {};
//
//     if (rawVisibility is Map<String, dynamic>) {
//       parsedVisibility = rawVisibility.map((moduleKey, perms) {
//         if (perms is Map<String, dynamic>) {
//           return MapEntry(
//             moduleKey,
//             perms.map((permKey, value) => MapEntry(permKey, value.toString())),
//           );
//         }
//         return MapEntry(moduleKey, <String, String>{});
//       });
//     }
//     return User(
//       id: json['id'],
//       email: json['email'],
//       name: json['name'],
//       role: json['role'],
//       lang: json['lang'],
//       visibility: parsedVisibility,
//     );
//   }
//
//   /// 🔍 Get all enabled permissions in format: `module.permission`
//   List<String> getAllPermissions() {
//     final List<String> permissions = [];
//     visibility.forEach((module, perms) {
//       perms.forEach((action, value) {
//         if (value == "1") {
//           permissions.add('$module.$action');
//         }
//       });
//     });
//     return permissions;
//   }
//
//   num? id;
//   String? name;
//   String? role;
//   final Map<String, Map<String, String>> visibility;
//   dynamic lang;
//   String? email;
// }
//
// class EnrolledPlan {
//   EnrolledPlan({
//     this.id,
//     this.planId,
//     this.businessId,
//     this.price,
//     this.duration,
//     this.plan,
//   });
//
//   EnrolledPlan.fromJson(dynamic json) {
//     id = json['id'];
//     planId = json['plan_id'];
//     businessId = json['business_id'];
//     price = json['price'];
//     duration = json['duration'];
//     plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
//   }
//   num? id;
//   num? planId;
//   num? businessId;
//   num? price;
//   num? duration;
//   Plan? plan;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['plan_id'] = planId;
//     map['business_id'] = businessId;
//     map['price'] = price;
//     map['duration'] = duration;
//     if (plan != null) {
//       map['plan'] = plan?.toJson();
//     }
//     return map;
//   }
// }
//
// class Plan {
//   Plan({
//     this.id,
//     this.subscriptionName,
//   });
//
//   Plan.fromJson(dynamic json) {
//     id = json['id'];
//     subscriptionName = json['subscriptionName'];
//   }
//   num? id;
//   String? subscriptionName;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['subscriptionName'] = subscriptionName;
//     return map;
//   }
// }
//
// class Category {
//   Category({
//     this.id,
//     this.name,
//   });
//
//   Category.fromJson(dynamic json) {
//     id = json['id'];
//     name = json['name'];
//   }
//   num? id;
//   String? name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['name'] = name;
//     return map;
//   }
// }
