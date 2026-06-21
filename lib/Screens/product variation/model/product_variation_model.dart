
class VariationListModel {
  VariationListModel({
    this.message,
    this.data,
  });

  VariationListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(VariationData.fromJson(v));
      });
    }
  }
  String? message;
  List<VariationData>? data;
}

class VariationData {
  VariationData({
    this.id,
    this.name,
    this.status,
    this.values,
  });

  VariationData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];

    if (json['values'] is List) {
      values = List<String>.from(json['values']);
    }
  }
  num? id;
  String? name;
  num? status; // 1 or 0
  List<String>? values;
}
