import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/DashBoard/global_container.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../Provider/profile_provider.dart';
import '../../http_client/custome_http_client.dart';
import '../../widgets/build_date_selector/build_date_selector.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'numeric_axis.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Map<String, String> dateOptions = {
    'today': lang.S.current.today,
    'yesterday': lang.S.current.yesterday,
    'last_seven_days': lang.S.current.last7Days,
    'last_thirty_days': lang.S.current.last30Days,
    'current_month': lang.S.current.currentMonth,
    'last_month': lang.S.current.lastMonth,
    'current_year': lang.S.current.currentYear,
    'custom_date': lang.S.current.customDate,
  };
  String selectedTime = 'today';
  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.refresh(dashboardInfoProvider(selectedTime.toLowerCase()));

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  bool _showCustomDatePickers = false; // Track if custom date pickers should be shown

  DateTime? fromDate;
  DateTime? toDate;

  String _getDateRangeString() {
    if (selectedTime != 'custom_date') {
      return selectedTime.toLowerCase();
    } else if (fromDate != null && toDate != null) {
      final formattedFrom = DateFormat('yyyy-MM-dd', 'en_US').format(fromDate!);
      final formattedTo = DateFormat('yyyy-MM-dd', 'en_US').format(toDate!);
      return 'custom_date&from_date=$formattedFrom&to_date=$formattedTo';
    } else {
      return 'custom_date'; // fallback
    }
  }

  Future<void> _selectedFormDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
      if (toDate != null) refreshData(ref);
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: fromDate ?? DateTime(2021),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
      if (fromDate != null) refreshData(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (_, ref, watch) {
      final dateRangeString = _getDateRangeString();
      final dashboardInfo = ref.watch(dashboardInfoProvider(dateRangeString));
      final permissionService = PermissionService(ref);
      return dashboardInfo.when(data: (dashboard) {
        final totalSales = dashboard.data!.sales!.fold<double>(
          0,
          (sum, item) => sum + (item.amount ?? 0),
        );

        final totalPurchase = dashboard.data!.purchases!.fold<double>(
          0,
          (sum, items) => sum + (items.amount ?? 0),
        );
        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            backgroundColor: kWhite,
            surfaceTintColor: kWhite,
            title: Text(lang.S.of(context).dashboard),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 120,
                  height: 32,
                  child: DropdownButtonFormField2<String>(
                    isExpanded: true,
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down, color: kPeraColor, size: 20),
                    ),
                    value: selectedTime,
                    items: dateOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: kPeraColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTime = value!;
                        _showCustomDatePickers = selectedTime == 'custom_date';

                        if (_showCustomDatePickers) {
                          fromDate = DateTime.now().subtract(const Duration(days: 7));
                          toDate = DateTime.now();
                        }

                        if (selectedTime != 'custom_date') {
                          refreshData(ref);
                        }
                      });
                    },
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 500,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: WidgetStateProperty.all<double>(6),
                        thumbVisibility: WidgetStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 6)),
                  ),
                ),
              )
            ],
            bottom: _showCustomDatePickers
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Column(
                      children: [
                        Divider(thickness: 1, color: kBottomBorder, height: 1),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => _selectedFormDate(context),
                                  child: buildDateSelector(
                                    prefix: 'From',
                                    date:
                                        fromDate != null ? DateFormat('dd MMMM yyyy').format(fromDate!) : 'Select Date',
                                    theme: theme,
                                  ),
                                ),
                                SizedBox(width: 5),
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Container(
                                    height: 1,
                                    width: 22,
                                    color: kSubPeraColor,
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () => _selectToDate(context),
                                  child: buildDateSelector(
                                    prefix: 'To',
                                    date: toDate != null ? DateFormat('dd MMMM yyyy').format(toDate!) : 'Select Date',
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : null,
          ),
          body: RefreshIndicator(
            onRefresh: () => refreshData(ref),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (permissionService.hasPermission(Permit.dashboardRead.value)) ...{
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.S.of(context).quickOver,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: kWhite,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  child: GlobalContainer(
                                    minVerticalPadding: 0,
                                    minTileHeight: 0,
                                    titlePadding: EdgeInsets.zero,
                                    // isShadow: true,
                                    textColor: true,
                                    title: lang.S.of(context).sales,
                                    subtitle: '$currency${formatAmount(totalSales.toString())}',
                                  ),
                                ),
                                Flexible(
                                  child: GlobalContainer(
                                    alainRight: true,
                                    minVerticalPadding: 0,
                                    minTileHeight: 0,
                                    // isShadow: true,
                                    textColor: true,
                                    titlePadding: EdgeInsets.zero,
                                    title: lang.S.of(context).purchased,
                                    subtitle: '$currency${formatAmount(totalPurchase.toString())}',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  child: GlobalContainer(
                                    minVerticalPadding: 0,
                                    textColor: true,
                                    minTileHeight: 0,
                                    titlePadding: EdgeInsets.zero,
                                    title: lang.S.of(context).income,
                                    subtitle: '$currency${formatAmount(dashboard.data?.totalIncome.toString() ?? '0')}',
                                  ),
                                ),
                                Flexible(
                                  child: GlobalContainer(
                                    alainRight: true,
                                    minVerticalPadding: 0,
                                    minTileHeight: 0,
                                    textColor: true,
                                    titlePadding: EdgeInsets.zero,
                                    title: lang.S.of(context).expense,
                                    subtitle:
                                        '$currency${formatAmount(dashboard.data?.totalExpense.toString() ?? '0')}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      ///---------------chart----------------------
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kWhite),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.S.of(context).tranSacOver,
                              //'Sales & Purchase Overview',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: kTitleColor),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                    text: TextSpan(
                                        text: '${lang.S.of(context).sales}: ',
                                        //'Sales',
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                      TextSpan(
                                          text: '$currency${formatAmount(totalSales.toString())}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w600, color: kTitleColor)),
                                    ])),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Icon(
                                  Icons.circle,
                                  color: kMainColor,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RichText(
                                    text: TextSpan(
                                        text: '${lang.S.of(context).purchase}: ',
                                        //'Purchase',
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                      TextSpan(
                                          text: '$currency${formatAmount(totalPurchase.toString())}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w600, color: kTitleColor)),
                                    ])),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: DashboardChart(
                                  model: dashboard,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: GlobalContainer(
                                  title: lang.S.of(context).totalDue,
                                  image: 'assets/duelist.svg',
                                  subtitle: '$currency ${formatAmount(dashboard.data!.totalDue.toString())}')),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                              child: GlobalContainer(
                                  title: lang.S.of(context).stockValue,
                                  image: 'assets/h_stock.svg',
                                  subtitle: "$currency${formatAmount(dashboard.data!.stockValue.toString())}"))
                        ],
                      ),

                      const SizedBox(height: 19),

                      ///_________Items_Category________________________
                      Row(
                        children: [
                          Expanded(
                              child: GlobalContainer(
                                  title: lang.S.of(context).item,
                                  image: 'assets/totalItem.svg',
                                  subtitle: formatAmount('${dashboard.data?.totalItems!.round().toString()}'))),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                              child: GlobalContainer(
                                  title: lang.S.of(context).categories,
                                  image: 'assets/purchaseLisst.svg',
                                  subtitle: formatAmount('${dashboard.data?.totalCategories?.round().toString()}')))
                        ],
                      ),
                      const SizedBox(height: 21),
                      Text(
                        lang.S.of(context).profitLoss,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                      ),

                      ///__________Total_Lass_and_Total_profit_____________________________________
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: GlobalContainer(
                                  title: lang.S.of(context).profit,
                                  image: 'assets/h_lossProfit.svg',
                                  subtitle: '$currency ${formatAmount(dashboard.data!.totalProfit.toString())}')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: GlobalContainer(
                                  title: lang.S.of(context).loss,
                                  image: 'assets/expense.svg',
                                  subtitle: '$currency ${formatAmount(dashboard.data!.totalLoss!.abs().toString())}'))
                        ],
                      ),
                    } else
                      Center(child: PermitDenyWidget()),
                  ],
                ),
              ),
            ),
          ),
        );
      }, error: (e, stack) {
        print('--------------print-------${e.toString()}-----------------');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  //'{No data found} $e',
                  '${lang.S.of(context).noDataFound} $e',
                  style: const TextStyle(color: kGreyTextColor, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }, loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      });
    });
  }
}
