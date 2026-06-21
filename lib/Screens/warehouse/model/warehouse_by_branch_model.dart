class WarehouseByBranchModel {
  List<WarehouseByBranchData>? data;

  WarehouseByBranchModel({this.data});

  WarehouseByBranchModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <WarehouseByBranchData>[];
      json['data'].forEach((v) {
        data!.add(WarehouseByBranchData.fromJson(v));
      });
    }
  }
}

class WarehouseByBranchData {
  int? id;
  String? name;

  WarehouseByBranchData({this.id, this.name});

  WarehouseByBranchData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
