import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/product_model/provider/models_provider.dart';
import 'package:mobile_pos/Screens/product_model/repo/product_models_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../constant.dart';
import '../../http_client/custome_http_client.dart';
import '../../service/check_user_role_permission_provider.dart';
import 'model/product_models_model.dart';

class AddProductModel extends ConsumerStatefulWidget {
  const AddProductModel({super.key, this.editData});

  final Data? editData;

  bool get isEditMode => editData != null;

  @override
  ConsumerState<AddProductModel> createState() => _AddProductModelState();
}

class _AddProductModelState extends ConsumerState<AddProductModel> {
  late final TextEditingController nameController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditMode) {
        setState(() {
          nameController.text = widget.editData?.name ?? '';
          isActive = widget.editData?.status == 1;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissionService = PermissionService(ref);
    final _lang = lang.S.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEditMode ? _lang.editModel : _lang.addNewModel),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Model Name Input
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _lang.pleaseEnterValidName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: _lang.modelName,
                  hintText: _lang.enterModelName,
                ),
              ),
              const SizedBox(height: 8),

              // Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_lang.status),
                  SizedBox(
                    height: 32,
                    width: 44,
                    child: FittedBox(
                      child: Switch.adaptive(
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  disabledBackgroundColor: theme.colorScheme.primary.withAlpha(40),
                ),
                onPressed: () async {
                  if (widget.editData == null) {
                    if (!permissionService.hasPermission(Permit.productModelsCreate.value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(_lang.youDoNotHavePermissionToCreateModel),
                        ),
                      );
                      return;
                    }
                  } else {
                    if (!permissionService.hasPermission(Permit.productModelsUpdate.value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(_lang.youDoNotHavePermissionToUpdateModel),
                        ),
                      );
                      return;
                    }
                  }
                  if (formKey.currentState?.validate() ?? false) {
                    final repo = ProductModelsRepo();
                    final data = CreateModelsModel(
                      name: nameController.text,
                      status: isActive ? '1' : '0',
                      modelId: widget.editData?.id.toString(),
                    );

                    bool success =
                        widget.isEditMode ? await repo.updateModels(data: data) : await repo.createModels(data: data);

                    if (success) {
                      EasyLoading.showSuccess(
                        widget.isEditMode ? _lang.modelUpdateSuccessfully : _lang.modelCreatedSuccessfully,
                      );
                      ref.refresh(fetchModelListProvider);
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(
                  _lang.save,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateModelsModel {
  CreateModelsModel({
    this.modelId,
    this.name,
    this.status,
  });
  String? modelId;
  String? name;
  String? status;
}
