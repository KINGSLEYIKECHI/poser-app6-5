import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../pdf_report/loss_profit_report/loss_profit_pdf.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../core/theme/_app_colors.dart';
import '../../currency.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Home/home.dart';
import '../../service/check_user_role_permission_provider.dart';

class LossProfitScreen extends ConsumerStatefulWidget {
  const LossProfitScreen({super.key, this.fromReport});

  final bool? fromReport;

  @override
  ConsumerState<LossProfitScreen> createState() => _LossProfitScreenState();
}

class _LossProfitScreenState extends ConsumerState<LossProfitScreen> {
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
      ref.refresh(filteredSaleProvider(filter));
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

    return WillPopScope(
      onWillPop: () async {
        return await const Home().launch(context, isNewTask: true);
      },
      child: Consumer(
        builder: (_, ref, watch) {
          final providerData = ref.watch(filteredLossProfitProvider(_getDateRangeFilter()));
          final permissionService = PermissionService(ref);
          final personalData = ref.watch(businessInfoProvider);
          return personalData.when(
            data: (business) {
              return providerData.when(
                data: (transaction) {
                  return GlobalPopup(
                    child: Scaffold(
                      backgroundColor: kWhite,
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        title: Text(
                          (widget.fromReport ?? false) ? _lang.profitAndLoss : _lang.profitAndLoss,
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              if ((transaction.expenseSummary?.isNotEmpty == true) ||
                                  (transaction.incomeSummary?.isNotEmpty == true)) {
                                generateLossProfitReportPdf(context, transaction, business, fromDate, toDate);
                              } else {
                                EasyLoading.showError(_lang.listIsEmpty);
                              }
                            },
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
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
                                              fromDate != null ? DateFormat('dd MMM yyyy').format(fromDate!) : 'From',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            l.S.of(context).to,
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
                                                toDate != null ? DateFormat('dd MMM yyyy').format(toDate!) : 'To',
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
                        iconTheme: const IconThemeData(color: Colors.black),
                        centerTitle: true,
                        elevation: 0.0,
                      ),
                      body: RefreshIndicator(
                        onRefresh: _refreshFilteredProvider,
                        child: permissionService.hasPermission(Permit.lossProfitsRead.value)
                            ? Column(
                                children: [
                                  // Overview Containers
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 77,
                                            width: 160,
                                            decoration: BoxDecoration(
                                              color: kSuccessColor.withValues(alpha: 0.1),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "$currency${formatPointNumber(transaction.cartGrossProfit ?? 0, addComma: true)}",
                                                  style: _theme.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    // Gross Profit Negative Check
                                                    color: (transaction.cartGrossProfit ?? 0) < 0 ? Colors.red : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _lang.grossProfit,
                                                  style: _theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: kPeraColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Container(
                                            height: 77,
                                            width: 160,
                                            decoration: BoxDecoration(
                                              color: DAppColors.kError.withValues(alpha: 0.1),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "$currency${formatPointNumber(transaction.totalCardExpense ?? 0, addComma: true)}",
                                                  style: _theme.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    // Expense Negative Check
                                                    color: (transaction.totalCardExpense ?? 0) < 0 ? Colors.red : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _lang.expense,
                                                  style: _theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: kPeraColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Container(
                                            height: 77,
                                            width: 160,
                                            decoration: BoxDecoration(
                                              color: DAppColors.kError.withValues(alpha: 0.1),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "$currency${formatPointNumber(transaction.cardNetProfit ?? 0, addComma: true)}",
                                                  style: _theme.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    // Net Profit Negative Check
                                                    color: (transaction.cardNetProfit ?? 0) < 0 ? Colors.red : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _lang.netProfit,
                                                  style: _theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: kPeraColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Data
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        // Income Type
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Header
                                            DefaultTextStyle.merge(
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffF7F7F7),
                                                  border: Border(bottom: Divider.createBorderSide(context)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: Text(_lang.name)),
                                                    Flexible(
                                                        flex: 0, child: Text(_lang.amount, textAlign: TextAlign.end)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Sub Header
                                            DefaultTextStyle.merge(
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                width: double.maxFinite,
                                                decoration: BoxDecoration(
                                                  border: Border(bottom: Divider.createBorderSide(context)),
                                                ),
                                                child: Text(_lang.incomeType),
                                              ),
                                            ),

                                            // Item
                                            ...?transaction.incomeSummary?.map((incomeType) {
                                              return DefaultTextStyle.merge(
                                                style: _theme.textTheme.bodyMedium,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border(bottom: Divider.createBorderSide(context)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: Text(incomeType.type ?? 'N/A')),
                                                      Flexible(
                                                        flex: 0,
                                                        child: Text(
                                                          "$currency${formatPointNumber(incomeType.totalIncome ?? 0, addComma: true)}",
                                                          textAlign: TextAlign.end,
                                                          // Individual Income Negative Check
                                                          style: TextStyle(
                                                              color: (incomeType.totalIncome ?? 0) < 0
                                                                  ? Colors.red
                                                                  : null),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),

                                            // Footer
                                            DefaultTextStyle.merge(
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                // Gross Income Footer Negative Check
                                                color: (transaction.grossIncomeProfit ?? 0) < 0
                                                    ? Colors.red
                                                    : const Color(0xff06A82F),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff06A82F).withValues(alpha: 0.15),
                                                  border: Border(bottom: Divider.createBorderSide(context)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: Text(_lang.grossProfit)),
                                                    Flexible(
                                                      flex: 0,
                                                      child: Text(
                                                        "$currency${formatPointNumber(transaction.grossIncomeProfit ?? 0, addComma: true)}",
                                                        textAlign: TextAlign.end,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Expense Type
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Sub Header
                                            DefaultTextStyle.merge(
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                width: double.maxFinite,
                                                decoration: BoxDecoration(
                                                  border: Border(bottom: Divider.createBorderSide(context)),
                                                ),
                                                child: Text(_lang.expensesType),
                                              ),
                                            ),

                                            // Item
                                            ...?transaction.expenseSummary?.map((incomeType) {
                                              return DefaultTextStyle.merge(
                                                style: _theme.textTheme.bodyMedium,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    border: Border(bottom: Divider.createBorderSide(context)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: Text(incomeType.type ?? 'N/A')),
                                                      Flexible(
                                                        flex: 0,
                                                        child: Text(
                                                          "$currency${formatPointNumber(incomeType.totalExpense ?? 0, addComma: true)}",
                                                          textAlign: TextAlign.end,
                                                          // Individual Expense Negative Check
                                                          style: TextStyle(
                                                              color: (incomeType.totalExpense ?? 0) < 0
                                                                  ? Colors.red
                                                                  : null),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),

                                            // Footer
                                            DefaultTextStyle.merge(
                                              style: _theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                // Total Expense Footer Negative Check
                                                color: (transaction.totalExpenses ?? 0) < 0
                                                    ? Colors.red
                                                    : const Color(0xffC52127),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffC52127).withValues(alpha: 0.15),
                                                  border: Border(bottom: Divider.createBorderSide(context)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: Text(_lang.totalExpense)),
                                                    Flexible(
                                                      flex: 0,
                                                      child: Text(
                                                        "$currency${formatPointNumber(transaction.totalExpenses ?? 0, addComma: true)}",
                                                        textAlign: TextAlign.end,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Center(child: PermitDenyWidget()),
                      ),
                      bottomNavigationBar: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          '${_lang.netProfit} (${_lang.income} - ${_lang.expense}) =$currency${formatPointNumber(transaction.netProfit ?? 0, addComma: true)}',
                          textAlign: TextAlign.center,
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            // Net Profit Negative Check in Bottom Bar
                            color: (transaction.netProfit ?? 0) < 0 ? Colors.red : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                error: (e, stack) => Center(child: Text(e.toString())),
                loading: () => Center(child: CircularProgressIndicator()),
              );
            },
            error: (e, stack) {
              print('-----------------${'I Found the error'}-----------------');
              return Center(child: Text(e.toString()));
            },
            loading: () => Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
