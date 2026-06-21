// File: adjust_cash_balance_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/cansh%20in%20hand/repo/cash_in_hand_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

// --- Local Imports ---
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../bank%20account/model/bank_transfer_history_model.dart'; // TransactionData Model
import '../widgets/image_picker_widget.dart';
import 'model/cash_transaction_list_model.dart';

// Adjustment Type Model (Add/Reduce Cash)
class CashAdjustmentType {
  final String displayName;
  final String apiValue; // 'credit' for Add, 'debit' for Reduce
  const CashAdjustmentType(this.displayName, this.apiValue);
}

List<CashAdjustmentType> adjustmentTypes = [
  CashAdjustmentType(lang.S.current.addCash, 'credit'),
  CashAdjustmentType(lang.S.current.reduceCash, 'debit'),
];

class AdjustCashBalanceScreen extends ConsumerStatefulWidget {
  // Optional transaction parameter for editing (TransactionData is used here)
  final CashTransactionData? transaction;

  const AdjustCashBalanceScreen({super.key, this.transaction});

  @override
  ConsumerState<AdjustCashBalanceScreen> createState() => _AdjustCashBalanceScreenState();
}

class _AdjustCashBalanceScreenState extends ConsumerState<AdjustCashBalanceScreen> {
  final GlobalKey<FormState> _key = GlobalKey();

  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();

  // State
  CashAdjustmentType? _selectedType;
  DateTime? _selectedDate;
  File? _pickedImage;
  String? _existingImageUrl; // For editing: stores existing image URL

  // API Constants (Based on your POST fields)
  final num _cashIdentifier = 0; // 'from' field will be 0/Cash
  final String _transactionType = 'adjust_cash';

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd', 'en_US');

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    if (transaction != null) {
      // Pre-fill data for editing
      amountController.text = transaction.amount?.toString() ?? '';
      descriptionController.text = transaction.note ?? '';
      _existingImageUrl = transaction.image;

      // Determine adjustment type based on transaction.type ('credit' or 'debit')
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
      // For a new transaction: Default to Add Cash (Credit)
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
  void _submit() async {
    if (!_key.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an adjustment type.')));
      return;
    }

    final repo = CashTransactionRepo();
    final isEditing = widget.transaction != null;
    final transactionId = widget.transaction?.id;

    // Common parameters
    final num cashId = _cashIdentifier;
    final num amount = num.tryParse(amountController.text) ?? 0;
    final String date = _apiFormat.format(_selectedDate!);
    final String note = descriptionController.text.trim();
    final String type = _selectedType!.apiValue;

    if (isEditing && transactionId != null) {
      // Call UPDATE function
      await repo.updateCashTransfer(
        transactionId: transactionId,
        existingImageUrl: _existingImageUrl,
        ref: ref,
        context: context,
        fromBankId: cashId, // Cash identifier
        toBankId: cashId, // Cash identifier (as per your API structure for adjustment)
        amount: amount,
        date: date,
        note: note,
        image: _pickedImage,
        transactionType: _transactionType, // 'adjust_cash'
        type: type, // 'credit' or 'debit'
      );
    } else {
      // Call CREATE function
      await repo.createCashTransfer(
        ref: ref,
        context: context,
        fromBankId: cashId,
        toBankId: cashId, // Cash identifier
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
  void _resetForm() {
    setState(() {
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

  void _resetOrCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final isEditing = widget.transaction != null;
    final appBarTitle = isEditing ? _lang.editCashAdjustment : _lang.adjustCashBalance;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Adjustment Type (Radio Buttons)
              _buildAdjustmentTypeSelector(),
              const SizedBox(height: 20),

              // 2. Amount
              _buildAmountInput(),
              const SizedBox(height: 20),

              // 3. Adjustment Date
              _buildDateInput(context),
              const SizedBox(height: 20),
              // 5. Description
              _buildDescriptionInput(),
              const SizedBox(height: 20),

              // 4. Image Picker
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetForm, // Reset the form fields
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
                child: Text(saveButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildAdjustmentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: adjustmentTypes.map((type) {
        return RadioListTile<CashAdjustmentType>(
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          title: Text(
            type.displayName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          value: type,
          groupValue: _selectedType,
          onChanged: (CashAdjustmentType? newValue) {
            setState(() {
              _selectedType = newValue;
            });
          },
          dense: false,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
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
        hintText: l.S.of(context).description,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      ),
    );
  }
}
