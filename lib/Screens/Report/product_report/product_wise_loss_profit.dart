import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';
import '../../../pdf_report/product_wise_loss_profit/product_wise_loss_profit.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Customers/Provider/customer_provider.dart';

class ProductWiseProfitAndLoss extends ConsumerStatefulWidget {
  const ProductWiseProfitAndLoss({super.key});

  @override
  ConsumerState<ProductWiseProfitAndLoss> createState() => _CustomerLedgerReportState();
}

class _CustomerLedgerReportState extends ConsumerState<ProductWiseProfitAndLoss> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    ref.refresh(partiesProvider);
    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(productProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        final _theme = Theme.of(context);

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
                    _lang.productWiseProfitAndLoss,
                  ),
                  actions: [
                    businessInfo.when(
                      data: (business) {
                        return providerData.when(
                          data: (transaction) {
                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (transaction.isNotEmpty) {
                                      generateProductLossProfitReportPdf(context, transaction, business);
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
                      error: (e, stack) => Center(
                        child: Text(e.toString()),
                      ),
                      loading: SizedBox.shrink,
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size(double.infinity, 70),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 45,
                            child: TextFormField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: updateBorderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.red, width: 1),
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    FeatherIcons.search,
                                    color: kNeutralColor,
                                  ),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchText = '';
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          size: 20,
                                          color: kSubPeraColor,
                                        ),
                                      )
                                    : null,
                                hintText: l.S.of(context).searchH,
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: kNeutralColor,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(color: kBottomBorder),
                      ],
                    ),
                  ),
                ),
                body: RefreshIndicator.adaptive(
                  onRefresh: () => refreshData(ref),
                  child: providerData.when(
                    data: (productList) {
                      if (!permissionService.hasPermission(Permit.partiesRead.value)) {
                        return const Center(child: PermitDenyWidget());
                      }

                      final filteredParties = productList.where((product) {
                        if (_searchText.isEmpty) return true;

                        final query = _searchText.toLowerCase();
                        return (product.productName ?? '').toLowerCase().contains(query) ||
                            (product.productCode ?? '').contains(query);
                      }).toList();

                      return filteredParties.isEmpty
                          ? Center(child: EmptyWidget(message: TextSpan(text: l.S.of(context).noParty)))
                          : ListView.separated(
                              itemCount: filteredParties.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (_, index) {
                                final products = filteredParties[index];
                                final num profitLoss = products.totalLossProfit ?? 0;

                                final num profitAmount = profitLoss > 0 ? profitLoss : 0;
                                final num lossAmount = profitLoss < 0 ? profitLoss.abs() : 0;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              products.productName ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: _theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              text: '${_lang.profit}: ',
                                              children: [
                                                TextSpan(
                                                    text: '$currency${formatPointNumber(profitAmount, addComma: true)}',
                                                    style: TextStyle(color: kSuccessColor)),
                                              ],
                                              style: _theme.textTheme.bodyLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${_lang.productCode}: ${products.productCode ?? 'n/a'}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: _theme.textTheme.bodyLarge,
                                            ),
                                          ),
                                          SizedBox(width: 30),
                                          Text.rich(
                                            TextSpan(
                                              text: '${_lang.loss}: ',
                                              children: [
                                                TextSpan(
                                                    text: '$currency${formatPointNumber(lossAmount, addComma: true)}',
                                                    style: TextStyle(color: DAppColors.kError)),
                                              ],
                                              style: _theme.textTheme.bodyLarge,
                                            ),
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
