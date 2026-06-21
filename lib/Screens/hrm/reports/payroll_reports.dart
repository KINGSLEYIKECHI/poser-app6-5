// File: payroll_reports.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/widgets/filter_dropdown.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/payroll/provider/payroll_provider.dart';
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';

import '../payroll/Model/payroll_lsit_model.dart';

class PayrollReports extends ConsumerStatefulWidget {
  const PayrollReports({super.key});

  @override
  ConsumerState<PayrollReports> createState() => _PayrollReportsState();
}

class _PayrollReportsState extends ConsumerState<PayrollReports> {
  // --- Filter State ---
  String? _selectedEmployeeFilter;
  String? _selectedMonthFilter;

  List<PayrollData> _filteredList = [];

  final List<String> _monthFilters = [
    'All Month',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedEmployeeFilter = 'All Employee';
    _selectedMonthFilter = 'All Month';
  }

  // --- Filtering Logic ---

  void _applyFilters() {
    setState(() {}); // Trigger rebuild to re-run filtering
  }

  void _filterPayrolls(List<PayrollData> allPayrolls) {
    _filteredList = allPayrolls.where((payroll) {
      final employeeName = (payroll.employee?.name ?? '').toLowerCase();
      final month = (payroll.month ?? '').toLowerCase();

      // 1. Employee Filter
      final employeeMatches =
          _selectedEmployeeFilter == 'All Employee' || employeeName == _selectedEmployeeFilter!.toLowerCase();

      // 2. Month Filter
      final monthMatches = _selectedMonthFilter == 'All Month' || month == _selectedMonthFilter!.toLowerCase();

      return employeeMatches && monthMatches;
    }).toList();
  }

  // --- Pull to Refresh ---

  Future<void> _refreshData() async {
    ref.invalidate(payrollListProvider);
    return ref.watch(payrollListProvider.future);
  }

  Color _getStatusColor(String? status) {
    if (status?.toLowerCase() == 'paid') return kSuccessColor;
    return Colors.red;
  }

  String _formatAmount(num? amount) {
    return '$currency${amount?.toStringAsFixed(2) ?? '0.00'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = l.S.of(context);

    // Watch primary data source and filter options
    final payrollsAsync = ref.watch(payrollListProvider);
    final employeesAsync = ref.watch(employeeListProvider);

    // Combine loading state
    final combinedAsync = payrollsAsync.asData != null && employeesAsync.asData != null
        ? AsyncValue.data(true)
        : payrollsAsync.hasError || employeesAsync.hasError
            ? AsyncValue.error(payrollsAsync.error ?? employeesAsync.error!, StackTrace.current)
            : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_lang.payrollReports),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Column(
              children: [
                const Divider(thickness: 1.5, color: kBackgroundColor, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
                  child: Row(
                    children: [
                      // Employee Filter
                      Expanded(
                        flex: 6,
                        child: FilterDropdownButton<String>(
                          value: _selectedEmployeeFilter,
                          items: [
                            DropdownMenuItem(value: 'All Employee', child: Text(_lang.allEmployee)),
                            // Map Employee List names from provider
                            ...(employeesAsync.value?.employees ?? [])
                                .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name ?? 'Unknown')))
                                .toList(),
                          ]
                              .map((item) => item.value != null
                                  ? DropdownMenuItem(
                                      value: item.value,
                                      child: Text(item.value!,
                                          style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    )
                                  : item)
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedEmployeeFilter = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Month Filter
                      Expanded(
                        flex: 4,
                        child: FilterDropdownButton<String>(
                          buttonDecoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: kBorderColor),
                          ),
                          value: _selectedMonthFilter,
                          items: [
                            DropdownMenuItem(
                              value: 'All Month',
                              child: Text(
                                _lang.allMonth,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'January',
                              child: Text(
                                _lang.january,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'February',
                              child: Text(
                                _lang.february,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'March',
                              child: Text(
                                _lang.march,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'April',
                              child: Text(
                                _lang.april,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'May',
                              child: Text(
                                _lang.may,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'June',
                              child: Text(
                                _lang.june,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'July',
                              child: Text(
                                _lang.july,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'August',
                              child: Text(
                                _lang.august,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'September',
                              child: Text(
                                _lang.september,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'October',
                              child: Text(
                                _lang.october,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'November',
                              child: Text(
                                _lang.november,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'December',
                              child: Text(
                                _lang.december,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          // items: _monthFilters.map((entry) {
                          //   return DropdownMenuItem(
                          //     value: entry,
                          //     child: Text(entry,
                          //         style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis),
                          //   );
                          // }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedMonthFilter = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1.5, color: kBackgroundColor, height: 1),
              ],
            )),
      ),

      // Body handles loading/error and displays filtered list
      body: combinedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: Failed to load report data.')),
        data: (_) {
          _filterPayrolls(payrollsAsync.value?.data ?? []);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Text(
                    _lang.noMatchingPayrollFound,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 1.5),
              itemBuilder: (_, index) => _buildPayrollItem(context: context, payroll: _filteredList[index]),
            ),
          );
        },
      ),
    );
  }

  // --- List Item Builder ---

  Widget _buildPayrollItem({
    required BuildContext context,
    required PayrollData payroll,
  }) {
    final theme = Theme.of(context);
    // Determine status and color
    final isPaid = payroll.amount != null && payroll.amount! > 0;
    final status = isPaid ? 'Paid' : 'Unpaid';
    final statusColor = _getStatusColor(status);

    // Logic to prepare Detail String for transactions (Modal)
    String paymentDetails = "";
    if (payroll.transactions != null && payroll.transactions!.isNotEmpty) {
      List<String> details = payroll.transactions!.map((t) {
        return (t.transactionType == 'cash_payment') ? 'Cash' : (t.paymentType?.name ?? 'Unknown');
      }).toList();
      paymentDetails = details.join('\n');
    } else {
      paymentDetails = "N/A";
    }

    // Logic for Summary text in the List view (Row)
    String paymentSummary = "N/A";
    if (payroll.transactions != null && payroll.transactions!.isNotEmpty) {
      paymentSummary = payroll.transactions!.first.paymentType?.name ?? 'Unknown';
      if (payroll.transactions!.length > 1) {
        paymentSummary += " +${payroll.transactions!.length - 1}";
      }
    }

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          l.S.of(context).employee: payroll.employee?.name ?? 'N/A',
          l.S.of(context).paymentYear: payroll.payemntYear ?? 'N/A',
          l.S.of(context).month: payroll.month ?? 'N/A',
          l.S.of(context).date: payroll.date ?? 'N/A',
          l.S.of(context).amount: _formatAmount(payroll.amount),
          l.S.of(context).paymentDetails: paymentDetails, // Showing Full Details Here
        },
        descriptionTitle: 'Note : ',
        description: payroll.note ?? 'N/A',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payroll.employee?.name ?? 'N/A Employee',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  payroll.date ?? 'N/A Date',
                  style: theme.textTheme.bodyMedium?.copyWith(color: kNeutral800),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(
                  time: _formatAmount(payroll.amount),
                  label: l.S.of(context).amount,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: paymentSummary, // Showing Summary Here
                  label: l.S.of(context).payment,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: status,
                  label: l.S.of(context).status,
                  titleColor: statusColor,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn({
    required String time,
    required String label,
    required ThemeData theme,
    Color? titleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor ?? kTitleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kNeutral800,
          ),
        ),
      ],
    );
  }
}
