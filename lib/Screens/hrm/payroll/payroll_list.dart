// File: payroll_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/currency.dart';

// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/payroll/add_new_payroll.dart';
import 'package:mobile_pos/Screens/hrm/widgets/filter_dropdown.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../../widgets/deleteing_alart_dialog.dart';

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/payroll/repo/payroll_repo.dart';
import 'package:mobile_pos/Screens/hrm/payroll/provider/payroll_provider.dart';
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/employee/model/employee_list_model.dart';

import 'Model/payroll_lsit_model.dart';

class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
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

  void _applyFilters() {
    setState(() {}); // Trigger rebuild to apply filters
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

  Color _getStatusColor(String? status) {
    if (status?.toLowerCase() == 'paid') return kSuccessColor;
    return Colors.orange; // Defaulting any other status to orange/pending
  }

  Future<void> _refreshData() async {
    ref.invalidate(payrollListProvider);
    return ref.watch(payrollListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final payrollsAsync = ref.watch(payrollListProvider);
    final employeesAsync = ref.watch(employeeListProvider);
    final permissionService = PermissionService(ref);

    final combinedAsync = payrollsAsync.asData != null && employeesAsync.asData != null
        ? AsyncValue.data(true)
        : payrollsAsync.hasError || employeesAsync.hasError
            ? AsyncValue.error(payrollsAsync.error ?? employeesAsync.error!, StackTrace.current)
            : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_lang.payrollList),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Column(
              children: [
                const Divider(thickness: 1.5, color: kBackgroundColor, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 13),
                  child: Row(
                    children: [
                      // Employee Filter Dropdown
                      Expanded(
                        flex: 6,
                        child: FilterDropdownButton<String>(
                          value: _selectedEmployeeFilter,
                          items: [
                            DropdownMenuItem(value: 'All Employee', child: Text(_lang.allEmployee)),
                            ...(employeesAsync.value?.employees ?? [])
                                .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name ?? 'n/a')))
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
                      // Month Filter Dropdown
                      Expanded(
                        flex: 4,
                        child: FilterDropdownButton<String>(
                          buttonDecoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: kBorderColor),
                          ),
                          value: _selectedMonthFilter,
                          // items: _monthFilters.map((entry) {
                          //   return DropdownMenuItem(
                          //     value: entry,
                          //     child: Text(entry,
                          //         style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis),
                          //   );
                          // }).toList(),
                          //   'All Month',
                          //   'January',
                          //   'February',
                          //   'March',
                          //   'April',
                          //   'May',
                          //   'June',
                          //   'July',
                          //   'August',
                          //   'September',
                          //   'October',
                          //   'November',
                          //   'December'
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
      body: combinedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: Failed to load data.')),
        data: (_) {
          if (!permissionService.hasPermission(Permit.payrollsRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          _filterPayrolls(payrollsAsync.value?.data ?? []);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(), child: Text(lang.S.of(context).noPayrollFound))),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 1.5),
              itemBuilder: (_, index) => _buildPayrollItem(
                context: context,
                ref: ref,
                payroll: _filteredList[index],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.payrollsCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNewPayroll()),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(_lang.addNewPayroll),
              ),
            )
          : null,
    );
  }

  // --- List Item Builder ---

  Widget _buildPayrollItem({
    required BuildContext context,
    required WidgetRef ref,
    required PayrollData payroll,
  }) {
    final theme = Theme.of(context);
    final status = payroll.amount != null ? lang.S.of(context).paid : lang.S.of(context).unPaid;
    final statusColor = _getStatusColor(status);

    // Logic to prepare Detail String for transactions
    String paymentDetails = "";
    if (payroll.transactions != null && payroll.transactions!.isNotEmpty) {
      // Create a list of strings like "Cash: 500", "Bank: 200"
      List<String> details = payroll.transactions!.map((t) {
        return (t.transactionType == 'cash_payment') ? 'Cash' : (t.paymentType?.name ?? 'Unknown');
      }).toList();
      paymentDetails = details.join('\n');
    } else {
      // Fallback for old data or no transactions
      paymentDetails = "N/A";
    }

    // Logic for Summary text in the List view
    String paymentSummary = "N/A";
    if (payroll.transactions != null && payroll.transactions!.isNotEmpty) {
      paymentSummary = (payroll.transactions!.first.transactionType == 'cash_payment')
          ? 'Cash'
          : (payroll.transactions!.first.paymentType?.name ?? 'Unknown');
      if (payroll.transactions!.length > 1) {
        paymentSummary += " +${payroll.transactions!.length - 1}";
      }
    }

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          lang.S.of(context).employee: payroll.employee?.name ?? 'N/A',
          lang.S.of(context).paymentYear: payroll.payemntYear ?? 'N/A',
          lang.S.of(context).month: payroll.month ?? 'N/A',
          lang.S.of(context).date: payroll.date ?? 'N/A',
          lang.S.of(context).amount: '$currency${payroll.amount?.toStringAsFixed(2) ?? '0.00'}',
          lang.S.of(context).paymentDetails: paymentDetails, // Showing Full Details Here
        },
        descriptionTitle: '${lang.S.of(context).paymentDetails} : ',
        description: payroll.note ?? 'N/A',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                _buildActionButtons(context, ref, payroll),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(
                  time: '$currency${payroll.amount?.toStringAsFixed(2) ?? '0.00'}',
                  label: lang.S.of(context).amount,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: paymentSummary, // Showing Summary Here
                  label: lang.S.of(context).payment,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: status,
                  label: lang.S.of(context).status,
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, PayrollData payroll) {
    final permissionService = PermissionService(ref);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!permissionService.hasPermission(Permit.payrollsUpdate.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHaveUpdatePayroll),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewPayroll(payrollData: payroll),
              ),
            );
          },
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedPencilEdit02,
            color: kSuccessColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (!permissionService.hasPermission(Permit.payrollsDelete.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHavePermissionToDeletePayroll),
                ),
              );
              return;
            }
            if (payroll.id != null) {
              _showDeleteConfirmationDialog(
                context,
                ref,
                payroll.id!,
                payroll.employee?.name ?? lang.S.of(context).payrollRecord,
              );
            }
          },
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedDelete03,
            color: Colors.red,
            size: 20,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id, String name) async {
    bool result = await showDeleteConfirmationDialog(
      context: context,
      itemName: name,
    );

    if (result) {
      final repo = PayrollRepo();
      await repo.deletePayroll(id: id, context: context, ref: ref);
      ref.invalidate(payrollListProvider);
    }
  }
}
