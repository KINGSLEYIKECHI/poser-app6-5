import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:nb_utils/nb_utils.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../pdf_report/party/top_5_supplier_report_pdf.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Customers/Provider/customer_provider.dart';
import '../../party ledger/single_party_ledger_screen.dart';

class TopFiveSupplier extends ConsumerStatefulWidget {
  const TopFiveSupplier({super.key});

  @override
  ConsumerState<TopFiveSupplier> createState() => _CustomerLedgerReportState();
}

class _CustomerLedgerReportState extends ConsumerState<TopFiveSupplier> {
  bool _isRefreshing = false;
  final searchController = TextEditingController();

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
        final providerData = ref.watch(partiesProvider);
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
                    _lang.top5Supplier,
                  ),
                  actions: [
                    businessInfo.when(
                      data: (business) {
                        return providerData.when(
                          data: (suppliers) {
                            final topFiveCustomers = suppliers.getTopFiveSuppliers();

                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (suppliers.isNotEmpty) {
                                      generateTop5SupplierReportPdf(context, topFiveCustomers, business);
                                    } else {
                                      EasyLoading.showError(_lang.listIsEmpty);
                                    }
                                  },
                                  icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                                ),
                                /*
                                IconButton(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (!permissionService.hasPermission(Permit.expenseReportsRead.value)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text('You do not have permission to view expense report.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (customers.isNotEmpty) {
                                    } else {
                                      EasyLoading.showInfo('No data available for generate pdf');
                                    }
                                  },
                                  icon: SvgPicture.asset('assets/excel.svg'),
                                ),
                                */
                                SizedBox(width: 8),
                              ],
                            );
                          },
                          error: (e, stack) => Center(child: Text(e.toString())),
                          loading: SizedBox.shrink,
                        );
                      },
                      error: (e, stack) => Center(
                        child: Text(e.toString()),
                      ),
                      loading: SizedBox.shrink,
                    ),
                  ],
                ),
                body: RefreshIndicator.adaptive(
                  onRefresh: () => refreshData(ref),
                  child: providerData.when(
                    data: (partyList) {
                      if (!permissionService.hasPermission(Permit.partiesRead.value)) {
                        return const Center(child: PermitDenyWidget());
                      }

                      final suppliers = partyList.where((party) {
                        final type = (party.type ?? '').toLowerCase();
                        return type == 'supplier';
                      }).toList();

                      suppliers.sort((a, b) {
                        final aPurchase = a.purchaseCount ?? 0;
                        final bPurchase = b.purchaseCount ?? 0;
                        return bPurchase.compareTo(aPurchase);
                      });

                      final topFiveSupplier = suppliers.length > 5 ? suppliers.take(5).toList() : suppliers;
                      return topFiveSupplier.isEmpty
                          ? Center(child: EmptyWidget(message: TextSpan(text: l.S.of(context).noParty)))
                          : ListView.separated(
                              itemCount: topFiveSupplier.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (_, index) {
                                final party = topFiveSupplier[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      PartyLedgerScreen(
                                        partyId: party.id.toString(),
                                        partyName: party.name.toString(),
                                      ).launch(context);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              party.name ?? '',
                                              style: _theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${_lang.due}: ${party.due}',
                                              style: _theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_lang.type}: ${party.type ?? ''}',
                                              style: _theme.textTheme.bodyMedium,
                                            ),
                                            Text(
                                              '${_lang.phone}: ${party.phone ?? 'n/a'}',
                                              style: _theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_lang.totalSales} : ${party.purchaseCount ?? 0}',
                                              style: _theme.textTheme.bodyMedium,
                                            ),
                                            Text(
                                              '${_lang.paidAmount} : ${party.totalPurchasePaid ?? 0}',
                                              style: _theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
