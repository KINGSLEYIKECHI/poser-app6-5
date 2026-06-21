import '../../Customers/Model/parties_model.dart' as party_model;
import '../../../core/helpers/helpers.export.dart';
import '../../product_category/model/category_model.dart';
import 'product_model.dart' as product_model;

class ProductListResponse {
  final double totalStockValue;
  final List<product_model.Product> products;

  ProductListResponse({
    required this.totalStockValue,
    required this.products,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      totalStockValue: (json['total_stock_value'] as num).toDouble(),
      products: (json['data'] as List).map((item) => product_model.Product.fromJson(item)).toList(),
    );
  }
}

class PaginatedProductListModel<T extends product_model.Product> extends PaginatedListModel<T> {
  const PaginatedProductListModel({
    super.data,
    super.message,
    required this.totalStockValue,
  });

  final num totalStockValue;

  factory PaginatedProductListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedProductListModel(
      message: json['message'],
      totalStockValue: json['total_stock_value'] ?? 0,
      data: PaginatedData<T>.fromJson(json['data'], fromJsonT),
    );
  }
}

class PaginatedProductListFilter {
  final String? search;
  final party_model.Party? customer;
  final CategoryModel? category;
  final int? warehouseId;
  final String? priceSort;

  const PaginatedProductListFilter({
    this.search,
    this.customer,
    this.category,
    this.warehouseId,
    this.priceSort,
  });

  static const _stub = _Stub();

  PaginatedProductListFilter copyWith({
    Object? search = _stub,
    Object? customer = _stub,
    Object? category = _stub,
    Object? warehouseId = _stub,
    Object? priceSort = _stub,
  }) {
    return PaginatedProductListFilter(
      search: search is _Stub ? this.search : search as String?,
      customer: customer is _Stub ? this.customer : customer as party_model.Party?,
      category: category is _Stub ? this.category : category as CategoryModel?,
      warehouseId: warehouseId is _Stub ? this.warehouseId : warehouseId as int?,
      priceSort: priceSort is _Stub ? this.priceSort : priceSort as String?,
    );
  }

  Map<String, String> toJson() {
    return {
      if (search != null) "search": search!,
      if (category?.id != null) "category_id": category!.id!.toString(),
      if (warehouseId != null) "warehouse_id": warehouseId!.toString(),
      if (customer?.type != null) "party_type": customer!.type!.toString(),
      if (priceSort != null) "price_sort": priceSort!,
    };
  }
}

class _Stub {
  const _Stub();
}
