// File: leave_reports.dart (Final Code)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/widgets/filter_dropdown.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/leave_request/leave/model/leave_list_model.dart'; // LeaveRequestData model
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart'; // Employee List Provider
import 'package:mobile_pos/Screens/hrm/employee/model/employee_list_model.dart';

import '../leave_request/leave/provider/leave_list_provider.dart'; // EmployeeData model

class LeaveReports extends ConsumerStatefulWidget {
  const LeaveReports({super.key});

  @override
  ConsumerState<LeaveReports> createState() => _LeaveReportsState();
}

class _LeaveReportsState extends ConsumerState<LeaveReports> {
  // --- Filter & Search State ---
  String? _selectedEmployeeFilter;
  String? _selectedMonthFilter;

  List<LeaveRequestData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearch = false;

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
    _searchController.addListener(_applyFilters);
    _selectedEmployeeFilter = 'All Employee';
    _selectedMonthFilter = 'All Month';
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // --- Filtering Logic ---

  void _applyFilters() {
    setState(() {}); // Trigger rebuild
  }

  void _filterLeaves(List<LeaveRequestData> allLeaves) {
    final query = _searchController.text.toLowerCase().trim();

    _filteredList = allLeaves.where((leave) {
      final employeeName = (leave.employee?.name ?? '').toLowerCase();
      final leaveType = (leave.leaveType?.name ?? '').toLowerCase();
      final month = (leave.month ?? '').toLowerCase();
      final status = (leave.status ?? '').toLowerCase();

      // 1. Search Query Filter
      final matchesQuery = query.isEmpty ||
          employeeName.contains(query) ||
          leaveType.contains(query) ||
          month.contains(query) ||
          status.contains(query);

      if (!matchesQuery) return false;

      // 2. Employee Filter
      final employeeMatches =
          _selectedEmployeeFilter == 'All Employee' || employeeName.contains(_selectedEmployeeFilter!.toLowerCase());

      // 3. Month Filter
      final monthMatches = _selectedMonthFilter == 'All Month' || month.startsWith(_selectedMonthFilter!.toLowerCase());

      return employeeMatches && monthMatches;
    }).toList();
  }

  // --- Utility Functions ---

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return kSuccessColor;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return kNeutral800;
    }
  }

  Future<void> _refreshData() async {
    ref.invalidate(leaveRequestListProvider);
    return ref.watch(leaveRequestListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final theme = Theme.of(context);
    final leavesAsync = ref.watch(leaveRequestListProvider);
    final employeesAsync = ref.watch(employeeListProvider);

    final combinedAsync = leavesAsync.asData != null && employeesAsync.asData != null
        ? AsyncValue.data(true)
        : leavesAsync.hasError || employeesAsync.hasError
            ? AsyncValue.error(leavesAsync.error ?? employeesAsync.error!, StackTrace.current)
            : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        // Search implementation
        title: _isSearch
            ? TextField(
                autofocus: true,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '${_lang.searchLeave}...',
                  border: InputBorder.none,
                  suffixIcon: Icon(FeatherIcons.search, color: kNeutral800),
                ),
              )
            : Text(_lang.leaveReports),
        actions: [
          IconButton(
            icon: Icon(
              _isSearch ? Icons.close : FeatherIcons.search,
              color: _isSearch ? kMainColor : kNeutral800,
              size: _isSearch ? null : 22,
            ),
            onPressed: () {
              setState(() {
                _isSearch = !_isSearch;
                if (!_isSearch) {
                  _searchController.clear();
                  _applyFilters();
                }
              });
            },
          ),
        ],
        // Filter Dropdowns
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
        error: (err, stack) => Center(child: Text('Error: Failed to load reports.')),
        data: (_) {
          _filterLeaves(leavesAsync.value?.data ?? []);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(), child: Text(_lang.noLeaveRecordFound))),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 1.5),
              itemBuilder: (_, index) => _buildReportItem(context, _filteredList[index]),
            ),
          );
        },
      ),
    );
  }

  // --- List Item Builder ---

  Widget _buildReportItem(BuildContext context, LeaveRequestData leave) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(leave.status);

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          l.S.of(context).name: leave.employee?.name ?? 'N/A',
          l.S.of(context).department: leave.department?.name ?? 'N/A',
          l.S.of(context).leaveType: leave.leaveType?.name ?? 'N/A',
          l.S.of(context).month: leave.month ?? 'N/A',
          l.S.of(context).startDate: leave.startDate ?? 'N/A',
          l.S.of(context).endDate: leave.endDate ?? 'N/A',
          l.S.of(context).leaveDuration: leave.leaveDuration?.toString() ?? '0',
          l.S.of(context).status: leave.status?.toUpperCase() ?? 'N/A',
        },
        description: leave.description,
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
                      leave.employee?.name ?? 'N/A Employee',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          leave.leaveType?.name ?? 'N/A Type',
                          style: theme.textTheme.bodyMedium?.copyWith(color: kNeutral800),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            leave.status?.toUpperCase() ?? 'N/A',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(
                  value: leave.month ?? 'N/A',
                  label: l.S.of(context).month,
                  theme: theme,
                ),
                _buildTimeColumn(
                  value: leave.startDate ?? 'N/A',
                  label: l.S.of(context).startDate,
                  theme: theme,
                ),
                _buildTimeColumn(
                  value: leave.leaveDuration?.toString() ?? 'N/A',
                  label: l.S.of(context).durationDays,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Changed name from _buildTimeColumn to _buildValueColumn for consistency
  Widget _buildTimeColumn({
    required String value,
    required String label,
    required ThemeData theme,
    Color? titleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
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
