import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/hrm/employee/add_new_employee.dart';
import 'package:mobile_pos/Screens/hrm/employee/provider/emplpyee_list_provider.dart';
import 'package:mobile_pos/Screens/hrm/employee/repo/employee_repo.dart';
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/Screens/hrm/widgets/global_search_appbar.dart';
import 'package:mobile_pos/Screens/hrm/widgets/model_bottom_sheet.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../../../Const/api_config.dart';
import '../../../generated/l10n.dart' as lang;
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  bool _isSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 2. Refresh logic using Riverpod's invalidate
  Future<void> _refreshEmployeeList() async {
    // Invalidate the provider, which forces it to refetch the data
    ref.invalidate(employeeListProvider);
    // Wait for the new future to complete
    await ref.read(employeeListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final _theme = Theme.of(context);
    final employeeListAsync = ref.watch(employeeListProvider);
    final permissionService = PermissionService(ref);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: GlobalSearchAppBar(
        isSearch: _isSearch,
        onSearchToggle: () {
          setState(() {
            _isSearch = !_isSearch;
            if (!_isSearch) {
              _searchController.clear();
              _searchQuery = '';
            }
          });
        },
        title: _lang.employee,
        controller: _searchController,
        onChanged: (query) {
          // Listener handles the search logic
        },
      ),
      body: employeeListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (employeeModel) {
          if (!permissionService.hasPermission(Permit.employeesRead.value)) {
            return const Center(child: PermitDenyWidget());
          }
          final allEmployees = employeeModel.employees ?? [];

          // Filtering logic
          final filteredEmployees = allEmployees.where((employee) {
            final nameLower = employee.name?.toLowerCase() ?? '';
            final phoneLower = employee.phone?.toLowerCase() ?? '';
            final emailLower = employee.email?.toLowerCase() ?? '';

            return nameLower.contains(_searchQuery) ||
                phoneLower.contains(_searchQuery) ||
                emailLower.contains(_searchQuery);
          }).toList();

          if (filteredEmployees.isEmpty) {
            return Center(
                child:
                    Text(_searchQuery.isEmpty ? _lang.noEmployeeFound : '${_lang.noResultFoundFor} "$_searchQuery".'));
          }

          // 3. Wrap the ListView with RefreshIndicator
          return RefreshIndicator(
            onRefresh: _refreshEmployeeList, // Calls the Riverpod refresh logic
            child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (_, index) {
                  final employee = filteredEmployees[index];

                  // Dynamic Data Mapping
                  final name = employee.name ?? 'N/A';
                  final phone = employee.phone ?? 'N/A';
                  final designation = employee.designation?.name ?? 'N/A';
                  final department = employee.department?.name ?? 'N/A';
                  final image = employee.image;
                  final email = employee.email ?? 'N/A';
                  final country = employee.country ?? 'N/A';
                  final salary = '\$${employee.amount?.toStringAsFixed(2) ?? '0.00'}';
                  final gender = employee.gender ?? 'N/A';
                  final shift = employee.shift?.name ?? 'N/A';
                  final birthDate = employee.birthDate ?? 'N/A';
                  final joinDate = employee.joinDate ?? 'N/A';
                  final status = employee.status ?? 'N/A';

                  return ListTile(
                    onTap: () {
                      // Displaying dynamic data in Modal Sheet
                      viewModalSheet(
                        context: context,
                        showImage: true,
                        image: image,
                        item: {
                          _lang.fullName: name,
                          _lang.designation: designation,
                          _lang.department: department,
                          _lang.email: email,
                          _lang.phone: phone,
                          _lang.country: country,
                          _lang.salary: salary,
                          _lang.gender: gender,
                          _lang.shift: shift,
                          _lang.birthDate: birthDate,
                          _lang.joinDate: joinDate,
                          _lang.status: status,
                        },
                      );
                    },
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    horizontalTitleGap: 14,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    leading: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: kMainColor.withValues(alpha: 0.1)),
                      child: image == null
                          ? Text(
                              name.substring(0, 1),
                              style: _theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: kMainColor,
                              ),
                            )
                          : Image.network(
                              fit: BoxFit.fill,
                              "$image",
                            ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: _theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 28,
                          width: 28,
                          child: IconButton(
                            style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.zero,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            onPressed: () {
                              if (!permissionService.hasPermission(Permit.employeesUpdate.value)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(_lang.youDoNotHavePermissionToUpdateEmployee),
                                  ),
                                );
                                return;
                              }
                              // Navigation to edit employee screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewEmployee(
                                    isEdit: true,
                                    employeeToEdit: employee,
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
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(
                          phone,
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: kNeutral800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        SizedBox(
                          height: 28,
                          width: 28,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                EdgeInsets.zero,
                              ),
                            ),
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            onPressed: () async {
                              if (!permissionService.hasPermission(Permit.employeesDelete.value)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(_lang.youDoNotHavePermissionToUpdateEmployee),
                                  ),
                                );
                                return;
                              }
                              final confirm = await showDeleteConfirmationDialog(
                                itemName: _lang.employee,
                                context: context,
                              );

                              if (confirm) {
                                EasyLoading.show(status: _lang.deleting);
                                final repo = EmployeeRepo();
                                try {
                                  final result =
                                      await repo.deleteEmployee(id: employee.id.toString(), ref: ref, context: context);
                                  if (result) {
                                    ref.refresh(employeeListProvider);
                                    EasyLoading.showSuccess(_lang.deletedSuccessFully);
                                  } else {
                                    EasyLoading.showError("Failed to delete the Employee");
                                  }
                                } catch (e) {
                                  EasyLoading.showError('Error deleting: $e');
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
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => Divider(
                      color: kBackgroundColor,
                      height: 2,
                    ),
                itemCount: filteredEmployees.length),
          );
        },
      ),
      bottomNavigationBar: permissionService.hasPermission(Permit.employeesCreate.value)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewEmployee()));
                },
                label: Text(_lang.addEmployee),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
