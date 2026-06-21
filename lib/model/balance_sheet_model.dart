class BalanceSheetModel {
  final num? totalAsset;
  final List<AssetData>? data;

  BalanceSheetModel({this.totalAsset, this.data});

  factory BalanceSheetModel.fromJson(Map<String, dynamic> json) {
    return BalanceSheetModel(
      totalAsset: json["total_asset"],
      data: json["asset_datas"] == null
          ? []
          : List<AssetData>.from(json["asset_datas"]!.map((x) => AssetData.fromJson(x))),
    );
  }
}

class AssetData {
  final int? id;
  final String? name;
  final num? amount;

  AssetData({this.id, this.name, this.amount});

  factory AssetData.fromJson(Map<String, dynamic> json) {
    final _source = json["source"]?.toString().trim().toLowerCase();
    final _productType = json["product_type"]?.toString().trim().toLowerCase();

    final String? _name = switch (_source) {
      "product" => json["productName"],
      "bank" => json["meta"]?["bank_name"] ?? "Bank Account",
      _ => null,
    };

    num _amount = 0;

    if (_source == "product") {
      if (_productType == "single" || _productType == "variation") {
        final stocks = json["stocks"];

        if (stocks is List && stocks.isNotEmpty) {
          final _firstStock = stocks.first as Map<String, dynamic>;

          final _purchasePrice = (_firstStock["productPurchasePrice"] as num?) ?? 0;
          final _stockQty = (_firstStock["productStock"] as num?) ?? 0;

          _amount = _purchasePrice * _stockQty;
        }
      } else if (_productType == "combo") {
        final comboProducts = json["combo_products"];

        if (comboProducts is List) {
          _amount = comboProducts.fold<num>(0, (sum, item) {
            if (item is Map<String, dynamic>) {
              final _price = (item["purchase_price"] as num?) ?? 0;
              final _qty = (item["quantity"] as num?) ?? 0;
              return sum + (_price * _qty);
            }
            return sum;
          });
        }
      }
    } else if (_source == "bank") {
      _amount = (json["balance"] as num?) ?? 0;
    }

    return AssetData(
      id: json["id"],
      name: _name,
      amount: _amount,
    );
  }
}
