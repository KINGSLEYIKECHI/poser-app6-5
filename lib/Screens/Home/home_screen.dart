import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/DashBoard/dashboard.dart';
import 'package:mobile_pos/Screens/Home/components/grid_items.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';

import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../service/check_actions_when_no_branch.dart';
import '../Customers/Provider/customer_provider.dart';
import '../DashBoard/global_container.dart';
import '../Home/Model/banner_model.dart' as b;
import '../../service/check_user_role_permission_provider.dart';
import '../branch/branch_list.dart';
import '../branch/repo/branch_repo.dart';
import '../subscription/package_screen.dart';
import 'Provider/banner_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 0.8);

  bool _isRefreshing = false;

  Future<void> refreshAllProviders({required WidgetRef ref}) async {
    if (_isRefreshing) return; // Prevent multiple refresh calls

    _isRefreshing = true;
    try {
      ref.refresh(summaryInfoProvider);
      ref.refresh(bannerProvider);
      ref.refresh(businessInfoProvider);
      ref.refresh(partiesProvider);
      ref.refresh(getExpireDateProvider(ref));
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (_, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      final summaryInfo = ref.watch(summaryInfoProvider);
      final banner = ref.watch(bannerProvider);
      final permissionService = PermissionService(ref);
      return businessInfo.when(data: (details) {
        final icons = getFreeIcons(
            context: context,
            warehousePermission: (details.data?.addons?.warehouseAddon == true),
            hrmPermission: (details.data?.addons?.hrmAddon == true),
            brunchPermission: (((details.data?.addons?.multiBranchAddon == true) &&
                    (details.data?.enrolledPlan?.allowMultibranch == 1) &&
                    (details.data?.user?.branchId == null)))
                ? true
                : false);
        return Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              backgroundColor: kWhite,
              titleSpacing: 5,
              surfaceTintColor: kWhite,
              actions: [
                if ((details.data?.addons?.multiBranchAddon ?? false) && (details.data?.user?.activeBranch != null))
                  TextButton.icon(
                    label: Text(
                      '${details.data?.user?.activeBranch?.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: kTitleColor),
                    ),
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(2),
                        ),
                      ),
                      textStyle: WidgetStatePropertyAll(
                        theme.textTheme.bodyMedium?.copyWith(color: kTitleColor),
                      ),
                    ),
                    onPressed: () async {
                      if (details.data?.user?.branchId != null) {
                        return;
                      }
                      bool switchBranch = await BranchListScreen.switchDialog(context: context, isLogin: false);
                      if (switchBranch) {
                        EasyLoading.show();

                        final switched =
                            await BranchRepo().exitBranch(id: details.data?.user?.activeBranchId.toString() ?? '');

                        if (switched) {
                          Restart.restartApp();
                        }
                        EasyLoading.dismiss();
                      }
                    },
                    icon: SvgPicture.asset(
                      'assets/branch_icon.svg',
                      height: 16,
                      width: 16,
                    ),
                  ),
                IconButton(onPressed: () async => refreshAllProviders(ref: ref), icon: const Icon(Icons.refresh))
              ],
              leading: Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    const ProfileDetails().launch(context);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: details.data?.pictureUrl == null
                        ? BoxDecoration(
                            image:
                                const DecorationImage(image: AssetImage('images/no_shop_image.png'), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          )
                        : BoxDecoration(
                            image:
                                DecorationImage(image: NetworkImage('${details.data?.pictureUrl}'), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          ),
                  ),
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.data?.user?.role == 'staff'
                        ? '${details.data?.companyName ?? ''} [${details.data?.user?.name ?? ''}]'
                        : details.data?.companyName ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    // onTap: () {
                    //   showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return goToPackagePagePopup(
                    //             context: context,
                    //             enrolledPlan: details.enrolledPlan);
                    //       });
                    // },
                    child: Text.rich(
                        TextSpan(
                          text: '${details.data?.enrolledPlan?.plan?.subscriptionName ?? 'No Active'} Plan',
                          children: [
                            // if (details.enrolledPlan?.duration != null &&
                            //     details.enrolledPlan!.duration! <= 7)
                            //   TextSpan(
                            //     text: ' (${getDayLeftInExpiring(
                            //       expireDate: details.willExpire,
                            //       shortMSG: false,
                            //     )})',
                            //     style: theme.textTheme.bodySmall?.copyWith(
                            //       fontSize: 13,
                            //       color: kPeraColor,
                            //     ),
                            //   ),
                          ],
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: kPeraColor,
                          fontWeight: FontWeight.w500,
                        )),
                  )
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: RefreshIndicator.adaptive(
              onRefresh: () async => refreshAllProviders(ref: ref),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (permissionService.hasPermission(Permit.dashboardRead.value)) ...{
                        summaryInfo.when(data: (summary) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        lang.S.of(context).quickOver,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: kWhite,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => DashboardScreen())),
                                      child: Text(
                                        lang.S.of(context).viewAll,
                                        style: theme.textTheme.bodySmall?.copyWith(color: kWhite, fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        minTileHeight: 0,
                                        titlePadding: EdgeInsets.zero,
                                        // isShadow: true,
                                        textColor: true,
                                        title: lang.S.of(context).sales,
                                        subtitle: '$currency${formatAmount(summary.data!.sales.toString())}',
                                      ),
                                    ),
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        minTileHeight: 0,
                                        // isShadow: true,
                                        textColor: true,
                                        alainRight: true,
                                        titlePadding: EdgeInsets.zero,
                                        title: lang.S.of(context).purchased,
                                        subtitle: '$currency${formatAmount(summary.data!.purchase.toString())}',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        textColor: true,
                                        minTileHeight: 0,
                                        titlePadding: EdgeInsets.zero,
                                        title: lang.S.of(context).income,
                                        subtitle: '$currency${formatAmount(summary.data!.income.toString())}',
                                      ),
                                    ),
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        minTileHeight: 0,
                                        textColor: true,
                                        alainRight: true,
                                        titlePadding: EdgeInsets.zero,
                                        title: lang.S.of(context).expense,
                                        subtitle: '$currency${formatAmount(summary.data!.expense.toString())}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }, error: (e, stack) {
                          return Text(e.toString());
                        }, loading: () {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                        SizedBox(height: 16),
                      },

                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        childAspectRatio: 3.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        children: List.generate(
                          icons.length,
                          (index) => HomeGridCards(
                            gridItems: icons[index],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///________________Banner_______________________________________
                      banner.when(data: (imageData) {
                        List<b.Banner> images = [];
                        if (imageData.isNotEmpty) {
                          images.addAll(imageData.where(
                            (element) => element.status == 1,
                          ));
                        }

                        if (images.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.S.of(context).whatNew,
                                textAlign: TextAlign.start,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                height: 150,
                                width: MediaQuery.of(context).size.width,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: images.length,
                                  itemBuilder: (_, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        const PackageScreen().launch(context);
                                      },
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(end: 10), // Spacing between items
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Image.network(
                                            "${images[index].imageUrl}",
                                            width: MediaQuery.of(context).size.width * 0.7, // 80% width
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        } else {
                          return Center(
                            child: Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('images/banner1.png'),
                                ),
                              ),
                            ),
                          );
                        }
                      }, error: (e, stack) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: Text(
                              lang.S.of(context).noDataFound,
                              style: theme.textTheme.titleMedium,
                              //'No Data Found'
                            ),
                          ),
                        );
                      }, loading: () {
                        return const CircularProgressIndicator();
                      }),
                    ],
                  ),
                ),
              ),
            ));
      }, error: (e, stack) {
        return Center(child: Text(e.toString()));
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}

class HomeGridCards extends StatefulWidget {
  const HomeGridCards({
    super.key,
    required this.gridItems,
    // this.visibility,
  });

  final GridItems gridItems;
  // final business.Visibility? visibility;

  @override
  State<HomeGridCards> createState() => _HomeGridCardsState();
}

class _HomeGridCardsState extends State<HomeGridCards> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return GestureDetector(
        onTap: () async {
          bool result = await checkActionWhenNoBranch(context: context, actionName: widget.gridItems.title, ref: ref);
          if (!result) {
            return;
          }
          Navigator.of(context).pushNamed('/${widget.gridItems.route}');
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kWhite, boxShadow: [
            BoxShadow(
                color: const Color(0xff171717).withOpacity(0.07),
                offset: const Offset(0, 3),
                blurRadius: 50,
                spreadRadius: -4)
          ]),
          child: Row(
            children: [
              SvgPicture.asset(
                widget.gridItems.icon.toString(),
                height: 40,
                width: 40,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                  child: Text(
                widget.gridItems.title.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: DAppColors.kNeutral700),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ))
            ],
          ),
        ),
      );
    });
  }
}

String getSubscriptionExpiring({required String? expireDate, required bool shortMSG}) {
  if (expireDate == null) {
    return shortMSG ? 'N/A' : lang.S.current.subscribeNow;
  }
  DateTime expiringDay = DateTime.parse(expireDate).add(const Duration(days: 1));
  if (expiringDay.isBefore(DateTime.now())) {
    return lang.S.current.expired;
  }
  if (expiringDay.difference(DateTime.now()).inDays < 1) {
    return shortMSG
        ? '${expiringDay.difference(DateTime.now()).inHours}\n${lang.S.current.hoursLeft}'
        : '${expiringDay.difference(DateTime.now()).inHours} ${lang.S.current.hoursLeft}';
  } else {
    return shortMSG
        ? '${expiringDay.difference(DateTime.now()).inDays}\n${lang.S.current.daysLeft}'
        : '${expiringDay.difference(DateTime.now()).inDays} ${lang.S.current.daysLeft}';
  }
}
