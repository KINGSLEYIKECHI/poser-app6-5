// File: cash_to_bank_transfer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/cansh%20in%20hand/repo/cash_in_hand_repo.dart';

// --- Local Imports ---
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

import '../bank%20account/model/bank_transfer_history_model.dart';
import '../bank%20account/model/bank_account_list_model.dart';
import '../bank%20account/provider/bank_account_provider.dart';
import '../widgets/image_picker_widget.dart';
import 'model/cash_transaction_list_model.dart';

class CashToBankTransferScreen extends ConsumerStatefulWidget {
  // Optional transaction parameter for editing
  final CashTransactionData? transaction;

  const CashToBankTransferScreen({super.key, this.transaction});

  @override
  ConsumerState<CashToBankTransferScreen> createState() => _CashToBankTransferScreenState();
}

class _CashToBankTransferScreenState extends ConsumerState<CashToBankTransferScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  // Controllers
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  // State
  BankData? _toBank; // Now we select the destination Bank
  DateTime? _selectedDate;
  File? _pickedImage;
  String? _existingImageUrl; // For editing: stores existing image URL

  // Placeholder for Cash ID/Platform identifier (API must accept this)
  final num _cashPlatformId = 0;
  final String _transactionType = 'cash_to_bank';

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    if (transaction != null) {
      // Pre-fill data for editing
      amountController.text = transaction.amount?.toString() ?? '';
      descriptionController.text = transaction.note ?? '';
      _existingImageUrl = transaction.image;

      try {
        if (transaction.date != null) {
          _selectedDate = _apiFormat.parse(transaction.date!);
          dateController.text = _displayFormat.format(_selectedDate!);
        }
      } catch (e) {
        _selectedDate = DateTime.now();
        dateController.text = _displayFormat.format(_selectedDate!);
      }

      // Note: _toBank selection will be handled in _setInitialBank
    } else {
      // For a new transaction
      _selectedDate = DateTime.now();
      dateController.text = _displayFormat.format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    descriptionController.dispose();
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

  // Helper to pre-select the 'To' bank on data load
  void _setInitialBank(List<BankData> banks) {
    if (widget.transaction != null && _toBank == null) {
      // For Cash to Bank, the destination bank is 'toBankId'
      _toBank = banks.firstWhere(
        (bank) => bank.id == widget.transaction!.toBank,
        orElse: () => _toBank!,
      );
    }
  }

  // --- Submission Logic ---
  void _submit() async {
    if (!_key.currentState!.validate()) return;
    if (_toBank == null) {
      // Check if destination bank is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.S.of(context).pleaseSelectADestinationBankAccounts,
          ),
        ),
      );
      return;
    }

    final repo = CashTransactionRepo(); // Using Cash Repo
    final isEditing = widget.transaction != null;
    final transactionId = widget.transaction?.id;

    // Common parameters
    final num fromBankId = _cashPlatformId; // Cash is always FROM
    final num toBankId = _toBank!.id!; // Destination bank is TO
    final num amount = num.tryParse(amountController.text) ?? 0;
    final String date = _apiFormat.format(_selectedDate!);
    final String note = descriptionController.text.trim();
    const String type = ''; // Assuming type is blank for transfers

    if (isEditing && transactionId != null) {
      // Call UPDATE function (Assuming CashTransactionRepo has a similar update structure)
      await repo.updateCashTransfer(
        // *** NOTE: Must match the function signature added to CashTransactionRepo below ***
        transactionId: transactionId,
        existingImageUrl: _existingImageUrl,
        ref: ref,
        context: context,
        fromBankId: fromBankId,
        toBankId: toBankId,
        amount: amount,
        date: date,
        note: note,
        image: _pickedImage,
        transactionType: _transactionType,
        type: type,
      );
    } else {
      // Call CREATE function
      await repo.createCashTransfer(
        // *** NOTE: Must match the function signature added to CashTransactionRepo below ***
        ref: ref,
        context: context,
        fromBankId: fromBankId,
        toBankId: toBankId,
        amount: amount,
        date: date,
        note: note,
        image: _pickedImage,
        transactionType: _transactionType,
        type: type,
      );
    }
  }

  // --- Reset/Cancel Logic ---
  void _resetOrCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final banksAsync = ref.watch(bankListProvider); // To get destination banks
    final isEditing = widget.transaction != null;
    final appBarTitle = isEditing ? _lang.editCashToBank : _lang.bankToCashTransfer;
    final saveButtonText = isEditing ? _lang.update : _lang.save;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(onPressed: _resetOrCancel, icon: const Icon(Icons.close)),
        ],
      ),
      body: banksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading bank accounts: $err')),
        data: (bankModel) {
          final banks = bankModel.data ?? [];

          _setInitialBank(banks); // Set initial bank selection for editing

          if (banks.isEmpty) {
            return Center(child: Text(_lang.noDestinationBankAccountFond, textAlign: TextAlign.center));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: From (Static Cash)
                  _buildStaticCashField(),
                  const SizedBox(height: 20),

                  // Row 2: To Bank (Dropdown)
                  _buildToBankDropdown(banks),
                  const SizedBox(height: 20),

                  // Row 3: Amount
                  _buildAmountInput(),
                  const SizedBox(height: 20),

                  // Row 4: Date
                  _buildDateInput(context),
                  const SizedBox(height: 20),

                  // Row 5: Description
                  _buildDescriptionInput(),
                  const SizedBox(height: 20),

                  // Row 6: Image Picker
                  ReusableImagePicker(
                    initialImage: _pickedImage,
                    existingImageUrl: _existingImageUrl,
                    onImagePicked: (file) {
                      setState(() {
                        _pickedImage = file;
                        if (file != null) _existingImageUrl = null;
                      });
                    },
                    onImageRemoved: () {
                      setState(() {
                        _pickedImage = null;
                        _existingImageUrl = null;
                      });
                    },
                  ),
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
                onPressed: _resetOrCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: Text(_lang.cancel),
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
                child: Text(saveButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildStaticCashField() {
    return TextFormField(
      initialValue: 'Cash',
      readOnly: true,
      decoration: InputDecoration(
        labelText: l.S.of(context).from, // Changed label to 'From'
        hintText: l.S.of(context).cash,
        filled: true,
      ),
    );
  }

  Widget _buildToBankDropdown(List<BankData> banks) {
    return DropdownButtonFormField<BankData>(
      initialValue: _toBank,
      icon: Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        labelText: l.S.of(context).to,
        hintText: l.S.of(context).selectOneAccount,
      ),
      validator: (value) => value == null ? l.S.of(context).selectAccount : null,
      items: banks.map((bank) {
        return DropdownMenuItem<BankData>(
          value: bank,
          child: Text(bank.name ?? 'Unknown'),
        );
      }).toList(),
      onChanged: (BankData? newValue) {
        setState(() {
          _toBank = newValue;
        });
      },
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: l.S.of(context).amount,
        hintText: 'Ex: 500',
        prefixText: currency,
      ),
      validator: (value) {
        if (value!.isEmpty) return l.S.of(context).amountsIsRequired;
        if (num.tryParse(value) == null || num.parse(value) <= 0) return l.S.of(context).invalidAmount;
        return null;
      },
    );
  }

  Widget _buildDateInput(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: dateController,
      decoration: InputDecoration(
        labelText: l.S.of(context).adjustmentDate,
        hintText: 'DD/MM/YYYY',
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
      maxLines: 4,
      decoration: InputDecoration(
        labelText: l.S.of(context).description,
        hintText: l.S.of(context).enterDescription,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      ),
    );
  }
}
