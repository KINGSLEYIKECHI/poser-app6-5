import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/model/dashboard_overview_model.dart';
import '../../../PDF Invoice/subscription_invoice_pdf.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../pdf_report/transactions/subscription_report_pdf.dart';
import '../../../service/check_user_role_permission_provider.dart';

class SubscriptionReportScreen extends ConsumerStatefulWidget {
  const SubscriptionReportScreen({super.key});

  @override
  ConsumerState<SubscriptionReportScreen> createState() => _SubscriptionReportScreenState();
}

class _SubscriptionReportScreenState extends ConsumerState<SubscriptionReportScreen> {
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
      ref.refresh(filteredSubscriptionReportProvider(filter));
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
      builder: (_, ref, watch) {
        final providerData = ref.watch(filteredSubscriptionReportProvider(_getDateRangeFilter()));
        final personalData = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        return personalData.when(
          data: (business) {
            return providerData.when(
              data: (transaction) {
                return GlobalPopup(
                  child: Scaffold(
                    backgroundColor: kWhite,
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      title: Text(_lang.subscriptionReports),
                      actions: [
                        IconButton(
                          onPressed: () {
                            if (transaction.isNotEmpty == true) {
                              generateSubscriptionReportPdf(context, transaction, business, fromDate, toDate);
                            } else {
                              EasyLoading.showError(_lang.listIsEmpty);
                            }
                          },
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                        ),

                        /*
                        IconButton(
                          onPressed: () {
                            if (!permissionService.hasPermission(Permit.lossProfitsRead.value)) {
                              // TODO: Shakil fix this permission
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('You do not have permission of loss profit.'),
                                ),
                              );
                              return;
                            }
                            if ((transaction.expenseSummary?.isNotEmpty == true) ||
                                (transaction.incomeSummary?.isNotEmpty == true)) {
                              generateLossProfitReportExcel(context, transaction, business, fromDate, toDate);
                            } else {
                              EasyLoading.showError('List is empty');
                            }
                          },
                          icon: SvgPicture.asset('assets/excel.svg'),
                        ),
                        */
                        SizedBox(width: 8),
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
                                          'To',
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
                      elevation: 0.0,
                    ),
                    body: RefreshIndicator(
                      onRefresh: _refreshFilteredProvider,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(Color(0xffF7F7F7)),
                            headingTextStyle: _theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            columns: [
                              DataColumn(label: Text(_lang.name)),
                              DataColumn(label: Text(_lang.startDate)),
                              DataColumn(label: Text(_lang.endDate)),
                              DataColumn(label: Text(_lang.status)),
                            ],
                            rows: List.generate(transaction.length, (index) {
                              final _transaction = transaction[index];
                              return DataRow(cells: [
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      SubscriptionInvoicePdf.generateSaleDocument(transaction, business, context);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 2,
                                      children: [
                                        Text(
                                          _transaction.name ?? "N/A",
                                          style: _theme.textTheme.titleSmall?.copyWith(
                                            fontSize: 15,
                                            color: DAppColors.kWarning,
                                          ),
                                        ),
                                        Text(
                                          _transaction.startDate == null
                                              ? "N/A"
                                              : DateFormat('dd MMM yyyy').format(_transaction.startDate!),
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            color: kPeraColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                  _transaction.startDate == null
                                      ? "N/A"
                                      : DateFormat('dd MMM yyyy').format(_transaction.startDate!),
                                  textAlign: TextAlign.center,
                                )),
                                DataCell(
                                  Text(
                                    _transaction.endDate == null
                                        ? "N/A"
                                        : DateFormat('dd MMM yyyy').format(_transaction.endDate!),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                DataCell(Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: (_transaction.isPaid ? Colors.green : const Color(0xffC52127))
                                                  .withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              _transaction.isPaid ? _lang.paid : _lang.unPaid,
                                              style: TextStyle(
                                                color: _transaction.isPaid ? Colors.green : const Color(0xffC52127),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                              ]);
                            })),
                      ),
                      // child: ListView.builder(
                      //   itemCount: transaction.length,
                      //   itemBuilder: (context, index) {
                      //     final _transaction = transaction[index];
                      //     return Container(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      //       decoration: BoxDecoration(
                      //         border: Border(bottom: Divider.createBorderSide(context)),
                      //       ),
                      //       child: Column(
                      //         mainAxisSize: MainAxisSize.min,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Row(
                      //             children: [
                      //               Expanded(
                      //                 child: DefaultTextStyle.merge(
                      //                   maxLines: 1,
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: _theme.textTheme.bodyLarge?.copyWith(
                      //                     fontWeight: FontWeight.w600,
                      //                     fontSize: 15,
                      //                   ),
                      //                   child: Column(
                      //                     mainAxisSize: MainAxisSize.min,
                      //                     crossAxisAlignment: CrossAxisAlignment.start,
                      //                     spacing: 2,
                      //                     children: [
                      //                       Text(
                      //                         _transaction.name ?? "N/A",
                      //                         style: TextStyle(fontWeight: FontWeight.w600),
                      //                       ),
                      //                       Text(
                      //                         _transaction.startDate == null
                      //                             ? "N/A"
                      //                             : DateFormat('dd MMM yyyy').format(_transaction.startDate!),
                      //                         style: TextStyle(color: const Color(0xff4B5563)),
                      //                       ),
                      //                       Text('Payment By: ${_transaction.paymentBy ?? "N/A"}'),
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ),
                      //               Expanded(
                      //                 child: DefaultTextStyle.merge(
                      //                   overflow: TextOverflow.ellipsis,
                      //                   maxLines: 1,
                      //                   textAlign: TextAlign.end,
                      //                   style: _theme.textTheme.bodyLarge?.copyWith(
                      //                     fontWeight: FontWeight.w500,
                      //                     fontSize: 15,
                      //                     color: const Color(0xff4B5563),
                      //                   ),
                      //                   child: Column(
                      //                     mainAxisSize: MainAxisSize.min,
                      //                     crossAxisAlignment: CrossAxisAlignment.end,
                      //                     spacing: 2,
                      //                     children: [
                      //                       Text(
                      //                         '${_lang.started}: ${_transaction.startDate == null ? "N/A" : DateFormat('dd MMM yyyy').format(_transaction.startDate!)}',
                      //                       ),
                      //                       Text(
                      //                         '${_lang.end}: ${_transaction.endDate == null ? "N/A" : DateFormat('dd MMM yyyy').format(_transaction.endDate!)}',
                      //                       ),
                      //                       Text.rich(
                      //                         TextSpan(
                      //                           text: '${_lang.status}: ',
                      //                           children: [
                      //                             WidgetSpan(
                      //                               alignment: PlaceholderAlignment.middle,
                      //                               child: Container(
                      //                                 padding: const EdgeInsets.symmetric(horizontal: 8),
                      //                                 decoration: BoxDecoration(
                      //                                   color: (_transaction.isPaid
                      //                                           ? Colors.green
                      //                                           : const Color(0xffC52127))
                      //                                       .withValues(alpha: 0.15),
                      //                                   borderRadius: BorderRadius.circular(5),
                      //                                 ),
                      //                                 child: Text(
                      //                                   _transaction.isPaid ? _lang.paid : _lang.unPaid,
                      //                                   style: TextStyle(
                      //                                     color: _transaction.isPaid
                      //                                         ? Colors.green
                      //                                         : const Color(0xffC52127),
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                             )
                      //                           ],
                      //                         ),
                      //                       )
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //         ],
                      //       ),
                      //     );
                      //   },
                      // ),
                    ),
                  ),
                );
              },
              error: (e, stack) => Center(child: Text(e.toString())),
              loading: () => Center(child: CircularProgressIndicator()),
            );
          },
          error: (e, stack) => Center(child: Text(e.toString())),
          loading: () => Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
