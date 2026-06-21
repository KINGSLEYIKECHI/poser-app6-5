import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/hrm/designation/add_new_designation.dart';
import 'package:mobile_pos/Screens/hrm/designation/provider/designation_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/designation/repo/designation_repo.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/Screens/hrm/widgets/global_search_appbar.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';

import '../../../generated/l10n.dart' as lang;
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';

class DesignationListScreen extends ConsumerStatefulWidget {
  const DesignationListScreen({super.key});

  @override
  ConsumerState<DesignationListScreen> createState() => _DesignationListScreenState();
}

class _DesignationListScreenState extends ConsumerState<DesignationListScreen> {
  bool _isSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _refreshList() async {
    await ref.refresh(designationListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    final theme = Theme.of(context);
    final designationAsync = ref.watch(designationListProvider);
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
        title: _lang.designation,
        controller: _searchController,
        onChanged: (query) {
          setState(() => _searchQuery = query.trim().toLowerCase());
        },
      ),
      body: designationAsync.when(
        data: (data) {
          if (!permissionService.hasPermission(Permit.designationsRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          final designationList = data.data ?? [];

          // Search filter
          final filteredList = designationList.where((item) {
            final name = item.name?.toLowerCase() ?? '';
            final desc = item.description?.toLowerCase() ?? '';
            return name.contains(_searchQuery) || desc.contains(_searchQuery);
          }).toList();

          if (filteredList.isEmpty) {
            return Center(child: Text(_lang.noDesignationFound));
          }

          return RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (_, index) {
                final desig = filteredList[index];
                return ListTile(
                  onTap: () {
                    viewModalSheet(
                      context: context,
                      item: {
                        _lang.designation: desig.name ?? 'n/a',
                        _lang.status: (desig.status == 1) ? _lang.active : _lang.inactive,
                      },
                      description: desig.description ?? _lang.noDescriptionAvailableForThisDesignation,
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
                          desig.name ?? 'n/a',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: desig.status.toString() != '1'
                                    ? kMainColor.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1)),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0, left: 8),
                              child: Text(
                                desig.status.toString() == '1' ? _lang.active : _lang.inactive ?? '',
                                style: theme.textTheme.titleMedium?.copyWith(),
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            onPressed: () {
                              if (!permissionService.hasPermission(Permit.designationsUpdate.value)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(_lang.youDoNotPermissionToUpdateDesignation),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditDesignation(
                                    isEdit: true,
                                    designation: desig,
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
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          desig.description ?? 'n/a',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: kNeutral800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: () async {
                          if (!permissionService.hasPermission(Permit.designationsDelete.value)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(_lang.youDoNotHavePermissionToDeleteDesignation),
                              ),
                            );
                            return;
                          }
                          final confirm = await showDeleteConfirmationDialog(
                            itemName: _lang.designation,
                            context: context,
                          );

                          if (confirm) {
                            EasyLoading.show(status: _lang.deleting);
                            final repo = DesignationRepo();
                            try {
                              final result =
                                  await repo.deleteDesignation(id: desig.id.toString(), ref: ref, context: context);
                              if (result) {
                                ref.refresh(designationListProvider);
                                EasyLoading.showSuccess(_lang.deletedSuccessFully);
                              } else {
                                EasyLoading.showError(_lang.failedToDeleteTheTax);
                              }
                            } catch (e) {
                              EasyLoading.showError('${_lang.errorDeletingTax}: $e');
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
        error: (err, _) => Center(child: Text('Failed to load designations.\n$err')),
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.designationsCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditDesignation(),
                    ),
                  );
                },
                label: Text(_lang.addDesignation),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
