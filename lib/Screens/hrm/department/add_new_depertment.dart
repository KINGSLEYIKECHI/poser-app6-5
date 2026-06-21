// File: add_edit_department.dart
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/department/model/department_list_model.dart';
import 'package:mobile_pos/Screens/hrm/department/repo/department_repo.dart';
import 'package:mobile_pos/constant.dart';
// Assuming DepartmentRepo is available via this path

class AddEditDepartment extends ConsumerStatefulWidget {
  final bool isEdit;
  final DepartmentData? department;

  const AddEditDepartment({super.key, this.isEdit = false, this.department});

  @override
  ConsumerState<AddEditDepartment> createState() => _AddEditDepartmentState();
}

class _AddEditDepartmentState extends ConsumerState<AddEditDepartment> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String? _selectedStatus; // UI state for dropdown

  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.department != null) {
      final data = widget.department!;
      nameController.text = data.name ?? '';
      descController.text = data.description ?? '';
      // Convert num status (1/0) to string status ('Active'/'Inactive')
      _selectedStatus = data.status.toString() == '1' || data.status.toString() == 'Active' ? 'Active' : 'Inactive';
    } else {
      _selectedStatus = 'Active'; // Default status for new entry
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  // --- Submission Logic ---
  Future<void> _submit() async {
    if (!_key.currentState!.validate()) {
      return;
    }

    final repo = DepartmentRepo();
    // Convert selected string status to API required string "1" (Active) or "0" (Inactive)
    final String apiStatus = _selectedStatus == 'Active' ? '1' : '0';

    EasyLoading.show(status: widget.isEdit ? 'Updating...' : 'Saving...');

    if (widget.isEdit) {
      await repo.updateDepartment(
        ref: ref,
        context: context,

        // Assuming ID is non-null when isEdit is true
        id: widget.department!.id!.round(),
        name: nameController.text,
        description: descController.text,
        status: apiStatus,
      );
    } else {
      await repo.createDepartment(
        ref: ref,
        context: context,
        name: nameController.text,
        description: descController.text,
        status: apiStatus,
      );
    }
  }

  // --- Reset Logic ---
  void _resetForm() {
    setState(() {
      _key.currentState?.reset();
      nameController.clear();
      descController.clear();
      _selectedStatus = 'Active';

      // If editing, pressing reset should revert to original values
      if (widget.isEdit && widget.department != null) {
        final data = widget.department!;
        nameController.text = data.name ?? '';
        descController.text = data.description ?? '';
        _selectedStatus = data.status == '1' || data.status == 'Active' ? 'Active' : 'Inactive';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEdit ? _lang.editDepartment : _lang.addDepartment),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: [
              // 1. Department Name
              TextFormField(
                controller: nameController,
                decoration: kInputDecoration.copyWith(
                  labelText: _lang.departmentName,
                  hintText: _lang.enterDepartmentName,
                ),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterDepartmentName : null,
              ),
              const SizedBox(height: 16),

              // 2. Status Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                icon: const Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: kInputDecoration.copyWith(labelText: _lang.status),
                // items: _statusOptions.map((String value) {
                //   return DropdownMenuItem(value: value, child: Text(value));
                // }).toList(),
                //   'Active', 'Inactive'
                items: [
                  DropdownMenuItem(value: 'Active', child: Text(_lang.active)),
                  DropdownMenuItem(value: 'Inactive', child: Text(_lang.inactive)),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) => value == null ? _lang.pleaseSelectAStatus : null,
              ),
              const SizedBox(height: 16),

              // 3. Description
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: kInputDecoration.copyWith(
                  labelText: _lang.description,
                  hintText: _lang.enterDescription,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Action Buttons (Reset/Save)
              Row(
                children: [
                  // Reset Button
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
                  // Save/Update Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      label: Text(widget.isEdit ? _lang.update : _lang.save),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
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
