import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../Customers/Model/parties_model.dart';
import '../../../pdf_report/party/top_5_customer_report_pdf.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Customers/Provider/customer_provider.dart';

class TopFiveCustomer extends ConsumerStatefulWidget {
  const TopFiveCustomer({super.key});

  @override
  ConsumerState<TopFiveCustomer> createState() => _CustomerLedgerReportState();
}

class _CustomerLedgerReportState extends ConsumerState<TopFiveCustomer> {
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
                    _lang.top5Customer,
                  ),
                  actions: [
                    businessInfo.when(
                      data: (business) {
                        return providerData.when(
                          data: (customers) {
                            final topFiveCustomers = customers.getTopFiveCustomers();

                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (customers.isNotEmpty) {
                                      generateTop5CustomerReportPdf(context, topFiveCustomers, business);
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
                      error: (e, stack) => Center(child: Text(e.toString())),
                      loading: SizedBox.shrink,
                    ),
                  ],
                ),
                body: RefreshIndicator.adaptive(
                  onRefresh: () => refreshData(ref),
                  child: providerData.when(
                    data: (customers) {
                      if (!permissionService.hasPermission(Permit.partiesRead.value)) {
                        return const Center(child: PermitDenyWidget());
                      }

                      final topFiveCustomers = customers.getTopFiveCustomers();

                      return topFiveCustomers.isEmpty
                          ? Center(child: EmptyWidget(message: TextSpan(text: l.S.of(context).noParty)))
                          : ListView.separated(
                              itemCount: topFiveCustomers.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (_, index) {
                                final party = topFiveCustomers[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: GestureDetector(
                                    // onTap: () {
                                    //   PartyLedgerScreen(
                                    //     partyId: party.id.toString(),
                                    //     partyName: party.name.toString(),
                                    //   ).launch(context);
                                    // },
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
                                              '${_lang.due}: ${formatPointNumber(party.due ?? 0, addComma: true)}',
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
                                              '${_lang.totalSales} : ${party.saleCount}',
                                              style: _theme.textTheme.bodyMedium,
                                            ),
                                            Text(
                                              '${_lang.paidAmount} : ${formatPointNumber(party.totalSalePaid ?? 0, addComma: true)}',
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
