// File: SalesListScreen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/business_info_model.dart';
import 'package:mobile_pos/widgets/global_error_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../GlobalComponents/sales_transaction_widget.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Home/home.dart';
import '../../service/check_user_role_permission_provider.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  bool _isRefreshing = false; // Prevents multiple refresh calls

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return; // Prevent duplicate refresh calls
    _isRefreshing = true;

    ref.refresh(salesTransactionProvider);
    ref.refresh(businessInfoProvider);
    ref.refresh(getExpireDateProvider(ref));
    ref.refresh(thermalPrinterProvider);

    await Future.delayed(const Duration(seconds: 1)); // Optional delay
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await const Home().launch(context, isNewTask: true);
      },
      child: GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(lang.S.of(context).saleList),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Consumer(builder: (context, ref, __) {
            final providerDataAsync = ref.watch(salesTransactionProvider);
            final profileAsync = ref.watch(businessInfoProvider);
            final permissionService = PermissionService(ref);

            return RefreshIndicator.adaptive(
              onRefresh: () => refreshData(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Builder(
                  builder: (context) {
                    // --- 1. Handle Combined Loading State ---
                    if (providerDataAsync.isLoading || profileAsync.isLoading) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        separatorBuilder: (_, __) => const Divider(color: kBackgroundColor, height: 2),
                        itemBuilder: (_, __) => const SaleItemShimmer(),
                      );
                    }

                    // --- 2. Handle Combined Error State ---
                    if (providerDataAsync.hasError || profileAsync.hasError) {
                      return GlobalErrorWidget(
                        errorMessage: providerDataAsync.error?.toString() ?? profileAsync.error?.toString() ?? 'Error',
                        onRetry: () => refreshData(ref),
                      );
                    }

                    // --- 3. Handle Data State ---
                    final transaction = providerDataAsync.value ?? [];
                    BusinessInformationModel? shopDetails = profileAsync.value;

                    if (transaction.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: EmptyWidget(
                            message: TextSpan(text: lang.S.of(context).addSale),
                          ),
                        ),
                      );
                    }

                    if (!permissionService.hasPermission(Permit.salesRead.value)) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: PermitDenyWidget(),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transaction.length,
                      itemBuilder: (context, index) {
                        final sale = transaction[index];

                        // Removed the individual item API call from here
                        return salesTransactionWidget(
                          context: context,
                          ref: ref,
                          businessInfo: shopDetails!,
                          sale: sale,
                          advancePermission: true,
                          isFromSaleList: true,
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// --- Smooth Shimmer Loading Widget for List Items ---
class SaleItemShimmer extends StatelessWidget {
  const SaleItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 150, color: Colors.white), // Invoice No
                    const SizedBox(height: 6),
                    Container(height: 12, width: 100, color: Colors.white), // Date
                  ],
                ),
                Container(height: 24, width: 70, color: Colors.white), // Status / Amount
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 14, width: 120, color: Colors.white), // Customer Name
                Container(height: 14, width: 80, color: Colors.white), // Total Amount
              ],
            ),
          ],
        ),
      ),
    );
  }
}
