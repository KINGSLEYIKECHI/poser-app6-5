class CategoryModel {
  CategoryModel({
    this.id,
    this.categoryName,
    this.businessId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  CategoryModel.fromJson(dynamic json) {
    id = json['id'];
    categoryName = json['categoryName'];
    businessId = json['business_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? categoryName;
  num? businessId;
  num? status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['categoryName'] = categoryName;
    map['business_id'] = businessId;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
