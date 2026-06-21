// File: add_edit_shelf.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

// --- Local Imports ---
import 'package:mobile_pos/Screens/shelfs/repo/shelf_repo.dart';
import 'package:mobile_pos/constant.dart';

import 'model/shelf_list_model.dart';

class AddEditShelf extends ConsumerStatefulWidget {
  final bool isEdit;
  final ShelfData? shelf;

  const AddEditShelf({super.key, this.isEdit = false, this.shelf});

  @override
  ConsumerState<AddEditShelf> createState() => _AddEditShelfState();
}

class _AddEditShelfState extends ConsumerState<AddEditShelf> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  // TextEditingController descController is removed

  String? _selectedStatus;
  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.shelf != null) {
      final data = widget.shelf!;
      nameController.text = data.name ?? '';
      // descController.text = data.description ?? ''; // Removed
      _selectedStatus = (data.status == 1 || data.status == 'Active') ? 'Active' : 'Inactive';
    } else {
      _selectedStatus = 'Active';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    // descController.dispose(); // Removed
    super.dispose();
  }

  // --- Submission Logic ---
  Future<void> _submit() async {
    if (!_key.currentState!.validate()) {
      return;
    }

    final repo = ShelfRepo();
    final String apiStatus = _selectedStatus == 'Active' ? '1' : '0';

    EasyLoading.show(status: widget.isEdit ? 'Updating...' : 'Saving...');

    if (widget.isEdit) {
      await repo.updateShelf(
        ref: ref,
        context: context,
        id: widget.shelf!.id!.round(),
        name: nameController.text,
        status: apiStatus,
      );
    } else {
      await repo.createShelf(
        ref: ref,
        context: context,
        name: nameController.text,
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
        // descController.clear(); // Removed
        _selectedStatus = 'Active';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEdit ? _lang.editShift : _lang.addShelf),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: [
              // 1. Shelf Name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: _lang.shelfName, hintText: _lang.enterShelfName),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterShelfName : null,
              ),
              const SizedBox(height: 16),

              // 2. Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(labelText: _lang.status, hintText: _lang.selectOne),
                items:
                    _statusOptions.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedStatus = newValue);
                },
                validator: (value) => value == null ? _lang.pleaseSelectStatus : null,
              ),
              const SizedBox(height: 30),

              // NOTE: Description field removed here

              // 4. Action Buttons (Reset/Save)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(widget.isEdit ? _lang.cancel : _lang.resets),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
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
