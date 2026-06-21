import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/user_role_model_new.dart';
import '../Repo/user_role_repo.dart';

UserRoleRepo repo = UserRoleRepo();
final userRoleProvider = FutureProvider<List<UserRoleListModelNew>>((ref) => repo.fetchAllUsers());
