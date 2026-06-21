// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/hrm/shift/add_new_shift.dart';
import 'package:mobile_pos/Screens/hrm/shift/provider/shift_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/shift/repo/shift_repo.dart';
import 'package:mobile_pos/Screens/hrm/shift/Model/shift_list_model.dart';
import 'package:mobile_pos/Screens/hrm/widgets/global_search_appbar.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/constant.dart';

import '../../../generated/l10n.dart' as lang;
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';

class ShiftScreen extends ConsumerStatefulWidget {
  const ShiftScreen({super.key});

  @override
  ConsumerState<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends ConsumerState<ShiftScreen> {
  bool _isSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshList() async {
    ref.refresh(shiftListProvider);
  }

  /// ✅ Convert "HH:mm" to "hh:mm a" format safely
  String _formatToAmPm(String? time) {
    if (time == null || time.isEmpty || !time.contains(':')) return 'n/a';
    try {
      final date = DateFormat("HH:mm").parse(time);
      return DateFormat("hh:mm a").format(date);
    } catch (_) {
      return time; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncShifts = ref.watch(shiftListProvider);
    final permissionService = PermissionService(ref);
    final _lang = lang.S.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () => setState(() {
          _isSearch = !_isSearch;
          _searchQuery = '';
          _searchController.clear();
        }),
        title: _lang.shift,
        controller: _searchController,
        onChanged: (query) {
          setState(() {
            _searchQuery = query.toLowerCase().trim();
          });
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: asyncShifts.when(
          data: (shiftList) {
            if (!permissionService.hasPermission(Permit.shiftsRead.value)) {
              return const Center(child: PermitDenyWidget());
            }
            final allShifts = shiftList.data ?? [];

            // ✅ Apply search filter
            final shifts = allShifts.where((shift) {
              final name = (shift.name ?? '').toLowerCase();
              return name.contains(_searchQuery);
            }).toList();

            if (shifts.isEmpty) {
              return Center(child: Text(_lang.noShiftFound));
            }

            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: shifts.length,
              separatorBuilder: (_, __) => const Divider(
                color: kBackgroundColor,
                height: 2,
              ),
              itemBuilder: (_, index) {
                final shift = shifts[index];
                return _buildShiftItem(context, shift);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.shiftsCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNewShift(isEdit: false),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(_lang.addShift),
              ),
            )
          : null,
    );
  }

  Widget _buildShiftItem(BuildContext context, ShiftData shift) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => viewModalSheet(
        context: context,
        item: {
          lang.S.of(context).shift: shift.name ?? 'n/a',
          lang.S.of(context).startTime: _formatToAmPm(shift.startTime),
          lang.S.of(context).endTime: _formatToAmPm(shift.endTime),
          lang.S.of(context).breakTime: (shift.startBreakTime == null ||
                  shift.startBreakTime!.isEmpty ||
                  shift.endBreakTime == null ||
                  shift.endBreakTime!.isEmpty)
              ? 'N/A'
              : "${_formatToAmPm(shift.startBreakTime)} - ${_formatToAmPm(shift.endBreakTime)}",
          lang.S.of(context).breakDuration: shift.breakTime?.isEmpty ?? true ? 'N/A' : shift.breakTime!,
          lang.S.of(context).status: shift.status == 1 ? lang.S.of(context).active : lang.S.of(context).inactive,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shift.name ?? 'n/a',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (shift.breakStatus == 'yes')
              Text.rich(
                TextSpan(
                  text: '${lang.S.of(context).breakTime}: ',
                  style: const TextStyle(color: kNeutral800),
                  children: [
                    TextSpan(
                      text: '${_formatToAmPm(shift.startBreakTime)} - ${_formatToAmPm(shift.endBreakTime)}',
                      style: const TextStyle(color: kTitleColor),
                    ),
                  ],
                ),
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 20.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(_formatToAmPm(shift.startTime), lang.S.of(context).startTime, theme),
                _buildTimeColumn(_formatToAmPm(shift.endTime), lang.S.of(context).endTime, theme),
                _buildActionButtons(context, shift),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String time, String label, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: kNeutral800),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, shift) {
    final _lang = lang.S.of(context);
    final permissionService = PermissionService(ref);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (!permissionService.hasPermission(Permit.shiftsUpdate.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(_lang.youDoNotToHavePermissionToUpdateShift),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewShift(
                  isEdit: true,
                  shift: shift,
                ),
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
          onTap: () async {
            if (!permissionService.hasPermission(Permit.shiftsDelete.value)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(lang.S.of(context).youDoNotToHavePermissionToDeleteShift),
                ),
              );
              return;
            }
            final _lang = lang.S.of(context);
            final confirm = await showDeleteConfirmationDialog(
              itemName: _lang.shift,
              context: context,
            );

            if (confirm) {
              EasyLoading.show(status: _lang.deleting);
              final repo = ShiftRepo();
              try {
                final result = await repo.deleteShift(id: shift.id, ref: ref, context: context);
                if (result) {
                  ref.refresh(shiftListProvider);
                  EasyLoading.showSuccess(_lang.deletedSuccessFully);
                } else {
                  EasyLoading.showError('Failed to delete the Shift');
                }
              } catch (e) {
                EasyLoading.showError('Error: $e');
              } finally {
                EasyLoading.dismiss();
              }
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
