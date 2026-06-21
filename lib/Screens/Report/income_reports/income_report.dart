import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Income/Providers/all_income_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/pdf_report/income_report/income_report_pdf.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../pdf_report/income_report/income_report_excel.dart';
import '../../../service/check_actions_when_no_branch.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../Income/add_income.dart';

class IncomeReport extends ConsumerStatefulWidget {
  const IncomeReport({super.key, this.fromIncomeReport});

  final bool? fromIncomeReport;

  @override
  ConsumerState<IncomeReport> createState() => _IncomeReportState();
}

class _IncomeReportState extends ConsumerState<IncomeReport> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  final Map<String, String> dateOptions = {
    'today': l.S.current.today,
    'yesterday': l.S.current.yesterday,
    'last_seven_days': l.S.current.last7Days,
    'last_thirty_days': l.S.current.last30Days,
    'current_month': l.S.current.currentMonth,
    'last_month': l.S.current.lastMonth,
    'current_year': l.S.current.currentYear,
    'custom_date': l.S.current.customerDate,
  };

  String selectedTime = 'today';
  bool _isRefreshing = false;
  bool _showCustomDatePickers = false;

  DateTime? fromDate;
  DateTime? toDate;
  String searchCustomer = '';

  /// Generates the date range string for the provider
  FilterModel _getDateRangeFilter() {
    if (_showCustomDatePickers && fromDate != null && toDate != null) {
      return FilterModel(
        duration: 'custom_date',
        fromDate: DateFormat('yyyy-MM-dd', 'en_US').format(fromDate!),
        toDate: DateFormat('yyyy-MM-dd', 'en_US').format(toDate!),
      );
    } else {
      return FilterModel(duration: selectedTime.toLowerCase());
    }
  }

  Future<void> _selectDate({
    required BuildContext context,
    required bool isFrom,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      initialDate: isFrom ? fromDate ?? DateTime.now() : toDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          toDate = picked;
          toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });

      if (fromDate != null && toDate != null) _refreshFilteredProvider();
    }
  }

  Future<void> _refreshFilteredProvider() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final filter = _getDateRangeFilter();
      ref.refresh(filteredIncomeProvider(filter));
      await Future.delayed(const Duration(milliseconds: 300)); // small delay
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  void _updateDateUI(DateTime? from, DateTime? to) {
    setState(() {
      fromDate = from;
      toDate = to;

      fromDateController.text = from != null ? DateFormat('yyyy-MM-dd').format(from) : '';

      toDateController.text = to != null ? DateFormat('yyyy-MM-dd').format(to) : '';
    });
  }

  void _setDateRangeFromDropdown(String value) {
    final now = DateTime.now();

    switch (value) {
      case 'today':
        _updateDateUI(now, now);
        break;

      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        _updateDateUI(y, y);
        break;

      case 'last_seven_days':
        _updateDateUI(
          now.subtract(const Duration(days: 6)),
          now,
        );
        break;

      case 'last_thirty_days':
        _updateDateUI(
          now.subtract(const Duration(days: 29)),
          now,
        );
        break;

      case 'current_month':
        _updateDateUI(
          DateTime(now.year, now.month, 1),
          now,
        );
        break;

      case 'last_month':
        final first = DateTime(now.year, now.month - 1, 1);
        final last = DateTime(now.year, now.month, 0);
        _updateDateUI(first, last);
        break;

      case 'current_year':
        _updateDateUI(
          DateTime(now.year, 1, 1),
          now,
        );
        break;

      case 'custom_date':
        // Custom: User will select manually
        _updateDateUI(null, null);
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    // Set initial From and To date = TODAY
    fromDate = now;
    toDate = now;

    fromDateController.text = DateFormat('yyyy-MM-dd').format(now);
    toDateController.text = DateFormat('yyyy-MM-dd').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    return Consumer(builder: (context, ref, __) {
      final incomeData = ref.watch(filteredIncomeProvider(_getDateRangeFilter()));
      final personalData = ref.watch(businessInfoProvider);
      final permissionService = PermissionService(ref);
      return personalData.when(
        data: (business) {
          return GlobalPopup(
            child: incomeData.when(
              data: (allIncomes) {
                final filteredIncomes = allIncomes.where((incomes) {
                  final incomeFor = incomes.incomeFor?.toLowerCase() ?? '';
                  return incomeFor.contains(searchCustomer);
                }).toList();

                final toIncomes = filteredIncomes.fold<num>(0, (sum, income) => sum + (income.amount ?? 0));
                return Scaffold(
                  backgroundColor: kWhite,
                  appBar: AppBar(
                    title: Text(l.S.of(context).incomeReport),
                    iconTheme: const IconThemeData(color: Colors.black),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                    actions: [
                      IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (!permissionService.hasPermission(Permit.incomeReportsRead.value)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(l.S.of(context).incomeReportPermission),
                              ),
                            );
                            return;
                          }
                          if (allIncomes.isNotEmpty) {
                            generateIncomeReportPdf(context, allIncomes, business, fromDate, toDate, selectedTime);
                          } else {
                            EasyLoading.showInfo(l.S.of(context).genPdfWarn);
                          }
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedPdf01,
                          color: kSecondayColor,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (!permissionService.hasPermission(Permit.incomeReportsRead.value)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(l.S.of(context).incomeReportPermission),
                              ),
                            );
                            return;
                          }
                          if (filteredIncomes.isNotEmpty) {
                            generateIncomeReportExcel(
                                context, filteredIncomes, business, selectedTime, fromDate, toDate);
                          } else {
                            EasyLoading.showInfo(l.S.of(context).genPdfWarn);
                          }
                        },
                        icon: SvgPicture.asset('assets/excel.svg'),
                      ),
                      SizedBox(width: 8),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: Column(
                        children: [
                          Divider(thickness: 1, color: kBottomBorder, height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Icon(IconlyLight.calendar, color: kPeraColor, size: 20),
                                      SizedBox(width: 3),
                                      GestureDetector(
                                        onTap: () {
                                          if (_showCustomDatePickers) {
                                            _selectDate(context: context, isFrom: true);
                                          }
                                        },
                                        child: Text(
                                          fromDate != null ? DateFormat('dd MMM yyyy').format(fromDate!) : _lang.from,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        _lang.to,
                                        style: _theme.textTheme.titleSmall,
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_showCustomDatePickers) {
                                              _selectDate(context: context, isFrom: false);
                                            }
                                          },
                                          child: Text(
                                            toDate != null ? DateFormat('dd MMM yyyy').format(toDate!) : _lang.to,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 2),
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Container(
                                    height: 1,
                                    width: 20,
                                    color: kSubPeraColor,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      iconSize: 20,
                                      value: selectedTime,
                                      isExpanded: true,
                                      items: dateOptions.entries.map((entry) {
                                        return DropdownMenuItem<String>(
                                          value: entry.key,
                                          child: Text(
                                            entry.value,
                                            overflow: TextOverflow.ellipsis,
                                            style: _theme.textTheme.bodyMedium,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value == null) return;

                                        setState(() {
                                          selectedTime = value;
                                          _showCustomDatePickers = value == 'custom_date';
                                        });

                                        if (value != 'custom_date') {
                                          _setDateRangeFromDropdown(value);
                                          _refreshFilteredProvider();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1, color: kBottomBorder, height: 1),
                        ],
                      ),
                    ),
                  ),
                  body: RefreshIndicator(
                    onRefresh: () => _refreshFilteredProvider(),
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ///__________income_data_table____________________________________________
                          if (permissionService.hasPermission(Permit.incomeReportsRead.value)) ...{
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: l.S.of(context).searchWith,
                                    ),
                                    onChanged: (value) => setState(() {
                                      searchCustomer = value.toLowerCase().trim();
                                    }),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: context.width(),
                                  padding: EdgeInsetsDirectional.symmetric(vertical: 13, horizontal: 24),
                                  height: 50,
                                  decoration: const BoxDecoration(color: kMainColor50),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l.S.of(context).incomeFor,
                                          style: _theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          l.S.of(context).date,
                                          style: _theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          l.S.of(context).amount,
                                          style: _theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (filteredIncomes.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: Text(l.S.of(context).noData),
                                ),
                              )
                            else
                              SizedBox(
                                width: context.width(),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredIncomes.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) {
                                    final income = filteredIncomes[index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 24),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      income.incomeFor ?? '',
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      income.category?.categoryName ?? '',
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: _theme.textTheme.bodySmall?.copyWith(
                                                        color: kPeraColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  DateFormat.yMMMd().format(DateTime.parse(income.incomeDate ?? '')),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '$currency${income.amount?.toStringAsFixed(2)}',
                                                  textAlign: TextAlign.end,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 1,
                                          color: Colors.black12,
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                          } else
                            Center(child: PermitDenyWidget()),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: widget.fromIncomeReport == true
                      ? Visibility(
                          visible: permissionService.hasPermission(Permit.incomeReportsRead.value),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: kMainColor50),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l.S.of(context).total}:',
                                  style: _theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$currency${toIncomes.toStringAsFixed(2)}',
                                  style: _theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 117,
                            child: Column(
                              children: [
                                Visibility(
                                  visible: permissionService.hasPermission(Permit.incomeReportsRead.value),
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(color: kMainColor50),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${l.S.of(context).total}:',
                                          style: _theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '$currency${toIncomes.toStringAsFixed(2)}',
                                          style: _theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),

                                ///________button________________________________________________
                                personalData.when(data: (details) {
                                  return ElevatedButton(
                                    onPressed: () async {
                                      bool result = await checkActionWhenNoBranch(ref: ref, context: context);
                                      if (!result) {
                                        return;
                                      }
                                      bool result2 = await const AddIncome().launch(context);

                                      if (result2) {
                                        await _refreshFilteredProvider();
                                      }
                                    },
                                    child: Text(l.S.of(context).addIncome),
                                  );
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                })
                              ],
                            ),
                          ),
                        ),
                );
              },
              error: (error, stackTrace) => Center(child: Text(error.toString())),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      );
    });
  }
}
