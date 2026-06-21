class UserRoleListModelNew {
  final num? id;
  final int? businessId;
  final int? activeBranchId;
  final int? branchId;
  final String? email;
  final String? name;
  final String? role;
  final String? phone;
  final String? image;
  final String? lang;
  final num? isVerified;

  final Map<String, Map<String, String>> visibility;
  final Branch? branch;

  UserRoleListModelNew({
    this.id,
    this.businessId,
    this.activeBranchId,
    this.branchId,
    this.email,
    this.name,
    this.role,
    this.phone,
    this.image,
    this.lang,
    this.isVerified,
    required this.visibility,
    this.branch,
  });

  factory UserRoleListModelNew.fromJson(Map<String, dynamic> json) {
    final rawVisibility = json['visibility'];
    Map<String, Map<String, String>> parsedVisibility = {};

    if (rawVisibility is Map<String, dynamic>) {
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

    return UserRoleListModelNew(
      id: json['id'],
      businessId: json['business_id'],
      activeBranchId: json['active_branch_id'],
      branchId: json['branch_id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      image: json['image'],
      lang: json['lang'],
      isVerified: json['is_verified'],
      visibility: parsedVisibility,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }

  List<String> getAllPermissions() {
    final List<String> permissions = [];
    visibility.forEach((module, perms) {
      perms.forEach((action, value) {
        if (value == "1") {
          permissions.add('$module.$action');
        }
        // permissions.add('$module.$action');
      });
    });
    return permissions;
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
