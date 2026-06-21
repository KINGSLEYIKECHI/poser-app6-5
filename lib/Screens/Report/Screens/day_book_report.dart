import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl; // Alias for date formatting inside list
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../pdf_report/transactions/daybook_report_pdf.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../all_transaction/model/transaction_model.dart';
import '../../all_transaction/provider/transacton_provider.dart';

class DayBookReport extends ConsumerStatefulWidget {
  const DayBookReport({super.key});

  @override
  DayBookReportState createState() => DayBookReportState();
}

class DayBookReportState extends ConsumerState<DayBookReport> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Logic to switch between Credit/Debit in the list
  final selectedTransactionTypeNotifier = ValueNotifier<String>('credit');

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

  /// Generates the date range string for the provider
  TransactionFilteredModel _getDateRangeFilter() {
    if (_showCustomDatePickers && fromDate != null && toDate != null) {
      return TransactionFilteredModel(
        duration: 'custom_date',
        fromDate: DateFormat('yyyy-MM-dd', 'en_US').format(fromDate!),
        toDate: DateFormat('yyyy-MM-dd', 'en_US').format(toDate!),
      );
    } else {
      // For predefined ranges (today, yesterday, etc.)
      return TransactionFilteredModel(
        duration: selectedTime.toLowerCase(),
      );
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

      // If custom date is selected and both dates are present, refresh
      if (selectedTime == 'custom_date' && fromDate != null && toDate != null) {
        _refreshFilteredProvider();
      }
    }
  }

  Future<void> _refreshFilteredProvider() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final filter = _getDateRangeFilter();
      ref.refresh(filteredTransactionProvider(filter));
      await Future.delayed(const Duration(milliseconds: 300));
    } finally {
      _isRefreshing = false;
    }
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
        _updateDateUI(now.subtract(const Duration(days: 6)), now);
        break;
      case 'last_thirty_days':
        _updateDateUI(now.subtract(const Duration(days: 29)), now);
        break;
      case 'current_month':
        _updateDateUI(DateTime(now.year, now.month, 1), now);
        break;
      case 'last_month':
        final first = DateTime(now.year, now.month - 1, 1);
        final last = DateTime(now.year, now.month, 0);
        _updateDateUI(first, last);
        break;
      case 'current_year':
        _updateDateUI(DateTime(now.year, 1, 1), now);
        break;
      case 'custom_date':
        // Dates stay as they are, user picks manually
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    fromDate = now;
    toDate = now;
    fromDateController.text = DateFormat('yyyy-MM-dd').format(now);
    toDateController.text = DateFormat('yyyy-MM-dd').format(now);
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);

    return Consumer(
      builder: (context, ref, __) {
        final filter = _getDateRangeFilter();
        final providerData = ref.watch(filteredTransactionProvider(filter));
        final personalData = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);

        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(_lang.dayBook),
              backgroundColor: Colors.white,
              elevation: 0.0,
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              actions: [
                personalData.when(
                  data: (business) {
                    return providerData.when(
                      data: (transaction) {
                        return Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (transaction.data?.isNotEmpty == true) {
                                  // Using DayBook PDF generator
                                  generateDayBookReportPdf(context, transaction, business, fromDate, toDate);
                                } else {
                                  EasyLoading.showError(_lang.listIsEmpty);
                                }
                              },
                              icon: const HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                            ),
                            // IconButton(
                            //   padding: EdgeInsets.zero,
                            //   onPressed: () {
                            //     // Placeholder for Excel or other actions
                            //     EasyLoading.showInfo('Excel export not implemented yet');
                            //   },
                            //   icon: SvgPicture.asset('assets/excel.svg'),
                            // ),
                            const SizedBox(width: 8),
                          ],
                        );
                      },
                      error: (e, stack) => Center(child: Text(e.toString())),
                      loading: SizedBox.shrink,
                    );
                  },
                  error: (e, stack) => Center(child: Text(e.toString())),
                  loading: SizedBox.shrink,
                ),
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
                                const Icon(IconlyLight.calendar, color: kPeraColor, size: 20),
                                const SizedBox(width: 3),
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
                                const SizedBox(width: 4),
                                Text(_lang.to, style: _theme.textTheme.titleSmall),
                                const SizedBox(width: 4),
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
                          const SizedBox(width: 2),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Container(
                              height: 1,
                              width: 20,
                              color: kSubPeraColor,
                            ),
                          ),
                          const SizedBox(width: 2),
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
              onRefresh: _refreshFilteredProvider,
              child: providerData.when(
                data: (transactions) {
                  final allTransactions = transactions.data ?? [];

                  return Column(
                    children: [
                      // Overview Containers (Horizontal Scroll)
                      SizedBox.fromSize(
                        size: const Size.fromHeight(100),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Card 1: Total Sales
                              Container(
                                constraints: const BoxConstraints(minWidth: 170, maxHeight: 80),
                                decoration: BoxDecoration(
                                  color: kPeraColor.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency${formatPointNumber(transactions.totalAmount ?? 0, addComma: true)}",
                                      style: _theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l.S.of(context).total,
                                      style: _theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: kPeraColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Card 2: Money In
                              Container(
                                constraints: const BoxConstraints(minWidth: 170, maxHeight: 80),
                                decoration: BoxDecoration(
                                  color: DAppColors.kSuccess.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency${formatPointNumber(transactions.moneyIn ?? 0, addComma: true)}",
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: DAppColors.kSuccess,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _lang.moneyIn,
                                      style: _theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: kPeraColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Card 3: Money Out
                              Container(
                                constraints: const BoxConstraints(minWidth: 170, maxHeight: 80),
                                decoration: BoxDecoration(
                                  color: DAppColors.kError.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency${formatPointNumber(transactions.moneyOut ?? 0, addComma: true)}",
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: DAppColors.kError,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _lang.moneyOut,
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

                      // Tabs & List Data
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Builder(
                            builder: (tabContext) {
                              // Listen to tab changes to update list filtering
                              DefaultTabController.of(tabContext).addListener(() {
                                if (DefaultTabController.of(tabContext).indexIsChanging) {
                                  // 0 = Credit (Money In), 1 = Debit (Money Out)
                                  selectedTransactionTypeNotifier.value =
                                      ['credit', 'debit'][DefaultTabController.of(tabContext).index];
                                }
                              });

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox.fromSize(
                                    size: const Size.fromHeight(40),
                                    child: TabBar(
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      unselectedLabelColor: Color(0xff4B5563),
                                      tabs: [
                                        Tab(text: _lang.moneyIn),
                                        Tab(text: _lang.moneyOut),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ValueListenableBuilder<String>(
                                      valueListenable: selectedTransactionTypeNotifier,
                                      builder: (_, selectedTransactionType, __) {
                                        // Filter transactions based on selected tab
                                        final filteredList = allTransactions
                                            .where((element) => element.type == selectedTransactionType)
                                            .toList();

                                        if (filteredList.isEmpty) {
                                          return Center(child: Text(_lang.noTransactionFound));
                                        }

                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Table Header
                                            DefaultTextStyle.merge(
                                              style: _theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xffF7F7F7),
                                                  border: Border(bottom: Divider.createBorderSide(context)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(_lang.details, textAlign: TextAlign.start),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(_lang.type, textAlign: TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        selectedTransactionType == "credit"
                                                            ? _lang.moneyIn
                                                            : _lang.moneyOut,
                                                        textAlign: TextAlign.end,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // List Items
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: filteredList.length,
                                                itemBuilder: (context, index) {
                                                  final t = filteredList[index];
                                                  // Using platform as name placeholder if party name is missing
                                                  // Adjust 't.user?.name' or 't.party?.name' based on your exact model
                                                  final displayTitle =
                                                      t.paymentType?.paymentType ?? t.platform ?? 'Unknown';

                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: Divider.createBorderSide(context),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text.rich(
                                                            TextSpan(
                                                              text: "$displayTitle\n",
                                                              children: [
                                                                TextSpan(
                                                                  text: t.date != null
                                                                      ? intl.DateFormat("dd MMM yyyy, hh:mm a")
                                                                          .format(DateTime.parse(t.date!))
                                                                      : "N/A",
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.normal,
                                                                    color: Color(0xff4B5563),
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            style: _theme.textTheme.bodyMedium?.copyWith(
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            t.platform?.capitalizeFirstLetter() ?? "N/A",
                                                            textAlign: TextAlign.center,
                                                            style: _theme.textTheme.bodySmall,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            "$currency${formatPointNumber(t.amount ?? 0, addComma: true)}",
                                                            textAlign: TextAlign.end,
                                                            style: TextStyle(
                                                                color: selectedTransactionType == 'credit'
                                                                    ? Colors.green
                                                                    : Colors.red,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) {
                  return Center(child: Text(e.toString()));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper extension if not already in your project
extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
