// File: bank_to_bank_transfer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';

// --- Local Imports ---
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
// Data Source Imports
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20to%20bank%20transfer/repo/bank_to_bank_transfar_repo.dart';
import '../bank account/model/bank_transfer_history_model.dart';
import '../bank%20account/model/bank_account_list_model.dart';
import '../bank%20account/provider/bank_account_provider.dart';
import '../widgets/image_picker_widget.dart';

class BankToBankTransferScreen extends ConsumerStatefulWidget {
  // 1. Add optional transaction parameter for editing
  final TransactionData? transaction;

  const BankToBankTransferScreen({super.key, this.transaction});

  @override
  ConsumerState<BankToBankTransferScreen> createState() => _BankToBankTransferScreenState();
}

class _BankToBankTransferScreenState extends ConsumerState<BankToBankTransferScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  // Controllers
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  // State
  BankData? _fromBank;
  BankData? _toBank;
  DateTime? _selectedDate;
  File? _pickedImage; // Image file state (for new upload/replace)
  String? _existingImageUrl; // State for image already on the server

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    if (transaction != null) {
      // 2. Pre-fill data for editing
      amountController.text = transaction.amount?.toString() ?? '';
      descriptionController.text = transaction.note ?? '';
      _existingImageUrl = transaction.image; // Set existing image URL

      // Parse and set the date
      try {
        if (transaction.date != null) {
          _selectedDate = _apiFormat.parse(transaction.date!);
          dateController.text = _displayFormat.format(_selectedDate!);
        }
      } catch (e) {
        // Fallback to current date if parsing fails
        _selectedDate = DateTime.now();
        dateController.text = _displayFormat.format(_selectedDate!);
      }

      // The actual bank selection (fromBankId and toBankId) will be handled
      // when the bank list loads (in the 'data' block of banksAsync.when).
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

  // --- Submission Logic ---
  void _submit() async {
    if (!_key.currentState!.validate()) return;
    if (_fromBank == null || _toBank == null) {
      // Show an error if banks haven't been selected/pre-filled
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.S.of(context).pleaseSelectBothAccounts)));
      return;
    }

    if (_fromBank!.id == _toBank!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.S.of(context).cannotTransferToSameAccounts,
          ),
        ),
      );
      return;
    }

    final repo = BankTransactionRepo();

    final isEditing = widget.transaction != null;
    final transactionId = widget.transaction?.id;

    if (isEditing && transactionId != null) {
      // 3. Call UPDATE function
      await repo.updateBankTransfer(
        // **You need to implement this in your repo**
        ref: ref,
        context: context,
        transactionId: transactionId, // Pass the ID for update
        fromBankId: _fromBank!.id!,
        toBankId: _toBank!.id!,
        amount: num.tryParse(amountController.text) ?? 0,
        date: _apiFormat.format(_selectedDate!),
        note: descriptionController.text.trim(),
        image: _pickedImage, // New image to upload (or null)
        existingImageUrl: _existingImageUrl, // Existing image URL if needed by the API
        transactionType: "bank_to_bank",
        type: '',
      );
    } else {
      // 3. Call CREATE function
      await repo.createBankTransfer(
        ref: ref,
        context: context,
        fromBankId: _fromBank!.id!,
        toBankId: _toBank!.id!,
        amount: num.tryParse(amountController.text) ?? 0,
        date: _apiFormat.format(_selectedDate!),
        note: descriptionController.text.trim(),
        image: _pickedImage,
        transactionType: "bank_to_bank",
        type: '',
      );
    }
  }

  // --- Reset/Cancel Logic ---
  void _resetOrCancel() {
    Navigator.pop(context);
  }

  // --- Helper to pre-select banks on data load ---
  void _setInitialBanks(List<BankData> banks) {
    if (widget.transaction != null && _fromBank == null && _toBank == null) {
      _fromBank = banks.firstWhere(
        (bank) => bank.id == widget.transaction!.fromBankId,
        orElse: () => _fromBank!, // Fallback (shouldn't happen if IDs are correct)
      );
      _toBank = banks.firstWhere(
        (bank) => bank.id == widget.transaction!.toBankId,
        orElse: () => _toBank!, // Fallback
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final banksAsync = ref.watch(bankListProvider);
    final isEditing = widget.transaction != null;
    final appBarTitle = isEditing ? _lang.editBankTransfer : _lang.bankToBankTransfer;
    final saveButtonText = isEditing ? _lang.update : _lang.save;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: banksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading bank accounts: $err')),
        data: (bankModel) {
          final banks = bankModel.data ?? [];

          // Important: Set initial bank state once the data is loaded
          _setInitialBanks(banks);

          if (banks.length < 2) {
            return Center(
                child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(_lang.needAtLeastTwoBankAccount, textAlign: TextAlign.center),
            ));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: From Bank (Full Width)
                  _buildBankDropdown(banks, isFrom: true),
                  const SizedBox(height: 20),

                  // Row 2: To Bank (Full Width)
                  _buildBankDropdown(banks, isFrom: false),
                  const SizedBox(height: 20),

                  // Row 3: Amount (Full Width)
                  _buildAmountInput(),
                  const SizedBox(height: 20),

                  // Row 4: Date (Full Width)
                  _buildDateInput(context),
                  const SizedBox(height: 20),

                  // Row 5: Description (Full Width)
                  _buildDescriptionInput(),
                  const SizedBox(height: 20),

                  // Row 6: Image Picker (Full Width, using reusable widget)
                  ReusableImagePicker(
                    initialImage: _pickedImage,
                    // Pass existing image URL for display when editing
                    existingImageUrl: _existingImageUrl,
                    onImagePicked: (file) {
                      // Update the local state variable when image is picked/removed
                      setState(() {
                        _pickedImage = file;
                        // If a new image is picked, clear the existing URL
                        if (file != null) _existingImageUrl = null;
                      });
                    },
                    onImageRemoved: () {
                      setState(() {
                        _pickedImage = null;
                        _existingImageUrl = null; // Clear both file and URL
                      });
                    },
                  ),
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
                // 4. Update button text
                child: Text(saveButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDropdown(List<BankData> banks, {required bool isFrom}) {
    return DropdownButtonFormField<BankData>(
      initialValue: isFrom ? _fromBank : _toBank,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: kPeraColor,
      ),
      decoration: InputDecoration(
        labelText: isFrom ? l.S.of(context).from : l.S.of(context).to,
        hintText: l.S.of(context).selectOne,
      ),
      validator: (value) => value == null ? l.S.of(context).selectAccount : null,
      items: banks.map((bank) {
        return DropdownMenuItem<BankData>(
          value: bank,
          enabled: isFrom ? (bank.id != _toBank?.id) : (bank.id != _fromBank?.id),
          child: Text(bank.name ?? 'Unknown'),
        );
      }).toList(),
      onChanged: (BankData? newValue) {
        setState(() {
          if (isFrom) {
            _fromBank = newValue;
          } else {
            _toBank = newValue;
          }
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
      maxLines: 3,
      decoration: InputDecoration(
        labelText: l.S.of(context).description,
        hintText: l.S.of(context).enterDescription,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      ),
    );
  }
}
