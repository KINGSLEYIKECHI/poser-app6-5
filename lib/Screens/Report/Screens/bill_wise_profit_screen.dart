import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../core/theme/_app_colors.dart';
import '../../../currency.dart';
import '../../../model/bill_wise_loss_profit_report_model.dart' as bwlpm;
import '../../../pdf_report/loss_profit_report/bill_wise_loss_profit_report_pdf.dart';
import '../../../service/check_user_role_permission_provider.dart';

class BillWiseProfitScreen extends ConsumerStatefulWidget {
  const BillWiseProfitScreen({super.key});
  @override
  ConsumerState<BillWiseProfitScreen> createState() => _BillWiseProfitScreenState();
}

class _BillWiseProfitScreenState extends ConsumerState<BillWiseProfitScreen> {
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
      ref.refresh(filteredBillWiseLossProfitReportProvider(filter));
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
        final providerData = ref.watch(filteredBillWiseLossProfitReportProvider(_getDateRangeFilter()));
        final personalData = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        return personalData.when(
          data: (business) {
            return providerData.when(
              data: (data) {
                return GlobalPopup(
                  child: Scaffold(
                    backgroundColor: kWhite,
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      title: Text(_lang.billWiseProfit),
                      actions: [
                        IconButton(
                          onPressed: () {
                            if (data.transactions?.isNotEmpty == true) {
                              generateBillWiseLossProfitReportPdf(context, data, business, fromDate, toDate);
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
                      elevation: 0.0,
                    ),
                    body: RefreshIndicator(
                      onRefresh: _refreshFilteredProvider,
                      child: Column(
                        children: [
                          // Overview Containers
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                          "$currency${formatPointNumber(data.totalProfit ?? 0)}",
                                          style: _theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _lang.profit,
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
                                      color: DAppColors.kError.withValues(alpha: 0.1),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$currency${formatPointNumber((data.totalLoss ?? 0).abs())}",
                                          style: _theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _lang.loss,
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

                          // Data
                          Expanded(
                            child: ListView.builder(
                              itemCount: data.transactions?.length ?? 0,
                              itemBuilder: (context, index) {
                                final transaction = [...?data.transactions][index];

                                return GestureDetector(
                                  onTap: () => handleShowInvoiceDetails(context, transaction),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border(bottom: Divider.createBorderSide(context)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DefaultTextStyle.merge(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: _theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  spacing: 2,
                                                  children: [
                                                    Text(
                                                      transaction.partyName ?? "N/A",
                                                      style: TextStyle(fontWeight: FontWeight.w600),
                                                    ),
                                                    Text(transaction.invoiceNumber ?? "N/A"),
                                                    Text(
                                                      transaction.transactionDate == null
                                                          ? "N/A"
                                                          : DateFormat('dd MMM yyyy')
                                                              .format(transaction.transactionDate!),
                                                      style: TextStyle(color: const Color(0xff4B5563)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: DefaultTextStyle.merge(
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.end,
                                                style: _theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: const Color(0xff4B5563),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  spacing: 2,
                                                  children: [
                                                    Text(
                                                      '${_lang.sales}:  $currency${formatPointNumber(transaction.totalAmount ?? 0, addComma: true)}',
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        text: "${_lang.profit}: ",
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '$currency${formatPointNumber(transaction.isProfit ? (transaction.lossProfit ?? 0) : 0, addComma: true)}',
                                                            style: TextStyle(
                                                              color: transaction.isProfit ? DAppColors.kSuccess : null,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Text.rich(
                                                      TextSpan(
                                                        text: "${_lang.loss}: ",
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '$currency${formatPointNumber(transaction.isProfit ? 0 : (transaction.lossProfit ?? 0).abs(), addComma: true)}',
                                                            style: TextStyle(
                                                              color: transaction.isProfit ? null : DAppColors.kError,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
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

  Future<void> handleShowInvoiceDetails(BuildContext context, bwlpm.TransactionModel transaction) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (modalContext) => TestModal(transaction: transaction),
    );
  }
}

class TestModal extends StatelessWidget {
  const TestModal({super.key, required this.transaction});
  final bwlpm.TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    final locale = Localizations.localeOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
          decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_lang.invoice}: ${transaction.invoiceNumber ?? "N/A"} - ${transaction.partyName ?? ""}',
                  style: _theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const CloseButton(),
            ],
          ),
        ),

        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xffF5F3F3),
                child: Row(
                  children: [
                    ...[
                      _lang.itemName,
                      _lang.qty,
                      locale.languageCode == 'en' ? "Purch" : _lang.purchase,
                      _lang.salePrice,
                      _lang.profit,
                      _lang.loss,
                    ].asMap().entries.map((entry) {
                      return Expanded(
                        flex: entry.key == 0 ? 4 : 3,
                        child: Text(
                          entry.value,
                          textAlign: entry.key == 0 ? TextAlign.start : TextAlign.center,
                          style: _theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: transaction.items?.length ?? 0,
                  itemBuilder: (context, index) {
                    final _item = [...?transaction.items][index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(bottom: Divider.createBorderSide(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              _item.name ?? "N/A",
                              textAlign: TextAlign.start,
                              style: _theme.textTheme.bodyMedium?.copyWith(),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              (_item.quantity ?? 0).toString(),
                              textAlign: TextAlign.center,
                              style: _theme.textTheme.bodyMedium?.copyWith(),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "$currency${formatPointNumber(_item.purchasePrice ?? 0, addComma: true)}",
                              textAlign: TextAlign.center,
                              style: _theme.textTheme.bodyMedium?.copyWith(),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "$currency${formatPointNumber(_item.salesPrice ?? 0, addComma: true)}",
                              textAlign: TextAlign.center,
                              style: _theme.textTheme.bodyMedium?.copyWith(),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "$currency${formatPointNumber(_item.isProfit ? (_item.lossProfit ?? 0) : 0, addComma: true)}",
                              textAlign: TextAlign.center,
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                color: _item.isProfit ? DAppColors.kSuccess : null,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "$currency${formatPointNumber(_item.isProfit ? 0 : (_item.lossProfit ?? 0).abs(), addComma: true)}",
                              textAlign: TextAlign.center,
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                color: _item.isProfit ? null : DAppColors.kError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context)),
          ),
          child: Row(
            children: [
              ...[
                _lang.total,
                "${transaction.items?.fold<int>(0, (p, ev) => p + (ev.quantity ?? 0))}",
                "--",
                "--",
                "$currency${formatPointNumber(transaction.items?.fold<num>(0, (p, ev) {
                      return ev.isProfit ? (p + (ev.lossProfit ?? 0)) : p;
                    }) ?? 0, addComma: true)}",
                "$currency${formatPointNumber(transaction.items?.fold<num>(0, (p, ev) {
                      return ev.isProfit ? p : (p + (ev.lossProfit ?? 0));
                    }).abs() ?? 0, addComma: true)}",
              ].asMap().entries.map((entry) {
                return Expanded(
                  flex: entry.key == 0 ? 4 : 3,
                  child: Text(
                    entry.value,
                    textAlign: entry.key == 0 ? TextAlign.start : TextAlign.center,
                    style: _theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              })
            ],
          ),
        ),
        const SizedBox.square(dimension: 16),
      ],
    );
  }
}
