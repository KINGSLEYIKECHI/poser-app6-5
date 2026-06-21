import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/subscription/payment_getway_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:shimmer/shimmer.dart';

import '../../GlobalComponents/go_to_subscription-package_page_popup_widget.dart';
import '../../constant.dart';
import '../../model/business_info_model.dart' as bInfo;
import '../Currency/Model/currency_model.dart';
import '../Currency/Provider/currency_provider.dart';
import '../Home/home.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'Model/subscription_plan_model.dart';
import 'Provider/subacription_plan_provider.dart';
import 'Repo/subscriptionPlanRepo.dart';

class PurchasePremiumPlanScreen extends ConsumerStatefulWidget {
  const PurchasePremiumPlanScreen({
    super.key,
    required this.isCameBack,
    this.isExpired,
    this.enrolledPlan,
    this.willExpire,
  });
  final bool isCameBack;
  final bool? isExpired;
  final bInfo.EnrolledPlan? enrolledPlan;
  final String? willExpire;

  @override
  ConsumerState<PurchasePremiumPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends ConsumerState<PurchasePremiumPlanScreen> {
  SubscriptionPlanModelNew? selectedPlan;
  bool isPlanExpiringIn7Days = false;
  bool _isRefreshing = false;

  late Future<List<SubscriptionPlanModelNew>> _plansFuture;
  final SubscriptionPlanRepo subscriptionRepo = SubscriptionPlanRepo();

  @override
  void initState() {
    super.initState();
    _checkExpiryDate();
    _plansFuture = subscriptionRepo.fetchAllPlans();
  }

  void _checkExpiryDate() {
    if (widget.willExpire != null && DateTime.tryParse(widget.willExpire ?? '') != null) {
      DateTime expiryDate = DateTime.parse(widget.willExpire!);
      isPlanExpiringIn7Days = expiryDate.isBefore(DateTime.now().add(const Duration(days: 6)));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isExpired == true) {
        getUpgradeDialog();
      }
    });
  }

  void getUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return goToPackagePagePopup(
          context: dialogContext,
          enrolledPlan: widget.enrolledPlan,
        );
      },
    );
  }

  Future<void> refreshData() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _plansFuture = subscriptionRepo.fetchAllPlans();
      selectedPlan = null;
    });

    ref.refresh(businessInfoProvider);
    ref.refresh(subscriptionPlanProvider);
    ref.refresh(getExpireDateProvider(ref));

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  CurrencyModel? getDefoultCurrency({required List<CurrencyModel> currencies}) {
    for (var element in currencies) {
      if (element.isDefault ?? false) {
        return element;
      }
    }
    return null;
  }

  int calculateDiscountPercent(double originalPrice, double offerPrice) {
    if (originalPrice == 0) return 0;
    return ((1 - (offerPrice / originalPrice)) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final businessInfo = ref.watch(businessInfoProvider);
    final currencyData = ref.watch(currencyProvider);
    final permissionService = PermissionService(ref);
    final currencySymbol = getDefoultCurrency(currencies: currencyData.value ?? [])?.symbol ?? '';

    return SafeArea(
      child: Scaffold(
        backgroundColor: kWhite,
        bottomNavigationBar: _buildBottomButton(businessInfo, permissionService),
        body: RefreshIndicator(
          onRefresh: () => refreshData(),
          child: FutureBuilder<List<SubscriptionPlanModelNew>>(
            future: _plansFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerLoading();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(lang.S.of(context).noDataFound));
              }

              final plans = snapshot.data!;

              if (selectedPlan == null) {
                final currentPlanId = widget.enrolledPlan?.planId;
                try {
                  selectedPlan = plans.firstWhere(
                    (plan) => plan.id == currentPlanId,
                    orElse: () => plans.first,
                  );
                } catch (e) {
                  selectedPlan = plans.first;
                }
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    if (selectedPlan != null && selectedPlan!.features != null)
                      ...selectedPlan!.features!.entries.map((entry) => _buildFeatureItem(entry.key, entry.value)),
                    const SizedBox(height: 16),
                    Text(
                      lang.S.of(context).outPremiumPlan,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildPlanList(plans, currencySymbol, Theme.of(context)),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Widgets Components ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          lang.S.of(context).purchasePremium,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kTitleColor),
        ),
        GestureDetector(
          onTap: () {
            if (widget.isExpired != true) {
              if (widget.isCameBack) {
                Navigator.pop(context);
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (Route<dynamic> route) => false,
                );
              }
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
                (Route<dynamic> route) => false,
              );
            }
          },
          child: Icon(
            Icons.close,
            color: widget.isExpired != true ? Colors.grey : Colors.black,
          ),
        )
      ],
    );
  }

  Widget _buildFeatureItem(String featureKey, dynamic featureValue) {
    final isActive = featureValue is List && featureValue.length > 1 && featureValue[1] == "1";
    final featureText = featureValue is List ? featureValue[0].toString() : featureKey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: const Color(0xff473232).withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: -1),
          BoxShadow(
              color: const Color(0xff0C1A4B).withValues(alpha: 0.024),
              blurRadius: 1,
              offset: const Offset(0, 0),
              spreadRadius: 0)
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        leading: Icon(
          isActive ? Icons.check_circle : CommunityMaterialIcons.close_circle,
          color: isActive ? Colors.green : Colors.red,
        ),
        title: Text(
          featureText,
          style: const TextStyle(
            color: kGreyTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanList(List<SubscriptionPlanModelNew> plans, String currencySymbol, ThemeData theme) {
    return SizedBox(
      height: 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          final isSelected = selectedPlan?.id == plan.id;
          final hasOffer = plan.offerPrice != null && plan.offerPrice! > 0;
          final discountPercent =
              hasOffer ? calculateDiscountPercent(plan.subscriptionPrice ?? 0, plan.offerPrice!) : null;

          return GestureDetector(
            onTap: () => setState(() => selectedPlan = plan),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.only(right: 16),
              width: 115,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 145,
                    width: 115,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffFEF0F1).withOpacity(0.2) : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? kMainColor : const Color(0xffEAECF0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan.subscriptionName ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${plan.duration} ${lang.S.of(context).days}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (hasOffer)
                          Column(
                            children: [
                              Text(
                                '$currencySymbol${plan.offerPrice}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? kMainColor : kTitleColor,
                                ),
                              ),
                              Text(
                                '$currencySymbol${plan.subscriptionPrice}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            '$currencySymbol${plan.subscriptionPrice}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? kMainColor : kTitleColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasOffer)
                    Positioned(
                      top: -8,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          '${lang.S.of(context).save} $discountPercent%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(
      AsyncValue<bInfo.BusinessInformationModel> businessInfo, PermissionService permissionService) {
    if (selectedPlan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handlePayment(businessInfo, permissionService),
          style: ElevatedButton.styleFrom(
            backgroundColor: kMainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            selectedPlan?.id == widget.enrolledPlan?.planId ? lang.S.of(context).extendPlan : lang.S.of(context).buyNow,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // --- UPDATED PAYMENT HANDLING LOGIC ---
  // --- UPDATED PAYMENT HANDLING LOGIC (Fixed SnackBar Delay) ---
  Future<void> _handlePayment(
      AsyncValue<bInfo.BusinessInformationModel> businessInfo, PermissionService permissionService) async {
    // 1. Check Permissions
    if (!permissionService.hasPermission(Permit.subscriptionsRead.value)) {
      EasyLoading.showError(lang.S.of(context).youDoNotHavePermissionToCreatePurchase);
      return;
    }

    final plan = selectedPlan!;
    final currentPlanId = widget.enrolledPlan?.planId;
    final bool isFreePlan = (plan.subscriptionPrice ?? 0) <= 0 && (plan.offerPrice ?? 0) <= 0;

    DateTime? currentExpiryDate;
    if (widget.willExpire != null) {
      currentExpiryDate = DateTime.tryParse(widget.willExpire!);
    }
    final now = DateTime.now();

    // 2. LOGIC CHECK: Free Plan Restriction
    if (isFreePlan && widget.enrolledPlan != null) {
      // Fix: Hide previous snackbar immediately
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Sorry, you cannot subscribe to a free plan again."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2), // Duration কমিয়ে দেওয়া হলো
      ));
      return;
    }

    // 3. LOGIC CHECK: Validity & Downgrade Prevention
    if (currentExpiryDate != null && currentExpiryDate.isAfter(now)) {
      // 3.1: Same Plan Extension Limit
      if (currentPlanId == plan.id) {
        final sevenDaysFromNow = now.add(const Duration(days: 7));
        if (currentExpiryDate.isAfter(sevenDaysFromNow)) {
          // Fix: Hide previous snackbar immediately
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Plan is not expiring soon enough to extend'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ));
          return;
        }
      }

      // 3.2: Check if Current Validity exceeds New Plan Duration
      final int newPlanDuration = plan.duration ?? 0;
      final DateTime theoreticalNewExpiry = now.add(Duration(days: newPlanDuration));

      if (currentExpiryDate.isAfter(theoreticalNewExpiry) || currentExpiryDate.isAtSameMomentAs(theoreticalNewExpiry)) {
        // Fix: Hide previous snackbar immediately
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("You cannot subscribe to this plan as your current plan validity is longer."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ));
        return;
      }
    }

    // 4. Proceed to Payment
    // Check if context is mounted before push
    if (!mounted) return;

    final bool success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          planId: plan.id.toString(),
          businessId: businessInfo.value?.data?.id.toString() ?? '',
        ),
      ),
    );

    if (success == true) {
      ref.refresh(businessInfoProvider);
      ref.refresh(getExpireDateProvider(ref));
      EasyLoading.showSuccess(lang.S.of(context).successfullyPaid);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      EasyLoading.showError('Payment Unsuccessfull');
    }
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 20, width: 150, color: Colors.white),
                const CircleAvatar(radius: 12, backgroundColor: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < 5; i++)
              Container(
                height: 40,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            const SizedBox(height: 20),
            Container(height: 20, width: 180, color: Colors.white),
            const SizedBox(height: 15),
            SizedBox(
              height: 165,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) => Container(
                  width: 115,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
