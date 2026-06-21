// File: attendance_reports.dart (Final Code with Search)

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:hugeicons/hugeicons.dart'; // HugeIcons Import

// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/widgets/filter_dropdown.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';
import '../attendance/model/attendence_list_model.dart';
import '../attendance/provider/attendence_provider.dart';

class AttendanceReports extends ConsumerStatefulWidget {
  const AttendanceReports({super.key});

  @override
  ConsumerState<AttendanceReports> createState() => _AttendanceReportsState();
}

class _AttendanceReportsState extends ConsumerState<AttendanceReports> {
  // --- Filter State ---
  String? _selectedEmployeeFilter;
  String? _selectedTimeFilter;

  List<AttendanceData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearch = false; // State to manage search bar visibility

  final List<String> _timeFilters = ['Today', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters); // Listen to search input changes
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
    // This is called when dropdowns or the search bar input changes
    setState(() {});
  }

  void _filterAttendance(List<AttendanceData> allAttendance) {
    final query = _searchController.text.toLowerCase().trim();

    _filteredList = allAttendance.where((att) {
      final employeeName = (att.employee?.name ?? '').toLowerCase();
      final date = (att.date ?? '').toLowerCase();
      final timeIn = (att.timeIn ?? '').toLowerCase();
      final timeOut = (att.timeOut ?? '').toLowerCase();

      // 1. Search Query Filter (Checks Employee, Date, Time In, Time Out)
      final matchesQuery = query.isEmpty ||
          employeeName.contains(query) ||
          date.contains(query) ||
          timeIn.contains(query) ||
          timeOut.contains(query);

      if (!matchesQuery) return false;

      // 2. Employee Filter
      final employeeNameMatches =
          _selectedEmployeeFilter == 'All Employee' || employeeName.contains(_selectedEmployeeFilter!.toLowerCase());

      // 3. Time Filter (Simplified date logic)
      bool timeMatches = true;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (_selectedTimeFilter == 'Today') {
        timeMatches = att.date == today;
      }
      // NOTE: Other time filters are just placeholders now.

      return employeeNameMatches && timeMatches;
    }).toList();
  }

  // --- Utility Functions ---

  String _formatTimeForDisplay(String? time) {
    if (time == null) return 'N/A';
    try {
      final dateTime = DateFormat('H:m:s').parse(time);
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

  Future<void> _refreshData() async {
    ref.invalidate(attendanceListProvider);
    return ref.watch(attendanceListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final attendanceAsync = ref.watch(attendanceListProvider);
    final employeesAsync = ref.watch(employeeListProvider);

    final combinedAsync = attendanceAsync.asData != null && employeesAsync.asData != null
        ? AsyncValue.data(true)
        : attendanceAsync.hasError || employeesAsync.hasError
            ? AsyncValue.error(attendanceAsync.error ?? employeesAsync.error!, StackTrace.current)
            : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        // *** SEARCH IMPLEMENTATION ***
        title: _isSearch
            ? TextField(
                autofocus: true,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '${lang.S.of(context).searchAttendance}...',
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    FeatherIcons.search,
                    // size: 18,
                    color: kNeutral800,
                  ),
                ),
              )
            : Text(lang.S.of(context).attendanceReport),
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
                  _applyFilters(); // Re-apply filters when search is closed
                }
              });
            },
          ),
        ],
        // *** END SEARCH IMPLEMENTATION ***
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
                      // Time Filter
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
                          //     child: Text(entry,
                          //         style: theme.textTheme.bodyLarge?.copyWith(color: kNeutral800),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis),
                          //   );
                          // }).toList(),
                          // 'Today', 'Weekly', 'Monthly', 'Yearly'
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
        error: (err, stack) => Center(child: Text('Error: Failed to load reports.')),
        data: (_) {
          _filterAttendance(attendanceAsync.value?.data ?? []);

          if (_filteredList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Text(
                    lang.S.of(context).noAttendanceRecordFound,
                    textAlign: TextAlign.center,
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
              itemBuilder: (_, index) => _buildReportItem(context, _filteredList[index]),
            ),
          );
        },
      ),
    );
  }

  // --- List Item Builder (Unchanged) ---

  Widget _buildReportItem(BuildContext context, AttendanceData attendance) {
    final theme = Theme.of(context);
    final timeInDisplay = _formatTimeForDisplay(attendance.timeIn);
    final timeOutDisplay = _formatTimeForDisplay(attendance.timeOut);
    final dateDisplay = _formatDateForDisplay(attendance.date);

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          lang.S.of(context).employee: attendance.employee?.name ?? 'N/A',
          lang.S.of(context).shift: attendance.shift?.name ?? 'N/A',
          lang.S.of(context).month: attendance.month ?? 'N/A',
          lang.S.of(context).date: dateDisplay,
          lang.S.of(context).timeIn: timeInDisplay,
          lang.S.of(context).timeOut: timeOutDisplay,
        },
        description: attendance.note,
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueColumn(
                  value: timeInDisplay,
                  label: lang.S.of(context).timeIn,
                  theme: theme,
                ),
                _buildValueColumn(
                  value: timeOutDisplay,
                  label: lang.S.of(context).timeOut,
                  theme: theme,
                ),
                _buildValueColumn(
                  value: attendance.duration ?? 'N/A',
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

  Widget _buildValueColumn({
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
