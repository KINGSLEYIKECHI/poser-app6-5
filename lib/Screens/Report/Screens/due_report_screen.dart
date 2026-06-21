import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/pdf_report/due_report/due_report_excel.dart';
import 'package:mobile_pos/pdf_report/due_report/due_report_pdf.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../PDF Invoice/due_invoice_pdf.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Provider/transactions_provider.dart';
import '../../../constant.dart';
import '../../../core/theme/_app_colors.dart';
import '../../../currency.dart';
import '../../../thermal priting invoices/model/print_transaction_model.dart';
import '../../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Due Calculation/Providers/due_provider.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../invoice_details/due_invoice_details.dart';

class DueReportScreen extends ConsumerStatefulWidget {
  const DueReportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DueReportScreenState createState() => _DueReportScreenState();
}

class _DueReportScreenState extends ConsumerState<DueReportScreen> {
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
      ref.refresh(filteredDueProvider(filter));
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
    // final translateTime = getTranslateTime(context);
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(filteredDueProvider(_getDateRangeFilter()));
        final printerData = ref.watch(thermalPrinterProvider);
        final personalData = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(
                l.S.of(context).dueReport,
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
                                  generateDueReportPdf(context, transaction, business, fromDate, toDate);
                                } else {
                                  EasyLoading.showError(_lang.listIsEmpty);
                                }
                              },
                              icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                            ),
                            IconButton(
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (transaction.isNotEmpty) {
                                  generateDueReportExcel(context, transaction, business, fromDate, toDate);
                                } else {
                                  EasyLoading.showInfo(_lang.noDataAvailableForGeneratePdf);
                                }
                              },
                              icon: SvgPicture.asset('assets/excel.svg'),
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
                    if (permissionService.hasPermission(Permit.dueReportsRead.value)) ...{
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
                        final filteredTransactions = transaction.where((due) {
                          final customerName = due.user?.name?.toLowerCase() ?? '';
                          final invoiceNumber = due.invoiceNumber?.toLowerCase() ?? '';
                          return customerName.contains(searchCustomer) || invoiceNumber.contains(searchCustomer);
                        }).toList();
                        double totalReceiveDue = 0; // Customer receive
                        double totalPaidDue = 0; // Supplier paid

                        for (var element in filteredTransactions) {
                          final amount = element.payDueAmount ?? 0;

                          if (element.party?.type == 'Supplier') {
                            totalPaidDue += amount; // For Suppliers
                          } else {
                            totalReceiveDue += amount; // For Customers
                          }
                        }
                        return filteredTransactions.isNotEmpty
                            ? Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 77,
                                            decoration: BoxDecoration(
                                              color: kSuccessColor.withValues(alpha: 0.1),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "$currency${formatPointNumber(totalReceiveDue)}",
                                                  style: _theme.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  l.S.of(context).customerPay,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: _theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: kPeraColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            height: 77,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: DAppColors.kWarning.withValues(alpha: 0.1),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "$currency${formatPointNumber(totalPaidDue)}",
                                                  style: _theme.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  l.S.of(context).supplerPay,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: _theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: kPeraColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filteredTransactions.length,
                                    itemBuilder: (context, index) {
                                      final item = transaction[index];

                                      final partyName = item.party?.name ?? item.sale?.invoiceNumber ?? 'n/a';
                                      final partyType = item.party?.type ?? 'n/a';
                                      final invoiceNo = item.invoiceNumber ?? 'n/a';

                                      final dueAmount = item.dueAmountAfterPay ?? 0;
                                      final totalDue = item.totalDue ?? 0;

                                      final paidAmount = (totalDue - dueAmount).clamp(0, double.infinity);

                                      // ---- SAFE DATE ----
                                      DateTime? paymentDate;
                                      try {
                                        if (item.paymentDate != null && item.paymentDate!.isNotEmpty) {
                                          paymentDate = DateTime.parse(item.paymentDate!);
                                        }
                                      } catch (_) {
                                        paymentDate = null;
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          if (personalData.value != null) {
                                            DueInvoiceDetails(
                                              dueCollection: filteredTransactions[index],
                                              personalInformationModel: personalData.value!,
                                            ).launch(context);
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              width: context.width(),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // ------------------- TOP ROW ----------------------
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(partyName,
                                                              style: _theme.textTheme.titleSmall?.copyWith(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 15,
                                                              )),
                                                          const SizedBox(width: 10),
                                                          if (partyType == 'Supplier')
                                                            Text(
                                                              '[S]',
                                                              style: _theme.textTheme.titleSmall
                                                                  ?.copyWith(color: kMainColor),
                                                            ),
                                                        ],
                                                      ),
                                                      Text('#$invoiceNo'),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // ------------------- STATUS + DATE ----------------------
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: dueAmount <= 0
                                                              ? const Color(0xff0dbf7d).withValues(alpha: 0.1)
                                                              : const Color(0xFFED1A3B).withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          dueAmount <= 0
                                                              ? l.S.of(context).fullyPaid
                                                              : l.S.of(context).stillUnpaid,
                                                          style: _theme.textTheme.titleSmall?.copyWith(
                                                            color: dueAmount <= 0
                                                                ? const Color(0xff0dbf7d)
                                                                : const Color(0xFFED1A3B),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        paymentDate == null
                                                            ? '--'
                                                            : DateFormat.yMMMd().format(paymentDate),
                                                        style: _theme.textTheme.bodyMedium
                                                            ?.copyWith(color: kPeragrapColor),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 8),

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${l.S.of(context).total} : $currency${formatPointNumber(totalDue)}',
                                                        style: _theme.textTheme.titleSmall?.copyWith(
                                                          color: kPeraColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${l.S.of(context).paid} : $currency${formatPointNumber(paidAmount)}',
                                                        style: _theme.textTheme.titleSmall?.copyWith(
                                                          color: kPeraColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 3),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      // if (dueAmount > 0)
                                                      Text(
                                                        '${l.S.of(context).due}: $currency${formatPointNumber(dueAmount)}',
                                                        style: _theme.textTheme.titleMedium?.copyWith(
                                                          color: kPeraColor,
                                                        ),
                                                      ),

                                                      // ------------------- PERSONAL DATA ----------------------
                                                      personalData.when(
                                                        data: (data) {
                                                          return Row(
                                                            children: [
                                                              IconButton(
                                                                padding: EdgeInsets.zero,
                                                                visualDensity:
                                                                    const VisualDensity(horizontal: -4, vertical: -4),
                                                                onPressed: () async {
                                                                  if (Theme.of(context).platform ==
                                                                      TargetPlatform.android) {
                                                                    final model = PrintDueTransactionModel(
                                                                      dueTransactionModel: item,
                                                                      personalInformationModel: data,
                                                                    );
                                                                    await printerData.printDueThermalInvoiceNow(
                                                                      transaction: model,
                                                                      invoiceSize: data.data?.invoiceSize,
                                                                      context: context,
                                                                    );
                                                                  }
                                                                },
                                                                icon: const Icon(FeatherIcons.printer,
                                                                    color: kPeraColor, size: 22),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    visualDensity: const VisualDensity(
                                                                        horizontal: -4, vertical: -4),
                                                                    onPressed: () => DueInvoicePDF.generateDueDocument(
                                                                      item,
                                                                      data,
                                                                      context,
                                                                      showPreview: true,
                                                                    ),
                                                                    icon: HugeIcon(
                                                                      icon: HugeIcons.strokeRoundedPdf02,
                                                                      size: 22,
                                                                      color: kPeraColor,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    visualDensity: const VisualDensity(
                                                                        horizontal: -4, vertical: -4),
                                                                    onPressed: () => DueInvoicePDF.generateDueDocument(
                                                                      item,
                                                                      data,
                                                                      context,
                                                                      download: true,
                                                                    ),
                                                                    icon: HugeIcon(
                                                                      icon: HugeIcons.strokeRoundedDownload01,
                                                                      size: 22,
                                                                      color: kPeraColor,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    visualDensity: const VisualDensity(
                                                                        horizontal: -4, vertical: -4),
                                                                    onPressed: () => DueInvoicePDF.generateDueDocument(
                                                                      item,
                                                                      data,
                                                                      context,
                                                                      isShare: true,
                                                                    ),
                                                                    icon: HugeIcon(
                                                                      icon: HugeIcons.strokeRoundedShare08,
                                                                      size: 22,
                                                                      color: kPeraColor,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                        error: (e, stack) => Text(e.toString()),
                                                        loading: () => Text(l.S.of(context).loading),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Divider
                                            Container(
                                              height: 1,
                                              color: kBottomBorder,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    // itemBuilder: (context, index) {
                                    //   return GestureDetector(
                                    //     onTap: () {
                                    //       DueInvoiceDetails(
                                    //         dueCollection: filteredTransactions[index],
                                    //         personalInformationModel: personalData.value!,
                                    //       ).launch(context);
                                    //     },
                                    //     child: Column(
                                    //       children: [
                                    //         Container(
                                    //           padding: const EdgeInsets.all(20),
                                    //           width: context.width(),
                                    //           child: Column(
                                    //             crossAxisAlignment: CrossAxisAlignment.start,
                                    //             children: [
                                    //               Row(
                                    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //                 children: [
                                    //                   Row(
                                    //                     children: [
                                    //                       Text(
                                    //                         transaction[index].party?.name ?? '',
                                    //                         style: const TextStyle(fontSize: 16),
                                    //                       ),
                                    //                       const SizedBox(
                                    //                         width: 10,
                                    //                       ),
                                    //                       Visibility(
                                    //                         visible: transaction[index].party?.type == 'Supplier',
                                    //                         child: const Text(
                                    //                           '[S]',
                                    //                           style: TextStyle(
                                    //                               //fontSize: 16,
                                    //                               color: kMainColor),
                                    //                         ),
                                    //                       )
                                    //                     ],
                                    //                   ),
                                    //                   Text('#${transaction[index].invoiceNumber}'),
                                    //                 ],
                                    //               ),
                                    //               const SizedBox(height: 10),
                                    //               Row(
                                    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //                 children: [
                                    //                   Container(
                                    //                     padding: const EdgeInsets.all(8),
                                    //                     decoration: BoxDecoration(
                                    //                         color: transaction[index].dueAmountAfterPay! <= 0
                                    //                             ? const Color(0xff0dbf7d).withOpacity(0.1)
                                    //                             : const Color(0xFFED1A3B).withOpacity(0.1),
                                    //                         borderRadius: const BorderRadius.all(Radius.circular(10))),
                                    //                     child: Text(
                                    //                       transaction[index].dueAmountAfterPay! <= 0 ? lang.S.of(context).fullyPaid : lang.S.of(context).stillUnpaid,
                                    //                       style: TextStyle(color: transaction[index].dueAmountAfterPay! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                    //                     ),
                                    //                   ),
                                    //                   Text(
                                    //                     DateFormat.yMMMd().format(DateTime.parse(transaction[index].paymentDate ?? '')),
                                    //                     style: const TextStyle(color: Colors.grey),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //               const SizedBox(height: 10),
                                    //               Text(
                                    //                 '${lang.S.of(context).total} : $currency${transaction[index].totalDue?.toStringAsFixed(2) ?? '0'}',
                                    //                 style: const TextStyle(color: Colors.grey),
                                    //               ),
                                    //               const SizedBox(height: 10),
                                    //               Text(
                                    //                 '${lang.S.of(context).paid} : $currency ${(transaction[index].totalDue!.toDouble() - transaction[index].dueAmountAfterPay!.toDouble()).toStringAsFixed(2) ?? '/a'}',
                                    //                 style: const TextStyle(color: Colors.grey),
                                    //               ),
                                    //               Row(
                                    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //                 children: [
                                    //                   Text(
                                    //                     '${lang.S.of(context).due}: $currency ${transaction[index].dueAmountAfterPay?.toStringAsFixed(2)}',
                                    //                     style: const TextStyle(fontSize: 16),
                                    //                   ).visible((transaction[index].dueAmountAfterPay ?? 0) > 0),
                                    //                   personalData.when(data: (data) {
                                    //                     return Row(
                                    //                       children: [
                                    //                         IconButton(
                                    //                             padding: EdgeInsets.zero,
                                    //                             visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    //                             onPressed: () async {
                                    //                               if ((Theme.of(context).platform == TargetPlatform.android)) {
                                    //                                 ///________Print_______________________________________________________
                                    //
                                    //                                 PrintDueTransactionModel model =
                                    //                                     PrintDueTransactionModel(dueTransactionModel: transaction[index], personalInformationModel: data);
                                    //                                 await printerData.printDueThermalInvoiceNow(
                                    //                                     transaction: model, invoiceSize: data.data?.invoiceSize, context: context);
                                    //                               }
                                    //                             },
                                    //                             icon: const Icon(
                                    //                               FeatherIcons.printer,
                                    //                               color: Colors.grey,
                                    //                               size: 22,
                                    //                             )),
                                    //                         const SizedBox(width: 10),
                                    //                         businessSettingData.when(data: (business) {
                                    //                           return Row(
                                    //                             children: [
                                    //                               IconButton(
                                    //                                   padding: EdgeInsets.zero,
                                    //                                   visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    //                                   onPressed: () =>
                                    //                                       DueInvoicePDF.generateDueDocument(transaction[index], data, context, business, showPreview: true),
                                    //                                   icon: const Icon(
                                    //                                     Icons.picture_as_pdf,
                                    //                                     color: Colors.grey,
                                    //                                     size: 22,
                                    //                                   )),
                                    //                               IconButton(
                                    //                                   padding: EdgeInsets.zero,
                                    //                                   visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    //                                   onPressed: () => DueInvoicePDF.generateDueDocument(transaction[index], data, context, business, download: true),
                                    //                                   icon: const Icon(
                                    //                                     FeatherIcons.download,
                                    //                                     color: Colors.grey,
                                    //                                     size: 22,
                                    //                                   )),
                                    //                               IconButton(
                                    //                                   padding: EdgeInsets.zero,
                                    //                                   visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    //                                   onPressed: () => DueInvoicePDF.generateDueDocument(transaction[index], data, context, business, isShare: true),
                                    //                                   icon: const Icon(
                                    //                                     Icons.share,
                                    //                                     color: Colors.grey,
                                    //                                     size: 22,
                                    //                                   )),
                                    //                             ],
                                    //                           );
                                    //                         }, error: (e, stack) {
                                    //                           return Text(e.toString());
                                    //                         }, loading: () {
                                    //                           return const Center(
                                    //                             child: CircularProgressIndicator(),
                                    //                           );
                                    //                         })
                                    //                       ],
                                    //                     );
                                    //                   }, error: (e, stack) {
                                    //                     return Text(e.toString());
                                    //                   }, loading: () {
                                    //                     //return const Text('Loading');
                                    //                     return Text(lang.S.of(context).loading);
                                    //                   }),
                                    //                 ],
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //         Container(
                                    //           height: 0.5,
                                    //           width: context.width(),
                                    //           color: Colors.grey,
                                    //         )
                                    //       ],
                                    //     ),
                                    //   );
                                    // },
                                  )
                                ],
                              )
                            : Center(
                                child: Text(
                                  l.S.of(context).collectDues,
                                  maxLines: 2,
                                  style:
                                      const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                                ),
                              );
                      }, error: (e, stack) {
                        return Text(e.toString());
                      }, loading: () {
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
