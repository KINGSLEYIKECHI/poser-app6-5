import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/create_warehouse_data_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/warehouse_list_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_repo/warehouse_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import 'package:mobile_pos/constant.dart';

class AddNewWarehouse extends ConsumerStatefulWidget {
  const AddNewWarehouse({super.key, this.editData});
  final WarehouseData? editData;

  @override
  ConsumerState<AddNewWarehouse> createState() => _AddNewWarehouseState();
}

class _AddNewWarehouseState extends ConsumerState<AddNewWarehouse> {
  final _formKey = GlobalKey<FormState>();
  final warehouseNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      warehouseNameController.text = widget.editData?.name ?? '';
      emailController.text = widget.editData?.email ?? '';
      phoneNumberController.text = widget.editData?.phone ?? '';
      addressController.text = widget.editData?.address ?? '';
    }
  }

  @override
  void dispose() {
    warehouseNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> handleSave({required WidgetRef ref, required BuildContext context}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repo = WarehouseRepo();
    final isEditing = widget.editData != null;

    final data = CreateWareHouseModel(
      warehouseId: widget.editData?.id.toString(),
      name: warehouseNameController.text.trim(),
      phone: phoneNumberController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
    );

    final success = isEditing
        ? await repo.updateWareHouse(data: data, ref: ref, context: context)
        : await repo.createWareHouse(data: data, ref: ref, context: context);

    if (success) {
      EasyLoading.showSuccess(isEditing ? 'Updated Successfully!' : 'Created Successfully!');
      ref.refresh(fetchWarehouseListProvider);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _lang = l.S.of(context);
    final isEditing = widget.editData != null;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? _lang.editWarehouse : _lang.addNewWarehouse),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 2, color: kBackgroundColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: warehouseNameController,
                decoration: InputDecoration(
                  labelText: _lang.warehouseName,
                  hintText: _lang.enterWarehouseName,
                ),
                validator: (val) => (val == null || val.isEmpty) ? _lang.pleaseEnterWarehouseName : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: _lang.phone,
                  hintText: _lang.enterPhoneNumber,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _lang.email,
                  hintText: _lang.enterYourEmailAddressOptional,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) return _lang.enterAValidEmailAddress;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: _lang.address,
                  hintText: _lang.enterYourAddress,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => handleSave(ref: ref, context: context),
                child: Text(isEditing ? _lang.update : _lang.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
