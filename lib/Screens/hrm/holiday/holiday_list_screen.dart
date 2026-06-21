// File: holiday_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

// --- Local Imports (Assuming correct paths) ---
import 'package:mobile_pos/Screens/hrm/holiday/add_new_holiday.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import '../../../service/check_user_role_permission_provider.dart'; // PermissionService
import '../../../widgets/empty_widget/_empty_widget.dart'; // PermitDenyWidget (Assuming this exists)
import '../../../widgets/deleteing_alart_dialog.dart';
import '../widgets/global_search_appbar.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

// --- Data Layer Imports ---
import 'package:mobile_pos/Screens/hrm/holiday/model/holiday_list_model.dart';
import 'package:mobile_pos/Screens/hrm/holiday/repo/holiday_repo.dart';
import 'package:mobile_pos/Screens/hrm/holiday/provider/holidays_list_provider.dart';

class HolidayList extends ConsumerStatefulWidget {
  const HolidayList({super.key});

  @override
  ConsumerState<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends ConsumerState<HolidayList> {
  final TextEditingController _searchController = TextEditingController();
  List<HolidayData> _filteredHolidays = [];
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Date Formatting Utility (FIX) ---
  String _formatDateForDisplay(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      // Parse YYYY-MM-DD from API
      final dateTime = DateFormat('yyyy-MM-dd').parse(date);
      // Format to dd MMM, yyyy (e.g., 02 Jun, 2025)
      return DateFormat('dd MMM, yyyy').format(dateTime);
    } catch (_) {
      return date;
    }
  }
  // --- End Date Formatting Utility ---

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild to re-apply filter
    });
  }

  void _filterHolidays(List<HolidayData> allHolidays) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredHolidays = allHolidays;
    } else {
      _filteredHolidays = allHolidays.where((holiday) {
        final nameMatch = (holiday.name ?? '').toLowerCase().contains(query);
        final branchMatch = (holiday.branch?.name ?? '').toLowerCase().contains(query);
        final startDateMatch = (holiday.startDate ?? '').toLowerCase().contains(query);
        final endDateMatch = (holiday.endDate ?? '').toLowerCase().contains(query);

        return nameMatch || branchMatch || startDateMatch || endDateMatch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final holidayListAsync = ref.watch(holidayListProvider);
    // Assuming PermissionService and Permit enum exist globally or are accessible
    final permissionService = PermissionService(ref);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () {
          setState(() {
            _isSearch = !_isSearch;
            if (!_isSearch) {
              _searchController.clear();
            }
          });
        },
        title: _lang.holidayList,
        controller: _searchController,
        onChanged: (query) {
          // Handled by _searchController.addListener
        },
      ),
      body: holidayListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Failed to load holidays: $err'),
        ),
        data: (model) {
          // Check read permission
          if (!permissionService.hasPermission(Permit.holidaysRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          final allHolidays = model.data ?? [];

          // Apply filter
          _filterHolidays(allHolidays);

          if (_filteredHolidays.isEmpty) {
            return Center(
              child: Text(
                _searchController.text.isEmpty
                    ? _lang.noHolidayFound
                    : '${_lang.noHolidayFundMatching}"${_searchController.text}".',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _filteredHolidays.length,
            separatorBuilder: (_, __) => const Divider(
              color: kBackgroundColor,
              height: 1.5,
            ),
            itemBuilder: (_, index) => _buildHolidayItem(
              context: context,
              ref: ref,
              holiday: _filteredHolidays[index], // Use filtered list
            ),
          );
        },
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.holidaysCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNewHoliday(),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(_lang.addHoliday),
              ),
            )
          : null,
    );
  }

  // --- Helper Methods ---

  Widget _buildHolidayItem({
    required BuildContext context,
    required WidgetRef ref,
    required HolidayData holiday,
  }) {
    final theme = Theme.of(context);

    // FIX: Formatting the dates for display
    final String startDateDisplay = _formatDateForDisplay(holiday.startDate);
    final String endDateDisplay = _formatDateForDisplay(holiday.endDate);
    final String description = holiday.description ?? 'N/A';

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          lang.S.of(context).name: holiday.name ?? 'N/A',
          lang.S.of(context).startDate: startDateDisplay,
          lang.S.of(context).endDate: endDateDisplay,
        },
        description: description,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  holiday.name ?? 'n/a',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                _buildActionButtons(context, ref, holiday),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(
                  time: startDateDisplay, // Use formatted date
                  label: lang.S.of(context).startDate,
                  theme: theme,
                ),
                _buildTimeColumn(
                  time: endDateDisplay, // Use formatted date
                  label: lang.S.of(context).endDate,
                  theme: theme,
                ),
                const SizedBox(width: 50),
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, HolidayData holiday) {
    final permissionService = PermissionService(ref);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!permissionService.hasPermission(Permit.holidaysUpdate.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotHavePermissionToUpgradeHoliday),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewHoliday(holidayData: holiday),
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
            if (!permissionService.hasPermission(Permit.holidaysDelete.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("You do not have permission to delete Holidays."),
                ),
              );
              return;
            }
            if (holiday.id != null) {
              _showDeleteConfirmationDialog(context, ref, holiday.id!);
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

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id) async {
    bool result = await showDeleteConfirmationDialog(
      context: context,
      itemName: lang.S.of(context).holiday,
    );

    if (result) {
      final repo = HolidayRepo();
      await repo.deleteHolidays(id: id, context: context, ref: ref);
      // The repo method handles refreshing the list
    }
  }
}
