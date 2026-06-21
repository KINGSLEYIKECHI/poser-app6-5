import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/product_racks_model.dart';
import '../repo/product_racks_repo.dart';

final repo = RackRepo();
final rackListProvider = FutureProvider<RackListModel>((ref) => repo.fetchAllRacks());
