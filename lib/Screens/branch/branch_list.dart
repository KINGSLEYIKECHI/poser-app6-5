import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_pos/Screens/branch/provider/branch_list_provider.dart';
import 'package:mobile_pos/Screens/branch/repo/branch_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:restart_app/restart_app.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../Provider/profile_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../../widgets/key_values/key_values_widget.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'add_and_edit_brunch_screen.dart';

class BranchListScreen extends ConsumerStatefulWidget {
  const BranchListScreen({super.key});
  static Future<bool> switchDialog({required BuildContext context, required bool isLogin}) async {
    const Color primaryColor = Color(0xffC52127);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      radius: 30,
                      child: Icon(
                        Icons.sync_alt_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isLogin ? l.S.of(context).switchBank : l.S.of(context).exitBank,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLogin
                          ? l.S.of(context).areYouSureWantToSwitchToDifferentBranch
                          : l.S.of(context).areYourSureYouWantToExitFromThisBranch,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: kMainColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              l.S.of(context).cancel,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              isLogin ? l.S.of(context).switchs : l.S.of(context).exit,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  @override
  ConsumerState<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends ConsumerState<BranchListScreen> {
  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _lang.branchList,
          style: _theme.textTheme.bodyMedium?.copyWith(
            color: kTitleColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFE8E9F2),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAndEditBranch(),
                ));
          },
          label: Text(_lang.createBranch),
        ),
      ),
      body: const BranchListWidget(formFullPage: true),
    );
  }
}

class BranchListWidget extends ConsumerWidget {
  const BranchListWidget({required this.formFullPage, super.key});

  final bool formFullPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _theme = Theme.of(context);
    final branchList = ref.watch(branchListProvider);
    final profile = ref.watch(businessInfoProvider);
    final permissionService = PermissionService(ref);

    return branchList.when(
      data: (snapshot) {
        if (!permissionService.hasPermission(Permit.branchesRead.value)) {
          return const Center(child: PermitDenyWidget());
        }
        return profile.when(
          data: (profileSnap) {
            final activeBranchId = profileSnap.data?.user?.activeBranchId;
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                ref.refresh(branchListProvider);
                ref.refresh(businessInfoProvider);
              },
              child: snapshot.data?.isNotEmpty ?? false
                  ? ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemBuilder: (context, index) {
                        final branch = snapshot.data?[index];
                        final isActiveBranch = branch?.id == activeBranchId;

                        Future<void> _handleMenuAction(String value) async {
                          switch (value) {
                            case 'view':
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (context) => _buildViewDetailsSheet(context, _theme, branch),
                              );
                              break;
                            case 'edit':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddAndEditBranch(
                                      branchData: branch,
                                    ),
                                  ));
                              break;
                            case 'delete':
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
                                              l.S.of(context).areYourSureYouWantToExitFromThisBranch,
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
                                                    child: Text(l.S.of(context).cancel),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      await Future.delayed(Duration.zero);
                                                      BranchRepo repo = BranchRepo();
                                                      bool success;
                                                      success = await repo.deleteUser(
                                                          id: branch?.id.toString() ?? '', context: context, ref: ref);
                                                      if (success) {
                                                        ref.refresh(branchListProvider);
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                            content: Text(l.S.of(context).deletedSuccessFully)));
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Text(l.S.of(context).delete),
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
                              break;

                            case 'login':
                              bool switchBranch = await BranchListScreen.switchDialog(
                                context: context,
                                isLogin: true,
                              );

                              if (switchBranch) {
                                EasyLoading.show();

                                final switched = await BranchRepo().switchBranch(id: branch?.id.toString() ?? '');

                                if (switched) {
                                  ref.refresh(branchListProvider);
                                  ref.refresh(businessInfoProvider);
                                  Restart.restartApp();
                                }
                                EasyLoading.dismiss();
                              }
                              break;

                            case 'exit':
                              bool exitBranch = await BranchListScreen.switchDialog(
                                context: context,
                                isLogin: false,
                              );

                              if (exitBranch) {
                                EasyLoading.show();

                                final switched = await BranchRepo().exitBranch(id: branch?.id.toString() ?? '');

                                if (switched) {
                                  ref.refresh(branchListProvider);
                                  ref.refresh(businessInfoProvider);
                                  Restart.restartApp();
                                }
                                EasyLoading.dismiss();
                              }
                              break;

                            default:
                              debugPrint('Unknown menu action: $value');
                          }
                        }

                        return ListTile(
                          onTap: () async {
                            await _handleMenuAction(isActiveBranch ? 'exit' : 'login');
                          },
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Row(
                            children: [
                              Text(
                                branch?.name?.toString() ?? 'n/a',
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  color: kTitleColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isActiveBranch) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: const Color(0xff08B935).withOpacity(0.12),
                                  ),
                                  child: Text(
                                    l.S.of(context).currents,
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xff00A92B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                          subtitle: Text(
                            branch?.address?.toString() ?? 'n/a',
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xff4B5563),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xff4B5563),
                            ),
                            onSelected: _handleMenuAction,
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'view',
                                child: Text(l.S.of(context).view),
                              ),
                              if (PermissionService(ref).hasPermission(Permit.branchesUpdate.value))
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text(l.S.of(context).edit),
                                ),
                              if (PermissionService(ref).hasPermission(Permit.branchesDelete.value))
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text(l.S.of(context).delete),
                                ),
                              // You can uncomment these if you want to enable login/exit from menu
                              // PopupMenuItem<String>(
                              //   value: 'login',
                              //   child: Text('Login'),
                              // ),
                              // PopupMenuItem<String>(
                              //   value: 'exit',
                              //   child: Text('Exit'),
                              // ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 0,
                        color: Color(0xffDADADA),
                      ),
                    )
                  : EmptyWidget(
                      message: TextSpan(text: l.S.of(context).noBrunchFound),
                    ),
            );
          },
          error: (e, stack) => Center(child: Text(e.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (e, stack) => Center(child: Text(e.toString())),
      loading: () => formFullPage
          ? const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator()))
          : Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.transparent),
              child: const Center(child: SizedBox(height: 40, width: 40, child: CircularProgressIndicator()))),
    );
  }

  Widget _buildViewDetailsSheet(BuildContext context, ThemeData theme, dynamic branch) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.S.of(context).viewDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xff121535),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const CloseButton(),
              ],
            ),
          ),
          const Divider(
            height: 0,
            color: Color(0xffE6E6E6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ...{
                l.S.of(context).name: branch?.name?.toString() ?? 'n/a',
                l.S.of(context).phone: branch?.phone?.toString() ?? 'n/a',
                l.S.of(context).email: branch?.email?.toString() ?? 'n/a',
                l.S.of(context).address: branch?.address?.toString() ?? 'n/a',
              }.entries.map(
                (entry) {
                  return KeyValueRow(
                    title: entry.key,
                    titleFlex: 1,
                    description: entry.value.toString(),
                    descriptionFlex: 4,
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                l.S.of(context).description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kTitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                branch?.description?.toString() ?? 'n/a',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xff4B5563),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
