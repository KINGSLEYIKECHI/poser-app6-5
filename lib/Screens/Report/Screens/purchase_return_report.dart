import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/pdf_report/purchase_return_report/purchase_return_excel.dart';
import 'package:mobile_pos/pdf_report/purchase_return_report/purchase_returned_pdf.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../PDF Invoice/purchase_invoice_pdf.dart';
import '../../../PDF Invoice/tax_purchase_invoice.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../core/theme/_app_colors.dart';
import '../../../currency.dart';
import '../../../thermal priting invoices/model/print_transaction_model.dart';
import '../../../thermal priting invoices/provider/print_thermal_invoice_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../invoice_details/purchase_invoice_details.dart';

class PurchaseReturnReportScreen extends ConsumerStatefulWidget {
  const PurchaseReturnReportScreen({super.key});

  @override
  PurchaseReportState createState() => PurchaseReportState();
}

class PurchaseReportState extends ConsumerState<PurchaseReturnReportScreen> {
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
    'custom_date': l.S.current.customerDate, // Notice: assuming customerDate is correct from original
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
      ref.refresh(filterPurchaseReturnProvider(filter));
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
    return Consumer(
      builder: (context, ref, __) {
        final filter = _getDateRangeFilter();
        final purchaseData = ref.watch(filterPurchaseReturnProvider(filter));
        final printerData = ref.watch(thermalPrinterProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);

        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(l.S.of(context).purchaseReturnReport),
              actions: [
                businessInfo.when(
                  data: (business) {
                    return purchaseData.when(
                      data: (transaction) {
                        return Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (transaction.isNotEmpty) {
                                  generatePurchaseReturnReportPdf(context, transaction, business, fromDate, toDate);
                                } else {
                                  EasyLoading.showError(l.S.of(context).listIsEmpty);
                                }
                              },
                              icon: const HugeIcon(icon: HugeIcons.strokeRoundedPdf02, color: kSecondayColor),
                            ),
                            IconButton(
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (transaction.isNotEmpty) {
                                  generatePurchaseReturnReportExcel(context, transaction, business, fromDate, toDate);
                                } else {
                                  EasyLoading.showInfo(l.S.of(context).noDataAvailableForGeneratePdf);
                                }
                              },
                              icon: SvgPicture.asset('assets/excel.svg'),
                            ),
                            const SizedBox(width: 8),
                          ],
                        );
                      },
                      error: (e, stack) => Center(child: Text(e.toString())),
                      loading: () => const SizedBox.shrink(),
                    );
                  },
                  error: (e, stack) => Center(child: Text(e.toString())),
                  loading: () => const SizedBox.shrink(),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Column(
                  children: [
                    const Divider(thickness: 1, color: kBottomBorder, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                const Icon(IconlyLight.calendar, color: kPeraColor, size: 20),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: () {
                                    if (_showCustomDatePickers) {
                                      _selectDate(context: context, isFrom: true);
                                    }
                                  },
                                  child: Text(
                                    fromDate != null ? DateFormat('dd MMM yyyy').format(fromDate!) : 'From',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'To',
                                  style: _theme.textTheme.titleSmall,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_showCustomDatePickers) {
                                        _selectDate(context: context, isFrom: false);
                                      }
                                    },
                                    child: Text(
                                      toDate != null ? DateFormat('dd MMM yyyy').format(toDate!) : 'To',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 2),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Container(
                              height: 1,
                              width: 20,
                              color: kSubPeraColor,
                            ),
                          ),
                          const SizedBox(width: 2),
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
                    const Divider(thickness: 1, color: kBottomBorder, height: 1),
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
                    if (permissionService.hasPermission(Permit.purchaseReturnReportsRead.value)) ...{
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 12, bottom: 0),
                        child: TextFormField(
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
                            prefixIcon: const Padding(
                              padding: EdgeInsetsDirectional.only(start: 10),
                              child: Icon(
                                FeatherIcons.search,
                                color: kGrey6,
                              ),
                            ),
                            hintText: l.S.of(context).searchH,
                          ),
                        ),
                      ),
                      purchaseData.when(
                        data: (transaction) {
                          final filteredTransactions = transaction.where((sale) {
                            final customerName = sale.user?.name?.toLowerCase() ?? '';
                            final invoiceNumber = sale.invoiceNumber?.toLowerCase() ?? '';
                            return customerName.contains(searchCustomer) || invoiceNumber.contains(searchCustomer);
                          }).toList();

                          final totalPurchaseReturn =
                              filteredTransactions.fold<num>(0, (sum, purchase) => sum + (purchase.totalAmount ?? 0));
                          final totalDues =
                              filteredTransactions.fold<num>(0, (sum, purchase) => sum + (purchase.dueAmount ?? 0));

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 77,
                                        decoration: BoxDecoration(
                                          color: kSuccessColor.withValues(alpha: 0.1),
                                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "$currency${formatPointNumber(totalPurchaseReturn)}",
                                              style: _theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              l.S.of(context).totalPurchase,
                                              style: _theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: kPeraColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        height: 77,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: DAppColors.kWarning.withValues(alpha: 0.1),
                                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "$currency${formatPointNumber(totalDues)}",
                                              style: _theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              l.S.of(context).balanceDue,
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
                              filteredTransactions.isNotEmpty
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredTransactions.length,
                                      itemBuilder: (context, index) {
                                        final sale = filteredTransactions[index];
                                        final taxAsync = ref.watch(purchaseTaxProvider(sale.id!.toInt()));

                                        // Variables calculation
                                        final num totalAmt = sale.totalAmount ?? 0;
                                        final num dueAmt = sale.dueAmount ?? 0;
                                        final num paidAmt = totalAmt - dueAmt;

                                        num returndAmount = 0;
                                        if (sale.purchaseReturns != null) {
                                          for (var element in sale.purchaseReturns!) {
                                            if (element.purchaseReturnDetails != null) {
                                              for (var returnDetail in element.purchaseReturnDetails!) {
                                                returndAmount += (returnDetail.returnAmount ?? 0);
                                              }
                                            }
                                          }
                                        }

                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              child: InkWell(
                                                onTap: () {
                                                  PurchaseInvoiceDetails(
                                                    businessInfo: businessInfo.value!,
                                                    transitionModel: sale,
                                                  ).launch(context);
                                                },
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
                                                            style: _theme.textTheme.titleSmall?.copyWith(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 15,
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '#${sale.invoiceNumber}',
                                                          style: _theme.textTheme.titleSmall?.copyWith(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 8, vertical: 2),
                                                              decoration: BoxDecoration(
                                                                color: dueAmt <= 0
                                                                    ? const Color(0xff0dbf7d).withValues(alpha: 0.1)
                                                                    : const Color(0xFFED1A3B).withValues(alpha: 0.1),
                                                                borderRadius:
                                                                    const BorderRadius.all(Radius.circular(4)),
                                                              ),
                                                              child: Text(
                                                                dueAmt <= 0
                                                                    ? l.S.of(context).paid
                                                                    : l.S.of(context).unPaid,
                                                                style: _theme.textTheme.titleSmall?.copyWith(
                                                                  color: dueAmt <= 0
                                                                      ? const Color(0xff0dbf7d)
                                                                      : const Color(0xFFED1A3B),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(DateTime.parse(sale.purchaseDate ?? '')),
                                                          style:
                                                              _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${l.S.of(context).total} : $currency${formatPointNumber(totalAmt)}',
                                                          style:
                                                              _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${l.S.of(context).paid} : $currency${formatPointNumber(paidAmt)}',
                                                          style:
                                                              _theme.textTheme.titleSmall?.copyWith(color: kPeraColor),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            '${l.S.of(context).returnAmount}: $currency${formatPointNumber(returndAmount)}',
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: _theme.textTheme.titleSmall,
                                                          ),
                                                        ),
                                                        businessInfo.when(
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
                                                                      PrintPurchaseTransactionModel model =
                                                                          PrintPurchaseTransactionModel(
                                                                              purchaseTransitionModel: sale,
                                                                              personalInformationModel: data);

                                                                      await printerData.printPurchaseThermalInvoiceNow(
                                                                        transaction: model,
                                                                        productList:
                                                                            model.purchaseTransitionModel!.details,
                                                                        context: context,
                                                                        invoiceSize:
                                                                            businessInfo.value?.data?.invoiceSize,
                                                                      );
                                                                    }
                                                                  },
                                                                  icon: const Icon(FeatherIcons.printer,
                                                                      color: kPeraColor, size: 22),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Row(
                                                                  children: [
                                                                    IconButton(
                                                                      padding: EdgeInsets.zero,
                                                                      visualDensity: const VisualDensity(
                                                                          horizontal: -4, vertical: -4),
                                                                      onPressed: () =>
                                                                          PurchaseInvoicePDF.generatePurchaseDocument(
                                                                              sale, data, context,
                                                                              showPreview: true),
                                                                      icon: const HugeIcon(
                                                                          icon: HugeIcons.strokeRoundedPdf02,
                                                                          size: 22,
                                                                          color: kPeraColor),
                                                                    ),
                                                                    IconButton(
                                                                      padding: EdgeInsets.zero,
                                                                      visualDensity: const VisualDensity(
                                                                          horizontal: -4, vertical: -4),
                                                                      onPressed: () =>
                                                                          PurchaseInvoicePDF.generatePurchaseDocument(
                                                                              sale, data, context,
                                                                              download: true),
                                                                      icon: const HugeIcon(
                                                                          icon: HugeIcons.strokeRoundedDownload01,
                                                                          size: 22,
                                                                          color: kPeraColor),
                                                                    ),
                                                                    IconButton(
                                                                      style: IconButton.styleFrom(
                                                                        padding: EdgeInsets.zero,
                                                                        visualDensity: const VisualDensity(
                                                                            horizontal: -4, vertical: -4),
                                                                      ),
                                                                      onPressed: () =>
                                                                          PurchaseInvoicePDF.generatePurchaseDocument(
                                                                              sale, data, context,
                                                                              isShare: true),
                                                                      icon: const HugeIcon(
                                                                          icon: HugeIcons.strokeRoundedShare08,
                                                                          size: 22,
                                                                          color: kPeraColor),
                                                                    ),

                                                                    ///_____More____________________________________________
                                                                    if (data.data?.addons?.taxInvoicePdf == true)
                                                                      taxAsync.when(
                                                                        data: (taxData) {
                                                                          return PopupMenuButton(
                                                                            offset: const Offset(0, 30),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                    BorderRadius.circular(4.0)),
                                                                            padding: EdgeInsets.zero,
                                                                            itemBuilder: (BuildContext bc) => [
                                                                              ///________Tax invoice___________________________________
                                                                              PopupMenuItem(
                                                                                onTap: () async {
                                                                                  try {
                                                                                    final refreshedTaxData = await ref
                                                                                        .refresh(purchaseTaxProvider(
                                                                                                sale.id!.toInt())
                                                                                            .future);

                                                                                    if (refreshedTaxData == null) {
                                                                                      ScaffoldMessenger.of(context)
                                                                                          .showSnackBar(const SnackBar(
                                                                                              content: Text(
                                                                                                  'No tax data available')));
                                                                                      return;
                                                                                    }

                                                                                    await TaxPurchaseInvoicePdf
                                                                                        .generateSaleDocument(
                                                                                      refreshedTaxData,
                                                                                      data,
                                                                                      context,
                                                                                      showPreview: true,
                                                                                    );
                                                                                  } catch (e) {
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .showSnackBar(SnackBar(
                                                                                            content: Text(
                                                                                                'Error: ${e.toString()}')));
                                                                                  }
                                                                                },
                                                                                child: const Row(
                                                                                  children: [
                                                                                    HugeIcon(
                                                                                        icon: HugeIcons
                                                                                            .strokeRoundedPdf02,
                                                                                        size: 22,
                                                                                        color: kPeraColor),
                                                                                    SizedBox(width: 8),
                                                                                    Text('Tax Invoice',
                                                                                        style: TextStyle(
                                                                                            color: kGreyTextColor)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                            onSelected: (value) {
                                                                              Navigator.pushNamed(context, '$value');
                                                                            },
                                                                            child: const Icon(FeatherIcons.moreVertical,
                                                                                color: kGreyTextColor),
                                                                          );
                                                                        },
                                                                        error: (e, stack) =>
                                                                            Center(child: Text(e.toString())),
                                                                        loading: () => const Center(
                                                                            child: CircularProgressIndicator()),
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
                                            ),
                                            const Divider(height: 0, color: kBottomBorder),
                                          ],
                                        );
                                      },
                                    )
                                  : Center(
                                      child: EmptyWidgetUpdated(
                                        message: TextSpan(
                                          text: l.S.of(context).addNewPurchase,
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        },
                        error: (e, stack) => Text(e.toString()),
                        loading: () => const Center(child: CircularProgressIndicator()),
                      ),
                    } else
                      const Center(child: PermitDenyWidget()),
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
