import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/shelf_list_model.dart';
import '../repo/shelf_repo.dart';

// Instantiate the repository
final repo = ShelfRepo();

final shelfListProvider = FutureProvider.autoDispose<ShelfListModel>((ref) {
  return repo.fetchAllShelves();
});
