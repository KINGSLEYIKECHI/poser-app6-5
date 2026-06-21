// File: leave_type_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/leave_request/leave_type/add_new_leave_type.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave_type/provider/leave_type_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave_type/repo/leave_type_repo.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/Screens/hrm/widgets/global_search_appbar.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/constant.dart';

import '../../../../service/check_user_role_permission_provider.dart';
import '../../../../widgets/empty_widget/_empty_widget.dart';
import 'model/leave_type_list_model.dart';

class LeaveTypeList extends ConsumerStatefulWidget {
  const LeaveTypeList({super.key});

  @override
  ConsumerState<LeaveTypeList> createState() => _LeaveTypeListState();
}

class _LeaveTypeListState extends ConsumerState<LeaveTypeList> {
  bool _isSearch = false;
  final _searchController = TextEditingController();
  List<LeaveTypeData> _filteredLeaveTypes = [];

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

  // Method to refresh the list manually (for pull-to-refresh)
  Future<void> _refreshList() async {
    ref.invalidate(leaveTypeListProvider);
    // Wait for the future provider to reload
    await ref.read(leaveTypeListProvider.future);
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger widget rebuild to run filter
    });
  }

  void _filterLeaveTypes(List<LeaveTypeData> allTypes) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredLeaveTypes = allTypes;
    } else {
      _filteredLeaveTypes = allTypes.where((type) {
        final nameMatch = (type.name ?? '').toLowerCase().contains(query);
        final descriptionMatch = (type.description ?? '').toLowerCase().contains(query);
        final status = type.status == 1 ? 'active' : 'inactive';
        final statusMatch = status.contains(query);

        return nameMatch || descriptionMatch || statusMatch;
      }).toList();
    }
  }

  String _getStatusText(num? status) {
    if (status == 1) return 'Active';
    if (status == 0) return 'Inactive';
    return 'N/A';
  }

  Color _getStatusColor(num? status) {
    if (status == 1) return kSuccessColor;
    if (status == 0) return Colors.red;
    return kNeutral800;
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final _theme = Theme.of(context);
    final leaveListAsync = ref.watch(leaveTypeListProvider);
    final permissionService = PermissionService(ref);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () => setState(() {
          _isSearch = !_isSearch;
          if (!_isSearch) _searchController.clear();
        }),
        title: _lang.leaveType,
        controller: _searchController,
        onChanged: (query) {
          // Handled by listener
        },
      ),
      body: leaveListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Failed to load leave types: $err'),
        ),
        data: (model) {
          if (!permissionService.hasPermission(Permit.leaveTypesRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          final allTypes = model.data ?? [];
          _filterLeaveTypes(allTypes);

          if (_filteredLeaveTypes.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshList,
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Text(
                    _searchController.text.isEmpty
                        ? _lang.noLeaveTypeFound
                        : '${_lang.noRequestFoundFor} "${_searchController.text}".',
                    style: _theme.textTheme.titleMedium,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (_, index) {
                final leaveType = _filteredLeaveTypes[index];
                return ListTile(
                  onTap: () {
                    viewModalSheet(
                      context: context,
                      item: {
                        _lang.name: leaveType.name ?? 'N/A',
                        _lang.status: _getStatusText(leaveType.status),
                      },
                      description: leaveType.description ?? 'N/A',
                    );
                  },
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          leaveType.name ?? 'n/a',
                          style: _theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildEditButton(context, leaveType),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Text(
                        leaveType.description ?? _lang.noDescription,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: kNeutral800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      _buildDeleteButton(context, ref, leaveType),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(
                color: kBackgroundColor,
                height: 2,
              ),
              itemCount: _filteredLeaveTypes.length,
            ),
          );
        },
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.leaveTypesCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewLeaveType()));
                },
                label: Text(_lang.addLeaveType),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEditButton(BuildContext context, LeaveTypeData leaveType) {
    final permissionService = PermissionService(ref);
    return IconButton(
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.all(0),
        ),
      ),
      padding: EdgeInsets.zero,
      visualDensity: const VisualDensity(
        horizontal: -4,
        vertical: -4,
      ),
      onPressed: () {
        if (!permissionService.hasPermission(Permit.leaveTypesUpdate.value)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(l.S.of(context).youDoNotHavePermissionUpdateTheLeaveType),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            // Pass data for editing
            builder: (context) => AddNewLeaveType(leaveTypeData: leaveType),
          ),
        );
      },
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedPencilEdit02,
        color: kSuccessColor,
        size: 20,
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, WidgetRef ref, LeaveTypeData leaveType) {
    return IconButton(
      padding: EdgeInsets.zero,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.all(0),
        ),
      ),
      visualDensity: const VisualDensity(
        horizontal: -4,
        vertical: -4,
      ),
      onPressed: () {
        if (leaveType.id != null) {
          _showDeleteConfirmationDialog(context, ref, leaveType.id!, leaveType.name ?? 'this leave type');
        }
      },
      icon: const HugeIcon(
        icon: HugeIcons.strokeRoundedDelete03,
        color: Colors.red,
        size: 20,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, num id, String name) async {
    final permissionService = PermissionService(ref);
    if (!permissionService.hasPermission(Permit.leaveTypesDelete.value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(l.S.of(context).youDoNotHavePermissionDeleteTheLeaveType),
        ),
      );
      return;
    }
    bool result = await showDeleteConfirmationDialog(
      context: context,
      itemName: l.S.of(context).leaveType,
    );

    if (result) {
      final repo = LeaveTypeRepo();
      await repo.deleteLeaveType(id: id, context: context, ref: ref);
    }
  }
}
