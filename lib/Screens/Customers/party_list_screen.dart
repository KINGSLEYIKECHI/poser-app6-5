import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/Customers/advance_collection_screen.dart';
import 'package:mobile_pos/Screens/Sales/provider/sales_cart_provider.dart';
import 'package:mobile_pos/Screens/Customers/Provider/customer_provider.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/Screens/Customers/customer_details.dart';
import 'package:mobile_pos/Screens/Sales/add_sales.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/deleteing_alart_dialog.dart';
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../currency.dart';
import '../../service/check_actions_when_no_branch.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'Repo/parties_repo.dart';

class PartyListScreen extends StatefulWidget {
  final bool isSelectionMode;

  const PartyListScreen({super.key, this.isSelectionMode = false});

  @override
  State<PartyListScreen> createState() => _PartyListScreenState();
}

class _PartyListScreenState extends State<PartyListScreen> {
  late Color color;
  bool _isRefreshing = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    ref.refresh(partiesProvider);

    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  String? partyType;

  // Define party types based on the mode
  List<String> get availablePartyTypes {
    if (widget.isSelectionMode) {
      return [
        PartyType.customer,
        PartyType.dealer,
        PartyType.wholesaler,
      ];
    } else {
      return [
        PartyType.customer,
        PartyType.supplier,
        PartyType.dealer,
        PartyType.wholesaler,
      ];
    }
  }

  // --- Updated Shimmer Loading Widget ---
  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Leading: Circle Avatar Placeholder
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 15),

                // 2. Body: Title and Subtitle Placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row (Name + Amount)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 16,
                            width: 140, // Name width
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 16,
                            width: 60, // Amount width
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Subtitle Row (Type + Status)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 14,
                            width: 100, // Type width
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 14,
                            width: 80, // Status width
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // 3. Trailing: Menu Dots Placeholder
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(partiesProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);

        final appBarTitle = widget.isSelectionMode ? lang.S.of(context).chooseCustomer : lang.S.of(context).partyList;

        return businessInfo.when(
          data: (details) {
            return GlobalPopup(
              child: Scaffold(
                backgroundColor: kWhite,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.black),
                  elevation: 0.0,
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    appBarTitle,
                    style: _theme.textTheme.titleMedium?.copyWith(color: Colors.black),
                  ),
                ),
                body: RefreshIndicator.adaptive(
                  onRefresh: () => refreshData(ref),
                  child: Column(
                    children: [
                      // Search and Filter Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                        child: TextFormField(
                          controller: _searchController,
                          autofocus: false, // Changed to false to prevent keyboard pop-up on load
                          decoration: InputDecoration(
                            hintText: lang.S.of(context).search,
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: const BoxDecoration(
                                        color: Color(0xffF7F7F7),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        )),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        hint: Text(lang.S.of(context).selectType),
                                        icon: partyType != null
                                            ? IconButton(
                                                icon: Icon(Icons.clear, color: kMainColor, size: 18),
                                                onPressed: () {
                                                  setState(() {
                                                    partyType = null;
                                                  });
                                                },
                                              )
                                            : const Icon(Icons.keyboard_arrow_down, color: kPeraColor),
                                        value: partyType,
                                        onChanged: (String? value) {
                                          setState(() {
                                            partyType = value;
                                          });
                                        },
                                        items: availablePartyTypes.map((entry) {
                                          final valueToStore = entry.toLowerCase();
                                          return DropdownMenuItem<String>(
                                            value: valueToStore,
                                            child: Text(
                                              getPartyTypeLabel(context, valueToStore),
                                              style: _theme.textTheme.bodyLarge?.copyWith(color: kTitleColor),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                          onChanged: (value) {
                            setState(() {
                              _isSearching = value.isNotEmpty;
                            });
                          },
                        ),
                      ),

                      if (widget.isSelectionMode)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          onTap: () {
                            AddSalesScreen(customerModel: null).launch(context);
                            ref.refresh(cartNotifier);
                          },
                          leading: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.asset(
                                  'images/no_shop_image.png',
                                  fit: BoxFit.cover,
                                  width: 120.0,
                                  height: 120.0,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            lang.S.of(context).walkInCustomer,
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              color: kTitleColor,
                              fontSize: 16.0,
                            ),
                          ),
                          subtitle: Text(
                            lang.S.of(context).guest,
                            style: _theme.textTheme.bodyLarge,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Color(0xff4B5563),
                          ),
                        ),

                      // Data List
                      Expanded(
                        child: providerData.when(
                          data: (partyList) {
                            if (!widget.isSelectionMode && !permissionService.hasPermission(Permit.partiesRead.value)) {
                              return const Center(child: PermitDenyWidget());
                            }

                            final filteredParties = partyList.where((c) {
                              final normalizedType = (c.type ?? '').toLowerCase();

                              if (widget.isSelectionMode && normalizedType == 'supplier') {
                                return false;
                              }

                              final nameMatches = !_isSearching || _searchController.text.isEmpty
                                  ? true
                                  : (c.name ?? '').toLowerCase().contains(_searchController.text.toLowerCase());

                              final effectiveType = normalizedType == 'retailer' ? 'customer' : normalizedType;
                              final typeMatches =
                                  partyType == null || partyType!.isEmpty ? true : effectiveType == partyType;

                              return nameMatches && typeMatches;
                            }).toList();

                            if (filteredParties.isEmpty) {
                              return Center(
                                child: EmptyWidget(
                                  message: TextSpan(text: lang.S.of(context).noParty),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: filteredParties.length,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (_, index) {
                                final item = filteredParties[index];
                                final normalizedType = (item.type ?? '').toLowerCase();

                                color = Colors.white;
                                if (normalizedType == 'retailer' || normalizedType == 'customer') {
                                  color = const Color(0xFF56da87);
                                }
                                if (normalizedType == 'wholesaler') color = const Color(0xFF25a9e0);
                                if (normalizedType == 'dealer') color = const Color(0xFFff5f00);
                                if (normalizedType == 'supplier') color = const Color(0xFFA569BD);

                                String effectiveDisplayType;
                                if (normalizedType == 'retailer') {
                                  effectiveDisplayType = lang.S.of(context).customer;
                                } else if (normalizedType == 'wholesaler') {
                                  effectiveDisplayType = lang.S.of(context).wholesaler;
                                } else if (normalizedType == 'dealer') {
                                  effectiveDisplayType = lang.S.of(context).dealer;
                                } else if (normalizedType == 'supplier') {
                                  effectiveDisplayType = lang.S.of(context).supplier;
                                } else {
                                  effectiveDisplayType = item.type ?? '';
                                }

                                String statusText;
                                Color statusColor;
                                num? statusAmount;

                                if (item.due != null && item.due! > 0) {
                                  statusText = lang.S.of(context).due;
                                  statusColor = const Color(0xFFff5f00);
                                  statusAmount = item.due;
                                } else if (item.openingBalanceType?.toLowerCase() == 'advance' &&
                                    item.wallet != null &&
                                    item.wallet! > 0) {
                                  statusText = lang.S.of(context).advance;
                                  statusColor = DAppColors.kSecondary;
                                  statusAmount = item.wallet;
                                } else {
                                  statusText = lang.S.of(context).noDue;
                                  statusColor = DAppColors.kSecondary;
                                  statusAmount = null;
                                }

                                return ListTile(
                                  visualDensity: const VisualDensity(vertical: -2),
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () {
                                    if (widget.isSelectionMode) {
                                      AddSalesScreen(customerModel: item).launch(context);
                                      ref.refresh(cartNotifier);
                                    } else {
                                      CustomerDetails(party: item).launch(context);
                                    }
                                  },
                                  leading: item.image != null
                                      ? Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: DAppColors.kBorder, width: 0.3),
                                            image: DecorationImage(
                                              image: NetworkImage('${item.image ?? ''}'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : CircleAvatarWidget(name: item.name),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            color: kTitleColor,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusAmount != null ? '$currency${statusAmount.toStringAsFixed(2)}' : '',
                                        style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          effectiveDisplayType,
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
                                        statusText,
                                        style: _theme.textTheme.bodyMedium?.copyWith(
                                          color: statusColor,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    offset: const Offset(0, 30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (BuildContext bc) => [
                                      PopupMenuItem(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CustomerDetails(party: item),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove_red_eye, color: kGreyTextColor, size: 20),
                                            SizedBox(width: 8.0),
                                            Text(lang.S.of(context).view, style: TextStyle(color: kGreyTextColor)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        onTap: () async {
                                          Future.delayed(
                                            const Duration(seconds: 0),
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AdvanceCollectionScreen(party: item),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.account_balance_wallet_outlined,
                                                color: kGreyTextColor, size: 20),
                                            SizedBox(width: 8.0),
                                            Text('Advance Collection', style: TextStyle(color: kGreyTextColor)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        onTap: () async {
                                          bool result = await checkActionWhenNoBranch(ref: ref, context: context);
                                          if (!permissionService.hasPermission(Permit.partiesUpdate.value)) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(lang.S.of(context).updatePartyWarn),
                                              ),
                                            );
                                            return;
                                          }
                                          if (result) {
                                            AddParty(customerModel: item).launch(context);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(IconlyBold.edit, color: kGreyTextColor, size: 20),
                                            SizedBox(width: 8.0),
                                            Text(lang.S.of(context).edit, style: TextStyle(color: kGreyTextColor)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        onTap: () async {
                                          bool result = await checkActionWhenNoBranch(ref: ref, context: context);
                                          if (!permissionService.hasPermission(Permit.partiesDelete.value)) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(lang.S.of(context).deletePartyWarn),
                                              ),
                                            );
                                            return;
                                          }
                                          if (result) {
                                            bool confirmDelete =
                                                await showDeleteConfirmationDialog(context: context, itemName: 'party');
                                            if (confirmDelete) {
                                              final party = PartyRepository();
                                              await party.deleteParty(
                                                  id: item.id.toString(), context: context, ref: ref);
                                            }
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(IconlyBold.delete, color: kGreyTextColor, size: 20),
                                            SizedBox(width: 8.0),
                                            Text(lang.S.of(context).delete, style: TextStyle(color: kGreyTextColor)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      Navigator.pushNamed(context, '$value');
                                    },
                                    child: const Icon(
                                      FeatherIcons.moreVertical,
                                      color: kGreyTextColor,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          // Replaced Text error with EmptyWidget containing message
                          error: (e, stack) {
                            return Center(
                              child: EmptyWidget(
                                message: TextSpan(text: e.toString()),
                              ),
                            );
                          },
                          // Replaced CircularProgressIndicator with Shimmer Loading
                          loading: () => _buildShimmerLoading(),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ElevatedButton.icon(
                    style: OutlinedButton.styleFrom(
                      maximumSize: const Size(double.infinity, 48),
                      minimumSize: const Size(double.infinity, 48),
                      disabledBackgroundColor: _theme.colorScheme.primary.withAlpha(15),
                      disabledForegroundColor: const Color(0xff567DF4).withOpacity(0.05),
                    ),
                    onPressed: () async {
                      bool result = await checkActionWhenNoBranch(ref: ref, context: context);
                      if (result) {
                        if (details.data?.subscriptionDate != null && details.data?.enrolledPlan != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddParty()));
                        } else if (!widget.isSelectionMode) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddParty()));
                        }
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    iconAlignment: IconAlignment.start,
                    label: Text(
                      lang.S.of(context).addCustomer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.colorScheme.primaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          // Error handler for business info
          error: (e, stack) => Scaffold(
            body: Center(
              child: EmptyWidget(message: TextSpan(text: e.toString())),
            ),
          ),
          // Loading handler for business info
          loading: () => Scaffold(
            body: _buildShimmerLoading(),
          ),
        );
      },
    );
  }
}
