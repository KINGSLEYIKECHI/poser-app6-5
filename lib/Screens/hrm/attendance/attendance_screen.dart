// File: attendance_screen.dart (Final Code)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/attendance/add_new_attendance.dart';
import 'package:mobile_pos/Screens/hrm/attendance/provider/attendence_provider.dart';
import 'package:mobile_pos/Screens/hrm/attendance/repo/attendence_repo.dart';
import 'package:mobile_pos/Screens/hrm/widgets/filter_dropdown.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../../widgets/deleteing_alart_dialog.dart';

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';

import 'model/attendence_list_model.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  // --- Filter State ---
  String? _selectedEmployeeFilter;
  String? _selectedTimeFilter;

  List<AttendanceData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  final List<String> _timeFilters = ['Today', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _selectedEmployeeFilter = 'All Employee';
    _selectedTimeFilter = 'Today';
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // --- Filtering Logic ---

  void _applyFilters() {
    setState(() {}); // Trigger rebuild to re-run filtering
  }

  void _filterAttendance(List<AttendanceData> allAttendance) {
    _filteredList = allAttendance.where((att) {
      final name = (att.employee?.name ?? '').toLowerCase();

      // 1. Employee Filter
      final employeeNameMatches =
          _selectedEmployeeFilter == 'All Employee' || name == _selectedEmployeeFilter!.toLowerCase();

      // 2. Time Filter (Simplified date logic)
      bool timeMatches = true;
      if (_selectedTimeFilter == 'Today') {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        timeMatches = att.date == today;
      } else {
        // Show all for other filter types, as full date range logic is complex
        timeMatches = true;
      }

      return employeeNameMatches && timeMatches;
    }).toList();
  }

  // --- Utility Functions ---

  String _formatTimeForDisplay(String? time) {
    if (time == null) return 'N/A';
    try {
      final dateTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (_) {
      return time;
    }
  }

  String _formatDateForDisplay(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {
      return date;
    }
  }

  // --- Delete Logic ---

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id, String name) async {
    bool result = await showDeleteConfirmationDialog(
      context: context,
      itemName: name,
    );

    if (result) {
      final repo = AttendanceRepo();
      await repo.deleteAttendance(id: id, context: context, ref: ref);
      ref.invalidate(attendanceListProvider); // Force list refresh
    }
  }

  // --- Pull to Refresh ---

  Future<void> _refreshData() async {
    ref.invalidate(attendanceListProvider);
    return ref.watch(attendanceListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final attendanceAsync = ref.watch(attendanceListProvider);
    final employeesAsync = ref.watch(employeeListProvider); // Employee List for filter data
    final permissionService = PermissionService(ref);

    // Combine data fetching results for UI
    final combinedAsync = attendanceAsync.asData != null && employeesAsync.asData != null
        ? AsyncValue.data(true)
        : attendanceAsync.hasError || employeesAsync.hasError
            ? AsyncValue.error(attendanceAsync.error ?? employeesAsync.error!, StackTrace.current)
            : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_lang.attendance),
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
                            DropdownMenuItem(value: 'All Employee', child: Text(_lang.allEmployees)),
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
                      // Time Filter Dropdown
                      Expanded(
                        flex: 4,
                        child: FilterDropdownButton<String>(
                          buttonDecoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: kBorderColor),
                          ),
                          value: _selectedTimeFilter,
                          // items: _timeFilters.map((entry) {
                          //   return DropdownMenuItem(
                          //     value: entry,
                          //     child: Text(
                          //       entry,
                          //       style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                          //       maxLines: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   );
                          // }).toList(),
                          items: [
                            DropdownMenuItem(
                              value: 'Today',
                              child: Text(
                                _lang.today,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Weekly',
                              child: Text(
                                _lang.weekly,
                                style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                                value: 'Monthly',
                                child: Text(
                                  _lang.monthly,
                                  style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            DropdownMenuItem(
                                value: 'Yearly',
                                child: Text(
                                  _lang.yearly,
                                  style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedTimeFilter = value;
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
          if (!permissionService.hasPermission(Permit.attendancesRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          // Data is loaded, apply filter
          _filterAttendance(attendanceAsync.value?.data ?? []);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Text(_lang.noAvailableRecordFound),
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
              itemBuilder: (_, index) => _buildAttendanceItem(
                context: context,
                ref: ref,
                attendance: _filteredList[index],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: permissionService.hasPermission(Permit.attendancesCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddNewAttendance()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(_lang.addAttendance),
              ),
            )
          : null,
    );
  }

  // --- List Item Builder ---

  Widget _buildAttendanceItem({
    required BuildContext context,
    required WidgetRef ref,
    required AttendanceData attendance,
  }) {
    final theme = Theme.of(context);

    String timeInDisplay = _formatTimeForDisplay(attendance.timeIn);
    String timeOutDisplay = _formatTimeForDisplay(attendance.timeOut);
    String dateDisplay = _formatDateForDisplay(attendance.date);

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          "Employee": attendance.employee?.name ?? 'N/A',
          "Shift": attendance.shift?.name ?? 'N/A',
          "Month": attendance.month ?? 'N/A',
          "Date": dateDisplay,
          "Time In": timeInDisplay,
          "Time Out": timeOutDisplay,
        },
        description: attendance.note ?? lang.S.of(context).noNoteProvided,
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
                      attendance.employee?.name ?? 'N/A Employee',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateDisplay,
                      style: theme.textTheme.bodyMedium?.copyWith(color: kNeutral800),
                    ),
                  ],
                ),
                _buildActionButtons(
                  context,
                  ref,
                  attendance.id,
                  attendance.employee?.name ?? lang.S.of(context).attendance,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(
                  time: timeInDisplay,
                  label: lang.S.of(context).timeIn,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: timeOutDisplay,
                  label: lang.S.of(context).timeOut,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: attendance.duration ?? 'N/A',
                  label: lang.S.of(context).duration,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: kNeutral800)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, num? id, String name) {
    final permissionService = PermissionService(ref);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!permissionService.hasPermission(Permit.attendancesUpdate.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHavePermissionToViewAttendance),
                ),
              );
              return;
            }
            if (id != null) {
              final attendanceData = _filteredList.firstWhere((a) => a.id == id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewAttendance(attendanceData: attendanceData),
                ),
              );
            }
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
            if (!permissionService.hasPermission(Permit.attendancesDelete.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHavePermissionToViewAttendance),
                ),
              );
              return;
            }
            if (id != null) {
              _showDeleteConfirmationDialog(context, ref, id, name);
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
}
