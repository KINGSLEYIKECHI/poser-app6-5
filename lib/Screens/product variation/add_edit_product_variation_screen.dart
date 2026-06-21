// File: add_edit_variation.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/product%20variation/repo/product_variation_repo.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'model/product_variation_model.dart';

class AddEditVariation extends ConsumerStatefulWidget {
  final bool isEdit;
  final VariationData? variation;

  const AddEditVariation({super.key, this.isEdit = false, this.variation});

  @override
  ConsumerState<AddEditVariation> createState() => _AddEditVariationState();
}

class _AddEditVariationState extends ConsumerState<AddEditVariation> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueInputController = TextEditingController(); // Input for adding new tag

  List<String> _selectedValues = []; // List of values (tags)
  String? _selectedStatus;

  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.variation != null) {
      final data = widget.variation!;
      nameController.text = data.name ?? '';

      // Load initial status
      _selectedStatus = (data.status == 1) ? 'Active' : 'Inactive';

      // Load existing values (List<String>)
      _selectedValues = data.values ?? [];
    } else {
      _selectedStatus = 'Active';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    valueInputController.dispose();
    super.dispose();
  }

  // --- Tag/Chip Management ---
  void _addValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_selectedValues.contains(trimmed)) {
      setState(() {
        _selectedValues.add(trimmed);
      });
      valueInputController.clear();
    }
  }

  void _removeValue(String value) {
    setState(() {
      _selectedValues.remove(value);
    });
    _key.currentState?.validate();
  }

  // --- Submission Logic ---
  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;

    // Final check for values input (if user entered text but didn't press enter/add)
    _addValue(valueInputController.text);

    if (_selectedValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one value.')),
      );
      return;
    }

    final repo = VariationRepo();
    final String apiStatus = _selectedStatus == 'Active' ? '1' : '0';

    // CRITICAL: Convert List<String> to Comma Separated String for API payload
    final String valuesString = _selectedValues.join(',');

    if (widget.isEdit) {
      await repo.updateVariation(
        ref: ref,
        context: context,
        id: widget.variation!.id!.round(),
        name: nameController.text,
        values: valuesString,
        status: apiStatus,
      );
    } else {
      await repo.createVariation(
        ref: ref,
        context: context,
        name: nameController.text,
        values: valuesString,
        status: apiStatus,
      );
    }
  }

  // --- Reset Logic ---
  void _resetForm() {
    if (widget.isEdit) {
      Navigator.pop(context);
    } else {
      setState(() {
        _key.currentState?.reset();
        nameController.clear();
        valueInputController.clear();
        _selectedStatus = 'Active';
        _selectedValues = [];
      });
    }
  }

  // Helper widget to display values as chips
  Widget _buildValueChip(String value) {
    return Chip(
      label: Text(value),
      backgroundColor: kMainColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: kMainColor),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _removeValue(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEdit ? _lang.editVariations : _lang.addNewVariation),
        actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Variation Name Input
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: _lang.name, hintText: _lang.enterName),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterName : null,
              ),
              const SizedBox(height: 20),

              // 2. Values (Chip/Tag Input)
              Text(_lang.values, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),

              Container(
                width: 500,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    ..._selectedValues.map(_buildValueChip),
                    IntrinsicWidth(
                      child: TextField(
                        controller: valueInputController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: _lang.enterValues,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                        ),

                        // Input settings
                        // CRITICAL FIX: Use onSubmitted to handle 'Enter' key press
                        onSubmitted: (value) => _addValue(value),

                        // onEditingComplete is also useful but usually triggered by software keyboard's 'Done'
                        onEditingComplete: () => _addValue(valueInputController.text),
                      ),
                    ),
                  ],
                ),
              ),
              // Hidden Validator based on selected list
              if (_selectedValues.isEmpty && valueInputController.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _lang.pleaseEnterAtLeastOneValues,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 20),

              // 3. Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(labelText: _lang.status, hintText: _lang.selectOne),
                items: [
                  DropdownMenuItem(value: 'Active', child: Text(_lang.active)),
                  DropdownMenuItem(value: 'Inactive', child: Text(_lang.inactive)),
                ],
                // items:
                //     _statusOptions.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (String? newValue) => setState(() => _selectedStatus = newValue),
                validator: (value) => value == null ? _lang.pleaseSelectAStatus : null,
              ),
              const SizedBox(height: 30),

              // 4. Action Buttons (Reset/Save)
              Row(
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
                      child: Text(widget.isEdit ? _lang.update : _lang.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
