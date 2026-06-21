import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';
import '../../../pdf_report/ledger_report_pdf/customer_ledger_report_pdf.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Customers/Provider/customer_provider.dart';

class CustomerLedgerReport extends ConsumerStatefulWidget {
  const CustomerLedgerReport({super.key});

  @override
  ConsumerState<CustomerLedgerReport> createState() => _CustomerLedgerReportState();
}

class _CustomerLedgerReportState extends ConsumerState<CustomerLedgerReport> {
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
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(partiesProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final personalData = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        final _theme = Theme.of(context);
        final _lang = l.S.of(context);

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
                    _lang.customerLedger,
                  ),
                  actions: [
                    personalData.when(
                      data: (business) {
                        return providerData.when(
                          data: (transaction) {
                            return Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (transaction.isNotEmpty) {
                                      generateCustomerLedgerReportPdf(context, transaction, business);
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
                                        if (transaction.isNotEmpty) {
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
                    data: (partyList) {
                      if (!permissionService.hasPermission(Permit.partiesRead.value)) {
                        return const Center(child: PermitDenyWidget());
                      }

                      // --- Filter to only Customer, Dealer, Wholesaler ---
                      final filteredParties = partyList.where((party) {
                        final type = (party.type ?? '').toLowerCase();
                        final nameMatches = _searchText.isEmpty
                            ? true
                            : (party.name ?? '').toLowerCase().contains(_searchText.toLowerCase()) ||
                                (party.phone ?? '').contains(_searchText);

                        final showType =
                            type == 'customer' || type == 'dealer' || type == 'wholesaler' || type == 'retailer';
                        return showType && nameMatches;
                      }).toList();

                      return filteredParties.isEmpty
                          ? Center(child: EmptyWidget(message: TextSpan(text: l.S.of(context).noParty)))
                          : ListView.separated(
                              itemCount: filteredParties.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (_, index) {
                                final party = filteredParties[index];
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
                                              '${_lang.due}: $currency${formatPointNumber(party.due ?? 0, addComma: true)}',
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
                                              '${_lang.amount}: ${party.totalSaleAmount ?? 0}',
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
                                              '${_lang.paidAmount} : $currency${formatPointNumber(party.totalSalePaid ?? 0, addComma: true)}',
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
