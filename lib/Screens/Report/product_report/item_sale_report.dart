import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/model/sale_transaction_model.dart';
import 'package:mobile_pos/pdf_report/sales_report/sales_report_excel.dart';
import 'package:mobile_pos/pdf_report/sales_report/sales_report_pdf.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../GlobalComponents/sales_transaction_widget.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';
import '../../../widgets/build_date_selector/build_date_selector.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../invoice_details/sales_invoice_details_screen.dart';

class ItemSaleReport extends ConsumerStatefulWidget {
  const ItemSaleReport({super.key});

  @override
  SalesReportScreenState createState() => SalesReportScreenState();
}

class SalesReportScreenState extends ConsumerState<ItemSaleReport> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  final Map<String, String> dateOptions = {
    'today': l.S.current.today,
    'yesterday': l.S.current.yesterday,
    'last_seven_days': l.S.current.last7Days,
    'last_thirty_days': l.S.current.last30Days,
    'current_month': l.S.current.currentMonth,
    'last_month': l.S.current.lastMonth,
    'current_year': l.S.current.currentYear,
    'custom_date': l.S.current.customerDate,
  };

  String selectedTime = 'today';
  bool _isRefreshing = false;
  bool _showCustomDatePickers = false;

  DateTime? fromDate;
  DateTime? toDate;
  String searchCustomer = '';

  /// Generates the date range string for the provider
  FilterModel _getDateRangeFilter() {
    if (_showCustomDatePickers && fromDate != null && toDate != null) {
      return FilterModel(
        duration: 'custom_date',
        fromDate: DateFormat('yyyy-MM-dd', 'en_US').format(fromDate!),
        toDate: DateFormat('yyyy-MM-dd', 'en_US').format(toDate!),
      );
    } else {
      return FilterModel(duration: selectedTime.toLowerCase());
    }
  }

  Future<void> _selectDate({
    required BuildContext context,
    required bool isFrom,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
      initialDate: isFrom ? fromDate ?? DateTime.now() : toDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          toDate = picked;
          toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });

      if (fromDate != null && toDate != null) _refreshFilteredProvider();
    }
  }

  Future<void> _refreshFilteredProvider() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final filter = _getDateRangeFilter();
      ref.refresh(filteredSaleProvider(filter));
      await Future.delayed(const Duration(milliseconds: 300)); // small delay
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  void _updateDateUI(DateTime? from, DateTime? to) {
    setState(() {
      fromDate = from;
      toDate = to;

      fromDateController.text = from != null ? DateFormat('yyyy-MM-dd').format(from) : '';

      toDateController.text = to != null ? DateFormat('yyyy-MM-dd').format(to) : '';
    });
  }

  void _setDateRangeFromDropdown(String value) {
    final now = DateTime.now();

    switch (value) {
      case 'today':
        _updateDateUI(now, now);
        break;

      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        _updateDateUI(y, y);
        break;

      case 'last_seven_days':
        _updateDateUI(
          now.subtract(const Duration(days: 6)),
          now,
        );
        break;

      case 'last_thirty_days':
        _updateDateUI(
          now.subtract(const Duration(days: 29)),
          now,
        );
        break;

      case 'current_month':
        _updateDateUI(
          DateTime(now.year, now.month, 1),
          now,
        );
        break;

      case 'last_month':
        final first = DateTime(now.year, now.month - 1, 1);
        final last = DateTime(now.year, now.month, 0);
        _updateDateUI(first, last);
        break;

      case 'current_year':
        _updateDateUI(
          DateTime(now.year, 1, 1),
          now,
        );
        break;

      case 'custom_date':
        // Custom: User will select manually
        _updateDateUI(null, null);
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    // Set initial From and To date = TODAY
    fromDate = now;
    toDate = now;

    fromDateController.text = DateFormat('yyyy-MM-dd').format(now);
    toDateController.text = DateFormat('yyyy-MM-dd').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final filter = _getDateRangeFilter();
        final providerData = ref.watch(filteredSaleProvider(filter));
        final personalData = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(
                _lang.productWiseSale,
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
                                  generateSaleReportPdf(context, transaction, business, fromDate, toDate);
                                } else {
                                  EasyLoading.showError(_lang.listIsEmpty);
                                }
                              },
                              icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                            ),
                            // IconButton(
                            //   visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            //   padding: EdgeInsets.zero,
                            //   onPressed: () {
                            //     if (!permissionService.hasPermission(Permit.expenseReportsRead.value)) {
                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           backgroundColor: Colors.red,
                            //           content: Text('You do not have permission to view expense report.'),
                            //         ),
                            //       );
                            //       return;
                            //     }
                            //     if (transaction.isNotEmpty) {
                            //       generateSaleReportExcel(context, transaction, business, fromDate, toDate);
                            //     } else {
                            //       EasyLoading.showInfo('No data available for generate pdf');
                            //     }
                            //   },
                            //   icon: SvgPicture.asset('assets/excel.svg'),
                            // ),
                            // SizedBox(width: 8),
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Column(
                  children: [
                    Divider(thickness: 1, color: kBottomBorder, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(IconlyLight.calendar, color: kPeraColor, size: 20),
                                SizedBox(width: 3),
                                GestureDetector(
                                  onTap: () {
                                    if (_showCustomDatePickers) {
                                      _selectDate(context: context, isFrom: true);
                                    }
                                  },
                                  child: Text(
                                    fromDate != null ? DateFormat('dd MMM yyyy').format(fromDate!) : _lang.from,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _lang.to,
                                  style: _theme.textTheme.titleSmall,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_showCustomDatePickers) {
                                        _selectDate(context: context, isFrom: false);
                                      }
                                    },
                                    child: Text(
                                      toDate != null ? DateFormat('dd MMM yyyy').format(toDate!) : _lang.to,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 2),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Container(
                              height: 1,
                              width: 20,
                              color: kSubPeraColor,
                            ),
                          ),
                          SizedBox(width: 2),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconSize: 20,
                                value: selectedTime,
                                isExpanded: true,
                                items: dateOptions.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      overflow: TextOverflow.ellipsis,
                                      style: _theme.textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    selectedTime = value;
                                    _showCustomDatePickers = value == 'custom_date';
                                  });

                                  if (value != 'custom_date') {
                                    _setDateRangeFromDropdown(value);
                                    _refreshFilteredProvider();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1, color: kBottomBorder, height: 1),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            body: RefreshIndicator(
              onRefresh: () => _refreshFilteredProvider(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (permissionService.hasPermission(Permit.saleReportsRead.value)) ...{
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 12, bottom: 0),
                        child: Column(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  searchCustomer = value.toLowerCase().trim();
                                });
                              },
                              decoration: InputDecoration(
                                prefixIconConstraints: const BoxConstraints(
                                  minHeight: 20,
                                  minWidth: 20,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsetsDirectional.only(start: 10),
                                  child: Icon(
                                    FeatherIcons.search,
                                    color: kGrey6,
                                  ),
                                ),
                                hintText: l.S.of(context).searchH,
                              ),
                            ),
                          ],
                        ),
                      ),
                      providerData.when(data: (transaction) {
                        final filteredTransactions = transaction.where((sale) {
                          final customerName = sale.user?.name?.toLowerCase() ?? '';
                          final invoiceNumber = sale.invoiceNumber?.toLowerCase() ?? '';
                          return customerName.contains(searchCustomer) || invoiceNumber.contains(searchCustomer);
                        }).toList();
                        final totalSales =
                            filteredTransactions.fold<num>(0, (sum, sale) => sum + (sale.totalAmount ?? 0));
                        final totalDue = filteredTransactions.fold<num>(0, (sum, due) => sum + (due.dueAmount ?? 0));
                        return filteredTransactions.isNotEmpty
                            ? Column(
                                children: [
                                  // Padding(
                                  //   padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                                  //   child: Row(
                                  //     children: [
                                  //       Expanded(
                                  //         child: Container(
                                  //           height: 77,
                                  //           decoration: BoxDecoration(
                                  //             color: kSuccessColor.withValues(alpha: 0.1),
                                  //             borderRadius: const BorderRadius.all(
                                  //               Radius.circular(8),
                                  //             ),
                                  //           ),
                                  //           child: Column(
                                  //             mainAxisAlignment: MainAxisAlignment.center,
                                  //             crossAxisAlignment: CrossAxisAlignment.center,
                                  //             children: [
                                  //               Text(
                                  //                 "$currency${formatPointNumber(totalSales)}",
                                  //                 style: _theme.textTheme.titleLarge?.copyWith(
                                  //                   fontWeight: FontWeight.w600,
                                  //                 ),
                                  //               ),
                                  //               const SizedBox(height: 4),
                                  //               Text(
                                  //                 lang.S.of(context).totalSales,
                                  //                 style: _theme.textTheme.titleMedium?.copyWith(
                                  //                   fontWeight: FontWeight.w500,
                                  //                   color: kPeraColor,
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       SizedBox(width: 12),
                                  //       Expanded(
                                  //         child: Container(
                                  //           height: 77,
                                  //           width: double.infinity,
                                  //           decoration: BoxDecoration(
                                  //             color: DAppColors.kWarning.withValues(alpha: 0.1),
                                  //             borderRadius: const BorderRadius.all(
                                  //               Radius.circular(8),
                                  //             ),
                                  //           ),
                                  //           child: Column(
                                  //             mainAxisAlignment: MainAxisAlignment.center,
                                  //             crossAxisAlignment: CrossAxisAlignment.center,
                                  //             children: [
                                  //               Text(
                                  //                 "$currency${formatPointNumber(totalDue)}",
                                  //                 style: _theme.textTheme.titleLarge?.copyWith(
                                  //                   fontWeight: FontWeight.w600,
                                  //                 ),
                                  //               ),
                                  //               const SizedBox(height: 4),
                                  //               Text(
                                  //                 'Balance Due',
                                  //                 style: _theme.textTheme.titleMedium?.copyWith(
                                  //                   fontWeight: FontWeight.w500,
                                  //                   color: kPeraColor,
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredTransactions.length,
                                      itemBuilder: (context, index) {
                                        final transaction = filteredTransactions[index];
                                        final details = transaction.salesDetails;

                                        final productName = details != null && details.isNotEmpty
                                            ? details.first.product?.productName ?? 'n/a'
                                            : 'n/a';

                                        final qty =
                                            details != null && details.isNotEmpty ? details.first.quantities ?? 0 : 0;

                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                SalesInvoiceDetails(
                                                  businessInfo: personalData.value!,
                                                  saleTransaction: filteredTransactions[index],
                                                ).launch(context);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                width: context.width(),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            productName,
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Text('#${transaction.invoiceNumber}'),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('${_lang.customer}: ${transaction.party?.name ?? ''}'),
                                                        Text(
                                                          '${_lang.date}: ${DateFormat('dd MMM yyyy').format(DateTime.parse(transaction.saleDate ?? ''))}',
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('${_lang.saleQty}: $qty'),
                                                        Text(
                                                          '${_lang.totalAmount}: $currency${transaction.totalAmount}',
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Divider(height: 0),
                                          ],
                                        );
                                      }),
                                ],
                              )
                            : Center(
                                child: EmptyWidgetUpdated(
                                  message: TextSpan(
                                    text: l.S.of(context).addSale,
                                  ),
                                ),
                              );
                      }, error: (e, stack) {
                        return Text(e.toString());
                      }, loading: () {
                        print('-------print again and again------------');
                        return const Center(child: CircularProgressIndicator());
                      }),
                    } else
                      Center(child: PermitDenyWidget()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
