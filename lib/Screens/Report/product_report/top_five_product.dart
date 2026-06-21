import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

// --- Local Imports ---
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/pdf_report/top_five_product_report/top_five_product_pdf.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../constant.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Products/Model/product_model.dart';

class TopFiveProduct extends ConsumerStatefulWidget {
  const TopFiveProduct({super.key});

  @override
  ConsumerState<TopFiveProduct> createState() => _CustomerLedgerReportState();
}

class _CustomerLedgerReportState extends ConsumerState<TopFiveProduct> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    ref.refresh(productProvider);
    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(productProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        final _theme = Theme.of(context);
        final _lang = lang.S.of(context);

        return businessInfo.when(
          data: (details) {
            return GlobalPopup(
              child: Scaffold(
                backgroundColor: kWhite,
                appBar: AppBar(
                  backgroundColor: kWhite,
                  surfaceTintColor: kWhite,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.black),
                  title: Text(
                    _lang.top5Product,
                  ),
                  actions: [
                    businessInfo.when(
                      data: (business) {
                        return providerData.when(
                          data: (productList) {
                            final sortedProducts = [...productList]
                              ..sort((a, b) => (b.saleCount ?? 0).compareTo(a.saleCount ?? 0));

                            final topFiveProducts = sortedProducts.take(5).toList();
                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (productList.isNotEmpty) {
                                      generateTopFiveReportPdf(context, topFiveProducts, business);
                                    } else {
                                      EasyLoading.showError(_lang.listIsEmpty);
                                    }
                                  },
                                  icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                                ),
                                SizedBox(width: 8),
                              ],
                            );
                          },
                          error: (e, stack) => Center(
                            child: Text(e.toString()),
                          ),
                          loading: SizedBox.shrink,
                        );
                      },
                      error: (e, stack) => Center(child: Text(e.toString())),
                      loading: SizedBox.shrink,
                    ),
                  ],
                ),
                body: RefreshIndicator.adaptive(
                  onRefresh: () => refreshData(ref),
                  child: providerData.when(
                    data: (productList) {
                      if (!permissionService.hasPermission(Permit.productsRead.value)) {
                        return const Center(child: PermitDenyWidget());
                      }

                      final sortedProducts = [...productList]
                        ..sort((a, b) => (b.saleCount ?? 0).compareTo(a.saleCount ?? 0));

                      final topFiveProducts = sortedProducts.take(5).toList();

                      return topFiveProducts.isEmpty
                          ? Center(child: EmptyWidget(message: TextSpan(text: lang.S.of(context).noParty)))
                          : ListView.separated(
                              itemCount: topFiveProducts.length,
                              itemBuilder: (_, index) {
                                final product = topFiveProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product.productName ?? 'N/A',
                                            style: _theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${_lang.totalAmount}: ${formatPointNumber(product.totalSaleAmount ?? 0, addComma: true)}',
                                            style: _theme.textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${_lang.code}: ${product.productCode ?? '-'}',
                                            style: _theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            '${_lang.totalSales}: ${product.saleCount ?? 0}',
                                            style: _theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => Divider(
                                thickness: 1,
                                height: 1,
                                color: kBottomBorder,
                              ),
                            );
                    },
                    error: (e, stack) => Text(e.toString()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            );
          },
          error: (e, stack) => Text(e.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
