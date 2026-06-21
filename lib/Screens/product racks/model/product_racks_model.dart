// File: product_rack_model.dart (Updated with actual API structure)

class RackListModel {
  RackListModel({
    this.message,
    this.data,
  });

  RackListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(RackData.fromJson(v));
      });
    }
  }
  String? message;
  List<RackData>? data;
}

class RackData {
  RackData({
    this.id,
    this.name,
    this.status,
    this.shelves, // List of Shelf objects (for reading/display)
  });

  RackData.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];

    // Process the nested 'shelves' list
    if (json['shelves'] is List) {
      shelves = (json['shelves'] as List).map((e) => Shelf.fromJson(e)).toList();
    }
  }
  num? id;
  String? name;
  dynamic status;
  List<Shelf>? shelves; // For UI display
}

// Model for the nested Shelf objects returned inside a Rack
class Shelf {
  Shelf({this.id, this.name});

  // NOTE: We ignore the 'pivot' field in the model as it's not needed for UI/submission
  Shelf.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }
  num? id;
  String? name;
}
