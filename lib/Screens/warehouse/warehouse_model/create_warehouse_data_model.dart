class CreateWareHouseModel {
  final String? warehouseId;
  final String name;
  final String phone;
  final String email;
  final String address;

  CreateWareHouseModel({
    this.warehouseId,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  // Convert model to Map for API request body
  Map<String, String> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      if (warehouseId != null) 'warehouse_id': warehouseId!,
    };
  }
}
