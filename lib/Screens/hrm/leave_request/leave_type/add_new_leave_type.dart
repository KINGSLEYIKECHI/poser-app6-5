// File: add_new_leave_type.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/leave_request/leave_type/repo/leave_type_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
// --- Local Imports ---
import 'package:mobile_pos/Screens/hrm/widgets/label_style.dart';
import 'package:mobile_pos/constant.dart';

import 'model/leave_type_list_model.dart';

class AddNewLeaveType extends ConsumerStatefulWidget {
  final LeaveTypeData? leaveTypeData; // For editing

  // isEdit property replaced by checking if leaveTypeData is null
  const AddNewLeaveType({super.key, this.leaveTypeData});

  @override
  ConsumerState<AddNewLeaveType> createState() => _AddNewLeaveTypeState();
}

class _AddNewLeaveTypeState extends ConsumerState<AddNewLeaveType> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String? selectedValue;
  GlobalKey<FormState> key = GlobalKey();

  bool get isEditing => widget.leaveTypeData != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final data = widget.leaveTypeData!;
      nameController.text = data.name ?? '';
      descriptionController.text = data.description ?? '';

      // Convert num status (1/0) to string status ('Active'/'Inactive')
      if (data.status == 1) {
        selectedValue = 'Active';
      } else if (data.status == 0) {
        selectedValue = 'Inactive';
      }
    } else {
      // Default status for new entry
      selectedValue = 'Active';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (key.currentState!.validate() && selectedValue != null) {
      final repo = LeaveTypeRepo();
      final statusNum = selectedValue == 'Active' ? 1 : 0;

      if (isEditing) {
        // --- UPDATE LEAVE TYPE ---
        await repo.updateLeaveType(
          ref: ref,
          context: context,
          id: widget.leaveTypeData!.id!,
          name: nameController.text,
          description: descriptionController.text,
          status: statusNum,
        );
      } else {
        // --- CREATE LEAVE TYPE ---
        await repo.createLeaveType(
          ref: ref,
          context: context,
          name: nameController.text,
          description: descriptionController.text,
          status: statusNum,
        );
      }
    }
  }

  void _resetOrCancel() {
    if (isEditing) {
      Navigator.pop(context);
    } else {
      setState(() {
        key.currentState?.reset();
        nameController.clear();
        descriptionController.clear();
        selectedValue = 'Active';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? _lang.editLeaveType : _lang.addNewLeaveType,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 2,
            color: kBackgroundColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  label: labelSpan(
                    title: _lang.name,
                    context: context,
                  ),
                  hintText: _lang.enterLeaveTypeName,
                ),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterLeaveTypeName : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedValue,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: kNeutral800,
                ),
                decoration: InputDecoration(
                  labelText: _lang.status,
                  hintText: _lang.selectAStatus,
                ),
                // items: ['Active', 'Inactive'].map((String value) {
                //   return DropdownMenuItem<String>(value: value, child: Text(value));
                // }).toList(),
                items: [
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text(_lang.active),
                  ),
                  DropdownMenuItem(
                    value: 'Inactive',
                    child: Text(_lang.inactive),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                },
                validator: (value) => value == null ? _lang.pleaseSelectAStatus : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: _lang.description,
                  hintText: _lang.enterDescription,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetOrCancel,
                      child: Text(isEditing ? _lang.cancel : _lang.resets),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? _lang.update : _lang.save),
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
