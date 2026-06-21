import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Repository/API/global_repo.dart';
import '../model/country_state_model.dart';

final globalRepositoryProvider = Provider((ref) => GlobalRepository());

// 1. Country List Provider
final countryListProvider = FutureProvider<List<CountryModel>>((ref) async {
  return ref.read(globalRepositoryProvider).getCountries();
});

// 2. State List Provider (Dependent on Country ID)
// Eta ekta family provider, jeta countryId parameter nay
final stateListProvider = FutureProvider.family<List<StateModel>, int>((ref, countryId) async {
  if (countryId == 0) return []; // kono country select na thakle empty list
  return ref.read(globalRepositoryProvider).getStates(countryId: countryId);
});
