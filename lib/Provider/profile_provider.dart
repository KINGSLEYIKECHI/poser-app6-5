import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:mobile_pos/model/dashboard_overview_model.dart';

import '../Repository/API/business_info_repo.dart';
import '../model/todays_summary_model.dart';

final BusinessRepository businessRepository = BusinessRepository();
final businessInfoProvider = FutureProvider<BusinessInformationModel>((ref) async {
  return await BusinessRepository().fetchBusinessData();
});

final getExpireDateProvider = FutureProvider.family<void, WidgetRef>(
    (ref, widgetRef) => businessRepository.fetchSubscriptionExpireDate(ref: widgetRef));
final summaryInfoProvider = FutureProvider<TodaysSummaryModel>((ref) => businessRepository.fetchTodaySummaryData());
final dashboardInfoProvider = FutureProvider.family<DashboardOverviewModel, String>((ref, type) {
  return businessRepository.dashboardData(type);
});
