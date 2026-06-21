// ignore_for_file: library_private_types_in_public_api, unused_result

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import '../../Screens/cash and bank/bank account/provider/bank_account_provider.dart';
import '../../constant.dart';
import '../../generated/l10n.dart' as lang;
import 'model/payment_transaction_model.dart';

class PaymentEntry {
  String? type;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController chequeNumberController = TextEditingController();
  final GlobalKey<FormFieldState> typeKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> amountKey = GlobalKey<FormFieldState>();

  PaymentEntry({this.type});

  void dispose() {
    amountController.dispose();
    chequeNumberController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': num.tryParse(amountController.text) ?? 0,
      'cheque_number': chequeNumberController.text,
    };
  }
}

class MultiPaymentWidget extends ConsumerStatefulWidget {
  final TextEditingController totalAmountController;
  final bool showChequeOption;
  final bool showWalletOption;
  final bool hideAddButton;
  final bool disableDropdown;

  final VoidCallback? onPaymentListChanged;
  final List<PaymentsTransaction>? initialTransactions;

  const MultiPaymentWidget({
    super.key,
    required this.totalAmountController,
    this.showChequeOption = false,
    this.showWalletOption = false,
    this.hideAddButton = false,
    this.disableDropdown = false,
    this.onPaymentListChanged,
    this.initialTransactions,
  });

  @override
  MultiPaymentWidgetState createState() => MultiPaymentWidgetState();
}

class MultiPaymentWidgetState extends ConsumerState<MultiPaymentWidget> {
  List<PaymentEntry> _paymentEntries = [];
  bool _isSyncing = false;

  List<PaymentEntry> getPaymentEntries() {
    return _paymentEntries;
  }

  @override
  void initState() {
    super.initState();
    _initializePaymentEntries();
    widget.totalAmountController.addListener(_onTotalAmountSync);
    _paymentEntries[0].amountController.addListener(_calculateTotalsFromPayments);
  }

  void _initializePaymentEntries() {
    if (widget.initialTransactions != null && widget.initialTransactions!.isNotEmpty) {
      for (var trans in widget.initialTransactions!) {
        String type = 'Cash';

        if (trans.transactionType?.toLowerCase().contains('cheque') ?? false) {
          type = 'Cheque';
        } else if (trans.paymentTypeId != null) {
          type = trans.paymentTypeId.toString();
        } else if (trans.transactionType?.toLowerCase().contains('cash') ?? false) {
          type = 'Cash';
        }

        PaymentEntry entry = PaymentEntry(type: type);
        entry.amountController.text = trans.amount?.toString() ?? '0';
        entry.amountController.addListener(_calculateTotalsFromPayments);
        if (type == 'Cheque') {
          entry.chequeNumberController.text = trans.meta?.chequeNumber ?? '';
        }

        _paymentEntries.add(entry);
      }
    } else {
      _paymentEntries = [PaymentEntry(type: 'Cash')];
      _paymentEntries[0].amountController.addListener(_calculateTotalsFromPayments);
    }
  }

  @override
  void dispose() {
    widget.totalAmountController.removeListener(_onTotalAmountSync);

    for (var entry in _paymentEntries) {
      entry.amountController.removeListener(_calculateTotalsFromPayments);
      entry.dispose();
    }
    super.dispose();
  }

  void _onTotalAmountSync() {
    if (_isSyncing || _paymentEntries.length != 1) return;
    _isSyncing = true;

    final totalText = widget.totalAmountController.text;
    if (_paymentEntries[0].amountController.text != totalText) {
      _paymentEntries[0].amountController.text = totalText;
    }
    setState(() {});

    _isSyncing = false;
  }

  void _calculateTotalsFromPayments() {
    if (_isSyncing) return;
    _isSyncing = true;

    double total = 0.0;
    for (var entry in _paymentEntries) {
      total += double.tryParse(entry.amountController.text) ?? 0.0;
    }

    setState(() {
      if (mounted) {
        if (widget.totalAmountController.text != total.toStringAsFixed(2)) {
          widget.totalAmountController.text = total.toStringAsFixed(2);
        }
      }
    });

    _isSyncing = false;
  }

  void _addPaymentRow() {
    final newEntry = PaymentEntry();
    newEntry.amountController.addListener(_calculateTotalsFromPayments);

    setState(() {
      _paymentEntries.add(newEntry);
    });

    widget.onPaymentListChanged?.call();
    _calculateTotalsFromPayments();
  }

  void _removePaymentRow(int index) {
    if (_paymentEntries.length > 1) {
      final entry = _paymentEntries[index];
      entry.amountController.removeListener(_calculateTotalsFromPayments);
      entry.dispose();

      setState(() {
        _paymentEntries.removeAt(index);
      });

      widget.onPaymentListChanged?.call();
      _calculateTotalsFromPayments();
    } else {
      EasyLoading.showError('At least one payment method is required');
    }
  }

  /// --------------------------------------------------------------------------
  /// Improved Shimmer Loading Widget
  /// Exact replica of the input layout + Add Button
  /// --------------------------------------------------------------------------
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // 1. Input Row Simulation
          Row(
            children: [
              // Dropdown Field (Flex 3)
              Expanded(
                flex: 3,
                child: Container(
                  height: 56, // Standard TextFormField height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8), // Matches standard radius
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Amount Field (Flex 2)
              Expanded(
                flex: 2,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8), // Gap between inputs and button

          // 2. Add Payment Button Simulation
          if (!widget.hideAddButton)
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                // Simulating the outlined button border
                borderRadius: BorderRadius.circular(4), // Standard button radius
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 18, height: 18, color: Colors.white), // Icon
                  const SizedBox(width: 8),
                  Container(width: 80, height: 14, color: Colors.white), // Text label
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = lang.S.of(context);
    final bankListAsync = ref.watch(bankListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///________PaymentType__________________________________
        Text(
          lang.S.of(context).paymentTypes,
          style: _theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        // Build dynamic payment rows
        bankListAsync.when(
          data: (bankData) {
            List<DropdownMenuItem<String>> paymentTypeItems = [
              DropdownMenuItem(
                value: 'Cash',
                child: Text(lang.S.of(context).cash),
              ),
              if (widget.showWalletOption)
                const DropdownMenuItem(
                  value: 'wallet',
                  child: Text("Wallet"),
                ),
              if (widget.showChequeOption)
                const DropdownMenuItem(
                  value: 'Cheque',
                  child: Text("Cheque"),
                ),
              ...(bankData.data?.map((bank) => DropdownMenuItem(
                        value: bank.id.toString(),
                        child: Text(bank.name ?? 'Unknown Bank'),
                      )) ??
                  []),
            ];

            return Column(
              children: [
                ..._paymentEntries.asMap().entries.map((entry) {
                  int index = entry.key;
                  PaymentEntry payment = entry.value;

                  return _buildPaymentRow(payment, index, paymentTypeItems,
                      readonly: widget.hideAddButton, disableDropdown: widget.disableDropdown);
                }),
                if (!widget.hideAddButton) const SizedBox(height: 4),
                // "Add Payment" Button
                if (!widget.hideAddButton)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(_lang.addPayment),
                      onPressed: _addPaymentRow,
                      style: TextButton.styleFrom(
                        foregroundColor: kMainColor,
                        side: const BorderSide(color: kMainColor),
                      ),
                    ),
                  ),
              ],
            );
          },
          // Replaced CircularProgressIndicator with Exact Layout Shimmer
          loading: () => _buildShimmerLoading(),
          error: (err, stack) => Text('Error loading banks: $err'),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(PaymentEntry payment, int index, List<DropdownMenuItem<String>> paymentTypeItems,
      {bool readonly = false, bool disableDropdown = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Type Dropdown
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: kGreyTextColor,
                ),
                key: payment.typeKey,
                initialValue: payment.type,
                hint: Text(lang.S.of(context).selectType),
                items: paymentTypeItems,
                onChanged: disableDropdown
                    ? null
                    : (value) {
                        setState(() {
                          payment.type = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),

            // Amount Field
            Expanded(
              flex: 2,
              child: TextFormField(
                key: payment.amountKey,
                readOnly: readonly,
                controller: payment.amountController,
                decoration: kInputDecoration.copyWith(labelText: lang.S.of(context).amount, hintText: 'Ex: 10'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                validator: (value) {
                  if (value.isEmptyOrNull) {
                    return 'Required';
                  }
                  if ((double.tryParse(value!) ?? 0) < 0) {
                    return 'Invalid';
                  }
                  return null;
                },
                onChanged: (val) {},
              ),
            ),
            // Remove Button
            if (_paymentEntries.length > 1)
              IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete02,
                  color: Colors.red,
                ),
                onPressed: () => _removePaymentRow(index),
              ),
          ],
        ),
        // Conditional Cheque Number field
        if (payment.type == 'Cheque')
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: TextFormField(
              controller: payment.chequeNumberController,
              decoration: kInputDecoration.copyWith(
                labelText: lang.S.of(context).chequeNumber,
                hintText: 'Ex: 12345689',
              ),
            ),
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}
