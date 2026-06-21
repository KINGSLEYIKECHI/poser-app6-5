import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Purchase/add_and_edit_purchase.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../PDF Invoice/purchase_invoice_pdf.dart';
import '../../PDF Invoice/tax_purchase_invoice.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../../core/theme/_app_colors.dart';
import '../../currency.dart';
import '../../service/check_actions_when_no_branch.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Home/home.dart';
import '../invoice return/invoice_return_screen.dart';
import '../invoice_details/purchase_invoice_details.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  PurchaseReportState createState() => PurchaseReportState();
}

class PurchaseReportState extends State<PurchaseListScreen> {
  bool _isRefreshing = false;

  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    ref.refresh(purchaseTransactionProvider);

    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 16, width: 150, color: Colors.white),
                    Container(height: 16, width: 80, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        height: 24,
                        width: 60,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                    Container(height: 16, width: 100, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 14, width: 120, color: Colors.white),
                    Container(height: 14, width: 80, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, width: double.infinity, color: Colors.white),
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

    return WillPopScope(
      onWillPop: () async {
        return await const Home().launch(context, isNewTask: true);
      },
      child: GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(lang.S.of(context).purchaseList),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: Consumer(builder: (context, ref, __) {
            final providerData = ref.watch(purchaseTransactionProvider);
            final printerData = ref.watch(thermalPrinterProvider);
            final businessInfoData = ref.watch(businessInfoProvider);
            final permissionService = PermissionService(ref);

            return RefreshIndicator.adaptive(
              onRefresh: () => refreshData(ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: providerData.when(
                  data: (purchaseTransactions) {
                    if (purchaseTransactions.isEmpty) {
                      return Center(
                        child: EmptyWidget(
                          message: TextSpan(
                            text: lang.S.of(context).addAPurchase,
                          ),
                        ),
                      );
                    }

                    return businessInfoData.when(
                      data: (details) {
                        if (!permissionService.hasPermission(Permit.purchasesRead.value)) {
                          return const Center(child: PermitDenyWidget());
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: purchaseTransactions.length,
                          itemBuilder: (context, index) {
                            final sale = purchaseTransactions[index];
                            final isTaxEnabled = businessInfoData.value?.data?.addons?.taxInvoicePdf ?? false;

                            AsyncValue? taxAsync;

                            if (isTaxEnabled) {
                              taxAsync = ref.watch(purchaseTaxProvider(sale.id!.toInt()));
                            }

                            final num totalAmt = sale.totalAmount ?? 0;
                            final num dueAmt = sale.dueAmount ?? 0;
                            final num paidAmt = totalAmt - dueAmt;

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    PurchaseInvoiceDetails(
                                      businessInfo: businessInfoData.value!,
                                      transitionModel: sale,
                                    ).launch(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    width: context.width(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                sale.party?.name ?? '',
                                                style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '#${sale.invoiceNumber}',
                                              style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: dueAmt <= 0
                                                        ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                        : const Color(0xFFED1A3B).withOpacity(0.1),
                                                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                  ),
                                                  child: Text(
                                                    dueAmt <= 0 ? lang.S.of(context).paid : lang.S.of(context).unPaid,
                                                    style: TextStyle(
                                                      color: dueAmt <= 0
                                                          ? const Color(0xff0dbf7d)
                                                          : const Color(0xFFED1A3B),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: sale.purchaseReturns?.isNotEmpty ?? false,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8, right: 8),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange.withOpacity(0.2),
                                                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                      ),
                                                      child: Text(
                                                        lang.S.of(context).returned,
                                                        style: const TextStyle(color: Colors.orange),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              DateFormat.yMMMd()
                                                  .format(DateTime.tryParse(sale.purchaseDate ?? '') ?? DateTime.now()),
                                              style: const TextStyle(color: DAppColors.kSecondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${lang.S.of(context).total} : $currency ${formatPointNumber(totalAmt)}',
                                              style: _theme.textTheme.bodyMedium
                                                  ?.copyWith(fontSize: 14, color: DAppColors.kSecondary),
                                            ),
                                            const SizedBox(width: 4),
                                            if (dueAmt.toInt() != 0)
                                              Text(
                                                '${lang.S.of(context).paid} : $currency ${formatPointNumber(paidAmt)}',
                                                style: _theme.textTheme.bodyMedium
                                                    ?.copyWith(fontSize: 14, color: DAppColors.kSecondary),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            if (dueAmt.toInt() == 0)
                                              Flexible(
                                                child: Text(
                                                  '${lang.S.of(context).paid} : $currency ${formatPointNumber(paidAmt)}',
                                                  style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            if (dueAmt.toInt() != 0)
                                              Flexible(
                                                child: Text(
                                                  '${lang.S.of(context).due}: $currency ${formatPointNumber(dueAmt)}',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: _theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                                                ),
                                              ),
                                            businessInfoData.when(
                                              data: (data) {
                                                return Row(
                                                  children: [
                                                    const Icon(FeatherIcons.printer, color: Colors.grey, size: 22),
                                                    const SizedBox(width: 6),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          padding: EdgeInsets.zero,
                                                          visualDensity:
                                                              const VisualDensity(horizontal: -4, vertical: -4),
                                                          onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                                                              sale, data, context,
                                                              showPreview: true),
                                                          icon: const Icon(Icons.picture_as_pdf,
                                                              color: Colors.grey, size: 22),
                                                        ),
                                                        IconButton(
                                                          padding: EdgeInsets.zero,
                                                          visualDensity:
                                                              const VisualDensity(horizontal: -4, vertical: -4),
                                                          onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                                                              sale, data, context,
                                                              download: true),
                                                          icon: const Icon(FeatherIcons.download,
                                                              color: Colors.grey, size: 22),
                                                        ),
                                                        IconButton(
                                                          style: IconButton.styleFrom(
                                                              padding: EdgeInsets.zero,
                                                              visualDensity:
                                                                  const VisualDensity(horizontal: -4, vertical: -4)),
                                                          onPressed: () => PurchaseInvoicePDF.generatePurchaseDocument(
                                                              sale, data, context,
                                                              isShare: true),
                                                          icon: const Icon(Icons.share_outlined,
                                                              color: Colors.grey, size: 22),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Visibility(
                                                      visible: !(sale.purchaseReturns?.isNotEmpty ?? false),
                                                      child: IconButton(
                                                        padding: EdgeInsets.zero,
                                                        visualDensity:
                                                            const VisualDensity(horizontal: -4, vertical: -4),
                                                        onPressed: () async {
                                                          ref.refresh(cartNotifierPurchaseNew);
                                                          AddAndUpdatePurchaseScreen(
                                                            transitionModel: sale,
                                                            customerModel: null,
                                                          ).launch(context);
                                                        },
                                                        icon: const Icon(FeatherIcons.edit, color: Colors.grey),
                                                      ),
                                                    ),
                                                    PopupMenuButton(
                                                      offset: const Offset(0, 30),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(4.0)),
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (BuildContext bc) => [
                                                        PopupMenuItem(
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              bool result = await checkActionWhenNoBranch(
                                                                  ref: ref, context: context);
                                                              if (!result) return;

                                                              await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => InvoiceReturnScreen(
                                                                    purchaseTransaction: sale,
                                                                  ),
                                                                ),
                                                              );

                                                              Navigator.pop(bc);
                                                            },
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons.keyboard_return_outlined,
                                                                    color: kGreyTextColor),
                                                                const SizedBox(width: 10.0),
                                                                Text(lang.S.of(context).purchaseReturn,
                                                                    style: const TextStyle(color: kGreyTextColor)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (data.data?.addons?.taxInvoicePdf == true) ...[
                                                          PopupMenuItem(
                                                            child: GestureDetector(
                                                              onTap: () async {
                                                                try {
                                                                  final refreshedTaxData = await ref.refresh(
                                                                      purchaseTaxProvider(sale.id!.toInt()).future);

                                                                  if (refreshedTaxData == null) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      SnackBar(
                                                                          content: Text(lang.S.of(context).noTaxFound ??
                                                                              'No tax data available')),
                                                                    );
                                                                    return;
                                                                  }

                                                                  await TaxPurchaseInvoicePdf.generateSaleDocument(
                                                                    refreshedTaxData,
                                                                    data,
                                                                    context,
                                                                    showPreview: true,
                                                                  );
                                                                } catch (e) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                                                  );
                                                                }
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  const HugeIcon(
                                                                      icon: HugeIcons.strokeRoundedPdf02,
                                                                      size: 22,
                                                                      color: kPeraColor),
                                                                  const SizedBox(width: 8),
                                                                  Text(lang.S.of(context).taxInvoice,
                                                                      style: const TextStyle(color: kGreyTextColor)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                      child:
                                                          const Icon(FeatherIcons.moreVertical, color: kGreyTextColor),
                                                    )
                                                  ],
                                                );
                                              },
                                              error: (e, stack) => Text(e.toString()),
                                              loading: () => Text(lang.S.of(context).loading),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(height: 0)
                              ],
                            );
                          },
                        );
                      },
                      error: (e, stack) => Text(e.toString()),
                      loading: () => _buildShimmerList(),
                    );
                  },
                  error: (e, stack) => Text(e.toString()),
                  loading: () => _buildShimmerList(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
