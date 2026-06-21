import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/hrm/designation/Model/designation_list_model.dart';
import 'package:mobile_pos/Screens/hrm/designation/repo/designation_repo.dart';
import 'package:mobile_pos/Screens/hrm/widgets/label_style.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/constant.dart';

class AddEditDesignation extends ConsumerStatefulWidget {
  final bool isEdit;
  final DesignationData? designation;

  const AddEditDesignation({super.key, this.isEdit = false, this.designation});

  @override
  ConsumerState<AddEditDesignation> createState() => _AddEditDesignationState();
}

class _AddEditDesignationState extends ConsumerState<AddEditDesignation> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String? selectedValue = 'Active';
  final key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.designation != null) {
      nameController.text = widget.designation?.name ?? '';
      descriptionController.text = widget.designation?.description ?? '';
      selectedValue = widget.designation?.status.toString() == '1' ? 'Active' : 'InActive';
    }
  }

  Future<void> _submit() async {
    if (!key.currentState!.validate()) return;

    final repo = DesignationRepo();
    EasyLoading.show(status: '${lang.S.of(context).saving}...');

    if (widget.isEdit) {
      await repo.updateDesignation(
        ref: ref,
        context: context,
        id: widget.designation!.id.toString(),
        name: nameController.text,
        status: selectedValue ?? lang.S.of(context).active,
        description: descriptionController.text,
      );
    } else {
      await repo.createDesignation(
        ref: ref,
        context: context,
        name: nameController.text,
        status: selectedValue ?? lang.S.of(context).active,
        description: descriptionController.text,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEdit ? _lang.editDesignation : _lang.addDesignation,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 2, color: kBackgroundColor),
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
                  label: labelSpan(title: _lang.designationName, context: context),
                  hintText: _lang.enterDesignationName,
                ),
                validator: (value) => value!.isEmpty ? _lang.pleaseEnterDesignationName : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: selectedValue,
                icon: Icon(Icons.keyboard_arrow_down, color: kNeutral800),
                decoration: InputDecoration(
                  labelText: _lang.status,
                  hintText: _lang.select,
                ),
                // items: ['Active', 'InActive'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                items: [
                  DropdownMenuItem(value: 'Active', child: Text(_lang.active)),
                  DropdownMenuItem(value: 'InActive', child: Text(_lang.inactive)),
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
                  hintText: '${_lang.enterDescription}...',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        key.currentState?.reset();
                        nameController.clear();
                        descriptionController.clear();
                        selectedValue = null;
                        setState(() {});
                      },
                      child: Text(_lang.resets),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
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
