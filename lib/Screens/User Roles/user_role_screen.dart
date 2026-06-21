import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Screens/User%20Roles/user_role_details.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../Products/product_details.dart';
import 'Model/user_role_model_new.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'Provider/user_role_provider.dart';
import 'Repo/user_role_repo.dart';
import 'add_user_role_screen.dart';

class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({super.key});

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  bool _isRefreshing = false;

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    ref.refresh(userRoleProvider);

    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final userRoleData = ref.watch(userRoleProvider);
        final _theme = Theme.of(context);
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                _lang.roleAndPermission,
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Color(0xFFE8E9F2),
                  height: 1,
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => refreshData(ref),
              child: userRoleData.when(
                data: (users) {
                  return users.isNotEmpty
                      ? ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          itemCount: users.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final user = users[index];
                            return ListTile(
                              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              title: Text(
                                user.name ?? '',
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  color: kTitleColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                '${_lang.role}: ${user.role ?? ''}',
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  color: Color(0xff5B5B5B),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (PermissionService(ref).hasPermission(Permit.rolesUpdate.value))
                                    IconButton(
                                      icon: const Icon(
                                        IconlyLight.edit_square,
                                        color: Color(0xff00932C),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddUserRoleScreen(userRole: user),
                                          ),
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(),
                                      tooltip: _lang.edit,
                                    ),
                                  if (PermissionService(ref).hasPermission(Permit.rolesDelete.value))
                                    IconButton(
                                      icon: const Icon(
                                        IconlyLight.delete,
                                        color: kMainColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext dialogContext) {
                                            return Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        _lang.areYouSureWantToDeleteThisRole,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 26),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Color(0xffF68A3D).withValues(alpha: 0.1),
                                                        ),
                                                        padding: EdgeInsets.all(20),
                                                        child: SvgPicture.asset(
                                                          height: 126,
                                                          width: 126,
                                                          'images/trash.svg',
                                                        ),
                                                      ),
                                                      SizedBox(height: 26),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: OutlinedButton(
                                                              onPressed: () async {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text(_lang.cancel),
                                                            ),
                                                          ),
                                                          SizedBox(width: 16),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () async {
                                                                await Future.delayed(Duration.zero);
                                                                UserRoleRepo repo = UserRoleRepo();
                                                                bool success;
                                                                success = await repo.deleteUser(
                                                                    id: user.id.toString() ?? '',
                                                                    context: context,
                                                                    ref: ref);
                                                                if (success) {
                                                                  ref.refresh(userRoleProvider);
                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      content: Text(_lang.deletedSuccessFully)));
                                                                  Navigator.pop(context);
                                                                }
                                                              },
                                                              child: Text(_lang.delete),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Delete',
                                    ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              thickness: 1,
                              color: Color(0xffDADADA),
                            );
                          },
                        )
                      : Center(child: Text(lang.S.of(context).noRoleFound));
                },
                error: (e, stack) => Text(e.toString()),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            bottomNavigationBar: (PermissionService(ref).hasPermission(Permit.rolesCreate.value))
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: GestureDetector(
                      onTap: () {
                        if (!PermissionService(ref).hasPermission(Permit.rolesCreate.value)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'You do not have permission to create Role.',
                              ),
                            ),
                          );
                          return;
                        }
                        const AddUserRoleScreen().launch(context);
                      },
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            lang.S.of(context).addUserRole,
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
