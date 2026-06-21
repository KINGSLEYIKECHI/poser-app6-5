// File: transfer_cheque_deposit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/cheques/repo/cheque_repository.dart';

// --- Local Imports ---
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
// Data Layer Imports
import '../bank%20account/model/bank_account_list_model.dart';
import '../bank%20account/provider/bank_account_provider.dart';
import 'model/cheques_list_model.dart';

// NOTE: Add a static Cash option to the dropdown list
final BankData _cashOption = BankData(name: 'Cash', id: 0);

class TransferChequeDepositScreen extends ConsumerStatefulWidget {
  final ChequeTransactionData cheque;

  const TransferChequeDepositScreen({super.key, required this.cheque});

  @override
  ConsumerState<TransferChequeDepositScreen> createState() => _TransferChequeDepositScreenState();
}

class _TransferChequeDepositScreenState extends ConsumerState<TransferChequeDepositScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  // Changed to dynamic to hold either BankData or _cashOption
  BankData? _depositDestination;
  DateTime? _selectedDate;

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    dateController.text = _displayFormat.format(_selectedDate!);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      context: context,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text = _displayFormat.format(picked);
      });
    }
  }

  void _submit() async {
    if (!_key.currentState!.validate()) return;
    if (_depositDestination == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a deposit destination (Bank or Cash).')));
      return;
    }

    final repo = ChequeRepository();

    // Determine the value to send to the repository: Bank ID or 'cash' string
    dynamic paymentDestination;
    if (_depositDestination!.id == 0) {
      // Using 0 for Cash option
      paymentDestination = 'cash';
    } else {
      paymentDestination = _depositDestination!.id; // Bank ID
    }

    await repo.depositCheque(
      ref: ref,
      context: context,
      chequeTransactionId: widget.cheque.id!,
      paymentDestination: paymentDestination,
      transferDate: _apiFormat.format(_selectedDate!),
      description: descriptionController.text.trim(),
    );
  }

  void _resetForm() {
    setState(() {
      _depositDestination = null;
      descriptionController.clear();
      _selectedDate = DateTime.now();
      dateController.text = _displayFormat.format(_selectedDate!);
    });
    // Reset form validation & states
    _key.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = l.S.of(context);
    final cheque = widget.cheque;
    final banksAsync = ref.watch(bankListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_lang.transferCheque),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      body: banksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading banks: $err')),
        data: (bankModel) {
          // Combine Bank List with the static Cash option
          final banks = [
            _cashOption, // Cash option first
            ...(bankModel.data ?? []),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Cheque Details ---
                  _buildDetailRow(theme, _lang.receivedFrom, cheque.user?.name ?? 'N/A'),
                  _buildDetailRow(theme, _lang.chequeAmount, '$currency${cheque.amount?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildDetailRow(theme, _lang.chequeNumber, cheque.meta?.chequeNumber ?? 'N/A'),
                  _buildDetailRow(theme, _lang.chequeDate, _formatDate(cheque.date)),
                  _buildDetailRow(theme, _lang.referenceNo, cheque.invoiceNo ?? 'N/A'),
                  const Divider(height: 30),

                  DropdownButtonFormField<BankData>(
                    initialValue: _depositDestination, // use value instead of initialValue
                    decoration: InputDecoration(
                      hintText: _lang.selectBankToCash,
                      labelText: _lang.depositTo,
                    ),
                    validator: (value) => value == null ? _lang.selectDepositDestination : null,
                    items: banks.map((destination) {
                      return DropdownMenuItem<BankData>(
                        value: destination,
                        child: Text(destination.name ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (BankData? newValue) {
                      setState(() {
                        _depositDestination = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Transfer Date Input ---
                  _buildDateInput(context),
                  const SizedBox(height: 20),

                  // --- Description Input ---
                  _buildDescriptionInput(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: Text(_lang.resets),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                ),
                child: Text(_lang.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(': ', style: theme.textTheme.bodyMedium),
          Expanded(
            child: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: dateController,
      decoration: InputDecoration(
        labelText: l.S.of(context).transferDate,
        suffixIcon: IconButton(
          icon: const Icon(IconlyLight.calendar, size: 22),
          onPressed: () => _selectDate(context),
        ),
      ),
      validator: (value) => value!.isEmpty ? l.S.of(context).dateIsRequired : null,
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: l.S.of(context).description,
        hintText: l.S.of(context).enterDescription,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}
