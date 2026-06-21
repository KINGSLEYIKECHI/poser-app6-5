// File: leave_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/leave_request/leave/add_new_leave.dart'; // Correct Provider Name
import 'package:mobile_pos/Screens/hrm/leave_request/leave/provider/leave_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/widgets/filter_dropdown.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../../../service/check_user_role_permission_provider.dart';
import '../../../../widgets/empty_widget/_empty_widget.dart';
import '../../../../widgets/deleteing_alart_dialog.dart';

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/leave_request/leave/repo/leave_repo.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave/model/leave_list_model.dart';
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart'; // Employee Provider

class LeaveListScreen extends ConsumerStatefulWidget {
  const LeaveListScreen({super.key});

  @override
  ConsumerState<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends ConsumerState<LeaveListScreen> {
  // --- Filter State ---
  String? _selectedEmployeeFilter;
  String? _selectedMonthFilter;

  List<LeaveRequestData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _monthOptions = [
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
    setState(() {}); // Rebuild to apply filters
  }

  void _filterLeaveRequests(List<LeaveRequestData> allRequests) {
    final query = _searchController.text.toLowerCase().trim();

    _filteredList = allRequests.where((leave) {
      final name = (leave.employee?.name ?? '').toLowerCase();
      final leaveType = (leave.leaveType?.name ?? '').toLowerCase();
      final month = (leave.month ?? '').toLowerCase();
      final status = (leave.status ?? '').toLowerCase();

      // 1. Search Query Filter
      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          leaveType.contains(query) ||
          month.contains(query) ||
          status.contains(query);

      if (!matchesQuery) return false;

      // 2. Employee Filter
      final employeeNameMatches =
          _selectedEmployeeFilter == 'All Employee' || name == _selectedEmployeeFilter!.toLowerCase();

      // 3. Month Filter
      final monthMatches = _selectedMonthFilter == 'All Month' || month.startsWith(_selectedMonthFilter!.toLowerCase());

      return employeeNameMatches && monthMatches;
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

  // --- Delete Logic ---

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id, String name) async {
    bool result = await showDeleteConfirmationDialog(
      context: context,
      itemName: name,
    );

    if (result) {
      final repo = LeaveRepo();
      await repo.deleteLeaveRequest(id: id, context: context, ref: ref);

      // The repo method should handle ref.invalidate(leaveRequestListProvider)
      // If it doesn't, uncomment the line below:
      // ref.invalidate(leaveRequestListProvider);
    }
  }

  // --- Pull to Refresh ---

  Future<void> _refreshData() async {
    // Invalidate and watch future to force reload of the leave list
    ref.invalidate(leaveRequestListProvider);
    return ref.watch(leaveRequestListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final leaveListAsync = ref.watch(leaveRequestListProvider);
    final employeesAsync = ref.watch(employeeListProvider);
    final permissionService = PermissionService(ref);

    // Combine data fetching results for UI
    final combinedAsync = leaveListAsync.asData != null && employeesAsync.asData != null
        ? AsyncValue.data(true)
        : leaveListAsync.hasError || employeesAsync.hasError
            ? AsyncValue.error(leaveListAsync.error ?? employeesAsync.error!, StackTrace.current)
            : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_lang.leaveList),
        // Filter Dropdowns in AppBar bottom section
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
                            DropdownMenuItem(
                              value: 'All Employee',
                              child: Text(_lang.allEmployee),
                            ),
                            // CRITICAL: Employee data access uses .data property
                            ...(employeesAsync.value?.employees ?? [])
                                .map((e) => DropdownMenuItem(
                                      value: e.name,
                                      child: Text(e.name ?? 'n/a'),
                                    ))
                                .toList(),
                          ]
                              .map((item) => item.value != null
                                  ? DropdownMenuItem(
                                      value: item.value,
                                      child: Text(
                                        item.value!,
                                        style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                          items: _monthOptions.map((entry) {
                            return DropdownMenuItem(
                              value: entry,
                              child: Text(
                                entry,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
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
        error: (err, stack) => Center(child: Text('Error: Failed to load data.')),
        data: (_) {
          // Permission Check
          if (!permissionService.hasPermission(Permit.leavesRead.value)) {
            return const Center(child: PermitDenyWidget());
          }

          // Data is loaded, apply filter
          _filterLeaveRequests(leaveListAsync.value?.data ?? []);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Text(
                    _lang.noLeaveRequestFound,
                    style: theme.textTheme.titleMedium,
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
              separatorBuilder: (_, __) => const Divider(
                color: kBackgroundColor,
                height: 1.5,
              ),
              itemBuilder: (_, index) => _buildShiftItem(
                context: context,
                ref: ref,
                leave: _filteredList[index],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: permissionService.hasPermission(Permit.leavesCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNewLeave()),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(_lang.addLeave),
              ),
            )
          : null,
    );
  }

  // --- List Item Builder ---

  Widget _buildShiftItem({
    required BuildContext context,
    required WidgetRef ref,
    required LeaveRequestData leave,
  }) {
    final theme = Theme.of(context);
    final status = leave.status;
    final statusColor = _getStatusColor(status);

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          "Name": leave.employee?.name ?? 'N/A',
          "Department": leave.department?.name ?? 'N/A',
          "Leave Type": leave.leaveType?.name ?? 'N/A',
          "Month": leave.month ?? 'N/A',
          "Start Date": leave.startDate ?? 'N/A',
          "End Date": leave.endDate ?? 'N/A',
          "Leave Duration": leave.leaveDuration?.toString() ?? '0',
          "Status": status?.toUpperCase() ?? 'N/A'
        },
        description: leave.description ?? lang.S.of(context).noDescriptionProvided,
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
                            status?.toUpperCase() ?? 'N/A',
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
                _buildActionButtons(context, ref, leave),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(
                  time: leave.month ?? 'N/A',
                  label: lang.S.of(context).month,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: leave.startDate ?? 'N/A',
                  label: lang.S.of(context).startDate,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: leave.endDate ?? 'N/A',
                  label: lang.S.of(context).endDate,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, LeaveRequestData leave) {
    final permissionService = PermissionService(ref);
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            // Made async to await navigation
            if (!permissionService.hasPermission(Permit.leavesUpdate.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHavePermissionToUpdateLeaveRequest),
                ),
              );
              return;
            }
            // Await the push operation
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewLeave(leaveRequestData: leave),
              ),
            );
            // The repo call inside AddNewLeave should invalidate the provider,
            // causing this screen to rebuild automatically upon return.
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
            if (!permissionService.hasPermission(Permit.leavesDelete.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHavePermissionToDeleteLeaveRequest),
                ),
              );
              return;
            }
            if (leave.id != null) {
              _showDeleteConfirmationDialog(
                context,
                ref,
                leave.id!,
                leave.employee?.name ?? lang.S.of(context).leaveRequest,
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

  // void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id, String name) async {
  //   bool result = await showDeleteConfirmationDialog(
  //     context: context,
  //     itemName: name,
  //   );
  //
  //   if (result) {
  //     final repo = LeaveRepo();
  //     // This call should trigger list refresh via repo's ref.invalidate()
  //     await repo.deleteLeaveRequest(id: id, context: context, ref: ref);
  //   }
  // }
}
