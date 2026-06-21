import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Customers/Provider/customer_provider.dart';
import 'package:mobile_pos/Screens/all_transaction/provider/transacton_provider.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../currency.dart';
import '../../pdf_report/transactions/all_transaction_report_pdf.dart';

class AllTransactionReport extends ConsumerStatefulWidget {
  const AllTransactionReport({super.key});

  @override
  SalesReportScreenState createState() => SalesReportScreenState();
}

class SalesReportScreenState extends ConsumerState<AllTransactionReport> {
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

  final Map<String, String> transactionType = {
    'all_transaction': l.S.current.allTransaction,
    'sale': l.S.current.sales,
    'purchase': l.S.current.purchase,
    'due_collect': l.S.current.dueCollection,
    'income': l.S.current.income,
    'expense': l.S.current.expense,
    'due_pay': l.S.current.duePay,
    'bank': l.S.current.bank,
    'cash': l.S.current.cash,
    'cheque': l.S.current.cheque,
  };

  String selectedTransaction = 'all_transaction';

  String? selectedParty;

  bool _isRefreshing = false;
  bool _showCustomDatePickers = false;

  DateTime? fromDate;
  DateTime? toDate;
  String searchCustomer = '';

  TransactionFilteredModel _getFilter() {
    return TransactionFilteredModel(
      duration: selectedTime,
      fromDate: fromDate == null ? null : DateFormat('yyyy-MM-dd').format(fromDate!),
      toDate: toDate == null ? null : DateFormat('yyyy-MM-dd').format(toDate!),
      transactionType: selectedTransaction == 'all_transaction' ? null : selectedTransaction,
      party: selectedParty,
    );
  }

  Future<void> _selectDate({
    required BuildContext context,
    required bool isFrom,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      initialDate: isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now()),
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

      if (fromDate != null && toDate != null) {
        _refreshFilteredProvider();
      }
    }
  }

  Future<void> _refreshFilteredProvider() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });

    try {
      final filter = _getFilter();
      // Force refresh by invalidating the provider
      ref.invalidate(filteredTransactionProvider(filter));
      // Wait for the new data
      await ref.refresh(filteredTransactionProvider(filter).future);

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Refresh error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
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

    setState(() {
      selectedTime = value;
      _showCustomDatePickers = value == 'custom_date';
    });

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
        // Clear dates for custom selection
        _updateDateUI(null, null);
        return; // Don't refresh, user will select dates manually
    }

    // Refresh data after setting dates (except for custom)
    _refreshFilteredProvider();
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
    return Consumer(
      builder: (context, ref, __) {
        final _lang = l.S.of(context);
        final filter = _getFilter();
        final providerData = ref.watch(filteredTransactionProvider(filter));
        final partyData = ref.watch(partiesProvider);
        final personalData = ref.watch(businessInfoProvider);

        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(_lang.allTransaction),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  children: [
                    Divider(thickness: 1, color: kBottomBorder, height: 1),
                    //Date Time
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(IconlyLight.calendar, color: kPeraColor, size: 20),
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
                                Text(
                                  _lang.to,
                                  style: _theme.textTheme.titleSmall,
                                ),
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
                                  _setDateRangeFromDropdown(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1, color: kBottomBorder, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: DropdownButtonFormField2<String>(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                ),
                                value: selectedTransaction,
                                isExpanded: true,
                                items: transactionType.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      overflow: TextOverflow.ellipsis,
                                      style: _theme.textTheme.titleSmall,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() => selectedTransaction = value);
                                  _refreshFilteredProvider();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: partyData.when(
                              data: (data) {
                                return SizedBox(
                                  height: 40,
                                  child: DropdownButtonFormField2<String>(
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'all_parties',
                                        child: Text(
                                          _lang.allParties,
                                          style: _theme.textTheme.titleSmall,
                                        ),
                                      ),
                                      ...data.map((entry) {
                                        return DropdownMenuItem<String>(
                                          value: entry.id?.toString() ?? '',
                                          child: Text(
                                            entry.name ?? 'Unknown',
                                            overflow: TextOverflow.ellipsis,
                                            style: _theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    value: selectedParty ?? 'all_parties',
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => selectedParty = value);
                                      _refreshFilteredProvider();
                                    },
                                  ),
                                );
                              },
                              error: (e, stack) => Center(
                                child: Text(e.toString()),
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
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
              backgroundColor: Colors.white,
              elevation: 0.0,
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
                                      generateAllTransactionReportPdf(context, transaction, business, fromDate, toDate);
                                    } else {
                                      EasyLoading.showError(_lang.listIsEmpty);
                                    }
                                  },
                                  icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                                ),
                                /*
                                IconButton(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (!permissionService.hasPermission(Permit.expenseReportsRead.value)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text('You do not have permission to view expense report.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (transaction.data?.isNotEmpty == true) {
                                      // generateSaleReportExcel(context, transaction, business, fromDate, toDate);
                                    } else {
                                      EasyLoading.showInfo('No data available for generate pdf');
                                    }
                                  },
                                  icon: SvgPicture.asset('assets/excel.svg'),
                                ),
                                */
                                SizedBox(width: 8),
                              ],
                            );
                          },
                          error: (e, stack) => Center(
                                child: Text(e.toString()),
                              ),
                          loading: () => Center(
                                child: CircularProgressIndicator(),
                              ));
                    },
                    error: (e, stack) => Center(
                          child: Text(e.toString()),
                        ),
                    loading: () => Center(
                          child: CircularProgressIndicator(),
                        )),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _refreshFilteredProvider,
              child: providerData.when(
                data: (transactions) {
                  final dataList = transactions.data ?? [];

                  if (dataList.isEmpty) {
                    return Center(
                      child: Text(_lang.noTransactionFound),
                    );
                  }

                  return Column(
                    children: [
                      // Overview Containers
                      SizedBox.fromSize(
                        size: Size.fromHeight(100),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                constraints: const BoxConstraints(minWidth: 170, maxHeight: 80),
                                decoration: BoxDecoration(
                                  color: const Color(0xffFAE3FF),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency${formatPointNumber(transactions.totalAmount ?? 0)}",
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _lang.transactions,
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
                                constraints: const BoxConstraints(minWidth: 170, maxHeight: 80),
                                decoration: BoxDecoration(
                                  color: kSuccessColor.withValues(alpha: 0.15),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency${formatPointNumber(transactions.moneyIn ?? 0)}",
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
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
                              SizedBox(width: 12),
                              Container(
                                constraints: const BoxConstraints(minWidth: 170, maxHeight: 80),
                                decoration: BoxDecoration(
                                  color: DAppColors.kError.withValues(alpha: 0.15),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$currency${formatPointNumber(transactions.moneyOut ?? 0)}",
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
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
                              Expanded(flex: 4, child: Text(_lang.name)),
                              Expanded(flex: 3, child: Text(_lang.type, textAlign: TextAlign.center)),
                              Expanded(flex: 2, child: Text(_lang.amount, textAlign: TextAlign.end)),
                            ],
                          ),
                        ),
                      ),

                      // Transactions
                      Expanded(
                        child: ListView.builder(
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            final _transaction = dataList[index];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
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
                                        text: "${_transaction.party?.name ?? "N/A"}\n",
                                        children: [
                                          TextSpan(
                                            text: _transaction.date == null
                                                ? "N/A"
                                                : DateFormat("dd MMM yyyy").format(DateTime.parse(_transaction.date!)),
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: const Color(0xff4B5563),
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
                                      _transaction.platform?.toTitleCase() ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "$currency${formatPointNumber(_transaction.amount ?? 0, addComma: true)}",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: switch (_transaction.type?.trim().toLowerCase()) {
                                          'credit' => Colors.green,
                                          'debit' => Colors.red,
                                          _ => null,
                                        },
                                        fontWeight: FontWeight.w500,
                                      ),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  print('Error Found: ${e.toString()}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${e.toString()}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshFilteredProvider,
                          child: Text(_lang.retry),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: providerData.when(
              data: (data) {
                return DefaultTextStyle.merge(
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F7F7),
                      border: Border(top: Divider.createBorderSide(context)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_lang.total)),
                        Expanded(
                          child: Text("$currency${formatPointNumber(data.totalAmount ?? 0)}", textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: SizedBox.shrink,
            ),
          ),
        );
      },
    );
  }
}

extension TitleCaseExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;

    final normalized = replaceAll(RegExp(r'[_\-]+'), ' ');

    final words = normalized.split(' ').map((w) => w.trim()).where((w) => w.isNotEmpty).toList();

    if (words.isEmpty) return '';

    final titleCased = words.map((word) {
      final lower = word.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).join(' ');

    return titleCased;
  }
}
