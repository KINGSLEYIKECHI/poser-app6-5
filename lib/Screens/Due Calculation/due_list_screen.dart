import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Providers/due_provider.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/guest_due_collection_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/due_collection_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart' as DAppColors;
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Customers/Provider/customer_provider.dart';
import '../../service/check_user_role_permission_provider.dart';

class DueCalculationContactScreen extends StatefulWidget {
  const DueCalculationContactScreen({super.key});

  @override
  State<DueCalculationContactScreen> createState() => _DueCalculationContactScreenState();
}

class _DueCalculationContactScreenState extends State<DueCalculationContactScreen> {
  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return GlobalPopup(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: kWhite,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).dueList,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Column(
                children: [
                  const Divider(height: 2, color: kBackgroundColor),
                  Theme(
                    data: _theme.copyWith(
                      tabBarTheme: const TabBarThemeData(dividerColor: kBackgroundColor),
                    ),
                    child: TabBar(
                      labelStyle: _theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                      labelColor: kMainColor, // Selected Color
                      unselectedLabelColor: kPeraColor,
                      indicatorColor: kMainColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: 'Party Due'),
                        const Tab(text: 'Guest Due'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              // First Tab: Regular customers' Due List
              _buildRegularDueList(context, _theme),

              // Second Tab: Guest Due List
              _buildGuestDueList(context, _theme),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== First Tab: Regular Due List =====================
  Widget _buildRegularDueList(BuildContext context, ThemeData _theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Consumer(builder: (context, ref, __) {
        final providerData = ref.watch(partiesProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);

        return providerData.when(data: (parties) {
          List<Party> dueCustomerList = [];

          for (var party in parties) {
            if ((party.due ?? 0) > 0) {
              dueCustomerList.add(party);
            }
          }

          return dueCustomerList.isNotEmpty
              ? businessInfo.when(data: (details) {
                  if (!permissionService.hasPermission(Permit.duesRead.value)) {
                    return const Center(child: PermitDenyWidget());
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dueCustomerList.length,
                      itemBuilder: (_, index) {
                        final item = dueCustomerList[index];
                        final (color, type) = switch (item.type?.trim().toLowerCase()) {
                          "retailer" => (const Color(0xFF56da87), lang.S.of(context).customer),
                          "wholesaler" => (const Color(0xFF25a9e0), lang.S.of(context).wholesaler),
                          "dealer" => (const Color(0xFFff5f00), lang.S.of(context).dealer),
                          "supplier" => (const Color(0xFFA569BD), lang.S.of(context).supplier),
                          _ => (Colors.black, ''),
                        };

                        return ListTile(
                          visualDensity: const VisualDensity(vertical: -2),
                          contentPadding: EdgeInsets.zero,
                          onTap: () async {
                            DueCollectionScreen(customerModel: item).launch(context);
                          },
                          leading: item.image != null
                              ? Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: DAppColors.kBorder, width: 0.3),
                                    image: DecorationImage(
                                      image: NetworkImage(item.image ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : CircleAvatarWidget(name: item.name ?? 'n/a'),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name ?? '',
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$currency ${item.due}',
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    color: color,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.due != null && item.due != 0 ? lang.S.of(context).due : 'No Due',
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  color: item.due != null && item.due != 0
                                      ? const Color(0xFFff5f00)
                                      : const Color(0xff808191),
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            IconlyLight.arrow_right_2,
                            size: 18,
                          ),
                        );
                      });
                }, error: (e, stack) {
                  return _buildShimmerLoading();
                }, loading: () {
                  return _buildShimmerLoading();
                })
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      lang.S.of(context).noDataAvailabe,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                  ),
                );
        }, error: (e, stack) {
          return Center(child: Text(e.toString()));
        }, loading: () {
          return _buildShimmerLoading();
        });
      }),
    );
  }

  // ===================== Second Tab: Guest Due List =====================
  Widget _buildGuestDueList(BuildContext context, ThemeData _theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Consumer(builder: (context, ref, __) {
        final guestDueData = ref.watch(guestDueListProvider);
        final permissionService = PermissionService(ref);

        return guestDueData.when(
          data: (guestDues) {
            if (!permissionService.hasPermission(Permit.duesRead.value)) {
              return const Center(child: PermitDenyWidget());
            }

            if (guestDues.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    lang.S.of(context).noDataAvailabe,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guestDues.length,
              itemBuilder: (_, index) {
                final item = guestDues[index];

                // Format the Date
                String formattedDate = '';
                if (item.saleDate != null) {
                  try {
                    formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(item.saleDate!));
                  } catch (e) {
                    formattedDate = item.saleDate!;
                  }
                }

                return ListTile(
                  visualDensity: const VisualDensity(vertical: -2),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    GuestDueCollectionScreen(guestDueModel: item).launch(context);
                  },
                  leading: const CircleAvatarWidget(name: 'Guest'),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Invoice: ${item.invoiceNumber ?? 'N/A'}',
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currency ${item.dueAmount ?? 0}',
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: kPeraColor,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lang.S.of(context).due,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFff5f00),
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    IconlyLight.arrow_right_2,
                    size: 18,
                  ),
                );
              },
            );
          },
          error: (e, stack) => Center(child: Text(e.toString())),
          loading: () => _buildShimmerLoading(),
        );
      }),
    );
  }

  // ===================== Shimmer Loading Widget =====================
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 16, width: 150, color: Colors.white),
                          Container(height: 16, width: 60, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 14, width: 100, color: Colors.white),
                          Container(height: 14, width: 50, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(height: 18, width: 18, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
