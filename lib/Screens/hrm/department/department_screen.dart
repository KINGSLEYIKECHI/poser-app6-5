import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/hrm/department/add_new_depertment.dart';
import 'package:mobile_pos/Screens/hrm/department/provider/department_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/department/repo/department_repo.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/Screens/hrm/widgets/global_search_appbar.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../../generated/l10n.dart' as lang;
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';

class DepartmentScreen extends ConsumerStatefulWidget {
  const DepartmentScreen({super.key});

  @override
  ConsumerState<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends ConsumerState<DepartmentScreen> {
  bool _isSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _refreshList() async {
    await ref.refresh(departmentListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final departmentAsync = ref.watch(departmentListProvider);
    final permissionService = PermissionService(ref);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () => setState(() {
          _isSearch = !_isSearch;
          _searchController.clear();
          _searchQuery = '';
        }),
        title: _lang.department,
        controller: _searchController,
        onChanged: (query) {
          setState(() => _searchQuery = query.trim().toLowerCase());
        },
      ),
      body: departmentAsync.when(
        data: (data) {
          if (!permissionService.hasPermission(Permit.departmentRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          final departmentList = data.data ?? [];

          // Search filter
          final filteredList = departmentList.where((dept) {
            final name = dept.name?.toLowerCase() ?? '';
            final desc = dept.description?.toLowerCase() ?? '';
            return name.contains(_searchQuery) || desc.contains(_searchQuery);
          }).toList();

          if (filteredList.isEmpty) {
            return Center(child: Text(_lang.noDepartmentFound));
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (_, index) {
                final dept = filteredList[index];
                return ListTile(
                  onTap: () {
                    viewModalSheet(
                      context: context,
                      item: {
                        _lang.department: dept.name ?? 'n/a',
                        _lang.status: (dept.status == 1) ? _lang.active : _lang.inactive,
                      },
                      description: dept.description ?? _lang.noDescriptionAvailableForThisDepartment,
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
                          dept.name ?? 'n/a',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: () {
                          if (!permissionService.hasPermission(Permit.departmentUpdate.value)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_lang.youDoNotHavePermissionToUpdateDepartment),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditDepartment(
                                isEdit: true,
                                department: dept,
                              ),
                            ),
                          );
                        },
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit02,
                          color: kSuccessColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          dept.description ?? 'n/a',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: kNeutral800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                        ),
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: () async {
                          if (!permissionService.hasPermission(Permit.departmentDelete.value)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(lang.S.of(context).youDoNotHavePermissionToDeleteDepartment),
                              ),
                            );
                            return;
                          }
                          final _lang = lang.S.of(context);
                          final confirm = await showDeleteConfirmationDialog(
                            itemName: lang.S.of(context).department,
                            context: context,
                          );

                          if (confirm) {
                            EasyLoading.show(status: _lang.deleting);
                            final DepartmentRepo repo = DepartmentRepo();
                            try {
                              final result =
                                  await repo.deleteDepartment(id: dept.id.toString(), ref: ref, context: context);
                              if (result) {
                                ref.refresh(departmentListProvider);
                                EasyLoading.showSuccess(_lang.deletedSuccessFully);
                              } else {
                                EasyLoading.showError(_lang.failedToDeleteTheDeterment);
                              }
                            } catch (e) {
                              EasyLoading.showError('${"Error deleting"}: $e');
                            } finally {
                              EasyLoading.dismiss();
                            }
                          }
                        },
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete03,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(
                color: kBackgroundColor,
                height: 2,
              ),
              itemCount: filteredList.length,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('${lang.S.of(context).failedToLoadDepartment}.\n$err'),
        ),
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.departmentCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEditDepartment(isEdit: false)),
                  );
                },
                label: Text(lang.S.of(context).addDepartment),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
