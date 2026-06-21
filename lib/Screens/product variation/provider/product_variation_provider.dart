import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/product_variation_model.dart';
import '../repo/product_variation_repo.dart';

final repo = VariationRepo();
final variationListProvider = FutureProvider<VariationListModel>((ref) => repo.fetchAllVariations());
