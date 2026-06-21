import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/subscription/purchase_premium_plan_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart'; // Ensure shimmer is imported

import '../../http_client/subscription_expire_provider.dart';
import '../Home/home_screen.dart';
import 'Model/subscription_plan_model.dart';
import 'Provider/subacription_plan_provider.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  // PART 1: State Management & Cleanup
  bool _isRefreshing = false;

  // Future variable to cache the API call
  late Future<List<SubscriptionPlanModelNew>> _plansFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future once when the screen loads
    _plansFuture = subscriptionRepo.fetchAllPlans();
  }

  // Refreshes profile info and the plans list
  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _plansFuture = subscriptionRepo.fetchAllPlans();
    });

    ref.refresh(businessInfoProvider);
    ref.refresh(getExpireDateProvider(ref));

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // PART 2: UI Helper Methods
  Widget _buildFeatureItem(String featureKey, dynamic featureValue) {
    // Logic: API returns ["Feature Name", "1"] for active, ["Feature Name", "0"] for inactive
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
        contentPadding: EdgeInsets.zero,
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

  // --- SHIMMER LOADING WIDGET ---
  Widget _buildShimmerLoading() {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 150,
            height: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Info Card Placeholder
              Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              // "Pack Features" Title Placeholder
              Container(
                height: 20,
                width: 150,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              // Feature List Placeholders
              Expanded(
                child: ListView.builder(
                  itemCount: 8, // Simulate 8 features
                  itemBuilder: (_, __) => Container(
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PART 3: Main Build Method
    return Consumer(builder: (context, ref, __) {
      final profileInfo = ref.watch(businessInfoProvider);

      return profileInfo.when(
        data: (info) {
          final enrolledPlan = info.data?.enrolledPlan;

          return Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(lang.S.of(context).yourPack),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
            ),
            // PART 4: Bottom Navigation (Update Button)
            bottomNavigationBar: SizedBox(
              height: 115,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      lang.S.of(context).unlimitedUsagesOfOurPackage,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        final subscriptionState = ref.read(subscriptionProvider);
                        PurchasePremiumPlanScreen(
                          isCameBack: true,
                          // If expired, pass null so user must select a new plan
                          enrolledPlan: subscriptionState.isExpired ? null : enrolledPlan,
                          willExpire: info.data?.willExpire,
                        ).launch(context);
                      },
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Text(
                            lang.S.of(context).updateNow,
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => refreshData(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PART 5: Active Plan Info Card
                      Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kMainColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      enrolledPlan != null
                                          ? (enrolledPlan.price ?? 0) > 0
                                              ? lang.S.of(context).premiumPlan
                                              : lang.S.of(context).freePlan
                                          : 'No active plan!',
                                      style: const TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Flexible(
                                      child: enrolledPlan?.plan != null
                                          ? Text.rich(
                                              TextSpan(
                                                text: lang.S.of(context).youRUsing,
                                                children: [
                                                  TextSpan(
                                                    text: '${enrolledPlan?.plan?.subscriptionName} Package',
                                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                          color: kMainColor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : const Text('You don’t have an active plan.'),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 63,
                                width: 63,
                                decoration: const BoxDecoration(
                                  color: kMainColor,
                                  borderRadius: BorderRadius.all(Radius.circular(50)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      getSubscriptionExpiring(
                                        expireDate: info.data?.willExpire,
                                        shortMSG: true,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        lang.S.of(context).packFeatures,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // PART 6: Features List
                      FutureBuilder<List<SubscriptionPlanModelNew>>(
                        future: _plansFuture, // Using the cached future
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          // Inner Loading State (Also replaced with Shimmer for partial loading)
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Column(
                                children: List.generate(
                                    5,
                                    (index) => Container(
                                          height: 50,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        )),
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("No plans available"));
                          }

                          final plans = snapshot.data!;
                          final currentPlanId = enrolledPlan?.planId;

                          // Bug Fix: Handle case where current plan is not found
                          final currentPlan = plans.firstWhere(
                            (plan) => plan.id == currentPlanId,
                            orElse: () => SubscriptionPlanModelNew(),
                          );

                          if (currentPlan.id == null) {
                            return Center(child: Text(lang.S.of(context).youRUsing + " Free/Custom Plan"));
                          }

                          // Ensure features is not null
                          if (currentPlan.features == null) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...currentPlan.features!.entries.map(
                                (entry) => _buildFeatureItem(entry.key, entry.value),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },
        // Replaced CircularProgressIndicator with Shimmer
        loading: () => _buildShimmerLoading(),
      );
    });
  }
}
