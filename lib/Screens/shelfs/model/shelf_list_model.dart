// File: product_shelf_model.dart

class ShelfListModel {
  ShelfListModel({
    this.message,
    this.data,
  });

  ShelfListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      // Handles list of shelves in the 'data' key
      json['data'].forEach((v) {
        data?.add(ShelfData.fromJson(v));
      });
    }
  }
  String? message;
  List<ShelfData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ShelfData {
  ShelfData({
    this.id,
    this.name,
    this.description, // Keeping it nullable in model as API might return it
    this.status,
  });

  ShelfData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    status = json['status'];
  }
  num? id;
  String? name;
  String? description; // Nullable string
  dynamic status; // Use dynamic to handle potential num (1/0) or String ("Active")

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['description'] = description;
    map['status'] = status;
    return map;
  }
}
