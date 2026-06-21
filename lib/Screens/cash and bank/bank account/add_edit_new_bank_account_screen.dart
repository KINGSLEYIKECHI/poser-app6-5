// File: add_edit_new_bank.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/cash%20and%20bank/bank%20account/repo/bank_account_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
// --- Local Imports ---
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/currency.dart';

import 'model/bank_account_list_model.dart';

// Accept optional BankData for editing
class AddEditNewBank extends ConsumerStatefulWidget {
  final BankData? bankData;
  const AddEditNewBank({super.key, this.bankData});

  @override
  ConsumerState<AddEditNewBank> createState() => _AddEditNewBankState();
}

class _AddEditNewBankState extends ConsumerState<AddEditNewBank> {
  final _key = GlobalKey<FormState>();

  // Core fields
  final nameController = TextEditingController(); // Account Display Name
  final openingBalanceController = TextEditingController();
  final asOfDateController = TextEditingController();

  // Meta fields
  final accNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final upiController = TextEditingController();
  final bankNameController = TextEditingController();
  final accHolderController = TextEditingController();

  // State
  bool _showMoreFields = false;
  bool _showInInvoice = false;
  DateTime? _selectedDate;

  // Date formats
  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd', 'en_US');

  bool get isEditing => widget.bankData != null;

  @override
  void initState() {
    super.initState();
    if (!isEditing) {
      _selectedDate = DateTime.now();
      asOfDateController.text = _displayFormat.format(_selectedDate!);
    } else {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final data = widget.bankData!;
    nameController.text = data.name ?? '';
    openingBalanceController.text = data.openingBalance?.toString() ?? '';
    _showInInvoice = data.showInInvoice == 1;

    if (data.openingDate != null) {
      try {
        _selectedDate = DateTime.parse(data.openingDate!);
        asOfDateController.text = _displayFormat.format(_selectedDate!);
      } catch (_) {
        asOfDateController.text = data.openingDate!;
      }
    }

    if (data.meta != null) {
      _showMoreFields = true;
      accNumberController.text = data.meta!.accountNumber ?? '';
      ifscController.text = data.meta!.ifscCode ?? '';
      upiController.text = data.meta!.upiId ?? '';
      bankNameController.text = data.meta!.bankName ?? '';
      accHolderController.text = data.meta!.accountHolder ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    openingBalanceController.dispose();
    asOfDateController.dispose();
    accNumberController.dispose();
    ifscController.dispose();
    upiController.dispose();
    bankNameController.dispose();
    accHolderController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      context: context,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        asOfDateController.text = _displayFormat.format(picked);
      });
    }
  }

  // --- Submission Logic ---
  void _submit() async {
    if (!_key.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As of Date is required.')));
      }
      return;
    }

    final repo = BankRepo();
    final apiOpeningDate = _apiFormat.format(_selectedDate!);
    final apiShowInInvoice = _showInInvoice ? 1 : 0;

    final meta = BankMeta(
      accountNumber: accNumberController.text.trim(),
      ifscCode: ifscController.text.trim(),
      upiId: upiController.text.trim(),
      bankName: bankNameController.text.trim(),
      accountHolder: accHolderController.text.trim(),
    );

    if (isEditing) {
      await repo.updateBank(
        ref: ref,
        context: context,
        id: widget.bankData!.id!,
        name: nameController.text,
        openingBalance: num.tryParse(openingBalanceController.text) ?? 0,
        openingDate: apiOpeningDate,
        showInInvoice: apiShowInInvoice,
        meta: meta,
      );
    } else {
      await repo.createBank(
        ref: ref,
        context: context,
        name: nameController.text,
        openingBalance: num.tryParse(openingBalanceController.text) ?? 0,
        openingDate: apiOpeningDate,
        showInInvoice: apiShowInInvoice,
        meta: meta,
      );
    }
  }

  // --- Reset/Cancel Logic ---
  void _resetOrCancel() {
    if (isEditing) {
      Navigator.pop(context);
    } else {
      setState(() {
        _key.currentState?.reset();
        nameController.clear();
        openingBalanceController.clear();
        accNumberController.clear();
        ifscController.clear();
        upiController.clear();
        bankNameController.clear();
        accHolderController.clear();
        _showInInvoice = false;
        _showMoreFields = false;
        _selectedDate = DateTime.now();
        asOfDateController.text = _displayFormat.format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          isEditing ? _lang.editBankAccounts : _lang.addNewBankAccounts,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 2, color: kBackgroundColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Row 1: Account Display Name ---
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: _lang.accountDisplayName,
                  hintText: _lang.enterAccountDisplayName,
                ),
                validator: (value) => value!.isEmpty ? _lang.displayNameIsRequired : null,
              ),
              const SizedBox(height: 20),

              // --- Row 2: Balance, Date (Max 2 fields) ---
              TextFormField(
                controller: openingBalanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _lang.openingBalance,
                  hintText: 'Ex: 500',
                  prefixText: currency,
                ),
                validator: (value) => value!.isEmpty ? _lang.openingBalanceIsRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: asOfDateController,
                decoration: InputDecoration(
                  labelText: _lang.asOfDate,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                    icon: const Icon(IconlyLight.calendar, size: 22),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => value!.isEmpty ? _lang.dateIsRequired : null,
              ),
              const SizedBox(height: 16),

              // --- Toggle More Fields Button ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showMoreFields = !_showMoreFields;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _showMoreFields ? '- ${_lang.hideFiled}' : '+ ${_lang.addMoreFiled}',
                    style: _theme.textTheme.bodyMedium?.copyWith(
                      color: kSuccessColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Extra Fields (Meta Data) ---
              if (_showMoreFields)
                Column(
                  children: [
                    // Row 3: Account Number, IFSC
                    TextFormField(
                      controller: accNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _lang.accountNumber,
                        hintText: _lang.enterAccountName,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: ifscController,
                      decoration: InputDecoration(labelText: _lang.ifscCode, hintText: 'Ex: DBBL0001234'),
                    ),
                    const SizedBox(height: 20),

                    // Row 4: UPI, Bank Name
                    TextFormField(
                      controller: upiController,
                      decoration: InputDecoration(
                        labelText: _lang.upiIdForQrCode,
                        hintText: 'yourname@upi',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: bankNameController,
                      decoration: InputDecoration(
                        labelText: _lang.bankName,
                        hintText: _lang.enterBankName,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Row 5: Account Holder (Single field)
                    TextFormField(
                      controller: accHolderController,
                      decoration: InputDecoration(
                        labelText: _lang.accountHolderName,
                        hintText: _lang.enterAccountHolderName,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // --- Show in Invoice Checkbox ---
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                            side: const BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        child: Checkbox(
                          value: _showInInvoice,
                          onChanged: (value) {
                            setState(() => _showInInvoice = value ?? false);
                          },
                          activeColor: Colors.blue, // your kMainColor
                        ),
                      ),
                    ),
                    TextSpan(
                      text: _lang.printBankDetailsAndInvoice,
                      style: const TextStyle(color: Colors.black),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() => _showInInvoice = !_showInInvoice);
                        },
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.grey, // your kGreyTextColor
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetOrCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: Text(isEditing ? _lang.cancel : _lang.resets),
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
                child: Text(_lang.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
