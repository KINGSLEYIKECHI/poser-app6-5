import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Products/Model/product_model.dart';

import '../Screens/Products/Model/product_total_stock_model.dart';
import '../Screens/Products/Repo/product_repo.dart';

ProductRepo productRepo = ProductRepo();
final productProvider = FutureProvider.autoDispose<List<Product>>((ref) => productRepo.fetchAllProducts());
final fetchProductDetails = FutureProvider.family.autoDispose<Product, String>((ref, id) {
  return productRepo.fetchProductDetails(productID: id);
});

final productPaginatedListProvider =
    FutureProvider.family.autoDispose<PaginatedProductListModel, PaginatedProductListFilter>(
  (_, filter) => productRepo.getPaginatedProducts(filter: filter),
);
