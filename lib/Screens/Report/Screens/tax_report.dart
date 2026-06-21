import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';
import '../../../model/tax_report_model.dart';
import '../../../pdf_report/transactions/tax_report_pdf.dart';

class TaxReportScreen extends ConsumerStatefulWidget {
  const TaxReportScreen({super.key});

  @override
  ConsumerState<TaxReportScreen> createState() => _TaxReportScreenState();
}

class _TaxReportScreenState extends ConsumerState<TaxReportScreen> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final tabIndexNotifier = ValueNotifier<int>(0);

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
      ref.refresh(filteredTaxReportReportProvider(filter));
      await Future.delayed(const Duration(milliseconds: 300));
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
        _updateDateUI(null, null);
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
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);

    return Consumer(
      builder: (_, ref, watch) {
        final providerData = ref.watch(filteredTaxReportReportProvider(_getDateRangeFilter()));
        final personalData = ref.watch(businessInfoProvider);

        return personalData.when(
          data: (business) {
            return DefaultTabController(
              length: 2,
              child: Builder(
                builder: (tabContext) {
                  final tabController = DefaultTabController.of(tabContext);
                  tabController.addListener(() {
                    tabIndexNotifier.value = tabController.index;
                  });

                  return providerData.when(
                    data: (taxReport) {
                      return GlobalPopup(
                        child: Scaffold(
                          backgroundColor: kWhite,
                          appBar: AppBar(
                            backgroundColor: Colors.white,
                            title: Text(_lang.taxReportList),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  if ((taxReport.sales.isNotEmpty) || (taxReport.purchases.isNotEmpty)) {
                                    generateTaxReportPdf(
                                      context,
                                      taxReport,
                                      business,
                                      fromDate,
                                      toDate,
                                      isPurchase: tabIndexNotifier.value == 1,
                                    );
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
                                                  fromDate != null
                                                      ? DateFormat('dd MMM yyyy').format(fromDate!)
                                                      : _lang.from,
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
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox.fromSize(
                                        size: const Size.fromHeight(40),
                                        child: TabBar(
                                          indicatorSize: TabBarIndicatorSize.tab,
                                          unselectedLabelColor: const Color(0xff4B5563),
                                          tabs: [
                                            Tab(text: _lang.sales),
                                            Tab(text: _lang.purchase),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ValueListenableBuilder(
                                          valueListenable: tabIndexNotifier,
                                          builder: (_, value, __) {
                                            final isPurchase = value == 1;
                                            final invoices = taxReport.getInvoices(isPurchase: isPurchase);
                                            final rowMap = taxReport.getRowMap(isPurchase: isPurchase);
                                            final returnRowMap = taxReport.getRowMap(isPurchase: isPurchase, isReturn: true);
                                            final vats = taxReport.activeVats;

                                            return SingleChildScrollView(
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: DataTable(
                                                  border: TableBorder.all(color: Colors.grey[300]!),
                                                  headingRowHeight: 40,
                                                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                                                  columns: [
                                                    DataColumn(
                                                      label: Text(
                                                        'Date',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Invoice',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Customer",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Tax Number",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Total Amount",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Payment Method",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        "Discount",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    ...vats.map((vat) {
                                                      return DataColumn(
                                                        label: Text(
                                                          vat.displayName,
                                                          style: TextStyle(
                                                            color: Colors.black87,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                  rows: [
                                                    ...invoices.map((invoice) {
                                                      return DataRow(
                                                        cells: [
                                                          DataCell(
                                                            Text(
                                                              invoice.transactionDate == null
                                                                  ? "N/A"
                                                                  : DateFormat("dd MMM, yyyy")
                                                                      .format(invoice.transactionDate!),
                                                            ),
                                                          ),
                                                          DataCell(Text(invoice.invoiceNumber ?? "N/A")),
                                                          DataCell(Text(invoice.partyName ?? "N/A")),
                                                          DataCell(Text(invoice.partyName ?? "N/A")),
                                                          DataCell(
                                                            Center(
                                                              child: Text(
                                                                "$currency${formatPointNumber(addComma: true, (invoice.amount ?? 0).toDouble())}",
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                          DataCell(Text(invoice.paymentType ?? "N/A")),
                                                          DataCell(
                                                            Center(
                                                              child: Text(
                                                                "$currency${formatPointNumber(addComma: true, (invoice.discountAmount ?? 0).toDouble())}",
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                          ...vats.map((vat) {
                                                            // Calculate VAT following web logic:
                                                            // totalVat = productVat + invoiceVat - returnVat
                                                            final amount = invoice.calculateVatAmount(vat.id, rowMap, returnRowMap);
                                                            return DataCell(
                                                              Center(
                                                                child: Text(
                                                                  "$currency${formatPointNumber(addComma: true, amount.toDouble())}",
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                      );
                                                    }),

                                                    // Total Row
                                                    DataRow(
                                                      color: WidgetStateProperty.all(Colors.grey[100]),
                                                      cells: [
                                                        DataCell(
                                                          Text(
                                                            'Total',
                                                            style: TextStyle(
                                                              color: Colors.black87,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(const SizedBox.shrink()),
                                                        DataCell(const SizedBox.shrink()),
                                                        DataCell(const SizedBox.shrink()),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              "$currency${formatPointNumber(addComma: true, invoices.totalAmount.toDouble())}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.black87,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(const SizedBox.shrink()),
                                                        DataCell(
                                                          Center(
                                                            child: Text(
                                                              "$currency${formatPointNumber(addComma: true, invoices.totalDiscountAmount.toDouble())}",
                                                              style: TextStyle(
                                                                color: Colors.black87,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                        ...vats.map((vat) {
                                                          // Calculate grand total following web logic:
                                                          // grandVatTotal = (vatTotals - returnVatTotals) + sum of invoice.vatAmount where vatId matches
                                                          final total = taxReport.calculateGrandVatTotal(vatId: vat.id, isPurchase: isPurchase);
                                                          return DataCell(
                                                            Center(
                                                              child: Text(
                                                                "$currency${formatPointNumber(addComma: true, total.toDouble())}",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.black87,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    error: (e, stack) => Center(child: Text(e.toString())),
                    loading: () => Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            );
          },
          error: (e, stack) => Center(child: Text(e.toString())),
          loading: () => Center(child: CircularProgressIndicator()),
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
