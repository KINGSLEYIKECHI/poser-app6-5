// File: adjust_bank_balance_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

// --- Local Imports ---
import 'package:mobile_pos/currency.dart';

// Data Source Imports
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20to%20bank%20transfer/repo/bank_to_bank_transfar_repo.dart';
import '../bank account/model/bank_transfer_history_model.dart';
import '../bank%20account/model/bank_account_list_model.dart';
import '../bank%20account/provider/bank_account_provider.dart';
import '../widgets/image_picker_widget.dart';

// Adjustment Type Model (Reused)
class AdjustmentType {
  final String displayName;
  final String apiValue;
  const AdjustmentType(this.displayName, this.apiValue);
}

const List<AdjustmentType> adjustmentTypes = [
  AdjustmentType('Increase balance', 'credit'),
  AdjustmentType('Decrease balance', 'debit'),
];

class AdjustBankBalanceScreen extends ConsumerStatefulWidget {
  // Added optional transaction parameter for editing
  final TransactionData? transaction;

  const AdjustBankBalanceScreen({super.key, this.transaction});

  @override
  ConsumerState<AdjustBankBalanceScreen> createState() => _AdjustBankBalanceScreenState();
}

class _AdjustBankBalanceScreenState extends ConsumerState<AdjustBankBalanceScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  BankData? _selectedBank;
  AdjustmentType? _selectedType;
  DateTime? _selectedDate;
  File? _pickedImage;
  String? _existingImageUrl; // State for image already on the server

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
      _selectedType = adjustmentTypes.firstWhere(
        (type) => type.apiValue == transaction.type,
        orElse: () => adjustmentTypes.first,
      );

      try {
        if (transaction.date != null) {
          _selectedDate = _apiFormat.parse(transaction.date!);
          dateController.text = _displayFormat.format(_selectedDate!);
        }
      } catch (e) {
        _selectedDate = DateTime.now();
        dateController.text = _displayFormat.format(_selectedDate!);
      }
    } else {
      // For a new transaction
      _selectedDate = DateTime.now();
      dateController.text = _displayFormat.format(_selectedDate!);
      _selectedType = adjustmentTypes.first;
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

  // --- Submission Logic (Handles both Create and Update) ---
// --- Submission Logic (Handles both Create and Update) ---
  void _submit() async {
    if (!_key.currentState!.validate()) return;
    if (_selectedBank == null || _selectedType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select an account and adjustment type.')));
      return;
    }

    final repo = BankTransactionRepo();
    final isEditing = widget.transaction != null;
    final transactionId = widget.transaction?.id;

    // Base parameters are collected from the state
    final num amount = num.tryParse(amountController.text) ?? 0;
    final String date = _apiFormat.format(_selectedDate!);
    final String note = descriptionController.text.trim();

    if (isEditing && transactionId != null) {
      // Call UPDATE function by passing EACH parameter explicitly
      await repo.updateBankTransfer(
        ref: ref,
        context: context,
        transactionId: transactionId, // Specific to UPDATE
        existingImageUrl: _existingImageUrl, // Specific to UPDATE
        // Common parameters passed explicitly
        fromBankId: _selectedBank!.id!,
        toBankId: _selectedBank!.id!, // Same bank for adjustment
        amount: amount,
        date: date,
        note: note,
        image: _pickedImage,
        transactionType: 'adjust_bank',
        type: _selectedType!.apiValue,
      );
    } else {
      // Call CREATE function by passing EACH parameter explicitly
      await repo.createBankTransfer(
        ref: ref,
        context: context,

        // Common parameters passed explicitly
        fromBankId: _selectedBank!.id!,
        toBankId: _selectedBank!.id!, // Same bank for adjustment
        amount: amount,
        date: date,
        note: note,
        image: _pickedImage,
        transactionType: 'adjust_bank',
        type: _selectedType!.apiValue,
      );
    }
  }

  // --- Form Reset Logic ---
  void _clearForm() {
    setState(() {
      _selectedBank = null;
      _selectedType = adjustmentTypes.first;
      _pickedImage = null;
      _existingImageUrl = null;
      _selectedDate = DateTime.now();
      dateController.text = _displayFormat.format(_selectedDate!);
      amountController.clear();
      descriptionController.clear();
    });
    _key.currentState?.reset();
  }

  void _resetOrCancel(bool isResetButton) {
    if (isResetButton) {
      _clearForm();
    } else {
      Navigator.pop(context);
    }
  }

  // --- Helper to pre-select bank on data load ---
  void _setInitialBank(List<BankData> banks) {
    if (widget.transaction != null && _selectedBank == null) {
      _selectedBank = banks.firstWhere(
        (bank) => bank.id == widget.transaction!.fromBankId,
        orElse: () => _selectedBank!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final banksAsync = ref.watch(bankListProvider);
    final isEditing = widget.transaction != null;
    final appBarTitle = isEditing ? _lang.editBankAdjustment : _lang.adjustBankBalance;
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
          // Set initial bank state once the data is loaded
          _setInitialBank(banks);

          if (banks.isEmpty) {
            return Center(
                child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(_lang.pleaseAddAtLeastOneBank, textAlign: TextAlign.center),
            ));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Account Name
                  _buildAccountDropdown(banks),
                  const SizedBox(height: 20),

                  // 2. Type (Increase/Decrease)
                  _buildAdjustmentTypeDropdown(),
                  const SizedBox(height: 20),

                  // 3. Amount
                  _buildAmountInput(),
                  const SizedBox(height: 20),

                  // 4. Adjustment Date
                  _buildDateInput(context),
                  const SizedBox(height: 20),

                  // 5. Description
                  _buildDescriptionInput(),
                  const SizedBox(height: 20),

                  // 6. Image Picker (Updated for Edit)
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
                  const SizedBox(height: 30),
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
                onPressed: () => _resetOrCancel(true),
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
                child: Text(saveButtonText), // Dynamically shows Save/Update
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildAccountDropdown(List<BankData> banks) {
    return DropdownButtonFormField<BankData>(
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: kPeraColor,
      ),
      initialValue: _selectedBank,
      decoration: InputDecoration(
        labelText: l.S.of(context).accountNumber,
        hintText: l.S.of(context).selectOne,
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
          _selectedBank = newValue;
        });
      },
    );
  }

  Widget _buildAdjustmentTypeDropdown() {
    return DropdownButtonFormField<AdjustmentType>(
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: kPeraColor,
      ),
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: l.S.of(context).type,
        hintText: l.S.of(context).selectType,
      ),
      validator: (value) => value == null ? l.S.of(context).selectType : null,
      items: adjustmentTypes.map((type) {
        return DropdownMenuItem<AdjustmentType>(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (AdjustmentType? newValue) {
        setState(() {
          _selectedType = newValue;
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
